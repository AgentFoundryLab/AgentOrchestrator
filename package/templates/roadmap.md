# {{PROJECT_NAME}} Roadmap

Hand-authored. **Not** an index like its neighbours `WORKORDERS.md`, `ISSUES.md`, `TECH_DEBT.md`, and `status/STATUS.md`.

This document is the bridge from [VISION.md](../objectives/VISION.md) to planning, and nothing else. It owns **ordering and rationale**. It does not own scope decomposition, schedule, workflow, or evidence — and it must never become a second Work Order or Milestone listing.

No id is minted here. Once a phase mints its `PLAN-*`, that Plan document owns the detail.

---

## Direction

{{Two or three paragraphs: where the product is going and why this order and not another. Name the
constraint that sets the sequence — a dependency, a risk to retire early, a decision waiting on
evidence.}}

## Order

| # | Phase | Plan | Why here | Status |
| --- | --- | --- | --- | --- |
| 1 | {{PHASE_NAME}} | [PLAN-{{NNN}}](plans/PLAN-{{NNN}}-{{slug}}.md) | {{the reason this comes before the next}} | {{Complete / Active / Planned}} |
| 2 | {{PHASE_NAME}} | [PLAN-{{NNN}}](plans/PLAN-{{NNN}}-{{slug}}.md) | {{...}} | Planned |
| 3 | {{PHASE_NAME}} | — *(not yet minted)* | {{...}} | Planned |

A phase with no `PLAN-*` yet is legitimate — it means the ordering is decided but the coordination
structure is not. Do not mint a Plan id here to fill the column.

## Superseded ordering

{{When the order changes, say what changed and why, once. Do not narrate every revision — the commit
log holds the history. Delete this section when empty.}}

<!--
Keep this document short. Its failure mode is growth: it accretes scope, milestone tables, and status
until it duplicates the Plan documents and the Work Order index, and then contradicts both.

If you are about to add a Work Order, a Milestone gate, an acceptance criterion, or a piece of
evidence here, it belongs in the Plan document, the Work Order record, the requirements document, or
the validation coverage instead.
-->
