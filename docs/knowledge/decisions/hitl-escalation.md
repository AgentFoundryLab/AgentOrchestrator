# HITL Escalation Decision

## Status

Superseded

## Date

2026-02-19

## Superseded

Superseded when the agent set adopted direct `AskUserQuestion` calls. Sub-agents now ask the user
directly; the `QUESTIONS FOR USER` relay block and the `hitl` skill that defined it were removed.
`/orchestrate` owns the list of decision points that require a user answer. This record is retained
for history — the protocol it describes is not live.

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

- `package/skills/orchestrate/SKILL.md` — current decision points
- `package/workflows/SWE.md`
- `AGENTS.md`
