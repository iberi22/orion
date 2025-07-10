import 'dart:async';
import 'dart:io';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:isar_agent_memory/isar_agent_memory.dart';

class VoiceChatScreen extends StatefulWidget {
  const VoiceChatScreen({super.key});

  @override
  State<VoiceChatScreen> createState() => _VoiceChatScreenState();
}

class _VoiceChatScreenState extends State<VoiceChatScreen> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  String _aiResponse = '';

  late final GenerativeModel _model;
  late final ChatSession _chat;

  late final IsarAgentMemory _memory;
  late final GeminiEmbeddingsAdapter _embeddingsAdapter;

  @override
  void initState() {
    super.initState();
    _initRecorder();

    // Initialize the Generative Model
    _model = FirebaseVertexAI.instance.generativeModel(
      model: 'gemini-pro-vision',
      generationConfig: GenerationConfig(maxOutputTokens: 2048),
    );
    _chat = _model.startChat();

    // Initialize Agent Memory
    // Initialize Agent Memory
    _embeddingsAdapter = GeminiEmbeddingsAdapter(apiKey: const String.fromEnvironment('GEMINI_API_KEY'));
    _memory = IsarAgentMemory(embeddingsAdapter: _embeddingsAdapter);
    _memory.init();
  }

  Future<void> _initRecorder() async {
    await _recorder.openRecorder();
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  Future<void> _startRecording() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      print('Microphone permission not granted');
      return;
    }
    await _recorder.startRecorder(toFile: 'audio.aac');
    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stopRecorder();
    if (path == null) return;

    final file = File(path);
    final audioBytes = await file.readAsBytes();

    setState(() {
      _isRecording = false;
    });

    try {
      // 1. First, get a transcription of the audio
      final transcriptionResponse = await _chat.sendMessage(
        Content.multi([
          TextPart('Transcribe this audio.'),
          DataPart('audio/aac', audioBytes),
        ]),
      );
      final userQuery = transcriptionResponse.text ?? 'Could not transcribe audio.';
      print('Transcription: $userQuery');

      // 2. Search for relevant context in memory using the transcription
      final memories = await _memory.search(query: userQuery, limit: 3);

      // 3. Build a prompt with the retrieved context
      final context = memories.map((m) => 'User: ${m.input}\nAI: ${m.output}').join('\n\n');
      final prompt = 'Use the following context from our past conversation to answer the new question.\n\nContext:\n$context\n\nNew Question: $userQuery';

      // 4. Send the enhanced prompt to the AI to get a conversational response
      final finalResponse = await _chat.sendMessage(Content.text(prompt));

      final newAiResponse = finalResponse.text ?? 'No response from AI.';
      setState(() {
        _aiResponse = newAiResponse;
      });
      print('AI Response: $newAiResponse');

      // 5. Save the new interaction (transcription and response) to memory
      await _memory.add(input: userQuery, output: newAiResponse);

    } catch (e) {
      print('Error during AI interaction: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return shadcn.Scaffold(
      header: shadcn.AppBar(
        title: const Text('Voice Chat'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTapDown: (_) => _startRecording(),
              onTapUp: (_) => _stopRecording(),
              onTapCancel: () => _stopRecording(),
              child: shadcn.Button.primary(
                onPressed: () {},
                child: Text(_isRecording ? 'Recording...' : 'Push to Talk'),
              ),
            ),
            if (_aiResponse.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(_aiResponse),
              ),
          ],
        ),
      ),
    );
  }
}
