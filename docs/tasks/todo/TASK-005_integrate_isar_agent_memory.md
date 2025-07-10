# Tarea 005: Integrar `isar_agent_memory`

**Épico:** [02_voice_chat_and_agent_memory.md](../epics/02_voice_chat_and_agent_memory.md)

**Descripción:**
Configurar e inicializar el paquete `isar_agent_memory` y crear una clase de servicio (o repositorio) que abstraiga la interacción con la memoria del agente.

**Criterios de Aceptación:**

1.  Crear un `AgentMemoryService` que encapsule la lógica de `isar_agent_memory`.
2.  En el servicio, inicializar el `MemoryGraph` con el `GeminiEmbeddingsAdapter` y la instancia de Isar.
3.  Implementar un método `saveMemory(String content)` que utilice `graph.storeNodeWithEmbedding`.
4.  Implementar un método `searchMemories(String query)` que genere el embedding de la consulta y utilice `graph.semanticSearch` para devolver los resultados más relevantes.
5.  Asegurar que la base de datos de Isar se abra y se cierre correctamente.
