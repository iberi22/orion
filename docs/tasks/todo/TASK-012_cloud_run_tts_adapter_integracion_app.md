# Tarea 012: `CloudRunTTSAdapter` e Integración en la App

**Épico:** [02_voice_chat_and_agent_memory.md](../epics/02_voice_chat_and_agent_memory.md)

**Descripción:**
Implementar el adaptador `CloudRunTTSAdapter` que consuma el endpoint `/tts` del servicio FastAPI (local/Cloud Run), integrarlo con `TTSService` y la UI de Ajustes (URL y API key).

**Criterios de Aceptación:**

1. Crear `lib/services/tts/cloud_run_adapter.dart` con manejo de estados, timeouts, reintentos y errores.
2. Configurar `CLOUD_RUN_URL` y `CLOUD_RUN_API_KEY` en `AppConfig`/`SecureConfigService`.
3. Reproducir WAV recibido usando el pipeline actual; verificar sample rate/mono.
4. Añadir prueba unitaria que valide la secuencia de estados TTS para una frase corta (mock HTTP).
5. UI de Ajustes: campos para URL/API key y prueba de conexión.
6. Documentar configuración y troubleshooting en README.
