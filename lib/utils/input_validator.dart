import 'dart:typed_data';
import 'package:flutter/foundation.dart';

/// Input validation and sanitization utilities
/// Provides security validation for user inputs, audio data, and AI responses
class InputValidator {
  // Constants for validation limits
  static const int maxTextLength = 10000;
  static const int maxAudioSizeBytes = 50 * 1024 * 1024; // 50MB
  static const int minAudioSizeBytes = 1024; // 1KB
  static const int maxPromptLength = 2000;
  static const int maxContextItems = 10;
  static const int maxContextItemLength = 500;

  /// Validate and sanitize user text input
  static ValidationResult<String> validateUserInput(String? input) {
    if (input == null) {
      return ValidationResult.error('Input cannot be null');
    }

    // Trim whitespace
    final trimmed = input.trim();

    // Check length
    if (trimmed.isEmpty) {
      return ValidationResult.error('Input cannot be empty');
    }

    if (trimmed.length > maxTextLength) {
      return ValidationResult.error('Input too long (max $maxTextLength characters)');
    }

    // Check for potentially malicious content
    if (_containsSuspiciousContent(trimmed)) {
      return ValidationResult.error('Input contains potentially unsafe content');
    }

    // Sanitize the input
    final sanitized = _sanitizeText(trimmed);

    return ValidationResult.success(sanitized);
  }

  /// Validate audio data
  static ValidationResult<Uint8List> validateAudioData(Uint8List? audioData) {
    if (audioData == null) {
      return ValidationResult.error('Audio data cannot be null');
    }

    // Check size limits
    if (audioData.length < minAudioSizeBytes) {
      return ValidationResult.error('Audio data too small (min ${minAudioSizeBytes} bytes)');
    }

    if (audioData.length > maxAudioSizeBytes) {
      return ValidationResult.error('Audio data too large (max ${maxAudioSizeBytes ~/ (1024 * 1024)}MB)');
    }

    // Basic audio format validation
    if (!_isValidAudioFormat(audioData)) {
      return ValidationResult.error('Invalid audio format');
    }

    return ValidationResult.success(audioData);
  }

  /// Validate AI prompt
  static ValidationResult<String> validateAIPrompt(String? prompt) {
    if (prompt == null) {
      return ValidationResult.error('Prompt cannot be null');
    }

    final trimmed = prompt.trim();

    if (trimmed.isEmpty) {
      return ValidationResult.error('Prompt cannot be empty');
    }

    if (trimmed.length > maxPromptLength) {
      return ValidationResult.error('Prompt too long (max $maxPromptLength characters)');
    }

    // Check for injection attempts
    if (_containsInjectionAttempts(trimmed)) {
      return ValidationResult.error('Prompt contains potentially unsafe content');
    }

    return ValidationResult.success(_sanitizeText(trimmed));
  }

  /// Validate context list for AI
  static ValidationResult<List<String>> validateContext(List<String>? context) {
    if (context == null) {
      return ValidationResult.success(<String>[]);
    }

    if (context.length > maxContextItems) {
      return ValidationResult.error('Too many context items (max $maxContextItems)');
    }

    final validatedContext = <String>[];

    for (final item in context) {
      final trimmed = item.trim();
      
      if (trimmed.isEmpty) continue;

      if (trimmed.length > maxContextItemLength) {
        return ValidationResult.error('Context item too long (max $maxContextItemLength characters)');
      }

      if (_containsSuspiciousContent(trimmed)) {
        if (kDebugMode) {
          print('InputValidator: Skipping suspicious context item');
        }
        continue;
      }

      validatedContext.add(_sanitizeText(trimmed));
    }

    return ValidationResult.success(validatedContext);
  }

  /// Validate AI response
  static ValidationResult<String> validateAIResponse(String? response) {
    if (response == null) {
      return ValidationResult.error('AI response cannot be null');
    }

    final trimmed = response.trim();

    if (trimmed.isEmpty) {
      return ValidationResult.error('AI response cannot be empty');
    }

    if (trimmed.length > maxTextLength) {
      return ValidationResult.error('AI response too long');
    }

    // Check for potentially harmful content in AI response
    if (_containsHarmfulContent(trimmed)) {
      return ValidationResult.error('AI response contains potentially harmful content');
    }

    return ValidationResult.success(_sanitizeText(trimmed));
  }

  /// Validate language parameter
  static ValidationResult<String?> validateLanguage(String? language) {
    if (language == null) {
      return ValidationResult.success(null);
    }

    final trimmed = language.trim();
    
    if (trimmed.isEmpty) {
      return ValidationResult.success(null);
    }

    // Allow only common language codes
    final allowedLanguages = {
      'spanish', 'english', 'french', 'german', 'italian', 'portuguese',
      'es', 'en', 'fr', 'de', 'it', 'pt', 'auto'
    };

    if (!allowedLanguages.contains(trimmed.toLowerCase())) {
      return ValidationResult.error('Unsupported language: $trimmed');
    }

    return ValidationResult.success(trimmed.toLowerCase());
  }

  /// Check for suspicious content patterns
  static bool _containsSuspiciousContent(String text) {
    final suspiciousPatterns = [
      // Script injection patterns
      RegExp(r'<script[^>]*>', caseSensitive: false),
      RegExp(r'javascript:', caseSensitive: false),
      RegExp(r'on\w+\s*=', caseSensitive: false),
      
      // SQL injection patterns
      RegExp(r'(union|select|insert|update|delete|drop|create|alter)\s+', caseSensitive: false),
      RegExp(r"""['";].*['";]""", caseSensitive: false),
      
      // Command injection patterns
      RegExp(r'[;&|`$]', caseSensitive: false),
      RegExp(r'\.\./'),
      
      // Prompt injection patterns
      RegExp(r'ignore\s+(previous|all)\s+(instructions|prompts)', caseSensitive: false),
      RegExp(r'system\s*:', caseSensitive: false),
      RegExp(r'assistant\s*:', caseSensitive: false),
    ];

    return suspiciousPatterns.any((pattern) => pattern.hasMatch(text));
  }

  /// Check for injection attempts in prompts
  static bool _containsInjectionAttempts(String text) {
    final injectionPatterns = [
      // Prompt injection
      RegExp(r'ignore\s+(previous|all|above)\s+(instructions|prompts|rules)', caseSensitive: false),
      RegExp(r'forget\s+(everything|all|previous)', caseSensitive: false),
      RegExp(r'new\s+(instructions|prompt|system)', caseSensitive: false),
      RegExp(r'act\s+as\s+', caseSensitive: false),
      RegExp(r'pretend\s+(to\s+be|you\s+are)', caseSensitive: false),
      RegExp(r'roleplay\s+as', caseSensitive: false),
      
      // System prompts
      RegExp(r'system\s*:\s*', caseSensitive: false),
      RegExp(r'assistant\s*:\s*', caseSensitive: false),
      RegExp(r'user\s*:\s*', caseSensitive: false),
      
      // Escape sequences
      RegExp(r'\\n\\n', caseSensitive: false),
      RegExp(r'```', caseSensitive: false),
    ];

    return injectionPatterns.any((pattern) => pattern.hasMatch(text));
  }

  /// Check for harmful content in AI responses
  static bool _containsHarmfulContent(String text) {
    final harmfulPatterns = [
      // Personal information patterns
      RegExp(r'\b\d{3}-\d{2}-\d{4}\b'), // SSN
      RegExp(r'\b\d{4}\s?\d{4}\s?\d{4}\s?\d{4}\b'), // Credit card
      RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'), // Email (if not expected)
      
      // Potentially harmful instructions
      RegExp(r'(download|install|execute|run)\s+.*\.(exe|bat|sh|cmd)', caseSensitive: false),
      RegExp(r'visit\s+.*\.(com|org|net|io)', caseSensitive: false),
    ];

    return harmfulPatterns.any((pattern) => pattern.hasMatch(text));
  }

  /// Basic audio format validation
  static bool _isValidAudioFormat(Uint8List audioData) {
    if (audioData.length < 4) return false;

    // Check for common audio file signatures
    final header = audioData.take(4).toList();
    
    // AAC (common for web recording)
    if (header[0] == 0xFF && (header[1] & 0xF0) == 0xF0) return true;
    
    // WAV
    if (header[0] == 0x52 && header[1] == 0x49 && header[2] == 0x46 && header[3] == 0x46) return true;
    
    // MP3
    if (header[0] == 0xFF && (header[1] & 0xE0) == 0xE0) return true;
    
    // WebM/OGG
    if (header[0] == 0x1A && header[1] == 0x45 && header[2] == 0xDF && header[3] == 0xA3) return true;
    
    // Allow unknown formats but log warning
    if (kDebugMode) {
      print('InputValidator: Unknown audio format, allowing but monitoring');
    }
    
    return true;
  }

  /// Sanitize text by removing/escaping dangerous characters
  static String _sanitizeText(String text) {
    return text
        .replaceAll(RegExp(r'[<>]'), '') // Remove angle brackets
        .replaceAll(RegExp(r'[&]'), '&amp;') // Escape ampersands
        .replaceAll(RegExp(r'["]'), '&quot;') // Escape quotes
        .replaceAll(RegExp(r"[']"), '&#x27;') // Escape single quotes
        .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '') // Remove control characters
        .trim();
  }
}

/// Validation result wrapper
class ValidationResult<T> {
  final bool isValid;
  final T? data;
  final String? error;

  const ValidationResult._(this.isValid, this.data, this.error);

  factory ValidationResult.success(T data) {
    return ValidationResult._(true, data, null);
  }

  factory ValidationResult.error(String error) {
    return ValidationResult._(false, null, error);
  }

  /// Get the data or throw an exception if invalid
  T get dataOrThrow {
    if (!isValid) {
      throw ValidationException(error ?? 'Validation failed');
    }
    return data!;
  }
}

/// Custom exception for validation errors
class ValidationException implements Exception {
  final String message;
  
  const ValidationException(this.message);
  
  @override
  String toString() => 'ValidationException: $message';
}
