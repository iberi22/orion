# Tarea 006: Conectar el Cerebro del Agente al Pipeline de Voz

**Épico:** [02_voice_chat_and_agent_memory.md](../epics/02_voice_chat_and_agent_memory.md)

**Descripción:**
Orquestar el flujo de datos completo: desde el texto transcrito por Vertex AI, pasando por la consulta a la memoria, hasta la generación de la respuesta final y su almacenamiento.

**Criterios de Aceptación:**

1.  Recibir el texto transcrito del stream de Vertex AI (resultado de la Tarea 004).
2.  Usar el `AgentMemoryService` (de la Tarea 005) para buscar recuerdos relevantes con el texto transcrito como consulta.
3.  Construir un prompt enriquecido que incluya el texto del usuario y el contexto recuperado de la memoria.
4.  Enviar el prompt enriquecido al modelo Gemini a través de `firebase_ai`.
5.  Recibir la respuesta de texto de Gemini.
6.  Guardar el turno de la conversación (pregunta del usuario y respuesta de la IA) en la memoria usando el `AgentMemoryService`.
7.  Pasar el texto de la respuesta al sistema de reproducción de audio (que se implementará en la siguiente tarea).
