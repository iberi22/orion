import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Volume level indicator widget
/// Shows real-time audio input levels during recording with visual feedback
class VolumeLevelIndicator extends StatefulWidget {
  const VolumeLevelIndicator({
    super.key,
    required this.isActive,
    this.volumeLevel = 0.0,
    this.size = 80.0,
    this.thickness = 8.0,
    this.primaryColor = Colors.green,
    this.warningColor = Colors.orange,
    this.dangerColor = Colors.red,
    this.backgroundColor = Colors.grey,
    this.showText = true,
    this.showOptimalRange = true,
    this.style = VolumeIndicatorStyle.circular,
  });

  final bool isActive;
  final double volumeLevel; // 0.0 to 1.0
  final double size;
  final double thickness;
  final Color primaryColor;
  final Color warningColor;
  final Color dangerColor;
  final Color backgroundColor;
  final bool showText;
  final bool showOptimalRange;
  final VolumeIndicatorStyle style;

  @override
  State<VolumeLevelIndicator> createState() => _VolumeLevelIndicatorState();
}

class _VolumeLevelIndicatorState extends State<VolumeLevelIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _levelAnimation;
  late Animation<double> _pulseAnimation;

  double _currentLevel = 0.0;
  double _peakLevel = 0.0;
  DateTime _lastPeakTime = DateTime.now();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _levelAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.isActive) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(VolumeLevelIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }

    if (widget.volumeLevel != oldWidget.volumeLevel) {
      _updateVolumeLevel();
    }
  }

  void _updateVolumeLevel() {
    final newLevel = widget.volumeLevel.clamp(0.0, 1.0);

    // Update peak level
    if (newLevel > _peakLevel) {
      _peakLevel = newLevel;
      _lastPeakTime = DateTime.now();
    } else {
      // Decay peak level over time
      final timeSincePeak =
          DateTime.now().difference(_lastPeakTime).inMilliseconds;
      if (timeSincePeak > 1000) {
        _peakLevel = math.max(_peakLevel - 0.01, newLevel);
      }
    }

    _currentLevel = newLevel;
    _animationController.animateTo(newLevel);
  }

  Color _getVolumeColor(double level) {
    if (level < 0.3) {
      return widget.primaryColor;
    } else if (level < 0.7) {
      return Color.lerp(
        widget.primaryColor,
        widget.warningColor,
        (level - 0.3) / 0.4,
      )!;
    } else if (level < 0.9) {
      return Color.lerp(
        widget.warningColor,
        widget.dangerColor,
        (level - 0.7) / 0.2,
      )!;
    } else {
      return widget.dangerColor;
    }
  }

  String _getVolumeText(double level) {
    if (level < 0.1) {
      return 'Too Quiet';
    } else if (level < 0.3) {
      return 'Quiet';
    } else if (level < 0.7) {
      return 'Good';
    } else if (level < 0.9) {
      return 'Loud';
    } else {
      return 'Too Loud';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_levelAnimation, _pulseAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isActive ? _pulseAnimation.value : 1.0,
          child: _buildIndicator(),
        );
      },
    );
  }

  Widget _buildIndicator() {
    switch (widget.style) {
      case VolumeIndicatorStyle.circular:
        return _buildCircularIndicator();
      case VolumeIndicatorStyle.linear:
        return _buildLinearIndicator();
      case VolumeIndicatorStyle.meter:
        return _buildMeterIndicator();
    }
  }

  Widget _buildCircularIndicator() {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          CustomPaint(
            size: Size(widget.size, widget.size),
            painter: CircularVolumePainter(
              level: 1.0,
              color: widget.backgroundColor.withOpacity(0.3),
              thickness: widget.thickness,
              showOptimalRange: false,
            ),
          ),

          // Optimal range indicator
          if (widget.showOptimalRange)
            CustomPaint(
              size: Size(widget.size, widget.size),
              painter: CircularVolumePainter(
                level: 0.7,
                startLevel: 0.3,
                color: widget.primaryColor.withOpacity(0.2),
                thickness: widget.thickness,
                showOptimalRange: true,
              ),
            ),

          // Current level
          CustomPaint(
            size: Size(widget.size, widget.size),
            painter: CircularVolumePainter(
              level: _levelAnimation.value,
              color: _getVolumeColor(_levelAnimation.value),
              thickness: widget.thickness,
              showOptimalRange: false,
            ),
          ),

          // Peak indicator
          if (_peakLevel > _currentLevel)
            CustomPaint(
              size: Size(widget.size, widget.size),
              painter: CircularPeakPainter(
                peakLevel: _peakLevel,
                color: _getVolumeColor(_peakLevel),
                thickness: widget.thickness,
              ),
            ),

          // Center text
          if (widget.showText)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(_levelAnimation.value * 100).round()}%',
                  style: TextStyle(
                    fontSize: widget.size * 0.15,
                    fontWeight: FontWeight.bold,
                    color: _getVolumeColor(_levelAnimation.value),
                  ),
                ),
                Text(
                  _getVolumeText(_levelAnimation.value),
                  style: TextStyle(
                    fontSize: widget.size * 0.08,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildLinearIndicator() {
    return Container(
      width: widget.size * 2,
      height: widget.thickness * 2,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.thickness),
        color: widget.backgroundColor.withOpacity(0.3),
      ),
      child: Stack(
        children: [
          // Optimal range
          if (widget.showOptimalRange)
            Positioned(
              left: widget.size * 2 * 0.3,
              width: widget.size * 2 * 0.4,
              top: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.thickness),
                  color: widget.primaryColor.withOpacity(0.2),
                ),
              ),
            ),

          // Current level
          Positioned(
            left: 0,
            width: widget.size * 2 * _levelAnimation.value,
            top: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.thickness),
                color: _getVolumeColor(_levelAnimation.value),
              ),
            ),
          ),

          // Peak indicator
          if (_peakLevel > _currentLevel)
            Positioned(
              left: widget.size * 2 * _peakLevel - 2,
              width: 4,
              top: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: _getVolumeColor(_peakLevel),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMeterIndicator() {
    const int segments = 10;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showText)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              _getVolumeText(_levelAnimation.value),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _getVolumeColor(_levelAnimation.value),
              ),
            ),
          ),

        SizedBox(
          height: widget.size,
          width: 20,
          child: Column(
            children: List.generate(segments, (index) {
              final segmentLevel = (segments - index) / segments;
              final isActive = _levelAnimation.value >= segmentLevel;
              final isPeak =
                  _peakLevel >= segmentLevel &&
                  _peakLevel < segmentLevel + (1 / segments);

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 1),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color:
                        isActive || isPeak
                            ? _getVolumeColor(segmentLevel)
                            : widget.backgroundColor.withOpacity(0.3),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
}

/// Custom painter for circular volume indicator
class CircularVolumePainter extends CustomPainter {
  const CircularVolumePainter({
    required this.level,
    required this.color,
    required this.thickness,
    required this.showOptimalRange,
    this.startLevel = 0.0,
  });

  final double level;
  final double startLevel;
  final Color color;
  final double thickness;
  final bool showOptimalRange;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - thickness) / 2;

    final paint =
        Paint()
          ..color = color
          ..strokeWidth = thickness
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2; // Start from top
    final sweepAngle = 2 * math.pi * (level - startLevel);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + (2 * math.pi * startLevel),
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CircularVolumePainter oldDelegate) {
    return level != oldDelegate.level ||
        color != oldDelegate.color ||
        thickness != oldDelegate.thickness;
  }
}

/// Custom painter for peak indicator
class CircularPeakPainter extends CustomPainter {
  const CircularPeakPainter({
    required this.peakLevel,
    required this.color,
    required this.thickness,
  });

  final double peakLevel;
  final Color color;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - thickness) / 2;

    final paint =
        Paint()
          ..color = color
          ..strokeWidth = thickness + 2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final peakAngle = startAngle + (2 * math.pi * peakLevel);

    // Draw a small arc at the peak position
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      peakAngle - 0.05,
      0.1,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CircularPeakPainter oldDelegate) {
    return peakLevel != oldDelegate.peakLevel || color != oldDelegate.color;
  }
}

/// Volume indicator styles
enum VolumeIndicatorStyle { circular, linear, meter }
