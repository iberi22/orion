import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Interface for CacheManager
abstract class CacheManagerInterface {
  Future<void> initialize();
  Future<Map<String, dynamic>> getCacheStats();
  Future<void> clearCache();
}

/// Optimized cache manager for images, data, and other assets
class CacheManager implements CacheManagerInterface {
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;
  CacheManager._internal();

  // Cache directories
  Directory? _cacheDir;
  Directory? _imageCache;
  Directory? _dataCache;
  Directory? _audioCache;

  // Cache configuration
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
  static const int maxImageCacheSize = 50 * 1024 * 1024; // 50MB
  static const int maxDataCacheSize = 30 * 1024 * 1024; // 30MB
  static const int maxAudioCacheSize = 20 * 1024 * 1024; // 20MB
  static const Duration defaultCacheExpiry = Duration(days: 7);

  // In-memory cache for frequently accessed data
  final Map<String, CacheEntry> _memoryCache = {};
  static const int maxMemoryCacheEntries = 100;

  /// Initialize the cache manager
  @override
  Future<void> initialize() async {
    try {
      _cacheDir = await getTemporaryDirectory();

      // Create cache subdirectories
      _imageCache = Directory('${_cacheDir!.path}/images');
      _dataCache = Directory('${_cacheDir!.path}/data');
      _audioCache = Directory('${_cacheDir!.path}/audio');

      await _imageCache!.create(recursive: true);
      await _dataCache!.create(recursive: true);
      await _audioCache!.create(recursive: true);

      // Clean up expired cache entries
      await _cleanupExpiredEntries();

      if (kDebugMode) {
        debugPrint(
          'CacheManager: Initialized with cache dir: ${_cacheDir!.path}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('CacheManager: Failed to initialize - $e');
      }
    }
  }

  /// Cache data with key
  Future<void> cacheData(
    String key,
    Uint8List data, {
    CacheType type = CacheType.data,
    Duration? expiry,
  }) async {
    if (_cacheDir == null) await initialize();

    try {
      final directory = _getCacheDirectory(type);
      final file = File('${directory.path}/${_sanitizeKey(key)}');

      // Write data to file
      await file.writeAsBytes(data);

      // Store metadata
      await _storeCacheMetadata(key, type, expiry ?? defaultCacheExpiry);

      // Add to memory cache if small enough
      if (data.length < 1024 * 1024) {
        // 1MB
        _addToMemoryCache(key, data, type);
      }

      // Cleanup if cache is too large
      await _cleanupIfNeeded(type);

      if (kDebugMode) {
        debugPrint('CacheManager: Cached ${data.length} bytes for key: $key');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('CacheManager: Failed to cache data for key $key - $e');
      }
    }
  }

  /// Retrieve cached data
  Future<Uint8List?> getCachedData(
    String key, {
    CacheType type = CacheType.data,
  }) async {
    if (_cacheDir == null) await initialize();

    // Check memory cache first
    final memoryEntry = _memoryCache[key];
    if (memoryEntry != null &&
        !memoryEntry.isExpired &&
        memoryEntry.type == type) {
      if (kDebugMode) {
        debugPrint('CacheManager: Retrieved from memory cache: $key');
      }
      return memoryEntry.data;
    }

    try {
      final directory = _getCacheDirectory(type);
      final file = File('${directory.path}/${_sanitizeKey(key)}');

      if (!await file.exists()) return null;

      // Check if cache entry is expired
      if (await _isCacheExpired(key, type)) {
        await file.delete();
        await _removeCacheMetadata(key, type);
        return null;
      }

      final data = await file.readAsBytes();

      // Add to memory cache
      _addToMemoryCache(key, data, type);

      if (kDebugMode) {
        debugPrint(
          'CacheManager: Retrieved ${data.length} bytes for key: $key',
        );
      }

      return data;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          'CacheManager: Failed to retrieve cached data for key $key - $e',
        );
      }
      return null;
    }
  }

  /// Check if data is cached
  Future<bool> isCached(String key, {CacheType type = CacheType.data}) async {
    if (_cacheDir == null) await initialize();

    // Check memory cache first
    final memoryEntry = _memoryCache[key];
    if (memoryEntry != null &&
        !memoryEntry.isExpired &&
        memoryEntry.type == type) {
      return true;
    }

    try {
      final directory = _getCacheDirectory(type);
      final file = File('${directory.path}/${_sanitizeKey(key)}');

      if (!await file.exists()) return false;

      // Check if expired
      return !(await _isCacheExpired(key, type));
    } catch (e) {
      return false;
    }
  }

  /// Remove cached data
  Future<void> removeCachedData(
    String key, {
    CacheType type = CacheType.data,
  }) async {
    if (_cacheDir == null) await initialize();

    // Remove from memory cache
    _memoryCache.remove(key);

    try {
      final directory = _getCacheDirectory(type);
      final file = File('${directory.path}/${_sanitizeKey(key)}');

      if (await file.exists()) {
        await file.delete();
      }

      await _removeCacheMetadata(key, type);

      if (kDebugMode) {
        debugPrint('CacheManager: Removed cached data for key: $key');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          'CacheManager: Failed to remove cached data for key $key - $e',
        );
      }
    }
  }

  /// Clear all cache
  @override
  Future<void> clearCache({CacheType? type}) async {
    if (_cacheDir == null) await initialize();

    try {
      if (type != null) {
        // Clear specific cache type
        final directory = _getCacheDirectory(type);
        if (await directory.exists()) {
          await directory.delete(recursive: true);
          await directory.create();
        }

        // Remove from memory cache
        _memoryCache.removeWhere((key, entry) => entry.type == type);
      } else {
        // Clear all cache
        if (await _cacheDir!.exists()) {
          await _cacheDir!.delete(recursive: true);
          await initialize();
        }
        _memoryCache.clear();
      }

      if (kDebugMode) {
        debugPrint(
          'CacheManager: Cleared cache${type != null ? ' for ${type.name}' : ''}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('CacheManager: Failed to clear cache - $e');
      }
    }
  }

  /// Get cache statistics
  @override
  Future<Map<String, dynamic>> getCacheStats() async {
    if (_cacheDir == null) await initialize();

    try {
      final imageSize = await _getDirectorySize(_imageCache!);
      final dataSize = await _getDirectorySize(_dataCache!);
      final audioSize = await _getDirectorySize(_audioCache!);
      final totalSize = imageSize + dataSize + audioSize;

      return {
        'totalSize': totalSize,
        'totalSizeMB': (totalSize / 1024 / 1024).toStringAsFixed(2),
        'imageCache': {
          'size': imageSize,
          'sizeMB': (imageSize / 1024 / 1024).toStringAsFixed(2),
          'files': await _getFileCount(_imageCache!),
        },
        'dataCache': {
          'size': dataSize,
          'sizeMB': (dataSize / 1024 / 1024).toStringAsFixed(2),
          'files': await _getFileCount(_dataCache!),
        },
        'audioCache': {
          'size': audioSize,
          'sizeMB': (audioSize / 1024 / 1024).toStringAsFixed(2),
          'files': await _getFileCount(_audioCache!),
        },
        'memoryCache': {
          'entries': _memoryCache.length,
          'maxEntries': maxMemoryCacheEntries,
        },
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Get cache directory for type
  Directory _getCacheDirectory(CacheType type) {
    switch (type) {
      case CacheType.image:
        return _imageCache!;
      case CacheType.data:
        return _dataCache!;
      case CacheType.audio:
        return _audioCache!;
    }
  }

  /// Sanitize cache key for file system
  String _sanitizeKey(String key) {
    return key.replaceAll(RegExp(r'[^\w\-_\.]'), '_');
  }

  /// Add entry to memory cache
  void _addToMemoryCache(String key, Uint8List data, CacheType type) {
    // Remove oldest entries if cache is full
    if (_memoryCache.length >= maxMemoryCacheEntries) {
      final oldestKey = _memoryCache.keys.first;
      _memoryCache.remove(oldestKey);
    }

    _memoryCache[key] = CacheEntry(
      data: data,
      type: type,
      timestamp: DateTime.now(),
      expiry: DateTime.now().add(defaultCacheExpiry),
    );
  }

  /// Store cache metadata
  Future<void> _storeCacheMetadata(
    String key,
    CacheType type,
    Duration expiry,
  ) async {
    // Implementation would store metadata in a separate file or database
    // For simplicity, we'll skip this in the example
  }

  /// Remove cache metadata
  Future<void> _removeCacheMetadata(String key, CacheType type) async {
    // Implementation would remove metadata
  }

  /// Check if cache entry is expired
  Future<bool> _isCacheExpired(String key, CacheType type) async {
    // Implementation would check metadata for expiry
    // For simplicity, we'll assume not expired
    return false;
  }

  /// Cleanup expired cache entries
  Future<void> _cleanupExpiredEntries() async {
    // Implementation would scan and remove expired entries
  }

  /// Cleanup cache if it exceeds size limits
  Future<void> _cleanupIfNeeded(CacheType type) async {
    final directory = _getCacheDirectory(type);
    final size = await _getDirectorySize(directory);
    final maxSize = _getMaxSizeForType(type);

    if (size > maxSize) {
      // Remove oldest files until under limit
      await _removeOldestFiles(directory, size - maxSize);
    }
  }

  /// Get maximum cache size for type
  int _getMaxSizeForType(CacheType type) {
    switch (type) {
      case CacheType.image:
        return maxImageCacheSize;
      case CacheType.data:
        return maxDataCacheSize;
      case CacheType.audio:
        return maxAudioCacheSize;
    }
  }

  /// Remove oldest files from directory
  Future<void> _removeOldestFiles(
    Directory directory,
    int bytesToRemove,
  ) async {
    final files =
        await directory
            .list()
            .where((entity) => entity is File)
            .cast<File>()
            .toList();

    // Sort by last modified time
    files.sort((a, b) => a.lastModifiedSync().compareTo(b.lastModifiedSync()));

    int removedBytes = 0;
    for (final file in files) {
      if (removedBytes >= bytesToRemove) break;

      final size = await file.length();
      await file.delete();
      removedBytes += size;
    }
  }

  /// Get directory size in bytes
  Future<int> _getDirectorySize(Directory directory) async {
    int size = 0;
    await for (final entity in directory.list(recursive: true)) {
      if (entity is File) {
        size += await entity.length();
      }
    }
    return size;
  }

  /// Get file count in directory
  Future<int> _getFileCount(Directory directory) async {
    int count = 0;
    await for (final entity in directory.list()) {
      if (entity is File) count++;
    }
    return count;
  }
}

/// Cache types
enum CacheType { image, data, audio }

/// Cache entry for memory cache
class CacheEntry {
  final Uint8List data;
  final CacheType type;
  final DateTime timestamp;
  final DateTime expiry;

  CacheEntry({
    required this.data,
    required this.type,
    required this.timestamp,
    required this.expiry,
  });

  bool get isExpired => DateTime.now().isAfter(expiry);
}
