import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;

import '../../config/app_config.dart';
import '../config/secure_config_service.dart';
import 'tts_adapter.dart';
import 'tts_types.dart';

/// Adapter that calls Google Gemini TTS (AI Studio) and plays PCM as WAV
class GeminiTTSAdapter implements TTSAdapter {
  @override
  TTSCallbacks callbacks;

  @override
  TTSState state = TTSState.uninitialized;

  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  String _language = 'es-ES';

  GeminiTTSAdapter({TTSCallbacks? callbacks})
      : callbacks = callbacks ?? const TTSCallbacks();

  @override
  Future<void> initialize() async {
    if (state != TTSState.uninitialized) return;
    await _player.openPlayer();
    state = TTSState.initialized;
  }

  static const _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-tts:generateContent';

  @override
  Future<void> speak(String text) async {
    if (text.trim().isEmpty) {
      callbacks.onError?.call('Cannot speak empty text');
      return;
    }

    try {
      callbacks.onStart?.call();
      state = TTSState.starting;

      final apiKey = await SecureConfigService.getGeminiApiKey();
      if (apiKey.isEmpty) {
        throw Exception('Missing Gemini API key');
      }

      final voiceName = AppConfig.ttsVoice.isNotEmpty
          ? AppConfig.ttsVoice
          : 'Kore';

      final body = {
        'model': 'gemini-2.5-flash-preview-tts',
        'contents': [
          {
            'parts': [
              {'text': text}
            ]
          }
        ],
        'generationConfig': {
          'responseModalities': ['AUDIO']
        },
        'speechConfig': {
          'voiceConfig': {
            'prebuiltVoiceConfig': {
              'voiceName': voiceName,
            }
          }
        }
      };

      final resp = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': apiKey,
        },
        body: jsonEncode(body),
      );

      if (resp.statusCode != 200) {
        throw Exception('Gemini TTS error ${resp.statusCode}: ${resp.body}');
      }

      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      final candidates = json['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        throw Exception('No candidates in Gemini response');
      }
      final content = candidates.first['content'] as Map<String, dynamic>;
      final parts = content['parts'] as List<dynamic>?;
      if (parts == null || parts.isEmpty) {
        throw Exception('No audio parts in Gemini response');
      }
      final inline = parts.first['inlineData'] as Map<String, dynamic>?;
      if (inline == null) {
        throw Exception('No inlineData in Gemini response');
      }
      final b64 = inline['data'] as String?;
      if (b64 == null || b64.isEmpty) {
        throw Exception('Empty audio data');
      }

      final pcm = base64Decode(b64);
      final wav = _pcm16ToWav(pcm, AppConfig.ttsSampleRate);

      // Stop any current playback, then play WAV bytes
      if (_player.isPlaying) await _player.stopPlayer();
      await _player.startPlayer(
        fromDataBuffer: wav,
        codec: Codec.pcm16WAV,
      );

      state = TTSState.completed;
      callbacks.onComplete?.call();
    } catch (e) {
      state = TTSState.error;
      callbacks.onError?.call('Gemini TTS speak error: $e');
      if (kDebugMode) print('GeminiTTSAdapter error: $e');
    }
  }

  Uint8List _pcm16ToWav(Uint8List pcm, int sampleRate) {
    final byteRate = sampleRate * 2; // mono 16-bit
    final blockAlign = 2; // mono 16-bit
    final dataLength = pcm.lengthInBytes;
    final chunkSize = 36 + dataLength;

    final header = BytesBuilder();
    // RIFF header
    header.add(ascii.encode('RIFF'));
    header.add(_le32(chunkSize));
    header.add(ascii.encode('WAVE'));
    // fmt chunk
    header.add(ascii.encode('fmt '));
    header.add(_le32(16)); // Subchunk1Size for PCM
    header.add(_le16(1)); // AudioFormat PCM = 1
    header.add(_le16(1)); // NumChannels = 1
    header.add(_le32(sampleRate));
    header.add(_le32(byteRate));
    header.add(_le16(blockAlign));
    header.add(_le16(16)); // BitsPerSample
    // data chunk
    header.add(ascii.encode('data'));
    header.add(_le32(dataLength));

    final bytes = BytesBuilder();
    bytes.add(header.takeBytes());
    bytes.add(pcm);
    return bytes.takeBytes();
  }

  Uint8List _le16(int v) => Uint8List(2)..buffer.asByteData().setUint16(0, v, Endian.little);
  Uint8List _le32(int v) => Uint8List(4)..buffer.asByteData().setUint32(0, v, Endian.little);

  @override
  Future<void> stop() async {
    if (_player.isPlaying) await _player.stopPlayer();
    state = TTSState.stopped;
    callbacks.onCancel?.call();
  }

  @override
  Future<void> pause() async {
    if (_player.isPlaying) await _player.stopPlayer();
    state = TTSState.paused;
    callbacks.onPause?.call();
  }

  @override
  Future<List<String>> getLanguages() async => ['es-ES', 'en-US'];

  @override
  Future<List<Map<String, String>>> getVoices() async => [
        {'name': AppConfig.ttsVoice, 'lang': _language},
      ];

  @override
  Future<void> setLanguage(String language) async {
    _language = language;
  }

  @override
  Future<void> setPitch(double pitch) async {
    // Not supported directly by Gemini REST at the moment; consider style prompts.
  }

  @override
  Future<void> setSpeechRate(double rate) async {
    // Not supported directly by Gemini REST at the moment; consider style prompts.
  }

  @override
  Future<void> setVolume(double volume) async {
    // No-op for now
  }

  @override
  void dispose() {
    _player.stopPlayer();
    _player.closePlayer();
  }
}
