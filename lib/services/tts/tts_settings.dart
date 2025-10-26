import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_config.dart';

/// Stores and retrieves user TTS preferences.
class TTSSettings {
  static const _kPreferredVoice = 'preferred_tts_voice';

  /// Returns the preferred voice or defaults to AppConfig.ttsVoice.
  static Future<String> getPreferredVoice() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_kPreferredVoice) ?? AppConfig.ttsVoice;
    } catch (_) {
      // In tests or restricted envs, fall back to AppConfig.
      return AppConfig.ttsVoice;
    }
  }

  /// Sets the preferred voice.
  static Future<void> setPreferredVoice(String voiceKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPreferredVoice, voiceKey);
  }
}
