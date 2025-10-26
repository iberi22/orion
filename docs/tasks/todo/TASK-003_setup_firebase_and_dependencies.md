# Tarea 003: Configurar Firebase y Dependencias del Chat de Voz

**Épico:** [02_voice_chat_and_agent_memory.md](../epics/02_voice_chat_and_agent_memory.md)

**Descripción:**
Configurar el proyecto de Firebase, añadir las dependencias necesarias de `pubspec.yaml` y asegurar que la aplicación se inicializa correctamente para soportar las nuevas funcionalidades de IA.

**Criterios de Aceptación:**

1. Añadir las siguientes dependencias a `pubspec.yaml`:
    - `firebase_core`
    - `firebase_ai`
    - `isar`
    - `isar_flutter_libs`
    - `isar_agent_memory` (apuntando a la versión correcta)
    - `flutter_sound` (o el paquete de captura de audio elegido)
    - `just_audio` (o el paquete de reproducción de audio elegido)
2. Configurar el proyecto de Flutter para Firebase si aún no se ha hecho (`flutterfire configure`).
3. Asegurar que `Firebase.initializeApp()` se llama correctamente en `main.dart`.
4. Inicializar Isar Core (`Isar.initializeIsarCore(download: true)`) en `main.dart`.
