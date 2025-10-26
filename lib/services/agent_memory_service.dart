import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

part 'agent_memory_service.g.dart';

/// Simple memory node for storing conversation data
@collection
class MemoryNode {
  Id id = Isar.autoIncrement;

  @Index()
  late String content;

  @Index()
  late DateTime timestamp;

  late String userInput;
  late String aiResponse;

  String? metadata;

  // Simple similarity score for search
  double similarity = 0.0;
}

/// Service to manage agent memory using a simplified approach
class AgentMemoryService {
  late final Isar _isar;
  bool _isInitialized = false;

  // Cache for recent searches to improve performance
  final Map<String, List<MemoryNode>> _searchCache = {};
  final int _maxCacheSize = 50;

  // Stream controllers for memory events
  final StreamController<int> _memoryCountController =
      StreamController<int>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  // Public streams
  Stream<int> get memoryCountStream => _memoryCountController.stream;
  Stream<String> get errorStream => _errorController.stream;

  /// Initialize the agent memory database
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Determine an application documents directory for Isar storage
      final dir = await getApplicationDocumentsDirectory();
      _isar = await Isar.open(
        [MemoryNodeSchema],
        directory: dir.path,
        name: 'orion_agent_memory',
      );

      _isInitialized = true;

      // Emit initial memory count
      final count = await getMemoryCount();
      _memoryCountController.add(count);

      if (kDebugMode) {
        print('AgentMemoryService: Initialized with $count memories');
      }
    } catch (e) {
      final errorMsg = 'Error initializing agent memory: $e';
      _errorController.add(errorMsg);
      if (kDebugMode) {
        print(errorMsg);
      }
      rethrow;
    }
  }

  /// Add a new memory (conversation turn)
  Future<void> addMemory({
    required String input,
    required String output,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_isInitialized) {
      throw StateError('AgentMemoryService not initialized');
    }

    try {
      // Create memory node
      final memoryNode =
          MemoryNode()
            ..content = 'User: $input\nAI: $output'
            ..timestamp = DateTime.now()
            ..userInput = input
            ..aiResponse = output
            ..metadata = metadata != null ? jsonEncode(metadata) : null;

      // Store in Isar
      await _isar.writeTxn(() async {
        await _isar.memoryNodes.put(memoryNode);
      });

      // Clear search cache since we have new data
      _searchCache.clear();

      // Emit updated memory count
      final count = await getMemoryCount();
      _memoryCountController.add(count);

      if (kDebugMode) {
        print('AgentMemoryService: Added memory. Total: $count');
      }
    } catch (e) {
      final errorMsg = 'Error adding memory: $e';
      _errorController.add(errorMsg);
      if (kDebugMode) {
        print(errorMsg);
      }
      rethrow;
    }
  }

  /// Search for relevant memories based on a query
  Future<List<MemoryNode>> searchMemories({
    required String query,
    int limit = 5,
  }) async {
    if (!_isInitialized) {
      throw StateError('AgentMemoryService not initialized');
    }

    // Check cache first
    final cacheKey = '${query.toLowerCase()}_$limit';
    if (_searchCache.containsKey(cacheKey)) {
      if (kDebugMode) {
        print(
          'AgentMemoryService: Cache hit for query: ${query.substring(0, query.length.clamp(0, 30))}...',
        );
      }
      return _searchCache[cacheKey]!;
    }

    try {
      // Simple text-based search using Isar queries
      final queryLower = query.toLowerCase();
      final allMemories =
          await _isar.memoryNodes
              .filter()
              .contentContains(queryLower, caseSensitive: false)
              .or()
              .userInputContains(queryLower, caseSensitive: false)
              .or()
              .aiResponseContains(queryLower, caseSensitive: false)
              .sortByTimestampDesc()
              .limit(limit)
              .findAll();

      // Calculate simple similarity scores based on keyword matches
      final memories =
          allMemories.map((memory) {
            memory.similarity = _calculateSimilarity(query, memory);
            return memory;
          }).toList();

      // Sort by similarity score
      memories.sort((a, b) => b.similarity.compareTo(a.similarity));

      // Cache the results
      _searchCache[cacheKey] = memories;

      // Limit cache size
      if (_searchCache.length > _maxCacheSize) {
        final oldestKey = _searchCache.keys.first;
        _searchCache.remove(oldestKey);
      }

      if (kDebugMode) {
        print(
          'AgentMemoryService: Found ${memories.length} memories for query: ${query.substring(0, query.length.clamp(0, 30))}...',
        );
      }

      return memories;
    } catch (e) {
      final errorMsg = 'Error searching memories: $e';
      _errorController.add(errorMsg);
      if (kDebugMode) {
        print(errorMsg);
      }
      return [];
    }
  }

  /// Get context string from relevant memories
  Future<String> getContextForQuery(String query) async {
    final memories = await searchMemories(query: query, limit: 3);

    if (memories.isEmpty) {
      return '';
    }

    return memories.map((m) => m.content).join('\n\n');
  }

  /// Clear all memories (use with caution)
  Future<void> clearMemories() async {
    if (!_isInitialized) {
      throw StateError('AgentMemoryService not initialized');
    }

    try {
      await _isar.writeTxn(() async {
        await _isar.memoryNodes.clear();
      });

      // Clear cache
      _searchCache.clear();

      // Emit updated memory count
      _memoryCountController.add(0);

      if (kDebugMode) {
        print('AgentMemoryService: Cleared all memories');
      }
    } catch (e) {
      final errorMsg = 'Error clearing memories: $e';
      _errorController.add(errorMsg);
      if (kDebugMode) {
        print(errorMsg);
      }
      rethrow;
    }
  }

  /// Get total number of memories
  Future<int> getMemoryCount() async {
    if (!_isInitialized) {
      return 0;
    }

    try {
      return await _isar.memoryNodes.count();
    } catch (e) {
      final errorMsg = 'Error getting memory count: $e';
      _errorController.add(errorMsg);
      if (kDebugMode) {
        print(errorMsg);
      }
      return 0;
    }
  }

  /// Calculate similarity score between query and memory
  double _calculateSimilarity(String query, MemoryNode memory) {
    final queryLower = query.toLowerCase();
    final contentLower = memory.content.toLowerCase();
    final userInputLower = memory.userInput.toLowerCase();
    final aiResponseLower = memory.aiResponse.toLowerCase();

    double score = 0.0;

    // Exact phrase matches get highest score
    if (contentLower.contains(queryLower)) {
      score += 1.0;
    }

    // Word matches in user input
    final queryWords = queryLower.split(' ');
    for (final word in queryWords) {
      if (word.length > 2) {
        // Skip very short words
        if (userInputLower.contains(word)) {
          score += 0.5;
        }
        if (aiResponseLower.contains(word)) {
          score += 0.3;
        }
      }
    }

    // Recency bonus (more recent memories get slight boost)
    final daysSinceCreation =
        DateTime.now().difference(memory.timestamp).inDays;
    final recencyBonus = 1.0 / (1.0 + daysSinceCreation * 0.1);
    score += recencyBonus * 0.1;

    return score;
  }

  /// Dispose of the service and clean up resources
  Future<void> dispose() async {
    if (_isInitialized) {
      await _isar.close();
      _isInitialized = false;
    }

    // Close stream controllers
    await _memoryCountController.close();
    await _errorController.close();

    // Clear cache
    _searchCache.clear();

    if (kDebugMode) {
      print('AgentMemoryService: Disposed');
    }
  }
}
