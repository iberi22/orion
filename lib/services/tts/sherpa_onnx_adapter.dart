import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path/path.dart' as p;
import 'package:sherpa_onnx/sherpa_onnx.dart';

import 'model_manager.dart';
import 'tts_adapter.dart';
import 'tts_types.dart';
import 'tts_settings.dart';

/// Adapter scaffold for on-device TTS using sherpa_onnx.
/// Note: Actual model loading/synthesis will be implemented in TASK-008.
class SherpaOnnxTTSAdapter implements TTSAdapter {
  @override
  TTSCallbacks callbacks;

  @override
  TTSState state = TTSState.uninitialized;

  FlutterSoundPlayer? _player;

  String _language = 'es-ES';

  SherpaOnnxTTSAdapter({TTSCallbacks? callbacks})
      : callbacks = callbacks ?? const TTSCallbacks();

  @override
  Future<void> initialize() async {
    if (state != TTSState.uninitialized) return;
    // Prepare audio output and on-device model storage
    _player ??= FlutterSoundPlayer();
    await _player!.openPlayer();
    await OnDeviceTTSModelManager().initialize();
    state = TTSState.initialized;
  }

  @override
  Future<void> speak(String text) async {
    if (text.trim().isEmpty) {
      callbacks.onError?.call('Cannot speak empty text');
      return;
    }

    // Ensure required on-device model exists
    final manager = OnDeviceTTSModelManager();
    final voiceKey = await TTSSettings.getPreferredVoice();
    final installed = await manager.isInstalled(voiceKey);
    if (!installed) {
      callbacks.onError?.call(
        'On-device TTS model not installed for voice "$voiceKey". '
        'Open Settings > TTS Models to download.',
      );
      if (kDebugMode) {
        print('SherpaOnnxTTSAdapter: model missing for voice=$voiceKey');
      }
      return;
    }

    try {
      callbacks.onStart?.call();
      state = TTSState.starting;

      // Resolve model artifacts for Piper VITS: .onnx and .onnx.json
      final voice = manager.manifest.voices.firstWhere((v) => v.key == voiceKey);
      final onnxMeta = voice.files.firstWhere((f) => f.url.endsWith('.onnx'));
      final jsonMeta = voice.files.firstWhere((f) => f.url.endsWith('.onnx.json'));
      final onnxPath = await manager.getLocalPath(voiceKey, onnxMeta.url);
      final jsonPath = await manager.getLocalPath(voiceKey, jsonMeta.url);
      if (onnxPath == null || jsonPath == null) {
        throw Exception('Missing local model files for voice $voiceKey');
      }

      // Ensure tokens.txt generated from Piper config JSON
      final modelDir = p.dirname(onnxPath);
      final tokensPath = p.join(modelDir, 'tokens.txt');
      final tokensFile = File(tokensPath);
      if (!await tokensFile.exists()) {
        if (kDebugMode) print('SherpaOnnxTTSAdapter: generating tokens.txt for $voiceKey');
        final cfgStr = await File(jsonPath).readAsString();
        final cfg = jsonDecode(cfgStr) as Map<String, dynamic>;
        final idMap = cfg['phoneme_id_map'] as Map<String, dynamic>?;
        if (idMap == null) {
          throw Exception('Invalid Piper config: phoneme_id_map missing');
        }
        // idMap: token -> [id, ...]
        final lines = StringBuffer();
        idMap.forEach((token, arr) {
          final id = (arr as List).first as int;
          lines.writeln('$token $id');
        });
        await tokensFile.writeAsString(lines.toString(), flush: true);
      }

      // Attempt to locate shared espeak-ng-data next to models directory (best-effort)
      String dataDir = '';
      final modelsParent = p.dirname(modelDir); // .../tts/models
      final espeakDir = Directory(p.join(modelsParent, 'espeak-ng-data'));
      if (await espeakDir.exists()) {
        dataDir = espeakDir.path;
      } else {
        if (kDebugMode) {
          print('SherpaOnnxTTSAdapter: espeak-ng-data not found; proceeding without dataDir');
        }
      }

      // Build VITS config
      final vits = OfflineTtsVitsModelConfig(
        model: onnxPath,
        tokens: tokensPath,
        dataDir: dataDir,
      );
      final modelCfg = OfflineTtsModelConfig(
        vits: vits,
        numThreads: 1,
        debug: kDebugMode,
        provider: 'cpu',
      );
      final cfg = OfflineTtsConfig(model: modelCfg);

      // Create TTS engine and synthesize
      final tts = OfflineTts(cfg);
      try {
        final generated = tts.generate(text: text, sid: 0, speed: 1.0);
        if (generated.sampleRate <= 0 || generated.samples.isEmpty) {
          throw Exception('TTS returned empty audio');
        }

        // Convert float32 PCM (-1..1) to 16-bit WAV
        final wav = _float32ToWav(generated.samples, generated.sampleRate);

        // Stop any current playback and play
        _player ??= FlutterSoundPlayer();
        if (_player!.isPlaying) {
          await _player!.stopPlayer();
        }
        await _player!.startPlayer(
          fromDataBuffer: wav,
          codec: Codec.pcm16WAV,
        );

        state = TTSState.completed;
        callbacks.onComplete?.call();
      } finally {
        tts.free();
      }
    } catch (e) {
      state = TTSState.error;
      callbacks.onError?.call('On-device TTS error: $e');
      if (kDebugMode) print('SherpaOnnxTTSAdapter error: $e');
    }
  }

  @override
  Future<void> stop() async {
    if (_player?.isPlaying == true) {
      await _player!.stopPlayer();
    }
    state = TTSState.stopped;
    callbacks.onCancel?.call();
  }

  @override
  Future<void> pause() async {
    if (_player?.isPlaying == true) {
      await _player!.stopPlayer();
    }
    state = TTSState.paused;
    callbacks.onPause?.call();
  }

  @override
  Future<List<String>> getLanguages() async {
    return ['es-ES', 'en-US'];
  }

  @override
  Future<List<Map<String, String>>> getVoices() async {
    final voiceKey = await TTSSettings.getPreferredVoice();
    return [
      {'name': voiceKey, 'lang': _language},
    ];
  }

  @override
  Future<void> setLanguage(String language) async {
    _language = language;
  }

  @override
  Future<void> setPitch(double pitch) async {
    // Not applied until synthesis parameters are wired
  }

  @override
  Future<void> setSpeechRate(double rate) async {
    // Not applied until synthesis parameters are wired
  }

  @override
  Future<void> setVolume(double volume) async {
    // Volume handled by system output for now.
  }

  @override
  void dispose() {
    _player?.stopPlayer();
    _player?.closePlayer();
  }

  // Convert Float32 PCM (-1.0..1.0) mono to PCM16 WAV bytes
  Uint8List _float32ToWav(Float32List pcm, int sampleRate) {
    final int16 = Int16List(pcm.length);
    for (var i = 0; i < pcm.length; i++) {
      var v = (pcm[i] * 32767.0).round();
      if (v > 32767) v = 32767;
      if (v < -32768) v = -32768;
      int16[i] = v;
    }
    final pcmBytes = int16.buffer.asUint8List();
    final byteRate = sampleRate * 2; // mono 16-bit
    final blockAlign = 2;
    final dataLength = pcmBytes.lengthInBytes;
    final chunkSize = 36 + dataLength;

    Uint8List _le16(int v) => Uint8List(2)..buffer.asByteData().setUint16(0, v, Endian.little);
    Uint8List _le32(int v) => Uint8List(4)..buffer.asByteData().setUint32(0, v, Endian.little);

    final header = BytesBuilder();
    header.add(ascii.encode('RIFF'));
    header.add(_le32(chunkSize));
    header.add(ascii.encode('WAVE'));
    header.add(ascii.encode('fmt '));
    header.add(_le32(16));
    header.add(_le16(1));
    header.add(_le16(1));
    header.add(_le32(sampleRate));
    header.add(_le32(byteRate));
    header.add(_le16(blockAlign));
    header.add(_le16(16));
    header.add(ascii.encode('data'));
    header.add(_le32(dataLength));

    final bytes = BytesBuilder();
    bytes.add(header.takeBytes());
    bytes.add(pcmBytes);
    return bytes.takeBytes();
  }
}
