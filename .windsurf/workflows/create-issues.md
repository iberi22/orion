# /create-issues

Purpose: Convert docs/tasks/todo items into GitHub issues using `gh` CLI.

## Prereqs
- Install GitHub CLI and authenticate: `gh auth login`

## Commands (PowerShell)
```powershell
# Update repo/owner accordingly
$REPO = (git config --get remote.origin.url)

# TASK-003: Configurar Firebase y Dependencias del Chat de Voz
gh issue create --title "TASK-003: Configurar Firebase y Dependencias del Chat de Voz" --body "See docs/tasks/todo/TASK-003.md" --label enhancement --repo $REPO

# TASK-004: Implementar Captura y Streaming de Audio
gh issue create --title "TASK-004: Implementar Captura y Streaming de Audio" --body "See docs/tasks/todo/TASK-004.md" --label enhancement --repo $REPO

# TASK-005: Integrar isar_agent_memory
gh issue create --title "TASK-005: Integrar isar_agent_memory" --body "See docs/tasks/todo/TASK-005.md" --label enhancement --repo $REPO

# TASK-006: Conectar el Cerebro del Agente al Pipeline de Voz
gh issue create --title "TASK-006: Conectar el Cerebro del Agente al Pipeline de Voz" --body "See docs/tasks/todo/TASK-006.md" --label enhancement --repo $REPO
```

## Notes
- Adjust labels/milestones as needed.
- Validate file paths in `docs/tasks/todo/` before running.
