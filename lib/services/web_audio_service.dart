import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util' as js_util;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:orion/config/app_config.dart';

/// Web-specific audio service with browser compatibility
/// Uses MediaRecorder API and WebRTC for optimal cross-browser support
class WebAudioService {
  static final WebAudioService _instance = WebAudioService._internal();
  factory WebAudioService() => _instance;
  WebAudioService._internal();

  // Web Audio API components
  html.MediaRecorder? _mediaRecorder;
  html.MediaStream? _mediaStream;
  html.AudioContext? _audioContext;
  html.AnalyserNode? _analyser;

  // State management
  bool _isInitialized = false;
  bool _isRecording = false;
  bool _hasPermission = false;
  final List<html.Blob> _recordedChunks = [];

  // Stream controllers
  final StreamController<WebAudioState> _stateController =
      StreamController<WebAudioState>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();
  final StreamController<List<double>> _volumeLevelsController =
      StreamController<List<double>>.broadcast();
  final StreamController<Duration> _recordingDurationController =
      StreamController<Duration>.broadcast();

  // Recording timer
  Timer? _recordingTimer;
  DateTime? _recordingStartTime;

  // Browser detection
  late BrowserType _browserType;
  late Map<String, bool> _browserCapabilities;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isRecording => _isRecording;
  bool get hasPermission => _hasPermission;
  BrowserType get browserType => _browserType;
  Stream<WebAudioState> get stateStream => _stateController.stream;
  Stream<String> get errorStream => _errorController.stream;
  Stream<List<double>> get volumeLevelsStream => _volumeLevelsController.stream;
  Stream<Duration> get recordingDurationStream =>
      _recordingDurationController.stream;

  /// Initialize the web audio service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _stateController.add(WebAudioState.initializing);

      // Detect browser and capabilities
      _detectBrowser();
      await _checkBrowserCapabilities();

      // Initialize audio context
      await _initializeAudioContext();

      _isInitialized = true;
      _stateController.add(WebAudioState.ready);

      if (kDebugMode) {
        print('WebAudioService: Initialized successfully');
        print('Browser: ${_browserType.name}');
        print('Capabilities: $_browserCapabilities');
      }
    } catch (e) {
      _errorController.add('Failed to initialize WebAudioService: $e');
      _stateController.add(WebAudioState.error);
      if (kDebugMode) {
        print('WebAudioService Initialization Error: $e');
      }
      rethrow;
    }
  }

  /// Detect browser type
  void _detectBrowser() {
    final userAgent = html.window.navigator.userAgent.toLowerCase();

    if (userAgent.contains('chrome') && !userAgent.contains('edg')) {
      _browserType = BrowserType.chrome;
    } else if (userAgent.contains('firefox')) {
      _browserType = BrowserType.firefox;
    } else if (userAgent.contains('safari') && !userAgent.contains('chrome')) {
      _browserType = BrowserType.safari;
    } else if (userAgent.contains('edg')) {
      _browserType = BrowserType.edge;
    } else {
      _browserType = BrowserType.unknown;
    }
  }

  /// Check browser capabilities
  Future<void> _checkBrowserCapabilities() async {
    _browserCapabilities = {
      'mediaRecorder': html.MediaRecorder.isTypeSupported('audio/webm'),
      'webm': html.MediaRecorder.isTypeSupported('audio/webm;codecs=opus'),
      'mp4': html.MediaRecorder.isTypeSupported('audio/mp4'),
      'wav': html.MediaRecorder.isTypeSupported('audio/wav'),
      'getUserMedia': html.window.navigator.mediaDevices != null,
      'audioContext': html.AudioContext.supported,
    };

    // Fallback checks for older browsers
    if (!_browserCapabilities['webm']!) {
      _browserCapabilities['webm'] = html.MediaRecorder.isTypeSupported(
        'audio/webm',
      );
    }
  }

  /// Initialize audio context
  Future<void> _initializeAudioContext() async {
    try {
      _audioContext = html.AudioContext();

      // Resume audio context if suspended (required by some browsers)
      if (_audioContext!.state == 'suspended') {
        await _audioContext!.resume();
      }

      if (kDebugMode) {
        print('WebAudioService: Audio context initialized');
      }
    } catch (e) {
      throw Exception('Failed to initialize audio context: $e');
    }
  }

  /// Request microphone permission
  Future<bool> requestMicrophonePermission() async {
    try {
      _stateController.add(WebAudioState.requestingPermission);

      final constraints = {
        'audio': {
          'echoCancellation': AppConfig.webAudioEchoCancellation,
          'noiseSuppression': AppConfig.webAudioNoiseSuppression,
          'autoGainControl': AppConfig.webAudioAutoGainControl,
          'sampleRate': AppConfig.webAudioSampleRate,
        },
      };

      _mediaStream = await html.window.navigator.mediaDevices!.getUserMedia(
        constraints,
      );
      _hasPermission = true;

      _stateController.add(WebAudioState.ready);

      if (kDebugMode) {
        print('WebAudioService: Microphone permission granted');
      }

      return true;
    } catch (e) {
      _hasPermission = false;
      _stateController.add(WebAudioState.error);

      String errorMessage;
      if (e.toString().contains('NotAllowedError')) {
        errorMessage =
            'Microphone permission denied. Please allow microphone access and try again.';
      } else if (e.toString().contains('NotFoundError')) {
        errorMessage =
            'No microphone found. Please connect a microphone and try again.';
      } else {
        errorMessage = 'Failed to access microphone: $e';
      }

      _errorController.add(errorMessage);

      if (kDebugMode) {
        print('WebAudioService Permission Error: $e');
      }

      return false;
    }
  }

  /// Start recording audio
  Future<void> startRecording() async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_isRecording) {
      if (kDebugMode) {
        print('WebAudioService: Already recording');
      }
      return;
    }

    try {
      // Request permission if not already granted
      if (!_hasPermission) {
        final hasPermission = await requestMicrophonePermission();
        if (!hasPermission) {
          return;
        }
      }

      // Clear previous recording chunks
      _recordedChunks.clear();

      // Set up media recorder with browser-specific options
      final mimeType = _getBestSupportedMimeType();
      final options = _getRecorderOptions(mimeType);

      _mediaRecorder = html.MediaRecorder(_mediaStream!, options);

      // Set up event handlers
      _setupRecorderEventHandlers();

      // Set up volume level monitoring
      await _setupVolumeMonitoring();

      // Start recording
      _mediaRecorder!.start();
      _isRecording = true;
      _recordingStartTime = DateTime.now();

      // Start duration tracking
      _startRecordingDurationTracking();

      _stateController.add(WebAudioState.recording);

      if (kDebugMode) {
        print('WebAudioService: Started recording with $mimeType');
      }
    } catch (e) {
      _errorController.add('Failed to start recording: $e');
      _stateController.add(WebAudioState.error);
      if (kDebugMode) {
        print('WebAudioService Recording Error: $e');
      }
    }
  }

  /// Get the best supported MIME type for the current browser
  String _getBestSupportedMimeType() {
    // Priority order based on quality and compatibility
    final mimeTypes = [
      'audio/webm;codecs=opus',
      'audio/webm',
      'audio/mp4',
      'audio/wav',
    ];

    for (final mimeType in mimeTypes) {
      if (html.MediaRecorder.isTypeSupported(mimeType)) {
        return mimeType;
      }
    }

    // Fallback to basic audio/webm
    return 'audio/webm';
  }

  /// Get recorder options based on browser and MIME type
  Map<String, dynamic> _getRecorderOptions(String mimeType) {
    final options = <String, dynamic>{'mimeType': mimeType};

    // Add browser-specific optimizations
    switch (_browserType) {
      case BrowserType.chrome:
        options['audioBitsPerSecond'] = AppConfig.webAudioBitRate;
        break;
      case BrowserType.firefox:
        // Firefox has different optimization needs
        options['audioBitsPerSecond'] =
            AppConfig.webAudioBitRate * 0.8; // Slightly lower for stability
        break;
      case BrowserType.safari:
        // Safari is more restrictive
        if (mimeType.contains('webm')) {
          options['audioBitsPerSecond'] = AppConfig.webAudioBitRate * 0.6;
        }
        break;
      case BrowserType.edge:
        options['audioBitsPerSecond'] = AppConfig.webAudioBitRate;
        break;
      case BrowserType.unknown:
        // Conservative settings for unknown browsers
        break;
    }

    return options;
  }

  /// Set up media recorder event handlers
  void _setupRecorderEventHandlers() {
    _mediaRecorder!.onDataAvailable.listen((html.BlobEvent event) {
      if (event.data != null && event.data!.size > 0) {
        _recordedChunks.add(event.data!);
      }
    });

    _mediaRecorder!.onStop.listen((html.Event event) {
      _stateController.add(WebAudioState.recordingStopped);
    });

    _mediaRecorder!.onError.listen((html.Event event) {
      _errorController.add('Recording error occurred');
      _stateController.add(WebAudioState.error);
    });
  }

  /// Set up volume level monitoring
  Future<void> _setupVolumeMonitoring() async {
    try {
      if (_audioContext == null || _mediaStream == null) return;

      final source = _audioContext!.createMediaStreamSource(_mediaStream!);
      _analyser = _audioContext!.createAnalyser();

      _analyser!.fftSize = 256;
      source.connectNode(_analyser!);

      // Start volume monitoring
      _startVolumeMonitoring();
    } catch (e) {
      if (kDebugMode) {
        print('WebAudioService: Failed to set up volume monitoring: $e');
      }
    }
  }

  /// Start volume level monitoring
  void _startVolumeMonitoring() {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isRecording) {
        timer.cancel();
        return;
      }

      if (_analyser != null) {
        final bufferLength = _analyser!.frequencyBinCount;
        final dataArray = Float32List(bufferLength);
        _analyser!.getFloatFrequencyData(dataArray);

        // Calculate volume levels
        final volumes = _calculateVolumeLevels(dataArray);
        _volumeLevelsController.add(volumes);
      }
    });
  }

  /// Calculate volume levels from frequency data
  List<double> _calculateVolumeLevels(Float32List frequencyData) {
    const int bands = 8; // Number of frequency bands
    final bandSize = frequencyData.length ~/ bands;
    final volumes = <double>[];

    for (int i = 0; i < bands; i++) {
      double sum = 0;
      final start = i * bandSize;
      final end = (i + 1) * bandSize;

      for (int j = start; j < end && j < frequencyData.length; j++) {
        sum += frequencyData[j];
      }

      final average = sum / bandSize;
      final normalized =
          (average + 100) / 100; // Normalize from -100dB to 0dB range
      volumes.add(normalized.clamp(0.0, 1.0));
    }

    return volumes;
  }

  /// Start recording duration tracking
  void _startRecordingDurationTracking() {
    _recordingTimer = Timer.periodic(const Duration(milliseconds: 100), (
      timer,
    ) {
      if (!_isRecording || _recordingStartTime == null) {
        timer.cancel();
        return;
      }

      final duration = DateTime.now().difference(_recordingStartTime!);
      _recordingDurationController.add(duration);

      // Auto-stop if max duration reached
      if (duration.inSeconds >= AppConfig.maxRecordingDuration) {
        stopRecording();
      }
    });
  }

  /// Stop recording and return audio data
  Future<Uint8List?> stopRecording() async {
    if (!_isRecording) {
      if (kDebugMode) {
        print('WebAudioService: Not currently recording');
      }
      return null;
    }

    try {
      _mediaRecorder!.stop();
      _isRecording = false;
      _recordingTimer?.cancel();

      // Wait for the stop event to process all chunks
      await Future.delayed(const Duration(milliseconds: 100));

      if (_recordedChunks.isEmpty) {
        _errorController.add('No audio data recorded');
        return null;
      }

      // Combine all chunks into a single blob
      final blob = html.Blob(_recordedChunks, _getBestSupportedMimeType());

      // Convert blob to Uint8List
      final audioBytes = await _blobToUint8List(blob);

      _stateController.add(WebAudioState.ready);

      if (kDebugMode) {
        print('WebAudioService: Recording stopped, ${audioBytes.length} bytes');
      }

      return audioBytes;
    } catch (e) {
      _isRecording = false;
      _errorController.add('Failed to stop recording: $e');
      _stateController.add(WebAudioState.error);
      if (kDebugMode) {
        print('WebAudioService Stop Recording Error: $e');
      }
      return null;
    }
  }

  /// Convert blob to Uint8List
  Future<Uint8List> _blobToUint8List(html.Blob blob) async {
    final reader = html.FileReader();
    final completer = Completer<Uint8List>();

    reader.onLoad.listen((html.ProgressEvent event) {
      final result = reader.result as List<int>;
      completer.complete(Uint8List.fromList(result));
    });

    reader.onError.listen((html.ProgressEvent event) {
      completer.completeError('Failed to read blob');
    });

    reader.readAsArrayBuffer(blob);
    return completer.future;
  }

  /// Stop all audio operations
  Future<void> stopAll() async {
    if (_isRecording) {
      await stopRecording();
    }

    _recordingTimer?.cancel();

    if (_mediaStream != null) {
      _mediaStream!.getTracks().forEach((track) => track.stop());
    }

    _stateController.add(WebAudioState.ready);
  }

  /// Dispose resources
  void dispose() {
    stopAll();
    _stateController.close();
    _errorController.close();
    _volumeLevelsController.close();
    _recordingDurationController.close();
    _audioContext?.close();
    _isInitialized = false;

    if (kDebugMode) {
      print('WebAudioService: Disposed');
    }
  }
}

/// Web audio service state enumeration
enum WebAudioState {
  uninitialized,
  initializing,
  ready,
  requestingPermission,
  recording,
  recordingStopped,
  error,
}

/// Browser type enumeration
enum BrowserType { chrome, firefox, safari, edge, unknown }
