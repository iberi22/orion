import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Centralized reactive state management for the Orion app
class AppStateManager extends ChangeNotifier {
  static final AppStateManager _instance = AppStateManager._internal();
  factory AppStateManager() => _instance;
  AppStateManager._internal();

  // Authentication state
  final ValueNotifier<User?> _currentUser = ValueNotifier<User?>(null);
  final ValueNotifier<AuthState> _authState = ValueNotifier<AuthState>(
    AuthState.unknown,
  );

  // App state
  final ValueNotifier<AppMode> _appMode = ValueNotifier<AppMode>(
    AppMode.welcome,
  );
  final ValueNotifier<bool> _isOnline = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);

  // Voice chat state
  final ValueNotifier<VoiceChatState> _voiceChatState =
      ValueNotifier<VoiceChatState>(VoiceChatState.idle);
  final ValueNotifier<bool> _isRecording = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isProcessing = ValueNotifier<bool>(false);

  // Memory state
  final ValueNotifier<int> _memoryCount = ValueNotifier<int>(0);
  final ValueNotifier<DateTime?> _lastMemoryUpdate = ValueNotifier<DateTime?>(
    null,
  );

  // Stream controllers for complex state changes
  final StreamController<StateChange> _stateChangeController =
      StreamController<StateChange>.broadcast();

  // Public getters for reactive values
  ValueListenable<User?> get currentUser => _currentUser;
  ValueListenable<AuthState> get authState => _authState;
  ValueListenable<AppMode> get appMode => _appMode;
  ValueListenable<bool> get isOnline => _isOnline;
  ValueListenable<bool> get isLoading => _isLoading;
  ValueListenable<VoiceChatState> get voiceChatState => _voiceChatState;
  ValueListenable<bool> get isRecording => _isRecording;
  ValueListenable<bool> get isProcessing => _isProcessing;
  ValueListenable<int> get memoryCount => _memoryCount;
  ValueListenable<DateTime?> get lastMemoryUpdate => _lastMemoryUpdate;

  // Stream for complex state changes
  Stream<StateChange> get stateChanges => _stateChangeController.stream;

  // Computed properties
  bool get isAuthenticated => _currentUser.value != null;
  bool get canUseVoiceChat =>
      isAuthenticated && isOnline.value && !isLoading.value;
  bool get isVoiceChatActive => _voiceChatState.value != VoiceChatState.idle;

  /// Initialize the state manager
  void initialize() {
    // Listen to auth state changes
    FirebaseAuth.instance.authStateChanges().listen((user) {
      updateCurrentUser(user);
    });

    if (kDebugMode) {
      debugPrint('AppStateManager: Initialized');
    }
  }

  /// Update current user
  void updateCurrentUser(User? user) {
    if (_currentUser.value != user) {
      final previousUser = _currentUser.value;
      _currentUser.value = user;

      // Update auth state
      if (user != null) {
        _authState.value = AuthState.authenticated;
        _appMode.value = AppMode.main;
      } else {
        _authState.value = AuthState.unauthenticated;
        _appMode.value = AppMode.welcome;
      }

      // Emit state change
      _emitStateChange(
        StateChange(
          type: StateChangeType.userChanged,
          previousValue: previousUser,
          newValue: user,
          timestamp: DateTime.now(),
        ),
      );

      notifyListeners();

      if (kDebugMode) {
        debugPrint('AppStateManager: User changed - ${user?.email ?? 'null'}');
      }
    }
  }

  /// Update app mode
  void updateAppMode(AppMode mode) {
    if (_appMode.value != mode) {
      final previousMode = _appMode.value;
      _appMode.value = mode;

      _emitStateChange(
        StateChange(
          type: StateChangeType.appModeChanged,
          previousValue: previousMode,
          newValue: mode,
          timestamp: DateTime.now(),
        ),
      );

      notifyListeners();

      if (kDebugMode) {
        debugPrint('AppStateManager: App mode changed to ${mode.name}');
      }
    }
  }

  /// Update online status
  void updateOnlineStatus(bool isOnline) {
    if (_isOnline.value != isOnline) {
      final previousStatus = _isOnline.value;
      _isOnline.value = isOnline;

      _emitStateChange(
        StateChange(
          type: StateChangeType.connectivityChanged,
          previousValue: previousStatus,
          newValue: isOnline,
          timestamp: DateTime.now(),
        ),
      );

      notifyListeners();

      if (kDebugMode) {
        debugPrint('AppStateManager: Online status changed to $isOnline');
      }
    }
  }

  /// Update loading state
  void updateLoadingState(bool isLoading) {
    if (_isLoading.value != isLoading) {
      _isLoading.value = isLoading;
      notifyListeners();

      if (kDebugMode) {
        debugPrint('AppStateManager: Loading state changed to $isLoading');
      }
    }
  }

  /// Update voice chat state
  void updateVoiceChatState(VoiceChatState state) {
    if (_voiceChatState.value != state) {
      final previousState = _voiceChatState.value;
      _voiceChatState.value = state;

      _emitStateChange(
        StateChange(
          type: StateChangeType.voiceChatStateChanged,
          previousValue: previousState,
          newValue: state,
          timestamp: DateTime.now(),
        ),
      );

      notifyListeners();

      if (kDebugMode) {
        debugPrint(
          'AppStateManager: Voice chat state changed to ${state.name}',
        );
      }
    }
  }

  /// Update recording state
  void updateRecordingState(bool isRecording) {
    if (_isRecording.value != isRecording) {
      _isRecording.value = isRecording;
      notifyListeners();

      if (kDebugMode) {
        debugPrint('AppStateManager: Recording state changed to $isRecording');
      }
    }
  }

  /// Update processing state
  void updateProcessingState(bool isProcessing) {
    if (_isProcessing.value != isProcessing) {
      _isProcessing.value = isProcessing;
      notifyListeners();

      if (kDebugMode) {
        debugPrint(
          'AppStateManager: Processing state changed to $isProcessing',
        );
      }
    }
  }

  /// Update memory count
  void updateMemoryCount(int count) {
    if (_memoryCount.value != count) {
      _memoryCount.value = count;
      _lastMemoryUpdate.value = DateTime.now();
      notifyListeners();

      if (kDebugMode) {
        debugPrint('AppStateManager: Memory count updated to $count');
      }
    }
  }

  /// Emit state change event
  void _emitStateChange(StateChange change) {
    _stateChangeController.add(change);
  }

  /// Get current state snapshot
  Map<String, dynamic> getStateSnapshot() {
    return {
      'currentUser': _currentUser.value?.uid,
      'authState': _authState.value.name,
      'appMode': _appMode.value.name,
      'isOnline': _isOnline.value,
      'isLoading': _isLoading.value,
      'voiceChatState': _voiceChatState.value.name,
      'isRecording': _isRecording.value,
      'isProcessing': _isProcessing.value,
      'memoryCount': _memoryCount.value,
      'lastMemoryUpdate': _lastMemoryUpdate.value?.toIso8601String(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Reset state (for logout)
  void reset() {
    _currentUser.value = null;
    _authState.value = AuthState.unauthenticated;
    _appMode.value = AppMode.welcome;
    _voiceChatState.value = VoiceChatState.idle;
    _isRecording.value = false;
    _isProcessing.value = false;
    _memoryCount.value = 0;
    _lastMemoryUpdate.value = null;

    notifyListeners();

    if (kDebugMode) {
      debugPrint('AppStateManager: State reset');
    }
  }

  @override
  void dispose() {
    _stateChangeController.close();
    _currentUser.dispose();
    _authState.dispose();
    _appMode.dispose();
    _isOnline.dispose();
    _isLoading.dispose();
    _voiceChatState.dispose();
    _isRecording.dispose();
    _isProcessing.dispose();
    _memoryCount.dispose();
    _lastMemoryUpdate.dispose();
    super.dispose();
  }
}

/// Authentication states
enum AuthState { unknown, authenticated, unauthenticated }

/// App modes
enum AppMode { welcome, main, settings }

/// Voice chat states
enum VoiceChatState { idle, listening, processing, speaking, error }

/// State change types
enum StateChangeType {
  userChanged,
  appModeChanged,
  connectivityChanged,
  voiceChatStateChanged,
}

/// State change event
class StateChange {
  final StateChangeType type;
  final dynamic previousValue;
  final dynamic newValue;
  final DateTime timestamp;

  StateChange({
    required this.type,
    required this.previousValue,
    required this.newValue,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'StateChange(type: ${type.name}, previous: $previousValue, new: $newValue, time: $timestamp)';
  }
}
