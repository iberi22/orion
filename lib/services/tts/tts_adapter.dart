import 'dart:async';

import 'tts_types.dart';

/// Callbacks for adapter to notify TTSService
class TTSCallbacks {
  final void Function()? onStart;
  final void Function()? onComplete;
  final void Function()? onCancel;
  final void Function()? onPause;
  final void Function()? onContinue;
  final void Function(String message)? onError;

  const TTSCallbacks({
    this.onStart,
    this.onComplete,
    this.onCancel,
    this.onPause,
    this.onContinue,
    this.onError,
  });
}

/// Abstract adapter interface implemented by concrete providers
abstract class TTSAdapter {
  TTSCallbacks callbacks;
  TTSState state = TTSState.uninitialized;

  TTSAdapter({TTSCallbacks? callbacks})
    : callbacks = callbacks ?? const TTSCallbacks();

  Future<void> initialize();
  Future<void> speak(String text);
  Future<void> stop();
  Future<void> pause();

  Future<List<String>> getLanguages();
  Future<List<Map<String, String>>> getVoices();

  Future<void> setSpeechRate(double rate);
  Future<void> setVolume(double volume);
  Future<void> setPitch(double pitch);
  Future<void> setLanguage(String language);

  void dispose();
}
