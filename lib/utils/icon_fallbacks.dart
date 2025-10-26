// Icon Fallbacks - Alternative icons for web compatibility
//
// Provides fallback solutions when Material Icons don't load properly

import 'package:flutter/material.dart';

class IconFallbacks {
  // Fallback icons using Unicode symbols
  static const Map<String, String> _unicodeIcons = {
    'psychology': '🧠',
    'mic': '🎤',
    'volume_up': '🔊',
    'hourglass_empty': '⏳',
    'error': '❌',
    'chat': '💬',
    'wifi': '📶',
    'wifi_off': '📵',
    'sync': '🔄',
    'lock': '🔒',
    'check_circle': '✅',
    'refresh': '🔄',
    'play_arrow': '▶️',
    'person': '👤',
    'cloud': '☁️',
    'star': '⭐',
    'add': '➕',
  };

  // Get fallback icon widget
  static Widget getFallbackIcon(
    IconData iconData, {
    double? size,
    Color? color,
  }) {
    final iconName = _getIconName(iconData);
    final unicodeIcon = _unicodeIcons[iconName];

    if (unicodeIcon != null) {
      return Text(
        unicodeIcon,
        style: TextStyle(fontSize: size ?? 24, color: color),
      );
    }

    // If no Unicode fallback, use a simple colored circle
    return Container(
      width: size ?? 24,
      height: size ?? 24,
      decoration: BoxDecoration(
        color: color ?? Colors.grey,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '?',
          style: TextStyle(
            color: Colors.white,
            fontSize: (size ?? 24) * 0.6,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Smart icon widget that tries Material Icon first, then fallback
  static Widget smartIcon(IconData iconData, {double? size, Color? color}) {
    return Builder(
      builder: (context) {
        try {
          // Try to use Material Icon
          return Icon(iconData, size: size, color: color);
        } catch (e) {
          // If Material Icon fails, use fallback
          return getFallbackIcon(iconData, size: size, color: color);
        }
      },
    );
  }

  // Extract icon name from IconData (simplified)
  static String _getIconName(IconData iconData) {
    // This is a simplified mapping - in a real app you'd want a more robust solution
    switch (iconData.codePoint) {
      case 0xe8b8:
        return 'psychology';
      case 0xe029:
        return 'mic';
      case 0xe050:
        return 'volume_up';
      case 0xe01b:
        return 'hourglass_empty';
      case 0xe000:
        return 'error';
      case 0xe0b7:
        return 'chat';
      case 0xe63e:
        return 'wifi';
      case 0xe648:
        return 'wifi_off';
      case 0xe627:
        return 'sync';
      case 0xe32a:
        return 'lock';
      case 0xe86c:
        return 'check_circle';
      case 0xe5d5:
        return 'refresh';
      case 0xe037:
        return 'play_arrow';
      case 0xe7fd:
        return 'person';
      case 0xe2bd:
        return 'cloud';
      case 0xe838:
        return 'star';
      case 0xe145:
        return 'add';
      default:
        return 'unknown';
    }
  }
}

// Extension to make it easier to use
extension IconDataExtension on IconData {
  Widget toSmartIcon({double? size, Color? color}) {
    return IconFallbacks.smartIcon(this, size: size, color: color);
  }

  Widget toFallbackIcon({double? size, Color? color}) {
    return IconFallbacks.getFallbackIcon(this, size: size, color: color);
  }
}
