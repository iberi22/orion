# Tarea 013: Pruebas E2E, Métricas y Fallback TTS

**Épico:** [02_voice_chat_and_agent_memory.md](../epics/02_voice_chat_and_agent_memory.md)

**Descripción:**
Ejecutar pruebas end-to-end para validar TTS on-device y Cloud Run, medir latencias/footprint, documentar resultados y asegurar flujos de fallback (on-device ⇄ cloud) con mensajes claros.

**Criterios de Aceptación:**

1. Pruebas on-device (Android real): EN/ES, 5/20/60 palabras; latencia <~1–2s en frases cortas.
2. Pruebas Cloud Run: latencia en caliente y en frío; registrar cold start y estabilidad bajo 5–10 solicitudes consecutivas.
3. Validar fallback: si on-device no tiene modelos, UI sugiere descarga; si cloud falla, sugerir on-device.
4. Crear `docs/results/tts_report.md` con tablas/resúmenes de latencia, tamaño de modelos y comentarios de calidad.
5. Actualizar `TASK.md` con avances y marcar tareas completadas.
6. Actualizar `README` con guía de uso (offline/online) y limitaciones conocidas.
