import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'tts_adapter.dart';
import 'tts_types.dart';

/// Adapter that wraps the platform system TTS via flutter_tts
class SystemTTSAdapter implements TTSAdapter {
  @override
  TTSCallbacks callbacks;

  @override
  TTSState state = TTSState.uninitialized;

  final FlutterTts _flutterTts = FlutterTts();

  SystemTTSAdapter({TTSCallbacks? callbacks})
    : callbacks = callbacks ?? const TTSCallbacks();

  @override
  Future<void> initialize() async {
    if (state != TTSState.uninitialized) return;

    _flutterTts.setStartHandler(() {
      state = TTSState.speaking;
      callbacks.onStart?.call();
      if (kDebugMode) print('SystemTTSAdapter: start');
    });

    _flutterTts.setCompletionHandler(() {
      state = TTSState.completed;
      callbacks.onComplete?.call();
      if (kDebugMode) print('SystemTTSAdapter: completed');
    });

    _flutterTts.setCancelHandler(() {
      state = TTSState.cancelled;
      callbacks.onCancel?.call();
      if (kDebugMode) print('SystemTTSAdapter: cancelled');
    });

    _flutterTts.setPauseHandler(() {
      state = TTSState.paused;
      callbacks.onPause?.call();
      if (kDebugMode) print('SystemTTSAdapter: paused');
    });

    _flutterTts.setContinueHandler(() {
      state = TTSState.continued;
      callbacks.onContinue?.call();
      if (kDebugMode) print('SystemTTSAdapter: continued');
    });

    _flutterTts.setErrorHandler((msg) {
      state = TTSState.error;
      callbacks.onError?.call(msg);
      if (kDebugMode) print('SystemTTSAdapter error: $msg');
    });

    // Default configuration similar to previous service
    await setLanguage('es-ES');
    await setSpeechRate(0.5);
    await setVolume(0.8);
    await setPitch(1.0);

    if (Platform.isAndroid) {
      await _flutterTts.setQueueMode(1); // Flush mode
    } else if (Platform.isIOS) {
      await _flutterTts.setSharedInstance(true);
      await _flutterTts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ],
        IosTextToSpeechAudioMode.spokenAudio,
      );
    }

    state = TTSState.initialized;
  }

  @override
  Future<void> speak(String text) async {
    if (text.trim().isEmpty) {
      callbacks.onError?.call('Cannot speak empty text');
      return;
    }
    await _flutterTts.speak(text);
  }

  @override
  Future<void> stop() async {
    await _flutterTts.stop();
    state = TTSState.stopped;
  }

  @override
  Future<void> pause() async {
    await _flutterTts.pause();
  }

  @override
  Future<List<String>> getLanguages() async {
    final languages = await _flutterTts.getLanguages;
    return List<String>.from(languages);
  }

  @override
  Future<List<Map<String, String>>> getVoices() async {
    final voices = await _flutterTts.getVoices;
    return List<Map<String, String>>.from(voices);
  }

  @override
  Future<void> setLanguage(String language) async {
    await _flutterTts.setLanguage(language);
  }

  @override
  Future<void> setPitch(double pitch) async {
    await _flutterTts.setPitch(pitch.clamp(0.5, 2.0));
  }

  @override
  Future<void> setSpeechRate(double rate) async {
    await _flutterTts.setSpeechRate(rate.clamp(0.0, 1.0));
  }

  @override
  Future<void> setVolume(double volume) async {
    await _flutterTts.setVolume(volume.clamp(0.0, 1.0));
  }

  @override
  void dispose() {
    _flutterTts.stop();
  }
}
