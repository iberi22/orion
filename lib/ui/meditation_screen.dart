import 'package:flutter/material.dart';
import 'package:orion/services/ai_service.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  final _aiService = AIService();
  List<String> _meditationSteps = [];
  int _currentStep = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchMeditationScript();
  }

  Future<void> _fetchMeditationScript() async {
    try {
      const prompt = 'Genera un guion para una meditación guiada de 5 pasos para principiantes. Separa cada paso con un "|".';
      final response = await _aiService.getResponse(prompt);
      setState(() {
        _meditationSteps = response.split('|').map((e) => e.trim()).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'No se pudo cargar la meditación: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _nextStep() {
    if (_currentStep < _meditationSteps.length - 1) {
      setState(() {
        _currentStep++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent, // Make scaffold transparent to see the gradient
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Meditación Guiada'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xff1e2a78),
              Color(0xff4b3f91),
              Color(0xff8a4d9e),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: _buildContent(theme),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_isLoading) {
      return const CircularProgressIndicator();
    }
    if (_error != null) {
      return Text(_error!, style: TextStyle(color: theme.colorScheme.error));
    }
    if (_meditationSteps.isEmpty) {
      return const Text('No hay pasos de meditación disponibles.');
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Paso ${_currentStep + 1} de ${_meditationSteps.length}',
          style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 16),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Text(
                _meditationSteps[_currentStep],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, height: 1.5),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (_currentStep < _meditationSteps.length - 1)
          shadcn.PrimaryButton(
            child: const Text('Siguiente'),
            onPressed: _nextStep,
          )
        else
          shadcn.PrimaryButton(
            child: const Text('Finalizar Meditación'),
            onPressed: () => Navigator.of(context).pop(),
          ),
      ],
    );
  }
}
