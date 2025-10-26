import 'dart:async';
import 'package:flutter/foundation.dart';

/// Reactive state management for voice chat functionality
class VoiceChatState extends ChangeNotifier {
  static final VoiceChatState _instance = VoiceChatState._internal();
  factory VoiceChatState() => _instance;
  VoiceChatState._internal();

  // Private state variables
  VoiceChatStatus _status = VoiceChatStatus.idle;
  String _statusMessage = 'Listo para conversar';
  String _currentTranscription = '';
  String _currentAiResponse = '';
  String? _errorMessage;
  Duration _recordingDuration = Duration.zero;
  bool _isMemoryAvailable = false;
  int _memoryCount = 0;
  List<ConversationTurn> _conversationHistory = [];

  // Stream controllers for real-time updates
  final StreamController<VoiceChatStatus> _statusController =
      StreamController<VoiceChatStatus>.broadcast();
  final StreamController<String> _transcriptionController =
      StreamController<String>.broadcast();
  final StreamController<String> _responseController =
      StreamController<String>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();
  final StreamController<List<ConversationTurn>> _historyController =
      StreamController<List<ConversationTurn>>.broadcast();

  // Public getters
  VoiceChatStatus get status => _status;
  String get statusMessage => _statusMessage;
  String get currentTranscription => _currentTranscription;
  String get currentAiResponse => _currentAiResponse;
  String? get errorMessage => _errorMessage;
  Duration get recordingDuration => _recordingDuration;
  bool get isMemoryAvailable => _isMemoryAvailable;
  int get memoryCount => _memoryCount;
  List<ConversationTurn> get conversationHistory =>
      List.unmodifiable(_conversationHistory);

  // Public streams
  Stream<VoiceChatStatus> get statusStream => _statusController.stream;
  Stream<String> get transcriptionStream => _transcriptionController.stream;
  Stream<String> get responseStream => _responseController.stream;
  Stream<String> get errorStream => _errorController.stream;
  Stream<List<ConversationTurn>> get historyStream => _historyController.stream;

  // Computed getters
  bool get isIdle => _status == VoiceChatStatus.idle;
  bool get isRecording => _status == VoiceChatStatus.recording;
  bool get isProcessing => _status == VoiceChatStatus.processing;
  bool get isSpeaking => _status == VoiceChatStatus.speaking;
  bool get hasError => _status == VoiceChatStatus.error;
  bool get canStartRecording =>
      _status == VoiceChatStatus.idle || _status == VoiceChatStatus.completed;
  bool get canStopRecording => _status == VoiceChatStatus.recording;
  bool get canInterrupt => _status == VoiceChatStatus.speaking;

  /// Update the current status
  void updateStatus(VoiceChatStatus newStatus, {String? message}) {
    if (_status == newStatus && message == null) return;

    _status = newStatus;
    if (message != null) {
      _statusMessage = message;
    } else {
      _statusMessage = _getDefaultStatusMessage(newStatus);
    }

    _statusController.add(_status);
    notifyListeners();

    if (kDebugMode) {
      print('VoiceChatState: Status changed to $_status - $_statusMessage');
    }
  }

  /// Update recording duration
  void updateRecordingDuration(Duration duration) {
    _recordingDuration = duration;
    notifyListeners();
  }

  /// Update transcription
  void updateTranscription(String transcription) {
    _currentTranscription = transcription;
    _transcriptionController.add(transcription);
    notifyListeners();

    if (kDebugMode) {
      print(
        'VoiceChatState: Transcription updated: ${transcription.substring(0, transcription.length.clamp(0, 50))}...',
      );
    }
  }

  /// Update AI response
  void updateAiResponse(String response) {
    _currentAiResponse = response;
    _responseController.add(response);
    notifyListeners();

    if (kDebugMode) {
      print(
        'VoiceChatState: AI response updated: ${response.substring(0, response.length.clamp(0, 50))}...',
      );
    }
  }

  /// Set error message
  void setError(String error) {
    _errorMessage = error;
    _status = VoiceChatStatus.error;
    _statusMessage = 'Error: $error';

    _errorController.add(error);
    _statusController.add(_status);
    notifyListeners();

    if (kDebugMode) {
      print('VoiceChatState: Error set: $error');
    }
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    if (_status == VoiceChatStatus.error) {
      updateStatus(VoiceChatStatus.idle);
    }
    notifyListeners();
  }

  /// Update memory availability
  void updateMemoryStatus(bool isAvailable, int count) {
    _isMemoryAvailable = isAvailable;
    _memoryCount = count;
    notifyListeners();

    if (kDebugMode) {
      print(
        'VoiceChatState: Memory status - Available: $isAvailable, Count: $count',
      );
    }
  }

  /// Add conversation turn to history
  void addConversationTurn(String userInput, String aiResponse) {
    final turn = ConversationTurn(
      userInput: userInput,
      aiResponse: aiResponse,
      timestamp: DateTime.now(),
    );

    _conversationHistory.add(turn);
    _historyController.add(List.unmodifiable(_conversationHistory));
    notifyListeners();

    if (kDebugMode) {
      print(
        'VoiceChatState: Added conversation turn. Total: ${_conversationHistory.length}',
      );
    }
  }

  /// Clear conversation history
  void clearHistory() {
    _conversationHistory.clear();
    _historyController.add(List.unmodifiable(_conversationHistory));
    notifyListeners();

    if (kDebugMode) {
      print('VoiceChatState: Conversation history cleared');
    }
  }

  /// Reset to initial state
  void reset() {
    _status = VoiceChatStatus.idle;
    _statusMessage = 'Listo para conversar';
    _currentTranscription = '';
    _currentAiResponse = '';
    _errorMessage = null;
    _recordingDuration = Duration.zero;

    _statusController.add(_status);
    notifyListeners();

    if (kDebugMode) {
      print('VoiceChatState: State reset to initial values');
    }
  }

  /// Get default status message for a given status
  String _getDefaultStatusMessage(VoiceChatStatus status) {
    switch (status) {
      case VoiceChatStatus.idle:
        return 'Listo para conversar';
      case VoiceChatStatus.recording:
        return 'Grabando...';
      case VoiceChatStatus.processing:
        return 'Procesando...';
      case VoiceChatStatus.speaking:
        return 'Hablando...';
      case VoiceChatStatus.completed:
        return 'Conversación completada';
      case VoiceChatStatus.error:
        return 'Error en la conversación';
    }
  }

  /// Dispose of resources
  @override
  void dispose() {
    _statusController.close();
    _transcriptionController.close();
    _responseController.close();
    _errorController.close();
    _historyController.close();
    super.dispose();
  }
}

/// Voice chat status enumeration
enum VoiceChatStatus { idle, recording, processing, speaking, completed, error }

/// Represents a single conversation turn
class ConversationTurn {
  final String userInput;
  final String aiResponse;
  final DateTime timestamp;

  ConversationTurn({
    required this.userInput,
    required this.aiResponse,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'ConversationTurn(user: ${userInput.substring(0, userInput.length.clamp(0, 30))}..., '
        'ai: ${aiResponse.substring(0, aiResponse.length.clamp(0, 30))}..., '
        'time: $timestamp)';
  }
}
