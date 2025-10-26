import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart' as crypto;
import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../utils/error_handler.dart';
import 'model_manifest.dart';

/// Manages on-device TTS models: manifest loading, install, verify, remove.
class OnDeviceTTSModelManager {
  OnDeviceTTSModelManager._internal() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(minutes: 5),
      ),
    );
  }
  static final OnDeviceTTSModelManager _instance = OnDeviceTTSModelManager._internal();
  factory OnDeviceTTSModelManager() => _instance;

  late Dio _dio;

  Directory? _baseDir;
  TTSModelManifest _manifest = TTSModelManifest.empty();

  /// Test-only: override base directory to avoid path_provider.
  void debugSetBaseDirForTesting(Directory dir) {
    _baseDir = dir;
  }

  /// Test-only: override Dio client to stub downloads.
  void debugSetDioForTesting(Dio dio) {
    _dio = dio;
  }

  /// Initialize storage dirs and load bundled manifest.
  Future<void> initialize() async {
    if (_baseDir != null) return;
    final support = await getApplicationSupportDirectory();
    _baseDir = Directory(p.join(support.path, 'tts'));
    if (!await _baseDir!.exists()) {
      await _baseDir!.create(recursive: true);
    }
    await _loadBundledManifest();
  }

  /// Return the loaded manifest.
  TTSModelManifest get manifest => _manifest;

  /// Path where a given voice will be stored.
  Future<String> _voiceDir(String voiceKey) async {
    await initialize();
    return p.join(_baseDir!.path, 'models', voiceKey);
  }

  /// Path of a local file for a remote artifact.
  Future<String> _localPathFor(String voiceKey, String remoteUrl) async {
    final dir = await _voiceDir(voiceKey);
    final fileName = p.basename(Uri.parse(remoteUrl).path);
    return p.join(dir, fileName);
  }

  /// Load manifest from bundled asset at assets/tts/manifest.json.
  Future<void> _loadBundledManifest() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/tts/manifest.json');
      _manifest = TTSModelManifest.parse(jsonStr);
    } catch (e) {
      // Keep empty manifest if asset missing; caller may provide remote manifest later.
      ErrorHandler.handleError(
        e,
        null,
        context: 'TTS Model Manifest: load bundled manifest',
        showToUser: false,
      );
      _manifest = TTSModelManifest.empty();
    }
  }

  /// Replace manifest at runtime (e.g., fetched remotely) and persist a copy.
  Future<void> setManifest(TTSModelManifest manifest) async {
    _manifest = manifest;
    try {
      final file = File(p.join(_baseDir!.path, 'manifest.json'));
      await file.writeAsString(_manifest.stringify(), flush: true);
    } catch (e) {
      ErrorHandler.handleError(
        e,
        null,
        context: 'TTS Model Manifest: persist manifest',
        showToUser: false,
      );
    }
  }

  /// True if all artifacts for voice are present and verify (if md5 provided).
  Future<bool> isInstalled(String voiceKey) async {
    final voice = _manifest.voices.where((v) => v.key == voiceKey).cast<VoiceEntry?>().firstOrNull;
    if (voice == null) return false;
    for (final f in voice.files) {
      final path = await _localPathFor(voice.key, f.url);
      final file = File(path);
      if (!await file.exists()) return false;
      if (f.md5.isNotEmpty && f.md5.length == 32) {
        final ok = await _verifyMd5(file, f.md5);
        if (!ok) return false;
      }
    }
    return true;
  }

  /// Download and install a voice. Returns when all files are present and valid.
  Future<void> installVoice(VoiceEntry voice, {void Function(double progress)? onProgress}) async {
    final total = voice.files.length;
    var done = 0;
    for (final f in voice.files) {
      await _downloadFile(voice.key, f, onProgress: (p) {
        // progress per file to overall progress approximation
        if (onProgress != null) {
          onProgress((done + p) / total);
        }
      });
      done += 1;
      onProgress?.call(done / total);
    }
  }

  /// Remove an installed voice.
  Future<void> removeVoice(String voiceKey) async {
    final dir = Directory(await _voiceDir(voiceKey));
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  /// Get local file path by remote URL for a voice (after install).
  Future<String?> getLocalPath(String voiceKey, String remoteUrl) async {
    final filePath = await _localPathFor(voiceKey, remoteUrl);
    return (await File(filePath).exists()) ? filePath : null;
  }

  /// Return all installed voice keys (best-effort by directory presence).
  Future<List<String>> listInstalled() async {
    await initialize();
    final modelsDir = Directory(p.join(_baseDir!.path, 'models'));
    if (!await modelsDir.exists()) return [];
    final entries = await modelsDir.list().toList();
    return entries.whereType<Directory>().map((e) => p.basename(e.path)).toList();
  }

  Future<void> _downloadFile(String voiceKey, VoiceFileMeta meta, {void Function(double progress)? onProgress}) async {
    final savePath = await _localPathFor(voiceKey, meta.url);
    final dir = Directory(p.dirname(savePath));
    if (!await dir.exists()) await dir.create(recursive: true);

    // If exists and checksum matches, skip
    final f = File(savePath);
    if (await f.exists()) {
      if (meta.md5.isNotEmpty && meta.md5.length == 32) {
        final ok = await _verifyMd5(f, meta.md5);
        if (ok) return;
      } else {
        // No checksum; rely on presence and (optionally) size heuristic
        if (meta.sizeBytes > 0) {
          final stat = await f.stat();
          if (stat.size == meta.sizeBytes) return;
        }
      }
    }

    await _dio.download(
      meta.url,
      savePath,
      onReceiveProgress: (received, total) {
        if (onProgress != null && total > 0) {
          onProgress(received / total);
        }
      },
      options: Options(responseType: ResponseType.bytes, followRedirects: true, receiveDataWhenStatusError: true),
    );

    // Verify if md5 provided
    if (meta.md5.isNotEmpty && meta.md5.length == 32) {
      final ok = await _verifyMd5(File(savePath), meta.md5);
      if (!ok) {
        try {
          await File(savePath).delete();
        } catch (_) {}
        throw Exception('Checksum mismatch for ${p.basename(savePath)}');
      }
    }
  }

  Future<bool> _verifyMd5(File file, String expectedMd5LowerHex) async {
    final bytes = await file.readAsBytes();
    final digest = crypto.md5.convert(bytes).toString();
    return digest.toLowerCase() == expectedMd5LowerHex.toLowerCase();
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    if (it.moveNext()) return it.current;
    return null;
  }
}
