import 'dart:async';
import 'package:flutter/foundation.dart';

/// Monitors app performance and provides optimization insights
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  // Performance metrics
  final Map<String, PerformanceMetric> _metrics = {};
  final List<FrameTimingInfo> _frameTimings = [];
  final List<MemoryUsage> _memoryUsages = [];

  // Timers for periodic monitoring
  Timer? _memoryMonitorTimer;
  Timer? _frameMonitorTimer;

  // Configuration
  static const int maxFrameTimings = 1000;
  static const int maxMemoryUsages = 100;
  static const Duration monitoringInterval = Duration(seconds: 5);

  /// Initialize performance monitoring
  void initialize() {
    if (kDebugMode) {
      _startMemoryMonitoring();
      _startFrameMonitoring();
      debugPrint('PerformanceMonitor: Initialized');
    }
  }

  /// Start monitoring memory usage
  void _startMemoryMonitoring() {
    _memoryMonitorTimer = Timer.periodic(monitoringInterval, (timer) async {
      final memoryUsage = await _getMemoryUsage();
      _recordMemoryUsage(memoryUsage);
    });
  }

  /// Start monitoring frame timings
  void _startFrameMonitoring() {
    // Note: Frame timing monitoring would require platform-specific implementation
    // This is a placeholder for the concept
    _frameMonitorTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // In a real implementation, you would collect frame timing data
      // from the Flutter engine or platform-specific APIs
    });
  }

  /// Record memory usage
  void _recordMemoryUsage(MemoryUsage usage) {
    _memoryUsages.add(usage);

    // Keep only the most recent entries
    if (_memoryUsages.length > maxMemoryUsages) {
      _memoryUsages.removeAt(0);
    }

    // Check for memory leaks
    _checkForMemoryLeaks();
  }

  /// Get current memory usage
  Future<MemoryUsage> _getMemoryUsage() async {
    try {
      // On mobile platforms, you might use platform channels to get memory info
      // This is a simplified version for demonstration
      final int rssBytes =
          0; // Would be obtained from platform-specific implementation

      return MemoryUsage(
        timestamp: DateTime.now(),
        rssBytes: rssBytes,
        // Note: These would need platform-specific implementation
        heapBytes: 0,
        externalBytes: 0,
      );
    } catch (e) {
      return MemoryUsage(
        timestamp: DateTime.now(),
        rssBytes: 0,
        heapBytes: 0,
        externalBytes: 0,
      );
    }
  }

  /// Check for potential memory leaks
  void _checkForMemoryLeaks() {
    if (_memoryUsages.length < 10) return;

    final recent = _memoryUsages.takeLast(10).toList();
    final averageGrowth = _calculateMemoryGrowthRate(recent);

    // If memory is consistently growing, warn about potential leak
    if (averageGrowth > 1024 * 1024) {
      // 1MB per monitoring interval
      if (kDebugMode) {
        debugPrint(
          'PerformanceMonitor: Potential memory leak detected - growth rate: ${(averageGrowth / 1024 / 1024).toStringAsFixed(2)}MB per interval',
        );
      }
    }
  }

  /// Calculate memory growth rate
  double _calculateMemoryGrowthRate(List<MemoryUsage> usages) {
    if (usages.length < 2) return 0;

    double totalGrowth = 0;
    for (int i = 1; i < usages.length; i++) {
      totalGrowth += usages[i].totalBytes - usages[i - 1].totalBytes;
    }

    return totalGrowth / (usages.length - 1);
  }

  /// Start measuring performance for an operation
  void startMeasurement(String operationName) {
    _metrics[operationName] = PerformanceMetric(
      name: operationName,
      startTime: DateTime.now(),
    );
  }

  /// End measuring performance for an operation
  void endMeasurement(String operationName, {Map<String, dynamic>? metadata}) {
    final metric = _metrics[operationName];
    if (metric != null) {
      metric.endTime = DateTime.now();
      metric.duration = metric.endTime!.difference(metric.startTime);
      metric.metadata = metadata ?? {};

      if (kDebugMode) {
        debugPrint(
          'PerformanceMonitor: $operationName took ${metric.duration.inMilliseconds}ms',
        );
      }

      // Check for slow operations
      if (metric.duration.inMilliseconds > 1000) {
        if (kDebugMode) {
          debugPrint(
            'PerformanceMonitor: Slow operation detected - $operationName (${metric.duration.inMilliseconds}ms)',
          );
        }
      }
    }
  }

  /// Measure an operation with automatic timing
  Future<T> measureOperation<T>(
    String operationName,
    Future<T> Function() operation, {
    Map<String, dynamic>? metadata,
  }) async {
    startMeasurement(operationName);
    try {
      final result = await operation();
      endMeasurement(operationName, metadata: metadata);
      return result;
    } catch (e) {
      endMeasurement(
        operationName,
        metadata: {...?metadata, 'error': e.toString()},
      );
      rethrow;
    }
  }

  /// Get performance statistics
  Map<String, dynamic> getPerformanceStats() {
    final completedMetrics =
        _metrics.values.where((m) => m.endTime != null).toList();

    if (completedMetrics.isEmpty) {
      return {'message': 'No performance data available'};
    }

    // Calculate statistics
    final durations =
        completedMetrics.map((m) => m.duration.inMilliseconds).toList();
    durations.sort();

    final avgDuration = durations.reduce((a, b) => a + b) / durations.length;
    final medianDuration = durations[durations.length ~/ 2];
    final p95Duration = durations[(durations.length * 0.95).floor()];

    return {
      'totalOperations': completedMetrics.length,
      'averageDuration': avgDuration,
      'medianDuration': medianDuration,
      'p95Duration': p95Duration,
      'slowestOperation':
          completedMetrics
              .reduce((a, b) => a.duration > b.duration ? a : b)
              .name,
      'fastestOperation':
          completedMetrics
              .reduce((a, b) => a.duration < b.duration ? a : b)
              .name,
      'memoryUsage': _getMemoryStats(),
      'operationBreakdown': _getOperationBreakdown(completedMetrics),
    };
  }

  /// Get memory usage statistics
  Map<String, dynamic> _getMemoryStats() {
    if (_memoryUsages.isEmpty) {
      return {'message': 'No memory data available'};
    }

    final latest = _memoryUsages.last;
    final peak = _memoryUsages.reduce(
      (a, b) => a.totalBytes > b.totalBytes ? a : b,
    );
    final average =
        _memoryUsages.map((m) => m.totalBytes).reduce((a, b) => a + b) /
        _memoryUsages.length;

    return {
      'currentMB': (latest.totalBytes / 1024 / 1024).toStringAsFixed(2),
      'peakMB': (peak.totalBytes / 1024 / 1024).toStringAsFixed(2),
      'averageMB': (average / 1024 / 1024).toStringAsFixed(2),
      'growthRate':
          '${(_calculateMemoryGrowthRate(_memoryUsages) / 1024).toStringAsFixed(2)} KB/interval',
    };
  }

  /// Get operation breakdown
  Map<String, dynamic> _getOperationBreakdown(List<PerformanceMetric> metrics) {
    final breakdown = <String, List<int>>{};

    for (final metric in metrics) {
      breakdown
          .putIfAbsent(metric.name, () => [])
          .add(metric.duration.inMilliseconds);
    }

    return breakdown.map((name, durations) {
      final avg = durations.reduce((a, b) => a + b) / durations.length;
      return MapEntry(name, {
        'count': durations.length,
        'averageMs': avg.toStringAsFixed(2),
        'totalMs': durations.reduce((a, b) => a + b),
      });
    });
  }

  /// Clear all performance data
  void clearData() {
    _metrics.clear();
    _memoryUsages.clear();
    _frameTimings.clear();

    if (kDebugMode) {
      debugPrint('PerformanceMonitor: Cleared all performance data');
    }
  }

  /// Dispose of the performance monitor
  void dispose() {
    _memoryMonitorTimer?.cancel();
    _frameMonitorTimer?.cancel();
    clearData();
  }
}

/// Performance metric for an operation
class PerformanceMetric {
  final String name;
  final DateTime startTime;
  DateTime? endTime;
  Duration duration = Duration.zero;
  Map<String, dynamic> metadata = {};

  PerformanceMetric({required this.name, required this.startTime});
}

/// Memory usage information
class MemoryUsage {
  final DateTime timestamp;
  final int rssBytes;
  final int heapBytes;
  final int externalBytes;

  MemoryUsage({
    required this.timestamp,
    required this.rssBytes,
    required this.heapBytes,
    required this.externalBytes,
  });

  int get totalBytes => rssBytes + heapBytes + externalBytes;
}

/// Frame timing information
class FrameTimingInfo {
  final DateTime timestamp;
  final Duration buildDuration;
  final Duration rasterDuration;
  final bool isJanky;

  FrameTimingInfo({
    required this.timestamp,
    required this.buildDuration,
    required this.rasterDuration,
    required this.isJanky,
  });
}

/// Extension to get last N elements from a list
extension ListExtension<T> on List<T> {
  List<T> takeLast(int count) {
    if (count >= length) return this;
    return sublist(length - count);
  }
}
