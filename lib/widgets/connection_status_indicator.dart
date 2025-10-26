// Connection Status Indicator Widget
//
// Shows animated connection status for Firebase and Vertex AI

import 'package:flutter/material.dart';
import 'package:orion/utils/icon_fallbacks.dart';

enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
  authenticating,
  ready,
}

class ConnectionStatusIndicator extends StatefulWidget {
  final ConnectionStatus status;
  final String? customMessage;
  final VoidCallback? onTap;
  final bool showLabel;

  const ConnectionStatusIndicator({
    super.key,
    required this.status,
    this.customMessage,
    this.onTap,
    this.showLabel = true,
  });

  @override
  State<ConnectionStatusIndicator> createState() =>
      _ConnectionStatusIndicatorState();
}

class _ConnectionStatusIndicatorState extends State<ConnectionStatusIndicator>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _scaleController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _updateAnimationForStatus();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
  }

  void _updateAnimationForStatus() {
    _pulseController.stop();
    _rotationController.stop();
    _scaleController.reset();

    switch (widget.status) {
      case ConnectionStatus.connecting:
      case ConnectionStatus.authenticating:
        _rotationController.repeat();
        _scaleController.forward();
        break;
      case ConnectionStatus.connected:
      case ConnectionStatus.ready:
        _pulseController.repeat(reverse: true);
        _scaleController.forward();
        break;
      case ConnectionStatus.error:
        _scaleController.forward();
        break;
      case ConnectionStatus.disconnected:
        _scaleController.forward();
        break;
    }
  }

  @override
  void didUpdateWidget(ConnectionStatusIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status) {
      _updateAnimationForStatus();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _getBackgroundColor().withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _getBackgroundColor().withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAnimatedIcon(),
            if (widget.showLabel) ...[
              const SizedBox(width: 8),
              _buildStatusText(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseAnimation, _rotationAnimation]),
        builder: (context, child) {
          Widget iconWidget = Transform.rotate(
            angle: _rotationAnimation.value * 2 * 3.14159,
            child: Container(
              width: 24 * _pulseAnimation.value,
              height: 24 * _pulseAnimation.value,
              decoration: BoxDecoration(
                color: _getIconColor(),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _getIconColor().withValues(alpha: 0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: _getStatusIcon().toSmartIcon(
                color: Colors.white,
                size: 12,
              ),
            ),
          );

          // Add additional effects for specific states
          if (widget.status == ConnectionStatus.connecting ||
              widget.status == ConnectionStatus.authenticating) {
            iconWidget = Stack(
              alignment: Alignment.center,
              children: [
                // Outer ring
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _getIconColor().withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                ),
                iconWidget,
              ],
            );
          }

          return iconWidget;
        },
      ),
    );
  }

  Widget _buildStatusText() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        widget.customMessage ?? _getStatusMessage(),
        key: ValueKey(widget.status),
        style: TextStyle(
          color: _getTextColor(),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (widget.status) {
      case ConnectionStatus.connected:
      case ConnectionStatus.ready:
        return Colors.green;
      case ConnectionStatus.connecting:
      case ConnectionStatus.authenticating:
        return Colors.orange;
      case ConnectionStatus.error:
        return Colors.red;
      case ConnectionStatus.disconnected:
        return Colors.grey;
    }
  }

  Color _getIconColor() {
    switch (widget.status) {
      case ConnectionStatus.connected:
      case ConnectionStatus.ready:
        return Colors.green;
      case ConnectionStatus.connecting:
      case ConnectionStatus.authenticating:
        return Colors.orange;
      case ConnectionStatus.error:
        return Colors.red;
      case ConnectionStatus.disconnected:
        return Colors.grey;
    }
  }

  Color _getTextColor() {
    return _getIconColor();
  }

  IconData _getStatusIcon() {
    switch (widget.status) {
      case ConnectionStatus.connected:
        return Icons.wifi;
      case ConnectionStatus.ready:
        return Icons.check_circle;
      case ConnectionStatus.connecting:
        return Icons.sync;
      case ConnectionStatus.authenticating:
        return Icons.lock;
      case ConnectionStatus.error:
        return Icons.error;
      case ConnectionStatus.disconnected:
        return Icons.wifi_off;
    }
  }

  String _getStatusMessage() {
    switch (widget.status) {
      case ConnectionStatus.connected:
        return 'Conectado';
      case ConnectionStatus.ready:
        return 'Listo';
      case ConnectionStatus.connecting:
        return 'Conectando...';
      case ConnectionStatus.authenticating:
        return 'Autenticando...';
      case ConnectionStatus.error:
        return 'Error';
      case ConnectionStatus.disconnected:
        return 'Desconectado';
    }
  }
}

// Firebase/Vertex AI specific connection widget
class FirebaseConnectionStatus extends StatelessWidget {
  final bool isFirebaseConnected;
  final bool isVertexAIReady;
  final bool isAuthenticating;
  final VoidCallback? onRetry;

  const FirebaseConnectionStatus({
    super.key,
    required this.isFirebaseConnected,
    required this.isVertexAIReady,
    this.isAuthenticating = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icons.cloud.toSmartIcon(color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'Estado de Conexión',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (onRetry != null)
                IconButton(
                  icon: Icons.refresh.toSmartIcon(),
                  onPressed: onRetry,
                  tooltip: 'Reintentar conexión',
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Firebase status
          Row(
            children: [
              ConnectionStatusIndicator(
                status:
                    isFirebaseConnected
                        ? ConnectionStatus.connected
                        : ConnectionStatus.disconnected,
                showLabel: false,
              ),
              const SizedBox(width: 8),
              const Text('Firebase'),
              const Spacer(),
              Text(
                isFirebaseConnected ? 'Conectado' : 'Desconectado',
                style: TextStyle(
                  color: isFirebaseConnected ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Vertex AI status
          Row(
            children: [
              ConnectionStatusIndicator(
                status:
                    isAuthenticating
                        ? ConnectionStatus.authenticating
                        : isVertexAIReady
                        ? ConnectionStatus.ready
                        : ConnectionStatus.disconnected,
                showLabel: false,
              ),
              const SizedBox(width: 8),
              const Text('Vertex AI (Gemini)'),
              const Spacer(),
              Text(
                isAuthenticating
                    ? 'Autenticando...'
                    : isVertexAIReady
                    ? 'Listo'
                    : 'No disponible',
                style: TextStyle(
                  color:
                      isAuthenticating
                          ? Colors.orange
                          : isVertexAIReady
                          ? Colors.green
                          : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
