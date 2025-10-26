import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:orion/config/app_config.dart';
import 'package:orion/services/tts/tts_adapter.dart';
import 'package:orion/services/tts/system_tts_adapter.dart';
import 'package:orion/services/tts/kitten_bridge_adapter.dart';
import 'package:orion/services/tts/gemini_tts_adapter.dart';
import 'package:orion/services/tts/tts_types.dart';
import 'package:orion/services/tts/sherpa_onnx_adapter.dart';

/// Service for Text-to-Speech functionality
class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;
  TTSService._internal();

  // Adapter selected by configuration
  TTSAdapter? _adapter;
  bool _isInitialized = false;
  bool _isSpeaking = false;

  // Stream controllers for TTS events
  final StreamController<TTSState> _stateController =
      StreamController<TTSState>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  // Public streams
  Stream<TTSState> get stateStream => _stateController.stream;
  Stream<String> get errorStream => _errorController.stream;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isSpeaking => _isSpeaking;

  /// Initialize the TTS service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Choose adapter based on AppConfig
      final provider = AppConfig.ttsProvider;
      _adapter = _createAdapter(provider);

      // Wire callbacks
      _adapter!.callbacks = TTSCallbacks(
        onStart: () {
          _isSpeaking = true;
          _stateController.add(TTSState.speaking);
          if (kDebugMode) print('TTS: Started speaking');
        },
        onComplete: () {
          _isSpeaking = false;
          _stateController.add(TTSState.completed);
          if (kDebugMode) print('TTS: Completed speaking');
        },
        onCancel: () {
          _isSpeaking = false;
          _stateController.add(TTSState.cancelled);
          if (kDebugMode) print('TTS: Cancelled speaking');
        },
        onPause: () {
          _stateController.add(TTSState.paused);
          if (kDebugMode) print('TTS: Paused speaking');
        },
        onContinue: () {
          _stateController.add(TTSState.continued);
          if (kDebugMode) print('TTS: Continued speaking');
        },
        onError: (msg) {
          _isSpeaking = false;
          _stateController.add(TTSState.error);
          _errorController.add(msg);
          if (kDebugMode) print('TTS Error: $msg');
        },
      );

      await _adapter!.initialize();

      _isInitialized = true;
      _stateController.add(TTSState.initialized);
      if (kDebugMode) print('TTS: Initialized successfully');
    } catch (e) {
      _errorController.add('Failed to initialize TTS: $e');
      if (kDebugMode) print('TTS Initialization Error: $e');
      rethrow;
    }
  }

  TTSAdapter _createAdapter(String provider) {
    switch (provider) {
      case 'kitten':
        return KittenBridgeAdapter();
      case 'cloud':
        // Map 'cloud' to Gemini TTS by default
        return GeminiTTSAdapter();
      case 'ondevice':
        return SherpaOnnxTTSAdapter();
      case 'system':
      default:
        return SystemTTSAdapter();
    }
  }

  /// Testing-only: inject a custom adapter (e.g., fake) and mark initialized.
  void setAdapterForTesting(TTSAdapter adapter) {
    _adapter = adapter;
    _adapter!.callbacks = TTSCallbacks(
      onStart: () {
        _isSpeaking = true;
        _stateController.add(TTSState.speaking);
        if (kDebugMode) print('TTS: Started speaking');
      },
      onComplete: () {
        _isSpeaking = false;
        _stateController.add(TTSState.completed);
        if (kDebugMode) print('TTS: Completed speaking');
      },
      onCancel: () {
        _isSpeaking = false;
        _stateController.add(TTSState.cancelled);
        if (kDebugMode) print('TTS: Cancelled speaking');
      },
      onPause: () {
        _stateController.add(TTSState.paused);
        if (kDebugMode) print('TTS: Paused speaking');
      },
      onContinue: () {
        _stateController.add(TTSState.continued);
        if (kDebugMode) print('TTS: Continued speaking');
      },
      onError: (msg) {
        _isSpeaking = false;
        _stateController.add(TTSState.error);
        _errorController.add(msg);
        if (kDebugMode) print('TTS Error: $msg');
      },
    );
    _isInitialized = true;
  }

  /// Speak the given text
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (text.trim().isEmpty) {
      _errorController.add('Cannot speak empty text');
      return;
    }

    try {
      if (_isSpeaking) await stop();
      _stateController.add(TTSState.starting);
      await _adapter!.speak(text);
    } catch (e) {
      _errorController.add('Failed to speak text: $e');
      if (kDebugMode) print('TTS Speak Error: $e');
    }
  }

  /// Stop current speech
  Future<void> stop() async {
    if (!_isInitialized) return;

    try {
      await _adapter!.stop();
      _isSpeaking = false;
      _stateController.add(TTSState.stopped);
    } catch (e) {
      _errorController.add('Failed to stop TTS: $e');
      if (kDebugMode) print('TTS Stop Error: $e');
    }
  }

  /// Pause current speech
  Future<void> pause() async {
    if (!_isInitialized) return;

    try {
      await _adapter!.pause();
    } catch (e) {
      _errorController.add('Failed to pause TTS: $e');
      if (kDebugMode) print('TTS Pause Error: $e');
    }
  }

  /// Get available languages
  Future<List<String>> getLanguages() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      return await _adapter!.getLanguages();
    } catch (e) {
      _errorController.add('Failed to get languages: $e');
      return [];
    }
  }

  /// Get available voices
  Future<List<Map<String, String>>> getVoices() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      return await _adapter!.getVoices();
    } catch (e) {
      _errorController.add('Failed to get voices: $e');
      return [];
    }
  }

  /// Set speech rate (0.0 to 1.0)
  Future<void> setSpeechRate(double rate) async {
    if (!_isInitialized) return;

    try {
      await _adapter!.setSpeechRate(rate);
    } catch (e) {
      _errorController.add('Failed to set speech rate: $e');
    }
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    if (!_isInitialized) return;

    try {
      await _adapter!.setVolume(volume);
    } catch (e) {
      _errorController.add('Failed to set volume: $e');
    }
  }

  /// Set pitch (0.5 to 2.0)
  Future<void> setPitch(double pitch) async {
    if (!_isInitialized) return;

    try {
      await _adapter!.setPitch(pitch);
    } catch (e) {
      _errorController.add('Failed to set pitch: $e');
    }
  }

  /// Set language
  Future<void> setLanguage(String language) async {
    if (!_isInitialized) return;

    try {
      await _adapter!.setLanguage(language);
    } catch (e) {
      _errorController.add('Failed to set language: $e');
    }
  }

  /// Dispose of the service
  void dispose() {
    try {
      _adapter?.dispose();
    } catch (_) {}
    _stateController.close();
    _errorController.close();
  }
}
