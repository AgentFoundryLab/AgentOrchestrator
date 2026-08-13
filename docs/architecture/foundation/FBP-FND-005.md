# Component Blueprint: Hook System

## Capability Summary

Hooks observe lifecycle boundaries and emit reminders. They write structured session logs and prompt the agent at session and sub-agent transitions, but they never enforce — the agent decides. Hook input arrives as JSON on stdin; hook output reaches the agent as a system reminder.

## Core Components

```component
name: HookScript
container: Installed Runtime Root
responsibilities:
	- Parsing hook input from stdin using `hook-utils.sh`
	- Writing `session_id`- and `agent_id`-scoped records under `logs/sessions/`
	- Emitting a reminder the agent may act on
```

```component
name: HookUtils
container: Installed Runtime Root
responsibilities:
	- Parsing the hook payload once for every `#HookScript`
	- Resolving session and agent log directories
	- Writing lifecycle records so each script carries no duplicate I/O
```

Five scripts across five events. `#HookUtils` exists so the five share one parser rather than five copies that drift: `inject-context.sh` on `SessionStart` and `SubagentStart`, `remind-validate.sh` then `remind-agent-learn.sh` on `SubagentStop`, `remind-session-learn.sh` on `Stop`, `checkpoint-session.sh` on `SessionEnd`.

The `SubagentStop` pair is ordered and phase-gated: validation fires on the first stop, learning only after. `Stop` and `SessionEnd` are distinct — `Stop` can still invoke a skill, `SessionEnd` cannot.

## System Contracts

### Key Contracts

- A hook emits reminders only. No hook prevents completion.
- A hook never names a skill that is not installed.
- Hook logs are evidence: read-only, never committed.
- Hooks install only on request, and only where the runtime's hook model supports them.

### Integration Contracts

- **Host runtime**: invokes by event with a JSON payload on stdin; blocking hooks have their stdout delivered to the agent.
- **Learning capability**: `remind-agent-learn.sh` and `remind-session-learn.sh` prompt `$meta-learn`; neither invokes it.

## Architecture Decision Records

- [ADR-FND-001](../ADR/ADR-FND-001.md) — Hook reminder pattern
- [ADR-FND-010](../ADR/ADR-FND-010.md) — Observability architecture
