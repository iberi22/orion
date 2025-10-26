import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../services/tts/model_manager.dart';
import '../../services/tts/model_manifest.dart';
import '../../services/tts/tts_settings.dart';

/// TTSModelsPage
///
/// UI para gestionar modelos TTS on-device (descargar/eliminar) y seleccionar
/// la voz predeterminada. Muestra progreso de descarga y estado instalado.
class TTSModelsPage extends StatefulWidget {
  /// Inyección opcional del gestor para pruebas.
  final OnDeviceTTSModelManager? manager;

  const TTSModelsPage({super.key, this.manager});

  @override
  State<TTSModelsPage> createState() => _TTSModelsPageState();
}

class _TTSModelsPageState extends State<TTSModelsPage> {
  late final OnDeviceTTSModelManager _manager;
  late TTSModelManifest _manifest;
  final Map<String, bool> _installed = {};
  String? _preferredVoice;
  String? _downloadingKey;
  double _progress = 0.0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _manager = widget.manager ?? OnDeviceTTSModelManager();
    _bootstrap();
  }

  /// Inicializa el gestor, carga el manifest y computa estado instalado.
  Future<void> _bootstrap() async {
    await _manager.initialize();
    _manifest = _manager.manifest;
    _preferredVoice = await TTSSettings.getPreferredVoice();
    for (final v in _manifest.voices) {
      final ok = await _manager.isInstalled(v.key);
      _installed[v.key] = ok;
    }
    if (mounted) setState(() => _loading = false);
  }

  /// Refresca el estado de instalación de todas las voces.
  Future<void> _refresh() async {
    setState(() => _loading = true);
    await _bootstrap();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Modelos TTS')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Modelos TTS')),
      body: _manifest.voices.isEmpty
          ? const Center(child: Text('No hay voces disponibles.'))
          : RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _manifest.voices.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final v = _manifest.voices[index];
                  final isInstalled = _installed[v.key] ?? false;
                  final isPreferred = _preferredVoice == v.key;
                  final sizeBytes = v.files.fold<int>(0, (acc, f) => acc + f.sizeBytes);
                  final sizeMb = sizeBytes > 0 ? (sizeBytes / (1024 * 1024)).toStringAsFixed(1) : '—';
                  final fileNames = v.files.map((f) => p.basename(Uri.parse(f.url).path)).join(', ');

                  return ListTile(
                    title: Row(
                      children: [
                        Expanded(child: Text(v.key)),
                        if (isPreferred)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('Predeterminada', style: TextStyle(color: Colors.green)),
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${v.language} • ${v.quality} • ${fileNames} • ${sizeMb} MB'),
                        if (_downloadingKey == v.key)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    value: (_progress > 0 && _progress < 1) ? _progress : null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text('${(_progress * 100).toStringAsFixed(0)}%'),
                              ],
                            ),
                          ),
                      ],
                    ),
                    trailing: _buildActions(v, isInstalled, isPreferred),
                  );
                },
              ),
            ),
    );
  }

  /// Acciones de cada voz: Descargar/Eliminar y Establecer Predeterminada.
  Widget _buildActions(VoiceEntry v, bool isInstalled, bool isPreferred) {
    if (_downloadingKey == v.key) {
      return const SizedBox(width: 24, height: 24);
    }
    return Wrap(
      spacing: 8,
      children: [
        ElevatedButton(
          onPressed: () => _onActionPressed(v, isInstalled),
          child: Text(isInstalled ? 'Eliminar' : 'Descargar'),
        ),
        if (isInstalled)
          OutlinedButton(
            onPressed: isPreferred ? null : () => _setPreferred(v.key),
            child: const Text('Usar'),
          ),
      ],
    );
  }

  /// Descarga o elimina una voz y actualiza estado/progreso.
  Future<void> _onActionPressed(VoiceEntry v, bool isInstalled) async {
    try {
      if (isInstalled) {
        setState(() => _loading = true);
        await _manager.removeVoice(v.key);
        _installed[v.key] = false;
      } else {
        setState(() {
          _downloadingKey = v.key;
          _progress = 0.0;
        });
        await _manager.installVoice(v, onProgress: (p) {
          if (!mounted) return;
          setState(() => _progress = p.clamp(0.0, 1.0));
        });
        _installed[v.key] = true;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _downloadingKey = null;
          _loading = false;
        });
      }
    }
  }

  /// Establece la voz predeterminada y refresca el UI.
  Future<void> _setPreferred(String voiceKey) async {
    await TTSSettings.setPreferredVoice(voiceKey);
    setState(() => _preferredVoice = voiceKey);
  }
}
