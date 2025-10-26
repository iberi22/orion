# Épico 2: Chat de Voz Conversacional con Memoria Cognitiva

**Resumen:**
Este épico describe la implementación de una funcionalidad de chat de voz en tiempo real. La interacción se basará en un pipeline de audio bidireccional que utiliza Firebase y Vertex AI para el reconocimiento de voz (Speech-to-Text) y la síntesis de voz (Text-to-Speech). El núcleo de la lógica conversacional residirá en un agente de IA que utilizará el paquete `isar_agent_memory` para la persistencia y recuperación de contexto, permitiendo conversaciones fluidas y coherentes.

---

## Arquitectura Propuesta

La arquitectura se divide en cuatro capas principales:

### 1. Interfaz de Usuario (UI Layer - Flutter)

- **Componente Principal:** Un botón de "Pulsar para hablar" (Push-to-Talk) que gestionará el estado de la grabación (grabando/en espera).
- **Flujo de Interacción:**
    1. El usuario presiona y mantiene el botón para comenzar a hablar.
    2. La aplicación captura el audio del micrófono en tiempo real.
    3. Al soltar el botón, la aplicación finaliza la captura y espera la respuesta de la IA.
    4. La respuesta de audio de la IA se reproduce automáticamente.

### 2. Pipeline de Audio (Client-Side - Flutter)

- **Captura de Audio:** Se utilizará un paquete de Flutter como `flutter_sound` o una solución nativa para capturar el stream de audio desde el micrófono del dispositivo en un formato compatible (e.g., PCM lineal de 16 bits).
- **Streaming a Firebase:** El stream de audio se enviará en tiempo real a Vertex AI utilizando la funcionalidad del **Gemini Live API**, accesible a través del paquete `firebase_ai`.

### 3. Procesamiento en la Nube (Firebase & Vertex AI)

- **Speech-to-Text (STT):** Vertex AI recibirá el stream de audio y realizará la transcripción a texto en tiempo real.
- **Generación de Respuesta (LLM):** El texto transcrito se enviará como prompt al modelo generativo de Gemini.
- **Text-to-Speech (TTS):** La respuesta de texto del modelo se enviará al servicio TTS de Vertex AI para generar el audio de respuesta.
- **Streaming de Respuesta:** El audio generado se devolverá al cliente en un stream para su reproducción inmediata.

### 4. Cerebro del Agente (Agent Brain)

- **Lógica Central:** Antes de enviar el texto transcrito a Gemini, el agente realizará una consulta a la memoria.
- **`isar_agent_memory`:**
  - **Recuperación de Contexto:** Se utilizará para buscar en la base de datos de Isar local los recuerdos, conversaciones pasadas o datos relevantes relacionados con el prompt del usuario.
  - **Enriquecimiento del Prompt:** La información recuperada se añadirá al prompt original para proporcionar un contexto más rico a Gemini, resultando en respuestas más precisas y personalizadas.
  - **Almacenamiento de Memoria:** La conversación actual (prompt del usuario y respuesta de la IA) se procesará y se guardará como un nuevo recuerdo en `isar_agent_memory` para futuras interacciones.

---

## Requisitos Técnicos

- **Flutter:** Versión >= 3.x
- **Dart:** Versión >= 3.2.0
- **Dependencias de `pubspec.yaml`:**
  - `firebase_core`
  - `firebase_ai`
  - `isar`
  - `isar_flutter_libs`
  - `isar_agent_memory`
  - Un paquete para la captura de audio (a definir, ej. `flutter_sound`).
  - Un paquete para la reproducción de audio (a definir, ej. `just_audio`).

## Próximos Pasos

1. **Validar `isar_agent_memory`:** Obtener la documentación o un ejemplo de código del autor para entender su API.
2. **Crear Tareas:** Desglosar este épico en tareas específicas en `docs/tasks/todo/`.
