# Identifier Migration Map

Date: 2026-08-13 · Serves WO-182

**Permanent and consulted forever.** Neither side of a row is ever reused for anything else.
Historical records — the original `adr/` files, `docs/archive/`, `docs/development/tasks/v0.md`,
and everything under `reports/` — keep their old ids because they record what was true when
written. This map is how a reader resolves them.

**Numbers are preserved across the type change.** `T-101` becomes `WO-101`, `FR3.2` becomes
`AC-003.2`, `ADR-014` becomes `ADR-FND-014`. Renumbering 180 records for contiguity would break
every historical reference for no gain. Type counters are independent, so a preserved number can
leave a gap in another type's sequence — `ISS` starts at 002 because `I-001` never existed. A
skipped number is harmless; a recycled one is not.

## Requirements — feature (`FR` → `REQ`/`AC`)

| Old | New | Title | Document |
| --- | --- | --- | --- |
| `FR1` | `REQ-001` | Agent System | `FRD-AGT-001` |
| `FR1.1` | `AC-001.1` | — | `FRD-AGT-001` |
| `FR1.2` | `AC-001.2` | — | `FRD-AGT-001` |
| `FR1.3` | `AC-001.3` | — | `FRD-AGT-001` |
| `FR1.4` | `AC-001.4` | — | `FRD-AGT-001` |
| `FR1.5` | `AC-001.5` | — | `FRD-AGT-001` |
| `FR2` | `REQ-002` | Skill Interface | `FRD-SKL-001` |
| `FR2.1` | `AC-002.1` | — | `FRD-SKL-001` |
| `FR2.2` | `AC-002.2` | — | `FRD-SKL-001` |
| `FR2.3` | `AC-002.3` | — | `FRD-SKL-001` |
| `FR2.4` | `AC-002.4` | — | `FRD-SKL-001` |
| `FR3` | `REQ-003` | Hooks System | `FRD-HOK-001` |
| `FR3.1` | `AC-003.1` | — | `FRD-HOK-001` |
| `FR3.2` | `AC-003.2` | — | `FRD-HOK-001` |
| `FR3.3` | `AC-003.3` | — | `FRD-HOK-001` |
| `FR3.4` | `AC-003.4` | — | `FRD-HOK-001` |
| `FR3.5` | `AC-003.5` | — | `FRD-HOK-001` |
| `FR4` | `REQ-004` | Workflow Templates | `FRD-WFL-001` |
| `FR4.1` | `AC-004.1` | — | `FRD-WFL-001` |
| `FR4.2` | `AC-004.2` | — | `FRD-WFL-001` |
| `FR4.3` | `AC-004.3` | — | `FRD-WFL-001` |
| `FR4.4` | `AC-004.4` | — | `FRD-WFL-001` |
| `FR5` | `REQ-005` | Memory System | `FRD-MEM-001` |
| `FR5.1` | `AC-005.1` | — | `FRD-MEM-001` |
| `FR5.2` | `AC-005.2` | — | `FRD-MEM-001` |
| `FR5.3` | `AC-005.3` | — | `FRD-MEM-001` |
| `FR5.4` | `AC-005.4` | — | `FRD-MEM-001` |
| `FR5.5` | `AC-005.5` | — | `FRD-MEM-001` |
| `FR5.6` | `AC-005.6` | — | `FRD-MEM-001` |
| `FR5.7` | `AC-005.7` | — | `FRD-MEM-001` |
| `FR5.8` | `AC-005.8` | — | `FRD-MEM-001` |
| `FR6` | `REQ-006` | Self-Validation | `FRD-VAL-001` |
| `FR6.1` | `AC-006.1` | — | `FRD-VAL-001` |
| `FR6.2` | `AC-006.2` | — | `FRD-VAL-001` |
| `FR6.3` | `AC-006.3` | — | `FRD-VAL-001` |
| `FR7` | `REQ-007` | Reflexion (Tactical) *(Decommissioned — superseded by REQ-008)* | `FRD-LRN-001` |
| `FR7.1` | `AC-007.1` | — | `FRD-LRN-001` |
| `FR7.2` | `AC-007.2` | — | `FRD-LRN-001` |
| `FR7.3` | `AC-007.3` | — | `FRD-LRN-001` |
| `FR7.4` | `AC-007.4` | — | `FRD-LRN-001` |
| `FR8` | `REQ-008` | Meta-Learning (Strategic) | `FRD-LRN-001` |
| `FR8.1` | `AC-008.1` | — | `FRD-LRN-001` |
| `FR8.2` | `AC-008.2` | — | `FRD-LRN-001` |
| `FR8.3` | `AC-008.3` | — | `FRD-LRN-001` |

`FR7` (Reflexion) describes a skill that no longer exists — `$meta-learn` absorbed reflexion,
reflection, and optimization into one loop. `REQ-007` keeps its id at `Decommissioned` with
`REQ-008` as its successor, rather than being deleted or renumbered.

## Requirements — technical (`NFR` → `TR`/`TRC`)

| Old | New | Constraint | Document |
| --- | --- | --- | --- |
| `NFR1` | `TR-001` (+ `TRC-001.1`) | Zero Python dependencies | `TRD-PLT-001` |
| `NFR2` | `TR-002` (+ `TRC-002.1`) | MCP footprint | `TRD-PLT-001` |
| `NFR3` | `TR-003` (+ `TRC-003.1`) | Installation time | `TRD-PLT-001` |
| `NFR4` | `TR-004` (+ `TRC-004.1`) | Claude Code compatibility | `TRD-PLT-001` |
| `NFR5` | `TR-005` (+ `TRC-005.1`) | Self-contained | `TRD-PLT-001` |
| `NFR6` | `TR-006` (+ `TRC-006.1`) | File count | `TRD-PLT-001` |

Each `NFR` was a single-line constraint with a target. It becomes a `TR` carrying the intent plus
one `TRC` carrying the verifiable requirement, so the `Verification` section has something to bind to.

## Requirements — user stories (`US` → `REQ`)

| Old | New | Title | Document |
| --- | --- | --- | --- |
| `US1` | `REQ-009` | Idea to PRD | `FRD-ORC-001` |
| `US2` | `REQ-010` | PRD to Architecture | `FRD-ORC-001` |
| `US3` | `REQ-011` | Architecture to Tasks | `FRD-ORC-001` |
| `US4` | `REQ-012` | End-to-End Orchestration | `FRD-ORC-001` |
| `US5` | `REQ-013` | Session Reflection | `FRD-ORC-001` |
| `US6` | `REQ-014` | Code Analysis | `FRD-ORC-001` |

User stories were end-to-end journeys spanning several components, so they promote to their own
requirements in an orchestration FRD rather than collapsing into a component requirement's ACs.
Their `Given/When/Then` bullets become that requirement's `AC-NNN.n`.

## Architecture decisions (`ADR-NNN` → `ADR-FND-NNN`)

| Old | New | Title |
| --- | --- | --- |
| `ADR-001` (`adr/001-hook-reminder-pattern.md`) | `ADR-FND-001` | hook reminder pattern |
| `ADR-002` (`adr/002-four-tier-memory.md`) | `ADR-FND-002` | four tier memory |
| `ADR-003` (`adr/003-minimal-mcp-footprint.md`) | `ADR-FND-003` | minimal mcp footprint |
| `ADR-004` (`adr/004-skill-agent-invocation-paths.md`) | `ADR-FND-004` | skill agent invocation paths |
| `ADR-005` (`adr/005-task-decomposition-hierarchy.md`) | `ADR-FND-005` | task decomposition hierarchy |
| `ADR-006` (`adr/006-policy-modularization.md`) | `ADR-FND-006` | policy modularization |
| `ADR-007` (`adr/007-multi-agent-protocol-selection.md`) | `ADR-FND-007` | multi agent protocol selection |
| `ADR-008` (`adr/008-multi-provider-integration-strategy.md`) | `ADR-FND-008` | multi provider integration strategy |
| `ADR-009` (`adr/009-orchestration-framework-selection.md`) | `ADR-FND-009` | orchestration framework selection |
| `ADR-010` (`adr/010-observability-architecture.md`) | `ADR-FND-010` | observability architecture |
| `ADR-011` (`adr/011-coordination-level-strategy.md`) | `ADR-FND-011` | coordination level strategy |
| `ADR-012` (`adr/012-governance-rationalization.md`) | `ADR-FND-012` | governance rationalization |
| `ADR-013` (`adr/013-extended-skills.md`) | `ADR-FND-013` | extended skills |
| `ADR-014` (`adr/014-multi-agent-installer.md`) | `ADR-FND-014` | multi agent installer |

All 14 govern the orchestrator's foundation, so all take the `FND` tier. No `SYS` or `FEAT` ADR is
minted here — inventing a tier split with no blueprint behind it would put structure in the id that
nothing downstream can resolve. Per-tier counters keep `FND` contiguous at 001-014.

## Feedback (`I-`/`G-` → `ISS`/`TD`)

| Old | New | Why this type |
| --- | --- | --- |
| `G-001` | `TD-001` | OpenCode hook incompatibility is an accepted platform gap with a policy decision behind it — drift, not a defect |
| `I-002` | `ISS-002` | Gemini capability drift is a defect with a root cause to diagnose |
| `I-006` | `ISS-006` | Runtime-isolation / command-transform regression is a defect |

`ISS-001`, `ISS-003`-`ISS-005`, and `TD-002`+ are never issued — preserved numbering leaves those
gaps permanently unused.

## Delivery (`T-nnn` → `WO-nnn`)

Every `T-nnn` maps to `WO-nnn` with the number preserved: `T-001` → `WO-001` through `T-180` →
`WO-180`. The mapping is total and mechanical, so it is stated as a rule rather than 180 rows.

The next free id is **`WO-181`**. This migration is `WO-181` (Phase A, the package) and `WO-182`
(Phase B, these artifacts).

## Delivery phases (milestones → `PLAN`)

| Old | New | Phase |
| --- | --- | --- |
| `v0` | `PLAN-001` | Core orchestration foundation and governance |
| `v0.3` | `PLAN-002` | Subagents extension and installer redesign |
| `v1` | `PLAN-003` | Full orchestrator platform |
| — | `PLAN-004` | Record-schema migration (`WO-181`, `WO-182`) |

