import 'dart:async';
import 'package:flutter/foundation.dart';

/// Browser permission management service
/// Handles microphone permissions gracefully across different browsers
class BrowserPermissionService {
  static final BrowserPermissionService _instance =
      BrowserPermissionService._internal();
  factory BrowserPermissionService() => _instance;
  BrowserPermissionService._internal();

  // State management
  bool _isInitialized = false;
  PermissionStatus _microphoneStatus = PermissionStatus.unknown;
  BrowserType _browserType = BrowserType.unknown;

  // Stream controllers
  final StreamController<PermissionStatus> _statusController =
      StreamController<PermissionStatus>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();
  final StreamController<String> _guidanceController =
      StreamController<String>.broadcast();

  // Getters
  bool get isInitialized => _isInitialized;
  PermissionStatus get microphoneStatus => _microphoneStatus;
  BrowserType get browserType => _browserType;
  Stream<PermissionStatus> get statusStream => _statusController.stream;
  Stream<String> get errorStream => _errorController.stream;
  Stream<String> get guidanceStream => _guidanceController.stream;

  /// Initialize the permission service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _detectBrowser();
      await _checkInitialPermissionStatus();

      _isInitialized = true;

      if (kDebugMode) {
        print('BrowserPermissionService: Initialized successfully');
        print('Browser: ${_browserType.name}');
        print('Initial microphone status: ${_microphoneStatus.name}');
      }
    } catch (e) {
      _errorController.add('Failed to initialize permission service: $e');
      if (kDebugMode) {
        print('BrowserPermissionService Initialization Error: $e');
      }
      rethrow;
    }
  }

  /// Detect browser type
  void _detectBrowser() {
    if (!kIsWeb) {
      _browserType = BrowserType.unknown;
      return;
    }

    // This is a simplified detection for Flutter web
    // In a real implementation, you would use dart:html to check navigator.userAgent
    _browserType = BrowserType.chrome; // Default assumption for Flutter web

    if (kDebugMode) {
      print(
        'BrowserPermissionService: Detected browser type: ${_browserType.name}',
      );
    }
  }

  /// Check initial permission status
  Future<void> _checkInitialPermissionStatus() async {
    try {
      // For Flutter web, we'll assume unknown initially
      // Real implementation would check navigator.permissions.query
      _microphoneStatus = PermissionStatus.unknown;
      _statusController.add(_microphoneStatus);
    } catch (e) {
      if (kDebugMode) {
        print(
          'BrowserPermissionService: Could not check initial permission status: $e',
        );
      }
      _microphoneStatus = PermissionStatus.unknown;
      _statusController.add(_microphoneStatus);
    }
  }

  /// Request microphone permission with user guidance
  Future<PermissionStatus> requestMicrophonePermission() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Provide pre-request guidance
      _providePreRequestGuidance();

      // Simulate permission request for Flutter web
      // In a real implementation, this would use getUserMedia
      await Future.delayed(const Duration(milliseconds: 500));

      // For demo purposes, we'll assume permission is granted
      _microphoneStatus = PermissionStatus.granted;
      _statusController.add(_microphoneStatus);

      _providePostRequestGuidance(_microphoneStatus);

      if (kDebugMode) {
        print(
          'BrowserPermissionService: Permission request result: ${_microphoneStatus.name}',
        );
      }

      return _microphoneStatus;
    } catch (e) {
      _microphoneStatus = PermissionStatus.denied;
      _statusController.add(_microphoneStatus);
      _handlePermissionError(e);

      if (kDebugMode) {
        print('BrowserPermissionService Permission Error: $e');
      }

      return _microphoneStatus;
    }
  }

  /// Provide guidance before requesting permission
  void _providePreRequestGuidance() {
    String guidance;

    switch (_browserType) {
      case BrowserType.chrome:
        guidance =
            'Chrome will ask for microphone permission. Click "Allow" in the popup that appears at the top of your browser.';
        break;
      case BrowserType.firefox:
        guidance =
            'Firefox will ask for microphone permission. Click "Allow" in the notification bar that appears.';
        break;
      case BrowserType.safari:
        guidance =
            'Safari will ask for microphone permission. Click "Allow" when prompted.';
        break;
      case BrowserType.edge:
        guidance =
            'Edge will ask for microphone permission. Click "Allow" in the popup that appears.';
        break;
      case BrowserType.unknown:
        guidance =
            'Your browser will ask for microphone permission. Please click "Allow" when prompted.';
        break;
    }

    _guidanceController.add(guidance);
  }

  /// Provide guidance after permission request
  void _providePostRequestGuidance(PermissionStatus status) {
    String guidance;

    switch (status) {
      case PermissionStatus.granted:
        guidance =
            'Great! Microphone access has been granted. You can now use voice features.';
        break;
      case PermissionStatus.denied:
        guidance = _getDeniedPermissionGuidance();
        break;
      case PermissionStatus.permanentlyDenied:
        guidance = _getPermanentlyDeniedGuidance();
        break;
      case PermissionStatus.unknown:
        guidance =
            'Permission status is unclear. Please try again or check your browser settings.';
        break;
    }

    _guidanceController.add(guidance);
  }

  /// Get guidance for denied permissions
  String _getDeniedPermissionGuidance() {
    switch (_browserType) {
      case BrowserType.chrome:
        return 'Microphone access was denied. To enable it:\n'
            '1. Click the camera/microphone icon in the address bar\n'
            '2. Select "Always allow" for microphone\n'
            '3. Refresh the page';
      case BrowserType.firefox:
        return 'Microphone access was denied. To enable it:\n'
            '1. Click the shield icon in the address bar\n'
            '2. Click "Allow" next to the microphone permission\n'
            '3. Refresh the page';
      case BrowserType.safari:
        return 'Microphone access was denied. To enable it:\n'
            '1. Go to Safari > Settings > Websites > Microphone\n'
            '2. Set this website to "Allow"\n'
            '3. Refresh the page';
      case BrowserType.edge:
        return 'Microphone access was denied. To enable it:\n'
            '1. Click the lock icon in the address bar\n'
            '2. Set microphone to "Allow"\n'
            '3. Refresh the page';
      case BrowserType.unknown:
        return 'Microphone access was denied. Please check your browser settings to allow microphone access for this website.';
    }
  }

  /// Get guidance for permanently denied permissions
  String _getPermanentlyDeniedGuidance() {
    switch (_browserType) {
      case BrowserType.chrome:
        return 'Microphone access is blocked. To fix this:\n'
            '1. Go to Chrome Settings > Privacy and Security > Site Settings > Microphone\n'
            '2. Remove this site from the "Blocked" list\n'
            '3. Refresh the page and try again';
      case BrowserType.firefox:
        return 'Microphone access is blocked. To fix this:\n'
            '1. Go to Firefox Settings > Privacy & Security > Permissions > Microphone\n'
            '2. Find this website and remove it or change to "Allow"\n'
            '3. Refresh the page and try again';
      case BrowserType.safari:
        return 'Microphone access is blocked. To fix this:\n'
            '1. Go to Safari > Settings > Websites > Microphone\n'
            '2. Find this website and set to "Allow"\n'
            '3. Refresh the page and try again';
      case BrowserType.edge:
        return 'Microphone access is blocked. To fix this:\n'
            '1. Go to Edge Settings > Site permissions > Microphone\n'
            '2. Remove this site from blocked list or add to allowed list\n'
            '3. Refresh the page and try again';
      case BrowserType.unknown:
        return 'Microphone access is permanently blocked. Please check your browser settings to allow microphone access for this website, then refresh the page.';
    }
  }

  /// Handle permission errors
  void _handlePermissionError(dynamic error) {
    String errorMessage;

    final errorString = error.toString().toLowerCase();

    if (errorString.contains('notallowederror')) {
      errorMessage = 'Microphone permission was denied by the user.';
      _microphoneStatus = PermissionStatus.denied;
    } else if (errorString.contains('notfounderror')) {
      errorMessage = 'No microphone device was found.';
      _microphoneStatus = PermissionStatus.denied;
    } else if (errorString.contains('notsupportederror')) {
      errorMessage = 'Microphone access is not supported in this browser.';
      _microphoneStatus = PermissionStatus.denied;
    } else if (errorString.contains('aborterror')) {
      errorMessage = 'Microphone access request was aborted.';
      _microphoneStatus = PermissionStatus.denied;
    } else {
      errorMessage =
          'An unexpected error occurred while requesting microphone access.';
      _microphoneStatus = PermissionStatus.unknown;
    }

    _errorController.add(errorMessage);
    _statusController.add(_microphoneStatus);
  }

  /// Check if permission is granted
  bool get isPermissionGranted => _microphoneStatus == PermissionStatus.granted;

  /// Check if permission can be requested
  bool get canRequestPermission =>
      _microphoneStatus != PermissionStatus.permanentlyDenied;

  /// Get user-friendly status message
  String getStatusMessage() {
    switch (_microphoneStatus) {
      case PermissionStatus.granted:
        return 'Microphone access is enabled';
      case PermissionStatus.denied:
        return 'Microphone access is denied';
      case PermissionStatus.permanentlyDenied:
        return 'Microphone access is permanently blocked';
      case PermissionStatus.unknown:
        return 'Microphone permission status is unknown';
    }
  }

  /// Dispose resources
  void dispose() {
    _statusController.close();
    _errorController.close();
    _guidanceController.close();
    _isInitialized = false;

    if (kDebugMode) {
      print('BrowserPermissionService: Disposed');
    }
  }
}

/// Permission status enumeration
enum PermissionStatus { unknown, granted, denied, permanentlyDenied }

/// Browser type enumeration
enum BrowserType { chrome, firefox, safari, edge, unknown }
