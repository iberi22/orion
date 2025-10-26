import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_config.dart';

class SecureConfigService {
  static const _kGeminiApiKey = 'gemini_api_key';

  static final FlutterSecureStorage _secure = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  /// Returns the Gemini API key from secure storage if present, otherwise from .env
  static Future<String> getGeminiApiKey() async {
    try {
      final v = await _secure.read(key: _kGeminiApiKey);
      if (v != null && v.isNotEmpty) return v;
    } catch (e) {
      if (kDebugMode) print('SecureConfigService read error: $e');
    }
    // Fallback to .env
    return AppConfig.geminiApiKey;
  }

  static Future<void> setGeminiApiKey(String key) async {
    await _secure.write(key: _kGeminiApiKey, value: key.trim());
  }

  /// Optional: persist last-used TTS voice/provider in plain prefs
  static Future<void> setStringPref(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<String?> getStringPref(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }
}
