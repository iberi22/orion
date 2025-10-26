// Animated Agent Avatar Widget
//
// Provides animated visual feedback for AI agent states

import 'package:flutter/material.dart';
import 'package:orion/state/app_state_manager.dart';
import 'package:orion/utils/icon_fallbacks.dart';

class AnimatedAgentAvatar extends StatefulWidget {
  final VoiceChatState chatState;
  final double size;
  final Color primaryColor;
  final Color secondaryColor;

  const AnimatedAgentAvatar({
    super.key,
    required this.chatState,
    this.size = 120.0,
    this.primaryColor = Colors.blue,
    this.secondaryColor = Colors.cyan,
  });

  @override
  State<AnimatedAgentAvatar> createState() => _AnimatedAgentAvatarState();
}

class _AnimatedAgentAvatarState extends State<AnimatedAgentAvatar>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late AnimationController _waveController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _updateAnimationForState();
  }

  void _initializeAnimations() {
    // Pulse animation for listening state
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Rotation animation for processing state
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    // Scale animation for speaking state
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Wave animation for speaking state
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );
  }

  void _updateAnimationForState() {
    // Stop all animations first
    _pulseController.stop();
    _rotationController.stop();
    _scaleController.stop();
    _waveController.stop();

    switch (widget.chatState) {
      case VoiceChatState.listening:
        _pulseController.repeat(reverse: true);
        break;
      case VoiceChatState.processing:
        _rotationController.repeat();
        break;
      case VoiceChatState.speaking:
        _scaleController.repeat(reverse: true);
        _waveController.repeat(reverse: true);
        break;
      case VoiceChatState.error:
        _scaleController.forward();
        break;
      case VoiceChatState.idle:
      default:
        // Reset to default state
        _pulseController.reset();
        _rotationController.reset();
        _scaleController.reset();
        _waveController.reset();
        break;
    }
  }

  @override
  void didUpdateWidget(AnimatedAgentAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chatState != widget.chatState) {
      _updateAnimationForState();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _scaleController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background glow effect
          _buildGlowEffect(),

          // Main avatar
          _buildMainAvatar(),

          // State-specific overlays
          _buildStateOverlay(),

          // Status indicator
          _buildStatusIndicator(),
        ],
      ),
    );
  }

  Widget _buildGlowEffect() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: widget.size * _pulseAnimation.value,
          height: widget.size * _pulseAnimation.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                widget.primaryColor.withValues(alpha: 0.3),
                widget.primaryColor.withValues(alpha: 0.1),
                Colors.transparent,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainAvatar() {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _rotationAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 2 * 3.14159,
            child: Container(
              width: widget.size * 0.7,
              height: widget.size * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [widget.primaryColor, widget.secondaryColor],
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.primaryColor.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icons.psychology.toSmartIcon(
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStateOverlay() {
    switch (widget.chatState) {
      case VoiceChatState.listening:
        return _buildListeningOverlay();
      case VoiceChatState.speaking:
        return _buildSpeakingOverlay();
      case VoiceChatState.processing:
        return _buildProcessingOverlay();
      case VoiceChatState.error:
        return _buildErrorOverlay();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildListeningOverlay() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          width: widget.size * 0.9,
          height: widget.size * 0.9,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.green.withValues(
                alpha: _pulseAnimation.value * 0.8,
              ),
              width: 3,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpeakingOverlay() {
    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: SoundWavePainter(
            animation: _waveAnimation.value,
            color: widget.primaryColor,
          ),
        );
      },
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      width: widget.size * 0.9,
      height: widget.size * 0.9,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.6),
          width: 2,
        ),
      ),
    );
  }

  Widget _buildErrorOverlay() {
    return Container(
      width: widget.size * 0.9,
      height: widget.size * 0.9,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.red.withValues(alpha: 0.8), width: 3),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    Color indicatorColor;
    IconData indicatorIcon;

    switch (widget.chatState) {
      case VoiceChatState.listening:
        indicatorColor = Colors.green;
        indicatorIcon = Icons.mic;
        break;
      case VoiceChatState.processing:
        indicatorColor = Colors.orange;
        indicatorIcon = Icons.hourglass_empty;
        break;
      case VoiceChatState.speaking:
        indicatorColor = Colors.blue;
        indicatorIcon = Icons.volume_up;
        break;
      case VoiceChatState.error:
        indicatorColor = Colors.red;
        indicatorIcon = Icons.error;
        break;
      default:
        indicatorColor = Colors.grey;
        indicatorIcon = Icons.chat;
        break;
    }

    return Positioned(
      bottom: 0,
      right: 0,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: indicatorColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: indicatorIcon.toSmartIcon(size: 12, color: Colors.white),
      ),
    );
  }
}

class SoundWavePainter extends CustomPainter {
  final double animation;
  final Color color;

  SoundWavePainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color.withValues(alpha: 0.6)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;

    // Draw multiple concentric circles with wave effect
    for (int i = 0; i < 3; i++) {
      final waveRadius = radius + (i * 15) + (animation * 20);
      final alpha = (1.0 - animation) * (1.0 - i * 0.3);

      paint.color = color.withValues(alpha: alpha.clamp(0.0, 1.0));
      canvas.drawCircle(center, waveRadius, paint);
    }
  }

  @override
  bool shouldRepaint(SoundWavePainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
