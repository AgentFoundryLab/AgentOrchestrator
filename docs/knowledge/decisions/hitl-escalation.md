# HITL Escalation Decision

## Status

Accepted

## Date

2026-02-19

## Context

Task-spawned sub-agents need a consistent human-in-the-loop escalation path when blocked by missing user input.

## Decision

- Sub-agents spawned via `Task` tool cannot call `AskUserQuestion` directly.
- Sub-agents must emit the structured `## QUESTIONS FOR USER` block defined in `package/skills/hitl/SKILL.md`.
- The orchestrator relays each question via `AskUserQuestion`, collects answers, and re-invokes the same agent with answers prepended.
- The loop repeats until no blocking questions remain.

## Consequences

- HITL behavior is standardized across orchestrated sub-agents.
- Escalation format is centralized in one skill and can evolve without duplicating guidance in `AGENTS.md`.
- Agents must stop implementation when blocking questions are unresolved.

## References

- `package/skills/hitl/SKILL.md`
- `package/workflows/SWE.md`
- `AGENTS.md`
