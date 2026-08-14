# Work Order Template

## Summary

State what is being built or changed and the outcome it enables in 2-3 sentences.

Implementation Plan: [WO-XXX-implementation-plan.md](WO-XXX-implementation-plan.md)

If no implementation plan is needed, write `Implementation Plan: None required.`

## In Scope

- Responsibility owned by this work order
- Another responsibility owned by this work order

## Out of Scope

- Explicit exclusion or deferred item
- Adjacent work handled elsewhere

## Requirements

Cross-reference the applicable requirements and acceptance criteria by immutable id — the
requirements document is the single source of truth. Give a brief high-level description per
id for quick context; do NOT copy the full requirement/AC text verbatim (it goes stale).
`$context-compiler` hydrates the full text on demand at implementation time.

| Requirement | In scope here (brief) |
| --- | --- |
| `REQ-001` | <one line: what this WO must satisfy from it> |
| `AC-001.1` | <one line: the acceptance this WO is on the hook for> |
| `TR-001` / `TRC-001.1` | <one line: the technical constraint in play> |

## Blueprints

- {Blueprint Name} - {one-line summary of what it covers}

## Test Plan

Keep Unit and Integration concise. Reserve structured scenario templates for E2E workflows.

### Unit Tests

- Focus on behavior, state transitions, invariants, and failure handling.
- Organize tests around the underlying behavior being validated, not surface-level symptoms.

### Integration Tests

- Focus on boundaries, contracts, interfaces, persistence, and messaging behavior.
- Keep concise unless setup or sequencing is unusual.

### E2E Tests

Use for full end-to-end workflows only. Use `COV_` ids for E2E coverage groups and `@COV_` tags for individual E2E test cases. Tag tests by the acceptance criterion they prove, never by the Work Order number.

```md
### COV_{SCOPE}_{NNN}: {Coverage Group Name}

**Surface:** `{user-facing workflow}`

**Scenarios:** End-to-end user flows that validate the scoped acceptance criteria

**Assertions:** User-visible outcomes, persisted state, and workflow completion

**Preconditions:** `{required data, state, or fixtures}`

**Selectors:** `{key selectors used by the workflow}`

**Tags:** {Tag(s) from coverage taxonomy} | **Priority:** {P0/P1/P2}

**@COV_{SCOPE}_{NNN}.1 - should {AC-aligned behavior}**

1. Sign in and navigate to {module}
2. {User action}
3. Assert {expected visible result}
4. {Next action}
5. Assert {state change or persistence}
```

<!--
Identity fields every WO carries at allocation (see the $planner skill):
  Phase (a PLAN-* id) . Milestone (an M-* id) . Category . Scope . Title
Then set: requirements, dependsOn, complexity, size, storyPoints, priority.
New Work Orders enter at Status: Open. Never invent a status -- $status-update owns it.
Ids are immutable: never renumber or recycle. Under $orchestrate ids come from the brief.
-->
