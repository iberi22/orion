# Tarea 010: Servicio TTS FastAPI y Docker Local

**Épico:** [02_voice_chat_and_agent_memory.md](../epics/02_voice_chat_and_agent_memory.md)

**Descripción:**
Crear `tools/tts_server/` con un servicio FastAPI que exponga `/tts`, `/voices` y `/_healthz`, utilice `sherpa-onnx` (o `kittentts`) para sintetizar y empaquetar en Docker para pruebas locales.

**Criterios de Aceptación:**

1. `tools/tts_server/main.py` con endpoints:
   - `POST /tts` => `audio/wav` (16/24 kHz, 16-bit mono) a partir de `{ text, lang, voice_id, sample_rate }`.
   - `GET /voices?lang=en|es` => lista de voces.
   - `GET /_healthz` => 200 OK.
2. `requirements.txt` con `fastapi`, `uvicorn`, y `sherpa-onnx` o `kittentts`.
3. `Dockerfile` basado en `python:3.11-slim` exponiendo `8080` (uvicorn) y README con instrucciones.
4. CORS habilitado y autenticación simple por API key (`Authorization: Bearer <KEY>`).
5. `docker build` y `docker run -p 8080:8080` funcionando; `curl` de ejemplo devuelve WAV válido.
6. Medir latencia local y registrar resultados básicos en el README.
