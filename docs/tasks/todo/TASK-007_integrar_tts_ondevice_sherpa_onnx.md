# Tarea 007: Integrar TTS On-Device con `sherpa_onnx`

**Épico:** [02_voice_chat_and_agent_memory.md](../epics/02_voice_chat_and_agent_memory.md)

**Descripción:**
Integrar el paquete `sherpa_onnx` en Flutter y crear el adaptador `SherpaOnnxTTSAdapter` con el nuevo proveedor `ondevice` en `TTSService`, permitiendo síntesis 100% offline. Soportar inglés y español mediante selección de `voiceId` y `sampleRate`.

**Criterios de Aceptación:**

1. Agregar `sherpa_onnx` y dependencias auxiliares (p. ej., `path_provider`, `dio`, `crypto`) a `pubspec.yaml`.
2. Crear `lib/services/tts/sherpa_onnx_adapter.dart` siguiendo el patrón de `TTSAdapter` (estados, cancelación, errores).
3. Integrar el proveedor `ondevice` en `TTSService` y `AppConfig.ttsProvider`.
4. Soportar parámetros `lang` (en|es), `voiceId` y `sampleRate`.
5. Reproducir PCM/WAV con el pipeline existente asegurando latencia aceptable para frases cortas.
6. Probar en dispositivo Android real en modo avión (offline total) con una frase de ejemplo.
7. Documentar en README la sección “On-Device TTS (sherpa_onnx)”.
