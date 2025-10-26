# Tarea 008: Gestor de Modelos y Manifest On-Device

**Épico:** [02_voice_chat_and_agent_memory.md](../epics/02_voice_chat_and_agent_memory.md)

**Descripción:**
Implementar un repositorio de modelos que gestione un `manifest` remoto (JSON) para voces EN/ES, la descarga con verificación (checksum), almacenamiento local y limpieza/actualización. Integrar con `SherpaOnnxTTSAdapter` para resolver rutas de modelo.

**Criterios de Aceptación:**

1. Definir `MODEL_MANIFEST_URL` en `AppConfig` y especificar el formato JSON: `{ voice_id, lang, name, size_bytes, sha256, files: [...] }`.
2. Crear `lib/services/models/model_repository.dart` con:
   - Descarga con `dio` y reintentos.
   - Verificación SHA256.
   - Listado de modelos instalados y su tamaño.
   - Eliminación de modelos.
3. Guardar modelos en `ApplicationDocumentsDirectory/tts_models/<voice_id>/...`.
4. Integrar con `SherpaOnnxTTSAdapter` para cargar rutas locales; error claro si el modelo no está instalado.
5. UI mínima de progreso (puede ser en consola/logs temporalmente) y manejo de errores.
6. Tests manuales: descargar una voz EN y una ES; verificar checksums y espacio usado.
