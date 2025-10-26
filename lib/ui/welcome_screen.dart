import 'package:animate_gradient/animate_gradient.dart';
import 'package:flutter/material.dart' as material;
import 'package:orion/services/ai_service.dart';
import 'package:orion/ui/meditation_screen.dart';
import 'package:orion/ui/animated_voice_chat_demo.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import 'package:google_fonts/google_fonts.dart';

class PrimaryButton extends material.StatelessWidget {
  final material.Widget child;
  final material.VoidCallback? onPressed;

  const PrimaryButton({super.key, required this.child, this.onPressed});

  @override
  material.Widget build(material.BuildContext context) {
    return material.ElevatedButton(onPressed: onPressed, child: child);
  }
}

class GhostButton extends material.StatelessWidget {
  final material.Widget child;
  final material.VoidCallback? onPressed;

  const GhostButton({super.key, required this.child, this.onPressed});

  @override
  material.Widget build(material.BuildContext context) {
    return material.TextButton(onPressed: onPressed, child: child);
  }
}

class WelcomeScreen extends material.StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  material.State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends material.State<WelcomeScreen> {
  // State for the chat functionality
  final _promptController = material.TextEditingController();
  final _aiService = AIService();
  String? _response;
  bool _isLoading = false;
  String? _error;

  // State for UI view
  bool _isChatMode = false;

  Future<void> _getAIResponse() async {
    if (_promptController.text.isEmpty) {
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
      _response = null;
    });
    try {
      final response = await _aiService.getResponse(_promptController.text);
      setState(() {
        _response = response;
      });
    } catch (e) {
      setState(() {
        _error = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  material.Widget _buildWelcomeView() {
    return material.Column(
      key: const material.ValueKey('welcomeView'),
      mainAxisAlignment: material.MainAxisAlignment.center,
      children: [
        material.Text(
          'Orion',
          style: GoogleFonts.lato(
            fontSize: 48,
            fontWeight: material.FontWeight.bold,
            color: material.Colors.white,
          ),
        ),
        const material.SizedBox(height: 8),
        material.Text(
          'Bienvenido/a a tu espacio interior.',
          style: GoogleFonts.lato(
            fontSize: 18,
            color: material.Colors.white.withValues(alpha: 0.8),
          ),
        ),
        const material.SizedBox(height: 48),
        material.Expanded(
          child: material.ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildMeditationCard();
              } else if (index == 1) {
                return _buildExploreCard();
              } else if (index == 2) {
                return _buildCalmCard();
              } else if (index == 3) {
                return _buildVoiceChatCard();
              } else {
                return _buildAnimationDemoCard();
              }
            },
          ),
        ),
      ],
    );
  }

  material.Widget _buildMeditationCard() {
    return shadcn.Card(
      child: material.Container(
        color: material.Colors.white.withValues(alpha: 0.1),
        margin: const material.EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        padding: const material.EdgeInsets.all(24.0),
        child: material.Column(
          mainAxisAlignment: material.MainAxisAlignment.center,
          children: [
            material.Text(
              'Iniciar Meditación Guiada',
              style: GoogleFonts.lato(
                fontSize: 24,
                fontWeight: material.FontWeight.bold,
                color: material.Colors.white,
              ),
              textAlign: material.TextAlign.center,
            ),
            const material.SizedBox(height: 16),
            PrimaryButton(
              child: const material.Text('Comenzar'),
              onPressed: () {
                material.Navigator.of(context).push(
                  material.MaterialPageRoute(
                    builder: (context) => const MeditationScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  material.Widget _buildExploreCard() {
    return shadcn.Card(
      child: material.Container(
        color: material.Colors.white.withValues(alpha: 0.1),
        margin: const material.EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        padding: const material.EdgeInsets.all(24.0),
        child: material.Column(
          mainAxisAlignment: material.MainAxisAlignment.center,
          children: [
            material.Text(
              'Explorar un Tema',
              style: GoogleFonts.lato(
                fontSize: 24,
                fontWeight: material.FontWeight.bold,
                color: material.Colors.white,
              ),
              textAlign: material.TextAlign.center,
            ),
            const material.SizedBox(height: 16),
            PrimaryButton(
              child: const material.Text('Explorar'),
              onPressed: () => setState(() => _isChatMode = true),
            ),
          ],
        ),
      ),
    );
  }

  material.Widget _buildVoiceChatCard() {
    return shadcn.Card(
      child: material.Container(
        color: material.Colors.white.withValues(alpha: 0.1),
        margin: const material.EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        padding: const material.EdgeInsets.all(24.0),
        child: material.Column(
          mainAxisAlignment: material.MainAxisAlignment.center,
          children: [
            material.Text(
              'Conversar con la IA',
              style: GoogleFonts.lato(
                fontSize: 24,
                fontWeight: material.FontWeight.bold,
                color: material.Colors.white,
              ),
              textAlign: material.TextAlign.center,
            ),
            const material.SizedBox(height: 16),
            PrimaryButton(
              child: const material.Text('Iniciar Chat de Voz'),
              onPressed: () {
                // Temporarily disabled due to compilation issues
                // shadcn.Navigator.of(context).push(
                //   shadcn.MaterialPageRoute(
                //     builder: (context) => const VoiceChatScreen(),
                //   ),
                // );
                material.Navigator.of(context).push(
                  material.MaterialPageRoute(
                    builder: (context) => const AnimatedVoiceChatDemo(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  material.Widget _buildCalmCard() {
    return shadcn.Card(
      child: material.Container(
        color: material.Colors.white.withValues(alpha: 0.1),
        margin: const material.EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        padding: const material.EdgeInsets.all(24.0),
        child: material.Column(
          mainAxisAlignment: material.MainAxisAlignment.center,
          children: [
            material.Text(
              'Necesito un Momento de Calma',
              style: GoogleFonts.lato(
                fontSize: 24,
                fontWeight: material.FontWeight.bold,
                color: material.Colors.white,
              ),
              textAlign: material.TextAlign.center,
            ),
            const material.SizedBox(height: 16),
            PrimaryButton(
              child: const material.Text('Calmarme'),
              onPressed: () {
                // TODO: Implement a quick calming interaction
              },
            ),
          ],
        ),
      ),
    );
  }

  material.Widget _buildChatView() {
    return material.Column(
      key: const material.ValueKey('chatView'),
      mainAxisAlignment: material.MainAxisAlignment.center,
      children: [
        GhostButton(
          onPressed: () => setState(() => _isChatMode = false),
          child: const material.Row(
            mainAxisSize: material.MainAxisSize.min,
            children: [
              material.Icon(material.Icons.arrow_back, size: 16),
              material.SizedBox(width: 8),
              material.Text('Volver'),
            ],
          ),
        ),
        const material.SizedBox(height: 24),
        shadcn.TextField(
          controller: _promptController,
          placeholder: const material.Text(
            'Escribe tu pregunta o pensamiento...',
          ),
        ),
        const material.SizedBox(height: 24),
        PrimaryButton(
          onPressed: _isLoading ? null : _getAIResponse,
          child:
              _isLoading
                  ? const material.SizedBox(
                    width: 20,
                    height: 20,
                    child: material.CircularProgressIndicator(),
                  )
                  : const material.Text('Enviar a Orion'),
        ),
        const material.SizedBox(height: 24),
        if (_response != null)
          material.Container(
            padding: const material.EdgeInsets.all(16),
            decoration: material.BoxDecoration(
              color: material.Colors.grey.shade800,
              borderRadius: material.BorderRadius.circular(8.0),
            ),
            child: material.SelectableText(
              _response!,
              style: const material.TextStyle(
                fontSize: 16,
                color: material.Colors.white,
              ),
            ),
          ),
        if (_error != null)
          material.Text(
            _error!,
            style: const material.TextStyle(
              fontSize: 16,
              color: material.Colors.red,
            ),
          ),
      ],
    );
  }

  @override
  material.Widget build(material.BuildContext context) {
    return material.Scaffold(
      body: AnimateGradient(
        primaryBegin: material.Alignment.topLeft,
        primaryEnd: material.Alignment.bottomLeft,
        secondaryBegin: material.Alignment.bottomLeft,
        secondaryEnd: material.Alignment.topRight,
        primaryColors: const [
          material.Color(0xff1e2a78),
          material.Color(0xff4b3f91),
          material.Color(0xff8a4d9e),
        ],
        secondaryColors: const [
          material.Color(0xff8a4d9e),
          material.Color(0xff4b3f91),
          material.Color(0xff1e2a78),
        ],
        child: material.Center(
          child: material.SingleChildScrollView(
            child: material.Padding(
              padding: const material.EdgeInsets.all(24.0),
              child: material.AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return material.FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: _isChatMode ? _buildChatView() : _buildWelcomeView(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  material.Widget _buildAnimationDemoCard() {
    return shadcn.Card(
      child: material.Container(
        color: material.Colors.white.withValues(alpha: 0.1),
        margin: const material.EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        padding: const material.EdgeInsets.all(24.0),
        child: material.Column(
          mainAxisAlignment: material.MainAxisAlignment.center,
          children: [
            material.Icon(
              material.Icons.animation,
              size: 48,
              color: material.Colors.white,
            ),
            const material.SizedBox(height: 16),
            material.Text(
              'Demo Animaciones IA',
              style: GoogleFonts.lato(
                fontSize: 24,
                fontWeight: material.FontWeight.bold,
                color: material.Colors.white,
              ),
              textAlign: material.TextAlign.center,
            ),
            const material.SizedBox(height: 8),
            material.Text(
              'Explora las animaciones del agente conversacional',
              style: GoogleFonts.lato(
                fontSize: 16,
                color: material.Colors.white.withValues(alpha: 0.8),
              ),
              textAlign: material.TextAlign.center,
            ),
            const material.SizedBox(height: 16),
            PrimaryButton(
              child: const material.Text('Ver Demo'),
              onPressed: () {
                material.Navigator.of(context).push(
                  material.MaterialPageRoute(
                    builder: (context) => const AnimatedVoiceChatDemo(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }
}
