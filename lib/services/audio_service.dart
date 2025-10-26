import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:orion/services/tts_service.dart';

/// Comprehensive audio service for recording and playback
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  // Recording components
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  final TTSService _ttsService = TTSService();

  // State management
  bool _isRecorderInitialized = false;
  bool _isPlayerInitialized = false;
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _currentRecordingPath;
  Timer? _volumeMonitoringTimer;
  DateTime? _recordingStartTime;

  // Stream controllers
  final StreamController<AudioState> _stateController =
      StreamController<AudioState>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();
  final StreamController<Duration> _recordingDurationController =
      StreamController<Duration>.broadcast();
  final StreamController<List<double>> _volumeLevelsController =
      StreamController<List<double>>.broadcast();
  final StreamController<double> _currentVolumeController =
      StreamController<double>.broadcast();

  // Public streams
  Stream<AudioState> get stateStream => _stateController.stream;
  Stream<String> get errorStream => _errorController.stream;
  Stream<Duration> get recordingDurationStream =>
      _recordingDurationController.stream;
  Stream<List<double>> get volumeLevelsStream => _volumeLevelsController.stream;
  Stream<double> get currentVolumeStream => _currentVolumeController.stream;

  // Getters
  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;
  bool get isInitialized => _isRecorderInitialized && _isPlayerInitialized;

  /// Initialize the audio service
  Future<void> initialize() async {
    try {
      // Initialize recorder
      if (!_isRecorderInitialized) {
        await _recorder.openRecorder();
        _isRecorderInitialized = true;
      }

      // Initialize player
      if (!_isPlayerInitialized) {
        await _player.openPlayer();
        _isPlayerInitialized = true;
      }

      // Initialize TTS service
      await _ttsService.initialize();

      // Set up player handlers
      _player.setSubscriptionDuration(const Duration(milliseconds: 100));

      _stateController.add(AudioState.initialized);
      if (kDebugMode) print('AudioService: Initialized successfully');
    } catch (e) {
      _errorController.add('Failed to initialize AudioService: $e');
      if (kDebugMode) print('AudioService Initialization Error: $e');
      rethrow;
    }
  }

  /// Request microphone permission
  Future<bool> requestMicrophonePermission() async {
    try {
      final status = await Permission.microphone.request();
      if (status == PermissionStatus.granted) {
        return true;
      } else if (status == PermissionStatus.permanentlyDenied) {
        _errorController.add(
          'Microphone permission permanently denied. Please enable it in settings.',
        );
      } else {
        _errorController.add('Microphone permission denied');
      }
      return false;
    } catch (e) {
      _errorController.add('Error requesting microphone permission: $e');
      return false;
    }
  }

  /// Start recording audio
  Future<void> startRecording() async {
    if (!isInitialized) {
      await initialize();
    }

    if (_isRecording) {
      if (kDebugMode) print('AudioService: Already recording');
      return;
    }

    try {
      // Request permission
      final hasPermission = await requestMicrophonePermission();
      if (!hasPermission) {
        return;
      }

      // Stop any current TTS
      await _ttsService.stop();

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = 'audio_recording_$timestamp.aac';

      // Start recording
      await _recorder.startRecorder(
        toFile: _currentRecordingPath,
        codec: Codec.aacADTS,
        bitRate: 128000,
        sampleRate: 44100,
      );

      _isRecording = true;
      _recordingStartTime = DateTime.now();
      _stateController.add(AudioState.recording);

      // Start duration tracking
      _startRecordingDurationTracking();

      // Start volume monitoring
      _startVolumeMonitoring();

      if (kDebugMode) {
        print('AudioService: Started recording to $_currentRecordingPath');
      }
    } catch (e) {
      _errorController.add('Failed to start recording: $e');
      if (kDebugMode) print('AudioService Recording Error: $e');
    }
  }

  /// Stop recording and return audio data
  Future<Uint8List?> stopRecording() async {
    if (!_isRecording) {
      if (kDebugMode) print('AudioService: Not currently recording');
      return null;
    }

    try {
      final path = await _recorder.stopRecorder();
      _isRecording = false;
      _volumeMonitoringTimer?.cancel();
      _stateController.add(AudioState.recordingStopped);

      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          final audioData = await file.readAsBytes();

          // Clean up the temporary file
          try {
            await file.delete();
          } catch (e) {
            if (kDebugMode)
              print('AudioService: Failed to delete temp file: $e');
          }

          if (kDebugMode)
            print('AudioService: Recording stopped, ${audioData.length} bytes');
          return audioData;
        }
      }

      _errorController.add('Recording file not found');
      return null;
    } catch (e) {
      _isRecording = false;
      _errorController.add('Failed to stop recording: $e');
      if (kDebugMode) print('AudioService Stop Recording Error: $e');
      return null;
    }
  }

  /// Play audio from bytes
  Future<void> playAudioBytes(Uint8List audioBytes) async {
    if (!isInitialized) {
      await initialize();
    }

    if (_isPlaying) {
      await stopPlayback();
    }

    try {
      // Create temporary file
      final tempDir = Directory.systemTemp;
      final tempFile = File(
        '${tempDir.path}/temp_audio_${DateTime.now().millisecondsSinceEpoch}.aac',
      );
      await tempFile.writeAsBytes(audioBytes);

      _isPlaying = true;
      _stateController.add(AudioState.playing);

      // Play the file
      await _player.startPlayer(
        fromURI: tempFile.path,
        whenFinished: () {
          _isPlaying = false;
          _stateController.add(AudioState.playbackCompleted);
          // Clean up temp file
          tempFile.delete().catchError((e) {
            if (kDebugMode)
              print('AudioService: Failed to delete temp playback file: $e');
            return tempFile; // Return the file to satisfy the return type
          });
        },
      );

      if (kDebugMode) print('AudioService: Started playing audio');
    } catch (e) {
      _isPlaying = false;
      _errorController.add('Failed to play audio: $e');
      if (kDebugMode) print('AudioService Playback Error: $e');
    }
  }

  /// Speak text using TTS
  Future<void> speakText(String text) async {
    if (!isInitialized) {
      await initialize();
    }

    try {
      // Stop any current playback
      if (_isPlaying) {
        await stopPlayback();
      }

      _stateController.add(AudioState.speaking);
      await _ttsService.speak(text);

      if (kDebugMode)
        print(
          'AudioService: Speaking text: ${text.substring(0, text.length.clamp(0, 50))}...',
        );
    } catch (e) {
      _errorController.add('Failed to speak text: $e');
      if (kDebugMode) print('AudioService TTS Error: $e');
    }
  }

  /// Stop current playback
  Future<void> stopPlayback() async {
    if (!_isPlaying) return;

    try {
      await _player.stopPlayer();
      _isPlaying = false;
      _stateController.add(AudioState.playbackStopped);
      if (kDebugMode) print('AudioService: Stopped playback');
    } catch (e) {
      _errorController.add('Failed to stop playback: $e');
      if (kDebugMode) print('AudioService Stop Playback Error: $e');
    }
  }

  /// Stop TTS
  Future<void> stopTTS() async {
    try {
      await _ttsService.stop();
      _stateController.add(AudioState.ttsStopped);
      if (kDebugMode) print('AudioService: Stopped TTS');
    } catch (e) {
      _errorController.add('Failed to stop TTS: $e');
      if (kDebugMode) print('AudioService Stop TTS Error: $e');
    }
  }

  /// Stop all audio activities
  Future<void> stopAll() async {
    await Future.wait([
      if (_isRecording) stopRecording(),
      if (_isPlaying) stopPlayback(),
      stopTTS(),
    ]);
  }

  /// Start tracking recording duration
  void _startRecordingDurationTracking() {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isRecording || _recordingStartTime == null) {
        timer.cancel();
        return;
      }

      final duration = DateTime.now().difference(_recordingStartTime!);
      _recordingDurationController.add(duration);
    });
  }

  /// Start volume monitoring during recording
  void _startVolumeMonitoring() {
    _volumeMonitoringTimer = Timer.periodic(const Duration(milliseconds: 100), (
      timer,
    ) {
      if (!_isRecording) {
        timer.cancel();
        return;
      }

      // Simulate real-time volume levels for demo
      // In a real implementation, this would get actual audio levels from the recorder
      final currentVolume = _generateDemoVolume();
      _currentVolumeController.add(currentVolume);

      // Generate volume levels for waveform visualization
      final volumeLevels = _generateVolumeLevels(currentVolume);
      _volumeLevelsController.add(volumeLevels);
    });
  }

  /// Generate demo volume level (simulates real microphone input)
  double _generateDemoVolume() {
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final baseVolume = 0.3 + (math.sin(time * 2.0) * 0.4);
    final noise = (math.Random().nextDouble() - 0.5) * 0.2;
    return (baseVolume + noise).clamp(0.0, 1.0);
  }

  /// Generate volume levels for waveform visualization
  List<double> _generateVolumeLevels(double currentVolume) {
    const int bands = 8;
    final levels = <double>[];

    // Create a realistic frequency distribution
    for (int i = 0; i < bands; i++) {
      // Lower frequencies typically have more energy
      final frequencyMultiplier = 1.0 - (i / bands * 0.5);
      final randomVariation = (math.Random().nextDouble() - 0.5) * 0.2;
      final level = (currentVolume * frequencyMultiplier + randomVariation)
          .clamp(0.0, 1.0);
      levels.add(level);
    }

    return levels;
  }

  /// Get TTS service for advanced configuration
  TTSService get ttsService => _ttsService;

  /// Dispose of the service
  Future<void> dispose() async {
    await stopAll();

    if (_isRecorderInitialized) {
      await _recorder.closeRecorder();
      _isRecorderInitialized = false;
    }

    if (_isPlayerInitialized) {
      await _player.closePlayer();
      _isPlayerInitialized = false;
    }

    _ttsService.dispose();
    _stateController.close();
    _errorController.close();
    _recordingDurationController.close();
  }
}

/// Audio state enumeration
enum AudioState {
  uninitialized,
  initialized,
  recording,
  recordingStopped,
  playing,
  playbackStopped,
  playbackCompleted,
  speaking,
  ttsStopped,
  error,
}
