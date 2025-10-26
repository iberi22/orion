# Tarea 011: Despliegue a Google Cloud Run y Configuración

**Épico:** [02_voice_chat_and_agent_memory.md](../epics/02_voice_chat_and_agent_memory.md)

**Descripción:**
Desplegar la imagen Docker del servicio TTS a Google Cloud Run con variables de entorno, seguridad básica y pruebas de humo. Documentar pasos de despliegue y resultados (latencia/cold start).

**Criterios de Aceptación:**

1. Documentar `gcloud`/Artifact Registry para publicar imagen y `gcloud run deploy` (región, CPU/RAM, concurrencia, escala a 0).
2. Configurar `API_KEY`, `DEFAULT_LANG`, `DEFAULT_VOICE`, `SAMPLE_RATE`, `MODEL_STORE` como variables de entorno.
3. Habilitar CORS (orígenes de la app) y decidir si endpoint es público o requiere invocador autenticado.
4. Realizar smoke test con `curl` y desde la app (`CloudRunTTSAdapter`).
5. Medir latencia en caliente y en frío, anotar resultados en `docs/results/tts_report.md`.
6. Anotar costos estimados en nivel gratuito y consideraciones de escalado.
