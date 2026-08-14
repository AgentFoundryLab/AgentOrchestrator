# TD-{{NNN}}: {{drift or debt title}}

> Architecture-versus-code drift, or a deliberate shortcut carrying a removal trigger. Not a defect —
> a defect is an `ISS` with its `REG` reports. File at `docs/development/debt/TD-NNN.md`.
>
> Ids are immutable and never recycled; under `$orchestrate` they come from the brief.

## Classification

- Category / scope: `{{category}}` / `{{scope}}`
- Severity: `{{Critical | High | Medium | Low}}`
- Priority: `{{P0 | P1 | P2 | P3}}`

## Status

`{{Open | Deferred | Closed | Decommissioned}}` — {{current state}}.

## Links

- Governing blueprint: `FBP-{{TIER}}-{{NNN}}`
- Affected requirements: `REQ-{{NNN}}` / `TR-{{NNN}}`
- Related Work Order: `WO-{{NNN}}`

## Drift

{{What the blueprint or requirement says, and what the code actually does. Name both sides
concretely — a file and symbol on the code side, a section on the artifact side.}}

## Why it exists

{{The constraint that produced the gap. A deliberate shortcut says so plainly; an accidental drift
says when it was noticed and against what evidence.}}

## Removal trigger

{{The condition under which this must be paid down — a dependency landing, a scale threshold, a
requirement changing. "Someday" is not a trigger; without one this is not tracked debt but an
undocumented decision.}}

## Remediation

{{The fix shape and its validation boundary. Enough for a planner to size a Work Order from.}}
