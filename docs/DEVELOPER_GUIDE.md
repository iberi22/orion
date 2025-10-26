# 👨‍💻 Guía del Desarrollador - Sistema de Animaciones Orion

## 🚀 Inicio Rápido

### Prerrequisitos
```bash
Flutter SDK: >=3.0.0
Dart SDK: >=3.0.0
```

### Instalación
```bash
# Clonar el repositorio
git clone <repository-url>
cd orion

# Instalar dependencias
flutter pub get

# Ejecutar demo de animaciones
flutter run -t lib/demo_main.dart -d chrome
```

## 🏗️ Estructura del Código

### Organización de Archivos
```
lib/
├── widgets/                    # Componentes animados reutilizables
│   ├── animated_agent_avatar.dart
│   ├── animated_chat_message.dart
│   └── connection_status_indicator.dart
├── state/                      # Gestión de estado
│   └── app_state_manager.dart
├── ui/                         # Pantallas y demos
│   ├── animated_voice_chat_demo.dart
│   └── demo_main.dart
├── utils/                      # Utilidades
│   ├── error_handler.dart
│   ├── loading_manager.dart
│   └── performance_monitor.dart
└── services/                   # Servicios de backend
    └── ai_service.dart
```

## 🎨 Creando Nuevas Animaciones

### 1. Estructura Básica de Widget Animado

```dart
class MyAnimatedWidget extends StatefulWidget {
  final MyState currentState;
  final Duration animationDuration;
  
  const MyAnimatedWidget({
    super.key,
    required this.currentState,
    this.animationDuration = const Duration(milliseconds: 800),
  });

  @override
  State<MyAnimatedWidget> createState() => _MyAnimatedWidgetState();
}

class _MyAnimatedWidgetState extends State<MyAnimatedWidget>
    with TickerProviderStateMixin {
  
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _updateAnimationForState();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  void _updateAnimationForState() {
    switch (widget.currentState) {
      case MyState.active:
        _controller.repeat(reverse: true);
        break;
      case MyState.inactive:
        _controller.stop();
        break;
    }
  }

  @override
  void didUpdateWidget(MyAnimatedWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentState != widget.currentState) {
      _updateAnimationForState();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_animation.value * 0.1),
          child: Container(
            // Tu widget aquí
          ),
        );
      },
    );
  }
}
```

### 2. Patrones de Animación Comunes

#### Pulso
```dart
Animation<double> _createPulseAnimation() {
  return Tween<double>(
    begin: 0.8,
    end: 1.2,
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  ));
}
```

#### Rotación
```dart
Animation<double> _createRotationAnimation() {
  return Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.linear,
  ));
}
```

#### Ondas Concéntricas
```dart
class WavePainter extends CustomPainter {
  final double animation;
  final Color color;

  WavePainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width / 4;

    for (int i = 0; i < 3; i++) {
      final radius = baseRadius + (i * 20) + (animation * 30);
      final alpha = (1.0 - animation) * (1.0 - i * 0.3);
      
      paint.color = color.withValues(alpha: alpha.clamp(0.0, 1.0));
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
```

## 🔧 Integración con Estados

### Definiendo Estados Personalizados
```dart
enum MyAgentState {
  idle,
  thinking,
  responding,
  error,
}

extension MyAgentStateExtension on MyAgentState {
  Color get color {
    switch (this) {
      case MyAgentState.idle:
        return Colors.grey;
      case MyAgentState.thinking:
        return Colors.orange;
      case MyAgentState.responding:
        return Colors.blue;
      case MyAgentState.error:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case MyAgentState.idle:
        return Icons.chat;
      case MyAgentState.thinking:
        return Icons.psychology;
      case MyAgentState.responding:
        return Icons.volume_up;
      case MyAgentState.error:
        return Icons.error;
    }
  }
}
```

### Gestión de Estado con StreamBuilder
```dart
class StateAwareAnimatedWidget extends StatelessWidget {
  final Stream<MyAgentState> stateStream;

  const StateAwareAnimatedWidget({
    super.key,
    required this.stateStream,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MyAgentState>(
      stream: stateStream,
      initialData: MyAgentState.idle,
      builder: (context, snapshot) {
        return MyAnimatedWidget(
          currentState: snapshot.data ?? MyAgentState.idle,
        );
      },
    );
  }
}
```

## 🧪 Testing de Animaciones

### 1. Unit Tests para Lógica de Estado
```dart
// test/animation_logic_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:orion/widgets/animated_agent_avatar.dart';

void main() {
  group('Animation State Logic', () {
    test('should return correct color for each state', () {
      expect(VoiceChatState.idle.color, Colors.grey);
      expect(VoiceChatState.listening.color, Colors.green);
      expect(VoiceChatState.processing.color, Colors.orange);
      expect(VoiceChatState.speaking.color, Colors.blue);
      expect(VoiceChatState.error.color, Colors.red);
    });

    test('should transition states correctly', () {
      final states = [
        VoiceChatState.idle,
        VoiceChatState.listening,
        VoiceChatState.processing,
        VoiceChatState.speaking,
        VoiceChatState.idle,
      ];

      for (int i = 0; i < states.length - 1; i++) {
        final current = states[i];
        final next = states[i + 1];
        expect(current != next, true);
      }
    });
  });
}
```

### 2. Widget Tests para Renderizado
```dart
// test/animated_avatar_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orion/widgets/animated_agent_avatar.dart';

void main() {
  group('AnimatedAgentAvatar Widget Tests', () {
    testWidgets('should render with correct initial state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedAgentAvatar(
              chatState: VoiceChatState.idle,
              size: 100,
            ),
          ),
        ),
      );

      expect(find.byType(AnimatedAgentAvatar), findsOneWidget);
      expect(find.byIcon(Icons.psychology), findsOneWidget);
    });

    testWidgets('should update animation when state changes', (tester) async {
      VoiceChatState currentState = VoiceChatState.idle;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    AnimatedAgentAvatar(
                      chatState: currentState,
                      size: 100,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentState = VoiceChatState.listening;
                        });
                      },
                      child: Text('Change State'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // Initial state
      expect(find.byType(AnimatedAgentAvatar), findsOneWidget);

      // Change state
      await tester.tap(find.text('Change State'));
      await tester.pump();

      // Verify state changed
      expect(find.byType(AnimatedAgentAvatar), findsOneWidget);
    });
  });
}
```

### 3. Integration Tests para Flujos Completos
```dart
// test/animation_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:orion/ui/animated_voice_chat_demo.dart';

void main() {
  group('Animation Flow Integration Tests', () {
    testWidgets('should complete full conversation simulation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AnimatedVoiceChatDemo(),
        ),
      );

      // Find and tap simulate button
      final simulateButton = find.text('Simular Chat');
      expect(simulateButton, findsOneWidget);
      
      await tester.tap(simulateButton);
      await tester.pump();

      // Wait for animation sequence
      await tester.pump(Duration(milliseconds: 500));
      
      // Verify listening state
      expect(find.text('Escuchando'), findsOneWidget);
      
      // Continue simulation
      await tester.pump(Duration(seconds: 2));
      expect(find.text('Procesando'), findsOneWidget);
      
      await tester.pump(Duration(seconds: 3));
      expect(find.text('Hablando'), findsOneWidget);
      
      await tester.pump(Duration(seconds: 5));
      expect(find.text('Inactivo'), findsOneWidget);
    });
  });
}
```

## 🎯 Performance Best Practices

### 1. Gestión Eficiente de AnimationControllers
```dart
class EfficientAnimatedWidget extends StatefulWidget {
  @override
  State<EfficientAnimatedWidget> createState() => _EfficientAnimatedWidgetState();
}

class _EfficientAnimatedWidgetState extends State<EfficientAnimatedWidget>
    with TickerProviderStateMixin {
  
  late AnimationController _primaryController;
  late AnimationController _secondaryController;
  
  @override
  void initState() {
    super.initState();
    
    // Inicializar solo cuando sea necesario
    _primaryController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    
    // Lazy initialization para controladores secundarios
    _secondaryController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    // CRÍTICO: Siempre dispose de todos los controllers
    _primaryController.dispose();
    _secondaryController.dispose();
    super.dispose();
  }

  void _startAnimation() {
    // Solo iniciar si el widget está montado
    if (mounted) {
      _primaryController.forward();
    }
  }

  void _stopAllAnimations() {
    _primaryController.stop();
    _secondaryController.stop();
  }
}
```

### 2. Optimización de Rebuilds
```dart
class OptimizedAnimatedWidget extends StatelessWidget {
  final VoiceChatState state;
  
  const OptimizedAnimatedWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: _buildStateWidget(state),
      ),
    );
  }

  Widget _buildStateWidget(VoiceChatState state) {
    // Usar keys para optimizar AnimatedSwitcher
    return Container(
      key: ValueKey(state),
      child: _getWidgetForState(state),
    );
  }
}
```

### 3. Lazy Loading de Animaciones Complejas
```dart
class LazyAnimatedWidget extends StatefulWidget {
  @override
  State<LazyAnimatedWidget> createState() => _LazyAnimatedWidgetState();
}

class _LazyAnimatedWidgetState extends State<LazyAnimatedWidget> {
  AnimationController? _expensiveController;
  
  AnimationController get expensiveController {
    _expensiveController ??= AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
    return _expensiveController!;
  }

  @override
  void dispose() {
    _expensiveController?.dispose();
    super.dispose();
  }
}
```

## 🔍 Debugging y Troubleshooting

### 1. Debug de Animaciones
```dart
class DebugAnimatedWidget extends StatefulWidget {
  @override
  State<DebugAnimatedWidget> createState() => _DebugAnimatedWidgetState();
}

class _DebugAnimatedWidgetState extends State<DebugAnimatedWidget>
    with TickerProviderStateMixin {
  
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    // Debug listener
    _controller.addListener(() {
      if (kDebugMode) {
        print('Animation value: ${_controller.value}');
      }
    });

    // Status listener para debugging
    _controller.addStatusListener((status) {
      if (kDebugMode) {
        print('Animation status: $status');
      }
    });
  }
}
```

### 2. Performance Monitoring
```dart
class PerformanceMonitoredWidget extends StatefulWidget {
  @override
  State<PerformanceMonitoredWidget> createState() => _PerformanceMonitoredWidgetState();
}

class _PerformanceMonitoredWidgetState extends State<PerformanceMonitoredWidget> {
  
  void _measureAnimationPerformance() {
    final stopwatch = Stopwatch()..start();
    
    _controller.forward().then((_) {
      stopwatch.stop();
      if (kDebugMode) {
        print('Animation completed in: ${stopwatch.elapsedMilliseconds}ms');
      }
      
      // Log to analytics in production
      PerformanceMonitor.logAnimationDuration(
        'agent_avatar_animation',
        stopwatch.elapsedMilliseconds,
      );
    });
  }
}
```

## 📦 Deployment y Build

### Configuración para Diferentes Plataformas

#### Web
```bash
# Build optimizado para web
flutter build web --release --web-renderer html

# Para mejor performance en dispositivos móviles
flutter build web --release --web-renderer canvaskit
```

#### Android
```bash
# Build con optimizaciones de animación
flutter build apk --release --enable-software-rendering=false
```

#### iOS
```bash
# Build con Metal rendering habilitado
flutter build ios --release
```

### Variables de Entorno para Animaciones
```dart
// lib/config/animation_config.dart
class AnimationConfig {
  static const bool enableAnimations = bool.fromEnvironment(
    'ENABLE_ANIMATIONS',
    defaultValue: true,
  );
  
  static const double animationScale = double.fromEnvironment(
    'ANIMATION_SCALE',
    defaultValue: 1.0,
  );
  
  static const bool debugAnimations = bool.fromEnvironment(
    'DEBUG_ANIMATIONS',
    defaultValue: false,
  );
}
```

## 🚀 Próximos Pasos

### Funcionalidades Avanzadas a Implementar
1. **Animaciones basadas en física**: Usar `SpringSimulation`
2. **Animaciones de partículas**: Para efectos más complejos
3. **Animaciones 3D**: Con `Transform` y perspectiva
4. **Animaciones sincronizadas**: Múltiples elementos coordinados
5. **Animaciones adaptativas**: Basadas en capacidades del dispositivo

### Herramientas Recomendadas
- **Flutter Inspector**: Para debugging de widgets
- **Performance Overlay**: Para monitorear FPS
- **Timeline**: Para análisis detallado de performance
- **Memory Profiler**: Para detectar memory leaks en animaciones
