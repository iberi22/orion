# Gestión de Tareas: Orion TTS

_Última actualización: 2025-08-10_

---

## 🎯 Resumen Ejecutivo y Estado Actual

**Estado General:** 55% - Arquitectura multi-proveedor lista (system, kitten bridge, Gemini). Siguiente foco: habilitar TTS 100% on-device (sherpa_onnx) y backend Python (Docker → Cloud Run), más UI para descargar modelos EN/ES.

**Progreso por Componente:**

- [ ] 🏗️ Infraestructura (Workflows, Docker, Cloud Run): 30%
- [ ] 🔗 Backend TTS (FastAPI/Docker/Cloud Run): 15%
- [ ] 📱 On-Device TTS (sherpa_onnx): 35%
- [ ] 🎨 Frontend UI (Ajustes + gestor de modelos): 10%
- [ ] 🧪 Testing (unit + e2e): 40%
- [ ] 📚 Documentación: 65%

---

## 📐 Instrucciones para Windsurf Rules

- Las reglas generales deben seguir este archivo como fuente de verdad operacional.
- Prompt recomendado para IA: "Update TASK.md to mark XYZ as done and add ABC as a new task."
- Workflows de Windsurf deben apuntar a tareas de esta fase (build/run Docker, deploy Cloud Run, instalación de modelos on-device, pruebas e2e TTS).

---

## 🚀 Fase Actual: "Integración Dual TTS (On-Device + Backend Cloud Run)"

**Objetivo:** Habilitar síntesis 100% en el dispositivo con `sherpa_onnx` (modelos EN/ES descargables) y un backend Python (FastAPI) contenedorizado, primero en Docker local y luego desplegado en Google Cloud Run, conmutables desde la app.

| ID    | Tarea                                                                                           | Prioridad | Estado        | Responsable |
|-------|--------------------------------------------------------------------------------------------------|-----------|---------------|-------------|
| F1-01 | Crear `SherpaOnnxTTSAdapter` y proveedor `ondevice` en `lib/services/tts/`                      | ALTA      | ✅ Completado | Cascade     |
| F1-02 | Gestor de modelos EN/ES: manifest remoto, descarga, checksum, paths locales                     | ALTA      | ✅ Completado | Cascade     |
| F1-03 | UI de Ajustes: selector de proveedor, lista de voces EN/ES, descarga/actualización/eliminación  | ALTA      | ⚙️ En Progreso| Cascade     |
| F1-04 | Reproducción PCM/WAV con pipeline actual (latencia/fidelidad)                                   | MEDIA     | ⬜ Pendiente  | Cascade     |
| F1-05 | Servicio FastAPI (`tools/tts_server/`): endpoints `/tts`, `/voices`, `/_healthz`                 | ALTA      | ⬜ Pendiente  | Cascade     |
| F1-06 | Dockerfile y ejecución local (smoke tests con `curl`/Postman)                                    | ALTA      | ⬜ Pendiente  | Cascade     |
| F1-07 | `CloudRunTTSAdapter` + configuración `AppConfig` (`CLOUD_RUN_URL`, `CLOUD_RUN_API_KEY`)         | ALTA      | ⬜ Pendiente  | Cascade     |
| F1-08 | Despliegue a Cloud Run (CPU/RAM, CORS, API Key, escalado a 0)                                    | ALTA      | ⬜ Pendiente  | Cascade     |
| F1-09 | Workflows Windsurf: build/run Docker, deploy Cloud Run, on-device setup                          | MEDIA     | ⬜ Pendiente  | Cascade     |
| F1-10 | Fallback y switches: `ondevice` ⇄ `cloud_run` (manejo de errores y sugerencias en UI)            | MEDIA     | ⬜ Pendiente  | Cascade     |
| F1-11 | Métricas: latencia (5/20/60 palabras), cold start, footprint en disco                            | BAJA      | ⬜ Pendiente  | Cascade     |
| F1-12 | Licencias y avisos de modelos (EN/ES), documentación de origen y uso                             | BAJA      | ⬜ Pendiente  | Cascade     |

**Leyenda de Estado:**

- `⬜ Pendiente`
- `⚙️ En Progreso`
- `✅ Completado`
- `❌ Bloqueado`

---

## ✅ Hitos Principales Completados

- Arquitectura TTS multi-proveedor y `TTSService` delegando por `AppConfig.ttsProvider`.
- Adaptadores: `system` (flutter_tts), `kitten` (FastAPI bridge), `cloud` (Gemini) con manejo de WAV/PCM.
- `SecureConfigService` (flutter_secure_storage) y canal nativo Android para compartir APK (method channel + helper Dart).
- Bridge KittenTTS con síntesis real (wheel oficial) y README de instalación/uso.
- On-Device: `SherpaOnnxTTSAdapter` creado y verifica instalación de modelos con `OnDeviceTTSModelManager`.
- On-Device: Gestor de modelos (`lib/services/tts/model_manager.dart`) + manifest inicial (`assets/tts/manifest.json`).
- Pruebas unitarias:
  - `test/tts/model_manager_test.dart` (instalación, checksum, borrado).
  - `test/tts/sherpa_adapter_test.dart` (error si falta modelo instalado).
  - Secuencia de estados TTS (start/speaking/completed/error).

---

## 👾 Deuda Técnica y Mejoras Pendientes

| ID    | Tarea                                                                                 | Prioridad | Estado       | Responsable |
|-------|-----------------------------------------------------------------------------------------|-----------|--------------|-------------|
| TD-01 | Soporte iOS completo para `sherpa_onnx` (binarios, paths, permisos, pruebas reales)    | ALTA      | ⬜ Pendiente | Cascade     |
| TD-02 | Caching y limpieza de modelos (limitar espacio, versiones)                              | MEDIA     | ⬜ Pendiente | Cascade     |
| TD-03 | Telemetría de errores TTS y tiempos (on-device y cloud)                                 | MEDIA     | ⬜ Pendiente | Cascade     |
| TD-04 | Mejorar pipeline de audio (colas, cancelación, ducking)                                 | MEDIA     | ⬜ Pendiente | Cascade     |
| TD-05 | Evaluar NNAPI/CoreML en ORT si fuera necesario                                           | BAJA      | ⬜ Pendiente | Cascade     |

---

## 📝 Tareas Descubiertas Durante el Desarrollo

| ID    | Tarea                                                                                                  | Prioridad | Estado        | Responsable |
|-------|--------------------------------------------------------------------------------------------------------|-----------|---------------|-------------|
| AD-01 | Selección final de 1–2 voces por idioma (EN/ES) balanceando calidad/tamaño                             | ALTA      | ⬜ Pendiente  | Cascade     |
| AD-02 | Definir `MODEL_MANIFEST_URL` (GCS/GitHub Pages) y formato JSON (voice_id, idioma, tamaños, checksums)  | ALTA      | ⬜ Pendiente  | Cascade     |
| AD-03 | Guías UX para descargar/actualizar modelos, manejo de espacio y estado offline                         | MEDIA     | ⬜ Pendiente  | Cascade     |

---

## 📥 Backlog (relacionado y de otras áreas)

| ID      | Tarea                                               | Prioridad | Estado       | Responsable |
|---------|-----------------------------------------------------|-----------|--------------|-------------|
| TASK-003| Configurar Firebase y dependencias del chat de voz  | MEDIA     | ⬜ Pendiente | Cascade     |
| TASK-004| Implementar captura y streaming de audio            | MEDIA     | ⬜ Pendiente | Cascade     |
| TASK-005| Integrar `isar_agent_memory`                        | MEDIA     | ⬜ Pendiente | Cascade     |
| TASK-006| Conectar el "cerebro" del agente al pipeline de voz| MEDIA     | ⬜ Pendiente | Cascade     |

---

## 📎 Referencias técnicas clave

- `sherpa_onnx` (Flutter): <https://pub.dev/packages/sherpa_onnx>
- Docs TTS sherpa-onnx: <https://k2-fsa.github.io/sherpa/onnx/tts/index.html>
- `flutter_tts` (motor del sistema): <https://pub.dev/packages/flutter_tts>
- ONNX Runtime (Flutter): <https://pub.dev/packages/onnxruntime>
- KittenTTS (bridge actual y wheel): <https://github.com/KittenML/KittenTTS>
- Cloud Run (despliegue): <https://cloud.google.com/run>

---

## 🤖 Prompt para IA

"Update TASK.md to mark XYZ as done and add ABC as a new task."
