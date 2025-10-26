# Tarea 009: UI de Ajustes y Gestor de Modelos TTS

**Épico:** [02_voice_chat_and_agent_memory.md](../epics/02_voice_chat_and_agent_memory.md)

**Descripción:**
Crear una pantalla de ajustes `tts_settings_screen.dart` para seleccionar proveedor (`system`, `ondevice`, `cloud_run`, etc.), listar voces EN/ES desde el manifest, descargar/actualizar/eliminar modelos y elegir la voz activa.

**Criterios de Aceptación:**

1. Agregar conmutador de proveedor TTS y persistir selección (SharedPreferences/SecureConfigService).
2. Mostrar lista de voces por idioma (EN/ES), estado (instalado/no), tamaño y acciones (Descargar/Eliminar/Actualizar).
3. Mostrar progreso de descarga y validación (checksum OK) y notificar errores.
4. Mostrar espacio usado por modelos y opción de limpieza.
5. Guardar `voiceId` y `lang` activos y reflejarlos en el adaptador on-device.
6. Validar flujo completamente offline al tener modelos instalados.
