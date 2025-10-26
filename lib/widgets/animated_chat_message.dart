// Animated Chat Message Widget
//
// Provides smooth animations for chat messages appearing and typing effects

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:orion/utils/icon_fallbacks.dart';

enum MessageType { user, agent, system }

class AnimatedChatMessage extends StatefulWidget {
  final String message;
  final MessageType type;
  final bool isTyping;
  final Duration animationDuration;
  final VoidCallback? onAnimationComplete;

  const AnimatedChatMessage({
    super.key,
    required this.message,
    required this.type,
    this.isTyping = false,
    this.animationDuration = const Duration(milliseconds: 800),
    this.onAnimationComplete,
  });

  @override
  State<AnimatedChatMessage> createState() => _AnimatedChatMessageState();
}

class _AnimatedChatMessageState extends State<AnimatedChatMessage>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _typingController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _typingAnimation;

  String _displayedText = '';
  Timer? _typingTimer;
  int _currentCharIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startEntryAnimation();
  }

  void _initializeAnimations() {
    // Slide animation for message entry
    _slideController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin:
          widget.type == MessageType.user
              ? const Offset(1.0, 0.0)
              : const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    // Fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    // Scale animation for emphasis
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Typing indicator animation
    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _typingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _typingController, curve: Curves.easeInOut),
    );
  }

  void _startEntryAnimation() async {
    // Start all entry animations
    _fadeController.forward();
    _slideController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _scaleController.forward();

    if (widget.isTyping && widget.type == MessageType.agent) {
      _startTypingEffect();
    } else {
      _displayedText = widget.message;
      if (widget.onAnimationComplete != null) {
        widget.onAnimationComplete!();
      }
    }
  }

  void _startTypingEffect() {
    _typingController.repeat(reverse: true);

    const typingSpeed = Duration(milliseconds: 50);
    _currentCharIndex = 0;

    _typingTimer = Timer.periodic(typingSpeed, (timer) {
      if (_currentCharIndex < widget.message.length) {
        setState(() {
          _displayedText = widget.message.substring(0, _currentCharIndex + 1);
          _currentCharIndex++;
        });
      } else {
        timer.cancel();
        _typingController.stop();
        if (widget.onAnimationComplete != null) {
          widget.onAnimationComplete!();
        }
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _typingController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: _buildMessageBubble(),
        ),
      ),
    );
  }

  Widget _buildMessageBubble() {
    final isUser = widget.type == MessageType.user;
    final isSystem = widget.type == MessageType.system;

    return Container(
      margin: EdgeInsets.only(
        left: isUser ? 50 : 0,
        right: isUser ? 0 : 50,
        bottom: 8,
      ),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser && !isSystem) _buildAgentAvatar(),
          if (!isUser && !isSystem) const SizedBox(width: 8),

          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _getMessageColor(),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _buildMessageContent(),
            ),
          ),

          if (isUser) const SizedBox(width: 8),
          if (isUser) _buildUserAvatar(),
        ],
      ),
    );
  }

  Widget _buildAgentAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [Colors.blue, Colors.cyan]),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icons.psychology.toSmartIcon(color: Colors.white, size: 18),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[300],
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icons.person.toSmartIcon(color: Colors.grey, size: 18),
    );
  }

  Widget _buildMessageContent() {
    if (widget.isTyping &&
        widget.type == MessageType.agent &&
        _displayedText.isEmpty) {
      return _buildTypingIndicator();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _displayedText,
          style: TextStyle(color: _getTextColor(), fontSize: 16, height: 1.4),
        ),
        if (widget.isTyping &&
            widget.type == MessageType.agent &&
            _displayedText.isNotEmpty)
          _buildTypingCursor(),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return AnimatedBuilder(
      animation: _typingAnimation,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.3;
            final animationValue = (_typingAnimation.value - delay).clamp(
              0.0,
              1.0,
            );

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              child: Transform.translate(
                offset: Offset(0, -10 * animationValue),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildTypingCursor() {
    return AnimatedBuilder(
      animation: _typingAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _typingAnimation.value,
          child: Container(width: 2, height: 16, color: _getTextColor()),
        );
      },
    );
  }

  Color _getMessageColor() {
    switch (widget.type) {
      case MessageType.user:
        return Colors.blue[600]!;
      case MessageType.agent:
        return Colors.grey[100]!;
      case MessageType.system:
        return Colors.orange[100]!;
    }
  }

  Color _getTextColor() {
    switch (widget.type) {
      case MessageType.user:
        return Colors.white;
      case MessageType.agent:
        return Colors.black87;
      case MessageType.system:
        return Colors.orange[800]!;
    }
  }
}
