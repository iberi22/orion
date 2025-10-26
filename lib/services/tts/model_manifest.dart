import 'dart:convert';

/// Voice file metadata for a TTS model asset.
class VoiceFileMeta {
  /// Remote URL to download the file.
  final String url;

  /// Expected MD5 checksum in hex lowercase.
  final String md5;

  /// Expected file size in bytes.
  final int sizeBytes;

  const VoiceFileMeta({required this.url, required this.md5, required this.sizeBytes});

  factory VoiceFileMeta.fromJson(Map<String, dynamic> json) => VoiceFileMeta(
        url: json['url'] as String,
        md5: json['md5'] as String,
        sizeBytes: (json['size_bytes'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {
        'url': url,
        'md5': md5,
        'size_bytes': sizeBytes,
      };
}

/// Voice entry describing all artifacts needed for synthesis.
class VoiceEntry {
  /// Unique key, e.g. "es_ES-mls_10246-low".
  final String key;

  /// BCP-47 language code, e.g. "es-ES".
  final String language;

  /// Quality tier or model family tag, e.g. "low", "medium".
  final String quality;

  /// Model files (e.g., onnx, config, maybe vocoder) required to run.
  final List<VoiceFileMeta> files;

  const VoiceEntry({
    required this.key,
    required this.language,
    required this.quality,
    required this.files,
  });

  factory VoiceEntry.fromJson(Map<String, dynamic> json) => VoiceEntry(
        key: json['key'] as String,
        language: json['language'] as String,
        quality: json['quality'] as String,
        files: (json['files'] as List<dynamic>)
            .map((e) => VoiceFileMeta.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'key': key,
        'language': language,
        'quality': quality,
        'files': files.map((e) => e.toJson()).toList(),
      };
}

/// Manifest describing available on-device TTS voices.
class TTSModelManifest {
  final List<VoiceEntry> voices;

  const TTSModelManifest({required this.voices});

  factory TTSModelManifest.empty() => const TTSModelManifest(voices: []);

  factory TTSModelManifest.fromJson(Map<String, dynamic> json) => TTSModelManifest(
        voices: (json['voices'] as List<dynamic>? ?? [])
            .map((e) => VoiceEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'voices': voices.map((e) => e.toJson()).toList(),
      };

  static TTSModelManifest parse(String jsonString) {
    return TTSModelManifest.fromJson(json.decode(jsonString) as Map<String, dynamic>);
  }

  String stringify() => json.encode(toJson());
}
