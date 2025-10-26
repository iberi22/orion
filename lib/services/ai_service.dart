import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:orion/config/app_config.dart';
import 'package:orion/utils/input_validator.dart';

/// Enhanced AI Service with Vertex AI integration for speech transcription
/// and conversational AI capabilities
class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  // AI Models
  GenerativeModel? _textModel;
  GenerativeModel? _multimodalModel;
  ChatSession? _chatSession;

  // State management
  bool _isInitialized = false;
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();
  final StreamController<AIServiceState> _stateController =
      StreamController<AIServiceState>.broadcast();

  // Configuration (loaded from AppConfig)
  int get _maxRetries => AppConfig.aiMaxRetries;
  Duration get _requestTimeout => Duration(seconds: AppConfig.aiRequestTimeout);
  int get _maxTokens => AppConfig.maxAiTokens;
  double get _textTemperature => AppConfig.aiTextTemperature;
  double get _transcriptionTemperature => AppConfig.aiTranscriptionTemperature;

  // Getters
  bool get isInitialized => _isInitialized;
  Stream<String> get errorStream => _errorController.stream;
  Stream<AIServiceState> get stateStream => _stateController.stream;

  /// Initialize the AI service with Vertex AI models
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _stateController.add(AIServiceState.initializing);

      // Initialize text generation model
      _textModel = FirebaseAI.googleAI().generativeModel(
        model: 'gemini-1.5-flash',
        generationConfig: GenerationConfig(
          maxOutputTokens: _maxTokens,
          temperature: _textTemperature,
          topP: 0.8,
          topK: 40,
        ),
      );

      // Initialize multimodal model for audio transcription
      _multimodalModel = FirebaseAI.googleAI().generativeModel(
        model: 'gemini-1.5-flash',
        generationConfig: GenerationConfig(
          maxOutputTokens: _maxTokens,
          temperature:
              _transcriptionTemperature, // Lower temperature for more accurate transcription
          topP: 0.9,
        ),
      );

      // Start chat session
      _chatSession = _textModel!.startChat();

      _isInitialized = true;
      _stateController.add(AIServiceState.ready);

      if (kDebugMode) {
        print('AIService: Initialized successfully with Vertex AI');
      }
    } catch (e) {
      _errorController.add('Failed to initialize AI service: $e');
      _stateController.add(AIServiceState.error);
      if (kDebugMode) {
        print('AIService Initialization Error: $e');
      }
      rethrow;
    }
  }

  /// Transcribe audio to text using Vertex AI multimodal capabilities
  Future<String> transcribeAudio(
    Uint8List audioBytes, {
    String? language,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_multimodalModel == null) {
      throw Exception('Multimodal model not initialized');
    }

    // Validate inputs
    final audioValidation = InputValidator.validateAudioData(audioBytes);
    if (!audioValidation.isValid) {
      throw ValidationException(audioValidation.error!);
    }

    final languageValidation = InputValidator.validateLanguage(language);
    if (!languageValidation.isValid) {
      throw ValidationException(languageValidation.error!);
    }

    try {
      _stateController.add(AIServiceState.transcribing);

      final transcriptionPrompt = _buildTranscriptionPrompt(
        languageValidation.data,
      );

      final response = await _executeWithRetry(() async {
        return await _multimodalModel!.generateContent([
          Content.multi([
            TextPart(transcriptionPrompt),
            InlineDataPart('audio/aac', audioValidation.dataOrThrow),
          ]),
        ]);
      });

      final transcription = response.text?.trim();

      if (transcription == null || transcription.isEmpty) {
        throw Exception('Empty transcription response');
      }

      // Validate AI response
      final responseValidation = InputValidator.validateAIResponse(
        transcription,
      );
      if (!responseValidation.isValid) {
        throw ValidationException(
          'Invalid AI response: ${responseValidation.error}',
        );
      }

      // Validate transcription quality
      if (_isValidTranscription(responseValidation.dataOrThrow)) {
        _stateController.add(AIServiceState.ready);

        if (kDebugMode) {
          print(
            'AIService: Transcription successful: ${responseValidation.dataOrThrow.substring(0, responseValidation.dataOrThrow.length.clamp(0, 50))}...',
          );
        }

        return responseValidation.dataOrThrow;
      } else {
        throw Exception('Invalid transcription quality');
      }
    } catch (e) {
      _errorController.add('Transcription failed: $e');
      _stateController.add(AIServiceState.error);

      if (kDebugMode) {
        print('AIService Transcription Error: $e');
      }

      // Try fallback transcription method
      return await _fallbackTranscription(audioBytes, language);
    }
  }

  /// Fallback transcription method when primary AI fails
  Future<String> _fallbackTranscription(
    Uint8List audioBytes,
    String? language,
  ) async {
    try {
      if (kDebugMode) {
        print('AIService: Attempting fallback transcription');
      }

      // Try with a simpler prompt
      final simplePrompt = 'Convert this audio to text:';

      final response = await _multimodalModel!
          .generateContent([
            Content.multi([
              TextPart(simplePrompt),
              InlineDataPart('audio/aac', audioBytes),
            ]),
          ])
          .timeout(Duration(seconds: 15)); // Shorter timeout for fallback

      final transcription = response.text?.trim();

      if (transcription != null &&
          transcription.isNotEmpty &&
          transcription.length > 2) {
        _stateController.add(AIServiceState.ready);

        if (kDebugMode) {
          print('AIService: Fallback transcription successful');
        }

        return transcription;
      }
    } catch (e) {
      if (kDebugMode) {
        print('AIService: Fallback transcription also failed: $e');
      }
    }

    // Final fallback - return helpful error message
    _stateController.add(AIServiceState.ready);
    return _getFallbackTranscriptionMessage(language);
  }

  /// Get appropriate fallback message based on language
  String _getFallbackTranscriptionMessage(String? language) {
    if (language?.toLowerCase().contains('english') == true) {
      return 'Could not transcribe audio. Please try speaking more clearly.';
    }
    return 'No se pudo transcribir el audio. Por favor, intenta hablar más claro.';
  }

  /// Generate AI response for conversational chat
  Future<String> getResponse(String promptText, {List<String>? context}) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_chatSession == null) {
      throw Exception('Chat session not initialized');
    }

    // Validate inputs
    final promptValidation = InputValidator.validateAIPrompt(promptText);
    if (!promptValidation.isValid) {
      throw ValidationException(promptValidation.error!);
    }

    final contextValidation = InputValidator.validateContext(context);
    if (!contextValidation.isValid) {
      throw ValidationException(contextValidation.error!);
    }

    try {
      _stateController.add(AIServiceState.generating);

      // Build enhanced prompt with context
      final enhancedPrompt = _buildConversationalPrompt(
        promptValidation.dataOrThrow,
        contextValidation.dataOrThrow,
      );

      final response = await _executeWithRetry(() async {
        return await _chatSession!.sendMessage(Content.text(enhancedPrompt));
      });

      final aiResponse = response.text?.trim();

      if (aiResponse == null || aiResponse.isEmpty) {
        throw Exception('Empty AI response');
      }

      // Validate AI response
      final responseValidation = InputValidator.validateAIResponse(aiResponse);
      if (!responseValidation.isValid) {
        throw ValidationException(
          'Invalid AI response: ${responseValidation.error}',
        );
      }

      _stateController.add(AIServiceState.ready);

      if (kDebugMode) {
        print(
          'AIService: Generated response: ${responseValidation.dataOrThrow.substring(0, responseValidation.dataOrThrow.length.clamp(0, 50))}...',
        );
      }

      return responseValidation.dataOrThrow;
    } catch (e) {
      _errorController.add('AI response generation failed: $e');
      _stateController.add(AIServiceState.error);

      if (kDebugMode) {
        print('AIService Response Error: $e');
      }

      // Try fallback response generation
      return await _fallbackResponse(promptText, context);
    }
  }

  /// Fallback response generation when primary AI fails
  Future<String> _fallbackResponse(
    String promptText,
    List<String>? context,
  ) async {
    try {
      if (kDebugMode) {
        print('AIService: Attempting fallback response generation');
      }

      // Try with a simpler prompt without context
      final simplePrompt = 'Responde brevemente en español: $promptText';

      final response = await _textModel!
          .generateContent([Content.text(simplePrompt)])
          .timeout(Duration(seconds: 10)); // Shorter timeout for fallback

      final aiResponse = response.text?.trim();

      if (aiResponse != null &&
          aiResponse.isNotEmpty &&
          aiResponse.length > 5) {
        _stateController.add(AIServiceState.ready);

        if (kDebugMode) {
          print('AIService: Fallback response successful');
        }

        return aiResponse;
      }
    } catch (e) {
      if (kDebugMode) {
        print('AIService: Fallback response also failed: $e');
      }
    }

    // Final fallback - return predefined helpful responses
    _stateController.add(AIServiceState.ready);
    return _getPredefinedResponse(promptText);
  }

  /// Get predefined response based on input patterns
  String _getPredefinedResponse(String input) {
    final lowerInput = input.toLowerCase();

    if (lowerInput.contains('hola') || lowerInput.contains('hello')) {
      return '¡Hola! ¿En qué puedo ayudarte hoy?';
    }

    if (lowerInput.contains('gracias') || lowerInput.contains('thank')) {
      return '¡De nada! Siempre es un placer ayudarte.';
    }

    if (lowerInput.contains('adiós') || lowerInput.contains('bye')) {
      return '¡Hasta luego! Que tengas un buen día.';
    }

    if (lowerInput.contains('ayuda') || lowerInput.contains('help')) {
      return 'Estoy aquí para ayudarte. ¿Qué necesitas saber?';
    }

    if (lowerInput.contains('tiempo') || lowerInput.contains('weather')) {
      return 'No tengo acceso a información del tiempo en tiempo real, pero espero que tengas un buen día.';
    }

    if (lowerInput.contains('nombre') || lowerInput.contains('name')) {
      return 'Soy tu asistente de voz. ¿Cómo puedo ayudarte?';
    }

    // Default fallback
    return 'Lo siento, estoy teniendo dificultades técnicas en este momento. Por favor, intenta reformular tu pregunta o inténtalo de nuevo más tarde.';
  }

  /// Execute operation with retry logic and timeout
  Future<T> _executeWithRetry<T>(Future<T> Function() operation) async {
    int attempts = 0;
    Exception? lastException;

    while (attempts < _maxRetries) {
      try {
        return await operation().timeout(_requestTimeout);
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        attempts++;

        // Check if this is a retryable error
        if (!_isRetryableError(e)) {
          if (kDebugMode) {
            print('AIService: Non-retryable error encountered: $e');
          }
          break;
        }

        if (attempts < _maxRetries) {
          final delay = Duration(seconds: attempts * 2); // Exponential backoff
          await Future.delayed(delay);

          if (kDebugMode) {
            print('AIService: Retry attempt $attempts after error: $e');
          }
        }
      }
    }

    throw lastException ??
        Exception('Operation failed after $attempts attempts');
  }

  /// Check if an error is retryable
  bool _isRetryableError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Network-related errors are retryable
    if (errorString.contains('network') ||
        errorString.contains('timeout') ||
        errorString.contains('connection') ||
        errorString.contains('socket')) {
      return true;
    }

    // Rate limiting errors are retryable
    if (errorString.contains('rate limit') ||
        errorString.contains('quota') ||
        errorString.contains('429')) {
      return true;
    }

    // Server errors (5xx) are retryable
    if (errorString.contains('500') ||
        errorString.contains('502') ||
        errorString.contains('503') ||
        errorString.contains('504')) {
      return true;
    }

    // Authentication errors are not retryable
    if (errorString.contains('unauthorized') ||
        errorString.contains('forbidden') ||
        errorString.contains('401') ||
        errorString.contains('403')) {
      return false;
    }

    // Invalid request errors are not retryable
    if (errorString.contains('400') ||
        errorString.contains('bad request') ||
        errorString.contains('invalid')) {
      return false;
    }

    // Default to retryable for unknown errors
    return true;
  }

  /// Build transcription prompt with language support
  String _buildTranscriptionPrompt(String? language) {
    final basePrompt =
        'Transcribe this audio to text accurately. Respond only with the transcribed text, no additional commentary or formatting.';

    if (language != null) {
      return '$basePrompt The audio is in $language language.';
    }

    return '$basePrompt Detect the language automatically and transcribe accordingly.';
  }

  /// Build conversational prompt with context
  String _buildConversationalPrompt(String userInput, List<String>? context) {
    final buffer = StringBuffer();

    if (context != null && context.isNotEmpty) {
      buffer.writeln('Context from previous conversations:');
      for (final contextItem in context.take(3)) {
        // Limit context to avoid token overflow
        buffer.writeln('- $contextItem');
      }
      buffer.writeln();
    }

    buffer.writeln('User: $userInput');
    buffer.writeln();
    buffer.writeln(
      'Please provide a helpful, conversational response in Spanish. Be concise but informative.',
    );

    return buffer.toString();
  }

  /// Validate transcription quality
  bool _isValidTranscription(String transcription) {
    // Basic validation rules
    if (transcription.length < 2) return false;
    if (transcription.toLowerCase().contains('no se pudo')) return false;
    if (transcription.toLowerCase().contains('error')) return false;

    // Check for reasonable character distribution
    final alphanumericCount =
        transcription.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').length;
    final totalLength = transcription.length;

    if (totalLength > 0 && alphanumericCount / totalLength < 0.3) {
      return false; // Too many special characters
    }

    return true;
  }

  /// Reset chat session
  Future<void> resetChatSession() async {
    if (_textModel != null) {
      _chatSession = _textModel!.startChat();

      if (kDebugMode) {
        print('AIService: Chat session reset');
      }
    }
  }

  /// Dispose resources
  void dispose() {
    _errorController.close();
    _stateController.close();
    _isInitialized = false;

    if (kDebugMode) {
      print('AIService: Disposed');
    }
  }
}

/// AI Service state enumeration
enum AIServiceState {
  uninitialized,
  initializing,
  ready,
  transcribing,
  generating,
  error,
}
