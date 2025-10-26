import 'dart:async';
import 'dart:isolate';
import 'package:flutter/foundation.dart';

/// Manages isolates for heavy computational tasks
class IsolateManager {
  static final IsolateManager _instance = IsolateManager._internal();
  factory IsolateManager() => _instance;
  IsolateManager._internal();

  // Map to track active isolates
  final Map<String, IsolateWorker> _workers = {};

  // Maximum number of concurrent isolates
  static const int maxWorkers = 4;

  /// Create or get an isolate worker for a specific task type
  Future<IsolateWorker> getWorker(String taskType) async {
    if (_workers.containsKey(taskType) && _workers[taskType]!.isActive) {
      return _workers[taskType]!;
    }

    // Check if we've reached the maximum number of workers
    final activeWorkers = _workers.values.where((w) => w.isActive).length;
    if (activeWorkers >= maxWorkers) {
      // Find the least recently used worker and terminate it
      final oldestWorker = _workers.values
          .where((w) => w.isActive)
          .reduce((a, b) => a.lastUsed.isBefore(b.lastUsed) ? a : b);
      await oldestWorker.terminate();
    }

    // Create new worker
    final worker = IsolateWorker(taskType);
    await worker.initialize();
    _workers[taskType] = worker;

    if (kDebugMode) {
      debugPrint('IsolateManager: Created worker for $taskType');
    }

    return worker;
  }

  /// Execute a task in an isolate
  Future<T> executeTask<T>(
    String taskType,
    Future<T> Function(dynamic) task,
    dynamic data,
  ) async {
    final worker = await getWorker(taskType);
    return await worker.execute<T>(task, data);
  }

  /// Terminate a specific worker
  Future<void> terminateWorker(String taskType) async {
    final worker = _workers[taskType];
    if (worker != null) {
      await worker.terminate();
      _workers.remove(taskType);

      if (kDebugMode) {
        debugPrint('IsolateManager: Terminated worker for $taskType');
      }
    }
  }

  /// Terminate all workers
  Future<void> terminateAll() async {
    final futures = _workers.values.map((worker) => worker.terminate());
    await Future.wait(futures);
    _workers.clear();

    if (kDebugMode) {
      debugPrint('IsolateManager: Terminated all workers');
    }
  }

  /// Get worker statistics
  Map<String, dynamic> getStats() {
    return {
      'totalWorkers': _workers.length,
      'activeWorkers': _workers.values.where((w) => w.isActive).length,
      'workers': _workers.map(
        (key, worker) => MapEntry(key, {
          'isActive': worker.isActive,
          'lastUsed': worker.lastUsed.toIso8601String(),
          'tasksExecuted': worker.tasksExecuted,
        }),
      ),
    };
  }
}

/// Individual isolate worker
class IsolateWorker {
  final String taskType;
  Isolate? _isolate;
  SendPort? _sendPort;
  ReceivePort? _receivePort;
  bool _isActive = false;
  DateTime _lastUsed = DateTime.now();
  int _tasksExecuted = 0;

  // Completer for initialization
  Completer<void>? _initCompleter;

  // Map to track pending tasks
  final Map<String, Completer<dynamic>> _pendingTasks = {};

  IsolateWorker(this.taskType);

  bool get isActive => _isActive;
  DateTime get lastUsed => _lastUsed;
  int get tasksExecuted => _tasksExecuted;

  /// Initialize the isolate worker
  Future<void> initialize() async {
    if (_isActive) return;

    _initCompleter = Completer<void>();
    _receivePort = ReceivePort();

    // Listen for messages from isolate
    _receivePort!.listen(_handleMessage);

    try {
      // Spawn the isolate
      _isolate = await Isolate.spawn(
        _isolateEntryPoint,
        _receivePort!.sendPort,
        debugName: 'IsolateWorker-$taskType',
      );

      // Wait for initialization confirmation
      await _initCompleter!.future;
      _isActive = true;

      if (kDebugMode) {
        debugPrint('IsolateWorker: Initialized worker for $taskType');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          'IsolateWorker: Failed to initialize worker for $taskType: $e',
        );
      }
      await terminate();
      rethrow;
    }
  }

  /// Execute a task in the isolate
  Future<T> execute<T>(Future<T> Function(dynamic) task, dynamic data) async {
    if (!_isActive) {
      throw StateError('Worker is not active');
    }

    _lastUsed = DateTime.now();
    _tasksExecuted++;

    final taskId = DateTime.now().millisecondsSinceEpoch.toString();
    final completer = Completer<T>();
    _pendingTasks[taskId] = completer;

    // Send task to isolate
    _sendPort!.send({'id': taskId, 'task': task, 'data': data});

    return completer.future;
  }

  /// Handle messages from the isolate
  void _handleMessage(dynamic message) {
    if (message is SendPort) {
      // Initialization message
      _sendPort = message;
      _initCompleter?.complete();
      return;
    }

    if (message is Map<String, dynamic>) {
      final taskId = message['id'] as String;
      final completer = _pendingTasks.remove(taskId);

      if (completer != null) {
        if (message.containsKey('error')) {
          completer.completeError(message['error']);
        } else {
          completer.complete(message['result']);
        }
      }
    }
  }

  /// Terminate the isolate worker
  Future<void> terminate() async {
    if (!_isActive) return;

    _isActive = false;

    // Complete any pending tasks with error
    for (final completer in _pendingTasks.values) {
      completer.completeError('Worker terminated');
    }
    _pendingTasks.clear();

    // Kill the isolate
    _isolate?.kill(priority: Isolate.immediate);
    _receivePort?.close();

    _isolate = null;
    _sendPort = null;
    _receivePort = null;

    if (kDebugMode) {
      debugPrint('IsolateWorker: Terminated worker for $taskType');
    }
  }

  /// Isolate entry point
  static void _isolateEntryPoint(SendPort mainSendPort) {
    final receivePort = ReceivePort();

    // Send the send port back to main isolate
    mainSendPort.send(receivePort.sendPort);

    // Listen for tasks
    receivePort.listen((message) async {
      if (message is Map<String, dynamic>) {
        final taskId = message['id'] as String;
        final task = message['task'] as Future<dynamic> Function(dynamic);
        final data = message['data'];

        try {
          final result = await task(data);
          mainSendPort.send({'id': taskId, 'result': result});
        } catch (e) {
          mainSendPort.send({'id': taskId, 'error': e.toString()});
        }
      }
    });
  }
}

/// Common isolate tasks
class IsolateTasks {
  /// Process AI response in isolate
  static Future<String> processAIResponse(dynamic data) async {
    final Map<String, dynamic> params = data as Map<String, dynamic>;
    final String response = params['response'] as String;

    // Simulate heavy processing
    await Future.delayed(const Duration(milliseconds: 100));

    // Process the response (e.g., format, clean up, etc.)
    return response.trim();
  }

  /// Process audio data in isolate
  static Future<List<double>> processAudioData(dynamic data) async {
    final List<int> audioBytes = data as List<int>;

    // Simulate audio processing
    await Future.delayed(const Duration(milliseconds: 50));

    // Convert to normalized audio data
    return audioBytes.map((byte) => byte / 255.0).toList();
  }

  /// Process memory search in isolate
  static Future<List<Map<String, dynamic>>> processMemorySearch(
    dynamic data,
  ) async {
    final Map<String, dynamic> params = data as Map<String, dynamic>;
    final String query = params['query'] as String;
    final List<Map<String, dynamic>> memories =
        params['memories'] as List<Map<String, dynamic>>;

    // Simulate memory search processing
    await Future.delayed(const Duration(milliseconds: 200));

    // Simple text matching (in real app, use more sophisticated search)
    final results =
        memories.where((memory) {
          final content = memory['content']?.toString().toLowerCase() ?? '';
          return content.contains(query.toLowerCase());
        }).toList();

    return results;
  }
}
