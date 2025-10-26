import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Centralized loading state management for the Orion app
class LoadingManager extends ChangeNotifier {
  static final LoadingManager _instance = LoadingManager._internal();
  factory LoadingManager() => _instance;
  LoadingManager._internal();

  // Map to track different loading states
  final Map<String, LoadingState> _loadingStates = {};

  // Stream controller for loading state changes
  final StreamController<Map<String, LoadingState>> _stateController =
      StreamController<Map<String, LoadingState>>.broadcast();

  // Public stream for listening to loading state changes
  Stream<Map<String, LoadingState>> get stateStream => _stateController.stream;

  /// Get current loading states
  Map<String, LoadingState> get loadingStates =>
      Map.unmodifiable(_loadingStates);

  /// Check if any operation is loading
  bool get isAnyLoading =>
      _loadingStates.values.any((state) => state.isLoading);

  /// Check if a specific operation is loading
  bool isLoading(String operation) {
    return _loadingStates[operation]?.isLoading ?? false;
  }

  /// Get loading state for a specific operation
  LoadingState? getLoadingState(String operation) {
    return _loadingStates[operation];
  }

  /// Start loading for an operation
  void startLoading(String operation, {String? message}) {
    _loadingStates[operation] = LoadingState(
      operation: operation,
      isLoading: true,
      message: message ?? 'Cargando...',
      startTime: DateTime.now(),
    );

    _notifyListeners();

    if (kDebugMode) {
      print('LoadingManager: Started loading for $operation');
    }
  }

  /// Stop loading for an operation
  void stopLoading(String operation) {
    final currentState = _loadingStates[operation];
    if (currentState != null) {
      _loadingStates[operation] = currentState.copyWith(
        isLoading: false,
        endTime: DateTime.now(),
      );

      _notifyListeners();

      if (kDebugMode) {
        final duration = DateTime.now().difference(currentState.startTime);
        print(
          'LoadingManager: Stopped loading for $operation (${duration.inMilliseconds}ms)',
        );
      }
    }
  }

  /// Update loading message for an operation
  void updateLoadingMessage(String operation, String message) {
    final currentState = _loadingStates[operation];
    if (currentState != null && currentState.isLoading) {
      _loadingStates[operation] = currentState.copyWith(message: message);
      _notifyListeners();

      if (kDebugMode) {
        print('LoadingManager: Updated message for $operation: $message');
      }
    }
  }

  /// Clear all loading states
  void clearAll() {
    _loadingStates.clear();
    _notifyListeners();

    if (kDebugMode) {
      print('LoadingManager: Cleared all loading states');
    }
  }

  /// Remove a specific loading state
  void remove(String operation) {
    _loadingStates.remove(operation);
    _notifyListeners();

    if (kDebugMode) {
      print('LoadingManager: Removed loading state for $operation');
    }
  }

  /// Execute an operation with automatic loading management
  Future<T> withLoading<T>(
    String operation,
    Future<T> Function() task, {
    String? loadingMessage,
    String? successMessage,
    String? errorMessage,
  }) async {
    try {
      startLoading(operation, message: loadingMessage);
      final result = await task();
      stopLoading(operation);

      if (successMessage != null && kDebugMode) {
        print(
          'LoadingManager: $operation completed successfully - $successMessage',
        );
      }

      return result;
    } catch (error) {
      stopLoading(operation);

      if (errorMessage != null && kDebugMode) {
        print('LoadingManager: $operation failed - $errorMessage: $error');
      }

      rethrow;
    }
  }

  /// Notify listeners and emit state change
  void _notifyListeners() {
    notifyListeners();
    _stateController.add(Map.unmodifiable(_loadingStates));
  }

  /// Dispose of resources
  @override
  void dispose() {
    _stateController.close();
    super.dispose();
  }
}

/// Loading state model
class LoadingState {
  final String operation;
  final bool isLoading;
  final String message;
  final DateTime startTime;
  final DateTime? endTime;

  LoadingState({
    required this.operation,
    required this.isLoading,
    required this.message,
    required this.startTime,
    this.endTime,
  });

  /// Get duration of loading operation
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  /// Create a copy with updated values
  LoadingState copyWith({
    String? operation,
    bool? isLoading,
    String? message,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return LoadingState(
      operation: operation ?? this.operation,
      isLoading: isLoading ?? this.isLoading,
      message: message ?? this.message,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  @override
  String toString() {
    return 'LoadingState(operation: $operation, isLoading: $isLoading, message: $message, duration: ${duration.inMilliseconds}ms)';
  }
}

/// Widget to show loading overlay
class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final String? operation;
  final bool showGlobalLoading;

  const LoadingOverlay({
    super.key,
    required this.child,
    this.operation,
    this.showGlobalLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, LoadingState>>(
      stream: LoadingManager().stateStream,
      initialData: LoadingManager().loadingStates,
      builder: (context, snapshot) {
        final loadingStates = snapshot.data ?? {};

        bool isLoading = false;
        String message = 'Cargando...';

        if (operation != null) {
          // Check specific operation
          final state = loadingStates[operation];
          isLoading = state?.isLoading ?? false;
          message = state?.message ?? message;
        } else if (showGlobalLoading) {
          // Check if any operation is loading
          isLoading = loadingStates.values.any((state) => state.isLoading);
          if (isLoading) {
            final loadingState = loadingStates.values.firstWhere(
              (state) => state.isLoading,
            );
            message = loadingState.message;
          }
        }

        return Stack(
          children: [
            child,
            if (isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            message,
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Common loading operations
class LoadingOperations {
  static const String signIn = 'sign_in';
  static const String signUp = 'sign_up';
  static const String signOut = 'sign_out';
  static const String voiceRecording = 'voice_recording';
  static const String voiceProcessing = 'voice_processing';
  static const String aiResponse = 'ai_response';
  static const String memorySearch = 'memory_search';
  static const String memoryStorage = 'memory_storage';
  static const String appInitialization = 'app_initialization';
  static const String dataSync = 'data_sync';
}
