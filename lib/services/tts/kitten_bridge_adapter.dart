import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;

import '../../config/app_config.dart';
import 'tts_adapter.dart';
import 'tts_types.dart';

/// Adapter that calls a local Python KittenTTS FastAPI bridge and plays WAV bytes
class KittenBridgeAdapter implements TTSAdapter {
  @override
  TTSCallbacks callbacks;

  @override
  TTSState state = TTSState.uninitialized;

  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  String _language = 'es-ES';
  double _rate = 0.5;
  double _pitch = 1.0;

  KittenBridgeAdapter({TTSCallbacks? callbacks})
    : callbacks = callbacks ?? const TTSCallbacks();

  @override
  Future<void> initialize() async {
    if (state != TTSState.uninitialized) return;
    await _player.openPlayer();
    // Keep volume/pitch/rate as metadata for future server params mapping.
    state = TTSState.initialized;
  }

  Uri _buildUri(String path) {
    final base = AppConfig.kittenBridgeUrl ?? 'http://127.0.0.1:8000';
    return Uri.parse(base + path);
  }

  @override
  Future<void> speak(String text) async {
    if (text.trim().isEmpty) {
      callbacks.onError?.call('Cannot speak empty text');
      return;
    }

    try {
      callbacks.onStart?.call();
      state = TTSState.starting;

      final reqBody = {
        'text': text,
        'sample_rate': AppConfig.ttsSampleRate,
        'voice': AppConfig.ttsVoice,
        'language': _language,
        'rate': _rate,
        'pitch': _pitch,
      };

      final resp = await http.post(
        _buildUri('/synthesize'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(reqBody),
      );

      if (resp.statusCode != 200) {
        throw Exception('Bridge error ${resp.statusCode}: ${resp.body}');
      }

      // Expect audio/wav bytes
      final bytes = resp.bodyBytes;
      await _playWavBytes(bytes);
      state = TTSState.completed;
      callbacks.onComplete?.call();
    } catch (e) {
      state = TTSState.error;
      callbacks.onError?.call('Kitten bridge speak error: $e');
      if (kDebugMode) print('KittenBridgeAdapter error: $e');
    }
  }

  Future<void> _playWavBytes(Uint8List bytes) async {
    // Stop any current playback
    if (_player.isPlaying) {
      await _player.stopPlayer();
    }

    // FlutterSound can play WAV buffers via startPlayer fromDataBuffer
    await _player.startPlayer(
      fromDataBuffer: bytes,
      codec: Codec.pcm16WAV,
      whenFinished: () {
        // Completion handled in speak() after startPlayer future resolves
      },
    );
  }

  @override
  Future<void> stop() async {
    if (_player.isPlaying) {
      await _player.stopPlayer();
    }
    state = TTSState.stopped;
    callbacks.onCancel?.call();
  }

  @override
  Future<void> pause() async {
    // FlutterSound does not expose pause for buffer playback on all platforms.
    // As a fallback, stop (idempotent) and signal pause.
    if (_player.isPlaying) {
      await _player.stopPlayer();
    }
    state = TTSState.paused;
    callbacks.onPause?.call();
  }

  @override
  Future<List<String>> getLanguages() async {
    // Optional: query bridge /languages
    return ['es-ES', 'en-US'];
  }

  @override
  Future<List<Map<String, String>>> getVoices() async {
    // Optional: query bridge /voices
    return [
      {'name': AppConfig.ttsVoice, 'lang': _language},
    ];
  }

  @override
  Future<void> setLanguage(String language) async {
    _language = language;
  }

  @override
  Future<void> setPitch(double pitch) async {
    _pitch = pitch;
  }

  @override
  Future<void> setSpeechRate(double rate) async {
    _rate = rate;
  }

  @override
  Future<void> setVolume(double volume) async {
    // No-op: volume handled by system output or future bridge params
  }

  @override
  void dispose() {
    _player.stopPlayer();
    _player.closePlayer();
  }
}
