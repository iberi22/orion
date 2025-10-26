import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application configuration management
/// Handles environment variables and app settings
class AppConfig {
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  // Safe env accessor to avoid NotInitializedError in tests
  static String? _env(String key) {
    try {
      return dotenv.env[key];
    } catch (_) {
      return null;
    }
  }

  // Firebase Configuration
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static String get firebaseProjectId =>
      dotenv.env['FIREBASE_PROJECT_ID'] ?? 'orion-d1229';

  // Vertex AI Configuration
  static String get vertexAiProjectId =>
      dotenv.env['VERTEX_AI_PROJECT_ID'] ?? 'orion-d1229';
  static String get vertexAiLocation =>
      dotenv.env['VERTEX_AI_LOCATION'] ?? 'us-central1';
  static String? get vertexAiServiceAccountKeyPath =>
      dotenv.env['VERTEX_AI_SERVICE_ACCOUNT_KEY_PATH'];

  // Development Configuration
  static bool get debugMode =>
      dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';

  // Audio Configuration
  static int get maxRecordingDuration =>
      int.tryParse(dotenv.env['MAX_RECORDING_DURATION'] ?? '60') ?? 60;
  static int get webAudioSampleRate =>
      int.tryParse(dotenv.env['WEB_AUDIO_SAMPLE_RATE'] ?? '44100') ?? 44100;
  static int get webAudioBitRate =>
      int.tryParse(dotenv.env['WEB_AUDIO_BIT_RATE'] ?? '128000') ?? 128000;
  static String get transcriptionAudioFormat =>
      dotenv.env['TRANSCRIPTION_AUDIO_FORMAT'] ?? 'aac';

  // TTS Configuration
  // provider: system | cloud | kitten (bridge) | ondevice | kitten_local (future)
  static String get ttsProvider {
    final v = _env('TTS_PROVIDER');
    if (v != null) return v.toLowerCase();
    // If no explicit provider is set, prefer cloud when a Gemini key is present in .env
    return geminiApiKey.isNotEmpty ? 'cloud' : 'system';
  }
  static int get ttsSampleRate =>
      int.tryParse(_env('TTS_SAMPLE_RATE') ?? '24000') ?? 24000;
  static String get ttsVoice => _env('TTS_VOICE') ?? 'Kore';
  static String? get kittenBridgeUrl => _env('KITTEN_BRIDGE_URL');

  // AI Configuration
  static int get maxAiTokens =>
      int.tryParse(dotenv.env['MAX_AI_TOKENS'] ?? '2048') ?? 2048;
  static int get aiRequestTimeout =>
      int.tryParse(dotenv.env['AI_REQUEST_TIMEOUT'] ?? '30') ?? 30;
  static int get aiMaxRetries =>
      int.tryParse(dotenv.env['AI_MAX_RETRIES'] ?? '3') ?? 3;
  static double get aiTextTemperature =>
      double.tryParse(dotenv.env['AI_TEXT_TEMPERATURE'] ?? '0.7') ?? 0.7;
  static double get aiTranscriptionTemperature =>
      double.tryParse(dotenv.env['AI_TRANSCRIPTION_TEMPERATURE'] ?? '0.1') ??
      0.1;

  // Memory Configuration
  static int get maxMemorySearchResults =>
      int.tryParse(dotenv.env['MAX_MEMORY_SEARCH_RESULTS'] ?? '5') ?? 5;

  // Web Audio Configuration
  static bool get webAudioEchoCancellation =>
      dotenv.env['WEB_AUDIO_ECHO_CANCELLATION']?.toLowerCase() != 'false';
  static bool get webAudioNoiseSuppression =>
      dotenv.env['WEB_AUDIO_NOISE_SUPPRESSION']?.toLowerCase() != 'false';
  static bool get webAudioAutoGainControl =>
      dotenv.env['WEB_AUDIO_AUTO_GAIN_CONTROL']?.toLowerCase() != 'false';

  /// Validate configuration
  static bool validateConfig() {
    final issues = <String>[];

    // Only require GEMINI_API_KEY when using cloud (Gemini TTS)
    if (ttsProvider == 'cloud' && geminiApiKey.isEmpty) {
      issues.add('GEMINI_API_KEY is required when TTS_PROVIDER=cloud');
    }

    if (vertexAiProjectId.isEmpty) {
      issues.add('VERTEX_AI_PROJECT_ID is required');
    }

    if (maxAiTokens <= 0) {
      issues.add('MAX_AI_TOKENS must be positive');
    }

    if (aiRequestTimeout <= 0) {
      issues.add('AI_REQUEST_TIMEOUT must be positive');
    }

    if (aiMaxRetries < 0) {
      issues.add('AI_MAX_RETRIES must be non-negative');
    }

    if (aiTextTemperature < 0.0 || aiTextTemperature > 1.0) {
      issues.add('AI_TEXT_TEMPERATURE must be between 0.0 and 1.0');
    }

    if (aiTranscriptionTemperature < 0.0 || aiTranscriptionTemperature > 1.0) {
      issues.add('AI_TRANSCRIPTION_TEMPERATURE must be between 0.0 and 1.0');
    }

    // TTS validation
    const allowedProviders = ['system', 'cloud', 'kitten', 'ondevice', 'kitten_local'];
    if (!allowedProviders.contains(ttsProvider)) {
      issues.add('TTS_PROVIDER must be one of: ${allowedProviders.join(', ')}');
    }
    if ((ttsProvider == 'kitten') &&
        (kittenBridgeUrl == null || kittenBridgeUrl!.isEmpty)) {
      issues.add('KITTEN_BRIDGE_URL is required when TTS_PROVIDER=kitten');
    }

    if (issues.isNotEmpty) {
      if (kDebugMode) {
        print('AppConfig validation issues:');
        for (final issue in issues) {
          print('  - $issue');
        }
      }
      return false;
    }

    return true;
  }

  /// Get configuration summary for debugging
  static Map<String, dynamic> getConfigSummary() {
    return {
      'firebase': {
        'projectId': firebaseProjectId,
        'hasGeminiKey': geminiApiKey.isNotEmpty,
      },
      'vertexAi': {
        'projectId': vertexAiProjectId,
        'location': vertexAiLocation,
        'hasServiceAccountKey': vertexAiServiceAccountKeyPath != null,
      },
      'audio': {
        'maxRecordingDuration': maxRecordingDuration,
        'sampleRate': webAudioSampleRate,
        'bitRate': webAudioBitRate,
        'format': transcriptionAudioFormat,
      },
      'tts': {
        'provider': ttsProvider,
        'sampleRate': ttsSampleRate,
        'voice': ttsVoice,
        'hasKittenBridgeUrl':
            kittenBridgeUrl != null && kittenBridgeUrl!.isNotEmpty,
      },
      'ai': {
        'maxTokens': maxAiTokens,
        'requestTimeout': aiRequestTimeout,
        'maxRetries': aiMaxRetries,
        'textTemperature': aiTextTemperature,
        'transcriptionTemperature': aiTranscriptionTemperature,
      },
      'webAudio': {
        'echoCancellation': webAudioEchoCancellation,
        'noiseSuppression': webAudioNoiseSuppression,
        'autoGainControl': webAudioAutoGainControl,
      },
      'debug': debugMode,
    };
  }

  /// Print configuration summary (debug mode only)
  static void printConfigSummary() {
    if (kDebugMode) {
      print('=== App Configuration Summary ===');
      final config = getConfigSummary();
      _printConfigSection('Firebase', config['firebase']);
      _printConfigSection('Vertex AI', config['vertexAi']);
      _printConfigSection('Audio', config['audio']);
      _printConfigSection('TTS', config['tts']);
      _printConfigSection('AI', config['ai']);
      _printConfigSection('Web Audio', config['webAudio']);
      print('Debug Mode: ${config['debug']}');
      print('================================');
    }
  }

  static void _printConfigSection(String title, Map<String, dynamic> section) {
    print('$title:');
    section.forEach((key, value) {
      print('  $key: $value');
    });
  }
}
