# Tarea 004: Implementar Captura y Streaming de Audio

**Épico:** [02_voice_chat_and_agent_memory.md](../epics/02_voice_chat_and_agent_memory.md)

**Descripción:**
Crear la interfaz de usuario para la interacción por voz y la lógica para capturar el audio del micrófono y transmitirlo en tiempo real a Vertex AI a través del Gemini Live API.

**Criterios de Aceptación:**

1.  Crear un widget de UI con un botón "Pulsar para hablar" (Push-to-Talk).
2.  Implementar la lógica para solicitar permisos de micrófono.
3.  Al presionar el botón, iniciar la captura de audio desde el micrófono.
4.  Establecer una conexión de streaming bidireccional con Vertex AI usando `firebase_ai`.
5.  Enviar los fragmentos de audio capturados a través del stream.
6.  Al soltar el botón, finalizar el envío de audio.
