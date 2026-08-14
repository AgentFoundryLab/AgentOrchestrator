# Feature Requirements: Hooks System

## Overview

Hooks give the workflow lifecycle awareness without taking control of it. They fire on session and sub-agent boundaries, write structured logs, and emit reminders the agent can act on — but they never enforce. That asymmetry is deliberate: an enforcing hook that misjudges context blocks legitimate work, while a reminder that misjudges context costs a line of output.

Hooks are Claude-only and off by default. They install only when explicitly requested, because a repository that gains blocking lifecycle scripts it did not ask for is harder to reason about than one without them.

## Terminology

- **Blocking hook**: its output reaches the agent before the agent completes, so the agent can act on it. It does not prevent completion.
- **Reminder pattern**: a hook prompts, the agent decides. Recorded in `ADR-FND-001`.
- **`Stop` versus `SessionEnd`**: `Stop` fires when the assistant finishes responding and can still invoke skills; `SessionEnd` fires when the session closes and cannot.

## Requirements

### REQ-003: Lifecycle hooks that remind without enforcing

**User Story:** As an operator, I want lifecycle hooks that surface validation and learning prompts, so that discipline is reinforced at boundaries without blocking legitimate work.

**Acceptance Criteria:**

- **AC-003.1:** On `SessionStart` and `SubagentStart` the system shall run `inject-context.sh` non-blocking, writing session and agent identifiers to `logs/sessions/`.
- **AC-003.2:** On `SubagentStop` the system shall run `remind-validate.sh` then `remind-agent-learn.sh`, both blocking and agent-scoped.
- **AC-003.3:** On `Stop` the system shall run `remind-session-learn.sh`, blocking, able to prompt for `$meta-learn`.
- **AC-003.4:** On `SessionEnd` the system shall run `checkpoint-session.sh` non-blocking, performing cleanup only.
- **AC-003.5:** Hooks shall emit reminders only; the agent or orchestrator decides whether to act. No hook shall prevent completion.
- **AC-003.6:** Hooks shall install only when explicitly requested, and only to runtimes whose hook model supports them.
- **AC-003.7:** A hook shall not name a skill that is not installed.
