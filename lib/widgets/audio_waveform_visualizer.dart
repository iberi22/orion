import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Real-time audio waveform visualizer widget
/// Displays audio input levels during recording and playback with smooth animations
class AudioWaveformVisualizer extends StatefulWidget {
  const AudioWaveformVisualizer({
    super.key,
    required this.isActive,
    this.volumeLevels = const [],
    this.height = 60.0,
    this.width = 200.0,
    this.barCount = 20,
    this.barWidth = 4.0,
    this.barSpacing = 2.0,
    this.primaryColor = Colors.blue,
    this.secondaryColor = Colors.grey,
    this.animationDuration = const Duration(milliseconds: 150),
    this.showBackground = true,
    this.style = WaveformStyle.bars,
  });

  final bool isActive;
  final List<double> volumeLevels;
  final double height;
  final double width;
  final int barCount;
  final double barWidth;
  final double barSpacing;
  final Color primaryColor;
  final Color secondaryColor;
  final Duration animationDuration;
  final bool showBackground;
  final WaveformStyle style;

  @override
  State<AudioWaveformVisualizer> createState() =>
      _AudioWaveformVisualizerState();
}

class _AudioWaveformVisualizerState extends State<AudioWaveformVisualizer>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  List<double> _currentLevels = [];
  List<AnimationController> _barControllers = [];
  List<Animation<double>> _barAnimations = [];

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Initialize bar controllers
    _initializeBarControllers();

    // Initialize current levels
    _currentLevels = List.filled(widget.barCount, 0.0);

    // Start pulse animation if active
    if (widget.isActive) {
      _pulseController.repeat(reverse: true);
    }
  }

  void _initializeBarControllers() {
    // Dispose existing controllers
    for (final controller in _barControllers) {
      controller.dispose();
    }
    _barControllers.clear();
    _barAnimations.clear();

    // Create new controllers for each bar
    for (int i = 0; i < widget.barCount; i++) {
      final controller = AnimationController(
        duration: Duration(milliseconds: 100 + (i * 10)), // Staggered animation
        vsync: this,
      );

      final animation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

      _barControllers.add(controller);
      _barAnimations.add(animation);
    }
  }

  @override
  void didUpdateWidget(AudioWaveformVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update animation state
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }

    // Update volume levels
    if (widget.volumeLevels != oldWidget.volumeLevels) {
      _updateVolumeLevels();
    }

    // Reinitialize if bar count changed
    if (widget.barCount != oldWidget.barCount) {
      _initializeBarControllers();
      _currentLevels = List.filled(widget.barCount, 0.0);
    }
  }

  void _updateVolumeLevels() {
    if (!widget.isActive) {
      // Animate to zero when not active
      for (int i = 0; i < _barControllers.length; i++) {
        _barControllers[i].animateTo(0.0);
      }
      return;
    }

    // Update levels based on input
    final newLevels = List<double>.filled(widget.barCount, 0.0);

    if (widget.volumeLevels.isNotEmpty) {
      // Map volume levels to bars
      for (int i = 0; i < widget.barCount; i++) {
        final levelIndex =
            (i * widget.volumeLevels.length / widget.barCount).floor();
        if (levelIndex < widget.volumeLevels.length) {
          newLevels[i] = widget.volumeLevels[levelIndex].clamp(0.0, 1.0);
        }
      }
    } else {
      // Generate demo waveform when no real data
      _generateDemoWaveform(newLevels);
    }

    // Animate to new levels
    for (int i = 0; i < _barControllers.length && i < newLevels.length; i++) {
      _barControllers[i].animateTo(newLevels[i]);
    }

    _currentLevels = newLevels;
  }

  void _generateDemoWaveform(List<double> levels) {
    if (!widget.isActive) return;

    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;

    for (int i = 0; i < levels.length; i++) {
      final frequency = 2.0 + (i * 0.5);
      final amplitude = 0.3 + (math.sin(time * frequency) * 0.4);
      levels[i] = amplitude.clamp(0.0, 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration:
          widget.showBackground
              ? BoxDecoration(
                color: widget.secondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: widget.secondaryColor.withOpacity(0.3),
                  width: 1.0,
                ),
              )
              : null,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isActive ? _pulseAnimation.value : 1.0,
            child: _buildWaveform(),
          );
        },
      ),
    );
  }

  Widget _buildWaveform() {
    switch (widget.style) {
      case WaveformStyle.bars:
        return _buildBarsWaveform();
      case WaveformStyle.line:
        return _buildLineWaveform();
      case WaveformStyle.dots:
        return _buildDotsWaveform();
    }
  }

  Widget _buildBarsWaveform() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(widget.barCount, (index) {
        return AnimatedBuilder(
          animation: _barAnimations[index],
          builder: (context, child) {
            final height = _barAnimations[index].value * widget.height * 0.8;
            return Container(
              width: widget.barWidth,
              height: math.max(height, 2.0), // Minimum height
              decoration: BoxDecoration(
                color:
                    widget.isActive
                        ? widget.primaryColor.withOpacity(
                          0.7 + (_barAnimations[index].value * 0.3),
                        )
                        : widget.secondaryColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(widget.barWidth / 2),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildLineWaveform() {
    return CustomPaint(
      size: Size(widget.width, widget.height),
      painter: LineWaveformPainter(
        levels: _barAnimations.map((anim) => anim.value).toList(),
        color: widget.isActive ? widget.primaryColor : widget.secondaryColor,
        isActive: widget.isActive,
      ),
    );
  }

  Widget _buildDotsWaveform() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(widget.barCount, (index) {
        return AnimatedBuilder(
          animation: _barAnimations[index],
          builder: (context, child) {
            final size = 4.0 + (_barAnimations[index].value * 8.0);
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color:
                    widget.isActive
                        ? widget.primaryColor.withOpacity(
                          0.7 + (_barAnimations[index].value * 0.3),
                        )
                        : widget.secondaryColor.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    for (final controller in _barControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}

/// Custom painter for line waveform style
class LineWaveformPainter extends CustomPainter {
  const LineWaveformPainter({
    required this.levels,
    required this.color,
    required this.isActive,
  });

  final List<double> levels;
  final Color color;
  final bool isActive;

  @override
  void paint(Canvas canvas, Size size) {
    if (levels.isEmpty) return;

    final paint =
        Paint()
          ..color = color.withOpacity(isActive ? 0.8 : 0.3)
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    final path = Path();
    final stepX = size.width / (levels.length - 1);
    final centerY = size.height / 2;

    for (int i = 0; i < levels.length; i++) {
      final x = i * stepX;
      final y = centerY - (levels[i] * centerY * 0.8);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(LineWaveformPainter oldDelegate) {
    return levels != oldDelegate.levels ||
        color != oldDelegate.color ||
        isActive != oldDelegate.isActive;
  }
}

/// Waveform visualization styles
enum WaveformStyle { bars, line, dots }
