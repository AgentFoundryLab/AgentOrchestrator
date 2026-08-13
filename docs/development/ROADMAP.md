# AgentOrchestrator Roadmap

Hand-authored. **Not** an index like its neighbours `WORKORDERS.md`, `ISSUES.md`, `TECH_DEBT.md`, and `status/STATUS.md`.

This document is the bridge from [VISION.md](../objectives/VISION.md) to planning, and nothing else. It owns **ordering and rationale**. It does not own scope decomposition, schedule, workflow, or evidence — and it must never become a second Work Order or Milestone listing.

No id is minted here. Once a phase mints its `PLAN-*`, that Plan document owns the detail.

---

## Direction

AgentOrchestrator's value is not the agent count; it is that role boundaries are enforceable and that independent work runs in parallel without agents overwriting each other. Everything is ordered against that.

The foundation came first because boundaries need somewhere to live: agents, skills, hooks, policy, and an installer that can put them in front of a runtime. Multi-runtime delegation came second because a boundary that only holds on one runtime is a convention, not a contract — and extending it meant rebuilding the installer that carries it.

The record schema was pulled ahead of the platform work. It changes the artifact model every other phase's records are expressed in, so migrating it while a delivery phase authored Work Orders against the old model would mean authoring against a moving target. Doing it early cost one phase; doing it late would have cost every phase after.

Platform work comes last because it composes all three and is the only phase whose scope is still open.

## Order

| # | Phase | Plan | Why here | Status |
| --- | --- | --- | --- | --- |
| 1 | Core orchestration foundation | [PLAN-001](plans/PLAN-001-foundation.md) | Boundaries need agents, skills, hooks, policy, and an install path to exist at all | Complete |
| 2 | Subagents extension + installer redesign | [PLAN-002](plans/PLAN-002-subagents-and-installer.md) | A boundary that holds on one runtime only is a convention; the installer is what carries it to the rest | Active |
| 3 | Record schema migration | [PLAN-004](plans/PLAN-004-record-schema-migration.md) | Pulled ahead of platform work: it changes the model every later phase's records are written in | Active |
| 4 | Full orchestrator platform | [PLAN-003](plans/PLAN-003-platform.md) | Composes the three above; the only phase whose scope is still open | Planned |

`PLAN-004` carries a higher id than `PLAN-003` because ids are minted in allocation order and never renumbered. Sequence lives in this table, not in the number.

## Superseded ordering

The original plan ran the platform phase directly after the installer redesign, with no schema migration. Adopting the typed record schema inserted `PLAN-004` ahead of it once the cost of migrating later became clear.
