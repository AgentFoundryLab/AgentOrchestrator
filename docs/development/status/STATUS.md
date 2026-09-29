# Implementation Status

Derived rollup across every record index. Owned by `$status-update`; no other stage writes here.

## Release picture

Shipping head: `dev` at `8a88d5a` (2026-09-29).

| Journey (`FRD-ORC-001`) | Highest proven verdict | Evidence |
| --- | --- | --- |
| `REQ-009` Idea to requirements | none proven | — |
| `REQ-010` Requirements to blueprints | none proven | — |
| `REQ-011` Blueprints to Work Orders | `faithful` for `AC-011.5`/`.6` only | `docs/validation/AC-015-outcome-anchored-delivery.md` |
| `REQ-012` End-to-end orchestrated delivery | `faithful` for `AC-012.8`/`.9` only | same |
| `REQ-013` Session learning | none proven | — |
| `REQ-014` Codebase investigation | none proven | — |
| `REQ-015` Outcome-anchored delivery | `faithful` (T0, installed copy) | same |

No journey is proven `journey-complete`.

Forecast basis: none. No representative slice has been completed and measured under the current process. Until one is, carry no delivery date.

> **Statuses are carried forward from the pre-migration assessment, not freshly verified.** The
> predecessor `PRD.md` and `BACKLOG.md` recorded the v0 milestone as complete, and these rows inherit
> that provenance. Only the criteria named under *Validation Coverage* below have coverage evidence.
> Run `$status-update` against the current codebase before citing any row as evidence.

## Requirements

| Status | Feature (`REQ`) | Technical (`TR`) |
| --- | --- | --- |
| Implemented | 14 | 6 |
| Partial | 0 | 0 |
| Not Implemented | 0 | 0 |
| Decommissioned | 1 (`REQ-007`) | 0 |
| **Total** | **15** | **6** |

## Work Orders

| Status | Count |
| --- | --- |
| Open | 80 |
| Implementing | 3 (`WO-097`, `WO-181`, `WO-182`) |
| Validating | 1 (`WO-183`) |
| Closed (archived) | 98 |
| **Total** | **182** |

## Feedback

| Type | Open | Closed | Deferred | Total |
| --- | --- | --- | --- | --- |
| `ISS` | 1 | 1 | 0 | 2 |
| `REG` | 1 | 0 | 0 | 1 |
| `TD` | 0 | 0 | 1 | 1 |
| `FB` | 0 | 0 | 0 | 0 |

## Phases

| Plan | Phase | Status |
| --- | --- | --- |
| `PLAN-001` | Core orchestration foundation | Complete |
| `PLAN-002` | Subagents extension + installer redesign | Active |
| `PLAN-003` | Full orchestrator platform | Draft |
| `PLAN-004` | Record schema migration | Active |

## Validation Coverage

| Document | Criteria | Level |
| --- | --- | --- |
| `AC-005-session-context-injection.md` | `AC-005.2`, `AC-005.4` | per document |
| `AC-015-outcome-anchored-delivery.md` | `AC-004.5`, `AC-011.5`, `AC-011.6`, `AC-012.8`, `AC-012.9`, `AC-015.1`–`AC-015.4` | `faithful` (T0) |

All other `AC`/`TRC` are uncovered. Their carried-forward status has no validation evidence behind it, and this is still the largest gap in the record set.
