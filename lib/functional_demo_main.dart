// Functional Demo Main - Complete voice chat demo with real audio
//
// This demo integrates real audio functionality with the animated components

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:animate_gradient/animate_gradient.dart';
import 'package:orion/widgets/animated_agent_avatar.dart';
import 'package:orion/widgets/animated_chat_message.dart';
import 'package:orion/widgets/connection_status_indicator.dart';
import 'package:orion/widgets/audio_waveform_visualizer.dart';
import 'package:orion/widgets/volume_level_indicator.dart';
import 'package:orion/state/app_state_manager.dart';
import 'package:orion/services/audio_service.dart';
import 'package:orion/services/ai_service.dart';
import 'package:orion/utils/icon_fallbacks.dart';

void main() {
  // Add error handling for web
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kDebugMode) {
      print('Flutter Error: ${details.exception}');
      print('Stack trace: ${details.stack}');
    }
  };

  runApp(const FunctionalDemoApp());
}

class FunctionalDemoApp extends StatelessWidget {
  const FunctionalDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orion Voice Chat Demo',
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      home: const FunctionalDemoScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FunctionalDemoScreen extends StatefulWidget {
  const FunctionalDemoScreen({super.key});

  @override
  State<FunctionalDemoScreen> createState() => _FunctionalDemoScreenState();
}

class _FunctionalDemoScreenState extends State<FunctionalDemoScreen> {
  // Services
  final AudioService _audioService = AudioService();
  final AIService _aiService = AIService();
  final AppStateManager _appStateManager = AppStateManager();

  // State
  VoiceChatState _currentState = VoiceChatState.idle;
  ConnectionStatus _connectionStatus = ConnectionStatus.connected;
  String _statusMessage = 'Toca para hablar';
  bool _isInitialized = false;
  String? _errorMessage;

  // Audio visualization data
  List<double> _currentVolumeLevels = [];
  double _currentVolumeLevel = 0.0;

  // Messages for demo
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _setupListeners();
  }

  Future<void> _initializeServices() async {
    try {
      setState(() {
        _statusMessage = 'Inicializando servicios...';
      });

      // Initialize audio service
      await _audioService.initialize();

      // Initialize AI service
      await _aiService.initialize();

      // Initialize app state manager
      _appStateManager.initialize();

      // Set up audio stream listeners
      _setupListeners();

      setState(() {
        _isInitialized = true;
        _statusMessage = 'Listo para conversar';
        _connectionStatus = ConnectionStatus.connected;
      });

      if (kDebugMode) {
        print('FunctionalDemo: Services initialized successfully');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al inicializar: $e';
        _currentState = VoiceChatState.error;
        _connectionStatus = ConnectionStatus.error;
      });

      if (kDebugMode) {
        print('FunctionalDemo: Initialization failed: $e');
      }
    }
  }

  void _setupListeners() {
    // Listen to audio state changes
    _audioService.stateStream.listen((audioState) {
      if (mounted) {
        setState(() {
          switch (audioState) {
            case AudioState.recording:
              _currentState = VoiceChatState.listening;
              _statusMessage = 'Escuchando...';
              break;
            case AudioState.recordingStopped:
              _currentState = VoiceChatState.processing;
              _statusMessage = 'Procesando audio...';
              break;
            case AudioState.speaking:
              _currentState = VoiceChatState.speaking;
              _statusMessage = 'Hablando...';
              break;
            case AudioState.playbackCompleted:
            case AudioState.ttsStopped:
              _currentState = VoiceChatState.idle;
              _statusMessage = 'Toca para hablar';
              break;
            case AudioState.error:
              _currentState = VoiceChatState.error;
              _statusMessage = 'Error de audio';
              break;
            default:
              break;
          }
        });
      }
    });

    // Listen to audio errors
    _audioService.errorStream.listen((error) {
      if (mounted) {
        setState(() {
          _errorMessage = error;
          _currentState = VoiceChatState.error;
          _statusMessage = 'Error: $error';
        });
      }
    });

    // Listen to volume levels for waveform visualization
    _audioService.volumeLevelsStream.listen((levels) {
      if (mounted) {
        setState(() {
          _currentVolumeLevels = levels;
        });
      }
    });

    // Listen to current volume for volume indicator
    _audioService.currentVolumeStream.listen((volume) {
      if (mounted) {
        setState(() {
          _currentVolumeLevel = volume;
        });
      }
    });
  }

  Future<void> _handleVoiceInteraction() async {
    if (!_isInitialized) {
      _showSnackBar('Servicios no inicializados');
      return;
    }

    try {
      switch (_currentState) {
        case VoiceChatState.idle:
          await _startRecording();
          break;
        case VoiceChatState.listening:
          await _stopRecording();
          break;
        case VoiceChatState.speaking:
          await _stopSpeaking();
          break;
        default:
          _showSnackBar('No se puede interactuar en el estado actual');
          break;
      }
    } catch (e) {
      _showSnackBar('Error: $e');
      if (kDebugMode) {
        print('FunctionalDemo: Voice interaction error: $e');
      }
    }
  }

  Future<void> _startRecording() async {
    setState(() {
      _errorMessage = null;
    });

    await _audioService.startRecording();

    if (kDebugMode) {
      print('FunctionalDemo: Started recording');
    }
  }

  Future<void> _stopRecording() async {
    final audioBytes = await _audioService.stopRecording();

    if (audioBytes != null) {
      // Process real audio transcription and AI response
      await _processAudioInput(audioBytes);
    }

    if (kDebugMode) {
      print(
        'FunctionalDemo: Stopped recording, ${audioBytes?.length ?? 0} bytes',
      );
    }
  }

  Future<void> _stopSpeaking() async {
    await _audioService.stopAll();

    setState(() {
      _currentState = VoiceChatState.idle;
      _statusMessage = 'Toca para hablar';
    });

    if (kDebugMode) {
      print('FunctionalDemo: Stopped speaking');
    }
  }

  Future<void> _processAudioInput(Uint8List audioBytes) async {
    try {
      setState(() {
        _currentState = VoiceChatState.processing;
        _statusMessage = 'Transcribiendo audio...';
        _errorMessage = null;
      });

      // 1. Transcribe audio using AI
      final transcription = await _aiService.transcribeAudio(
        audioBytes,
        language: 'Spanish',
      );

      if (transcription.contains('No se pudo transcribir')) {
        setState(() {
          _errorMessage =
              'No se pudo transcribir el audio. Intenta hablar más claro.';
          _currentState = VoiceChatState.error;
          _statusMessage = 'Error en transcripción';
        });
        return;
      }

      setState(() {
        _statusMessage = 'Generando respuesta...';
      });

      // Add user message to chat
      _addMessage(transcription, MessageType.user);

      // 2. Get AI response
      final aiResponse = await _aiService.getResponse(transcription);

      setState(() {
        _currentState = VoiceChatState.speaking;
        _statusMessage = 'Hablando...';
      });

      // Add AI response to chat
      await Future.delayed(const Duration(milliseconds: 500));
      _addMessage(aiResponse, MessageType.agent);

      // 3. Speak the response
      await _audioService.speakText(aiResponse);

      setState(() {
        _currentState = VoiceChatState.idle;
        _statusMessage = 'Toca para hablar';
      });

      if (kDebugMode) {
        print('FunctionalDemo: Conversation completed successfully');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error durante la conversación: $e';
        _currentState = VoiceChatState.error;
        _statusMessage = 'Error';
      });

      if (kDebugMode) {
        print('FunctionalDemo: Audio processing error: $e');
      }
    }
  }

  void _addMessage(String text, MessageType type) {
    setState(() {
      _messages.add(
        ChatMessage(text: text, type: type, timestamp: DateTime.now()),
      );
    });

    // Auto-scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red[700]),
    );
  }

  void _clearMessages() {
    setState(() {
      _messages.clear();
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimateGradient(
        primaryBegin: Alignment.topLeft,
        primaryEnd: Alignment.bottomLeft,
        secondaryBegin: Alignment.bottomLeft,
        secondaryEnd: Alignment.topRight,
        primaryColors: const [
          Color(0xff1e2a78),
          Color(0xff4b3f91),
          Color(0xff8a4d9e),
        ],
        secondaryColors: const [
          Color(0xff8a4d9e),
          Color(0xff4b3f91),
          Color(0xff1e2a78),
        ],
        child: Column(
          children: [
            // AppBar personalizado
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Orion - Chat de Voz',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ConnectionStatusIndicator(
                      status: _connectionStatus,
                      showLabel: false,
                    ),
                  ],
                ),
              ),
            ),
            // Contenido principal
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Status info
                    if (kDebugMode) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DEBUG INFO',
                              style: TextStyle(
                                color: Colors.yellow,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'State: ${_currentState.name}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              'Connection: ${_connectionStatus.name}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              'Messages: ${_messages.length}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Chat messages
                    Expanded(
                      child:
                          _messages.isEmpty
                              ? Center(
                                child: Text(
                                  '¡Hola! Soy tu asistente de bienestar con IA. ¿En qué puedo ayudarte hoy?',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              )
                              : ListView.builder(
                                controller: _scrollController,
                                itemCount: _messages.length,
                                itemBuilder: (context, index) {
                                  final message = _messages[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: AnimatedChatMessage(
                                      message: message.text,
                                      type: message.type,
                                      isTyping: message.isTyping,
                                    ),
                                  );
                                },
                              ),
                    ),

                    const SizedBox(height: 24),

                    // Voice interaction area
                    Column(
                      children: [
                        // Visual feedback row
                        if (_currentState == VoiceChatState.listening ||
                            _currentState == VoiceChatState.processing)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Volume level indicator
                              VolumeLevelIndicator(
                                isActive:
                                    _currentState == VoiceChatState.listening,
                                volumeLevel: _currentVolumeLevel,
                                size: 60,
                                primaryColor: Colors.green,
                                warningColor: Colors.orange,
                                dangerColor: Colors.red,
                                style: VolumeIndicatorStyle.circular,
                              ),

                              // Audio waveform visualizer
                              AudioWaveformVisualizer(
                                isActive:
                                    _currentState == VoiceChatState.listening,
                                volumeLevels: _currentVolumeLevels,
                                height: 60,
                                width: 150,
                                primaryColor: Colors.blue,
                                secondaryColor: Colors.grey,
                                style: WaveformStyle.bars,
                              ),
                            ],
                          ),

                        if (_currentState == VoiceChatState.listening ||
                            _currentState == VoiceChatState.processing)
                          const SizedBox(height: 16),

                        // Agent Avatar
                        GestureDetector(
                          onTap: _handleVoiceInteraction,
                          child: AnimatedAgentAvatar(
                            chatState: _currentState,
                            size: 120,
                            primaryColor: Colors.blue,
                            secondaryColor: Colors.cyan,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Status message
                        Text(
                          _statusMessage,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        if (_errorMessage != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.red[300],
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Action buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _clearMessages,
                              icon: Icons.clear.toSmartIcon(),
                              label: const Text('Limpiar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[700],
                                foregroundColor: Colors.white,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () async {
                                await _audioService.speakText(
                                  'Hola, este es un mensaje de prueba para verificar que el audio funciona correctamente.',
                                );
                              },
                              icon: Icons.volume_up.toSmartIcon(),
                              label: const Text('Prueba TTS'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[700],
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _audioService.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final MessageType type;
  final DateTime timestamp;
  final bool isTyping;

  ChatMessage({
    required this.text,
    required this.type,
    required this.timestamp,
    this.isTyping = false,
  });
}
