import 'package:flutter/services.dart';

class SystemChannel {
  static const MethodChannel _channel = MethodChannel('orion.system');

  static Future<String?> getApkPath() async {
    try {
      final path = await _channel.invokeMethod<String>('getApkPath');
      return path;
    } catch (e) {
      return null;
    }
  }
}
