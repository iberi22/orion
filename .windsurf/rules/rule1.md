---
trigger: always_on
---

# Project Awareness & Context

- **Always read `PLANNING.md` and the relevant epic file in `docs/epics/`** before starting a new task to fully understand the architecture, goals, and specific requirements.
- **Your primary context for any task is its corresponding file in the `docs/tasks/` directory.**

## Code & File Structure

- **For each major feature, a new Epic file must be created in `docs/epics/`.**
- **Break down Epics into specific, actionable tasks.** Each task must be a new `.md` file in the `docs/tasks/todo/` directory, following the `TASK-XXX_description.md` naming convention.

## ✅ Task Lifecycle

- When you start working on a task, **I will move its corresponding file** from `docs/tasks/todo/` to `docs/tasks/in-progress/`.
- Upon successful completion and testing, **I will move the task file** to `docs/tasks/done/`.
- **You must then update the main `README.md` dashboard** to reflect the high-level progress of the Epic.

## Style & Conventions

- **Primary Language:** Dart. and format all code with `black`.

- **Write Google-style docstrings** for every function and method.

## AI Behavior

- **Never assume missing context.** Your full context for a task is defined by `PLANNING.md`, the relevant epic file, and the specific task file. Ask for clarification if anything is ambiguous.
- **Never hallucinate libraries or functions.** Only use packages listed in `pyproject.toml` or well-known Python standard libraries.
- **Always confirm file paths** relative to the project root before creating, reading, or modifying files.