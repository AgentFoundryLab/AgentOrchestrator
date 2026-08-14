# Requirements Index

Feature and technical requirements with their acceptance criteria.

Requirement prose lives in the `FRD-*` and `TRD-*` documents in this directory; this index is the
lookup surface. Status is owned by `$status-update` — no other stage sets it.

> **Statuses here are carried forward from the pre-migration assessment, not freshly verified.** The
> predecessor `PRD.md` and `BACKLOG.md` recorded the v0 milestone as complete, and these rows inherit
> that. No `AC`/`TRC` in this set has coverage evidence under `docs/validation/` yet. Run
> `$status-update` against the current codebase before citing any row as evidence, and treat every
> `Implemented` here as provenance-only until it does.

Ids are immutable. `docs/development/ID-MAP.md` resolves the pre-migration `FR`/`NFR`/`US` forms.

## Feature Requirements

| REQ | Title | Scope | Priority | Criteria | Document | Status |
| --- | --- | --- | --- | --- | --- | --- |
| REQ-001 | Installable agents with enforced role boundaries | agt | P0 | `AC-001.1`–`AC-001.7` | [FRD-AGT-001.md](FRD-AGT-001.md) | Implemented |
| REQ-002 | Runtime-portable skill interface | skl | P0 | `AC-002.1`–`AC-002.6` | [FRD-SKL-001.md](FRD-SKL-001.md) | Implemented |
| REQ-003 | Lifecycle hooks that remind without enforcing | hok | P1 | `AC-003.1`–`AC-003.7` | [FRD-HOK-001.md](FRD-HOK-001.md) | Implemented |
| REQ-004 | Complexity-scaled workflow depth with a fixed delivery chain | wfl | P0 | `AC-004.1`–`AC-004.6` | [FRD-WFL-001.md](FRD-WFL-001.md) | Implemented |
| REQ-005 | Session context injection and durable project knowledge | mem | P1 | `AC-005.1`–`AC-005.9` | [FRD-MEM-001.md](FRD-MEM-001.md) | Implemented |
| REQ-006 | Pre-handoff self-validation | val | P1 | `AC-006.1`–`AC-006.4` | [FRD-VAL-001.md](FRD-VAL-001.md) | Implemented |
| REQ-007 | Tactical error capture | lrn | P2 | — | [FRD-LRN-001.md](FRD-LRN-001.md) | Decommissioned |
| REQ-008 | Session analysis with gated rule optimization | lrn | P1 | `AC-008.1`–`AC-008.5` | [FRD-LRN-001.md](FRD-LRN-001.md) | Implemented |
| REQ-009 | Idea to requirements | orc | P0 | `AC-009.1`–`AC-009.3` | [FRD-ORC-001.md](FRD-ORC-001.md) | Implemented |
| REQ-010 | Requirements to blueprints | orc | P0 | `AC-010.1`–`AC-010.4` | [FRD-ORC-001.md](FRD-ORC-001.md) | Implemented |
| REQ-011 | Blueprints to Work Orders | orc | P0 | `AC-011.1`–`AC-011.4` | [FRD-ORC-001.md](FRD-ORC-001.md) | Implemented |
| REQ-012 | End-to-end orchestrated delivery | orc | P0 | `AC-012.1`–`AC-012.7` | [FRD-ORC-001.md](FRD-ORC-001.md) | Implemented |
| REQ-013 | Session learning | orc | P1 | `AC-013.1`–`AC-013.3` | [FRD-ORC-001.md](FRD-ORC-001.md) | Implemented |
| REQ-014 | Codebase investigation | orc | P2 | `AC-014.1`–`AC-014.4` | [FRD-ORC-001.md](FRD-ORC-001.md) | Implemented |

## Technical Requirements

| TR | Title | Scope | Priority | Criteria | Document | Status |
| --- | --- | --- | --- | --- | --- | --- |
| TR-001 | No language runtime dependency for core operation | plt | P1 | `TRC-001.1`–`TRC-001.2` | [TRD-PLT-001.md](TRD-PLT-001.md) | Implemented |
| TR-002 | Minimal MCP footprint | plt | P1 | `TRC-002.1`–`TRC-002.2` | [TRD-PLT-001.md](TRD-PLT-001.md) | Implemented |
| TR-003 | Install completes in seconds | plt | P1 | `TRC-003.1`–`TRC-003.2` | [TRD-PLT-001.md](TRD-PLT-001.md) | Implemented |
| TR-004 | Host runtime compatibility | plt | P1 | `TRC-004.1`–`TRC-004.3` | [TRD-PLT-001.md](TRD-PLT-001.md) | Implemented |
| TR-005 | Self-contained operation | plt | P1 | `TRC-005.1`–`TRC-005.2` | [TRD-PLT-001.md](TRD-PLT-001.md) | Implemented |
| TR-006 | Bounded and inspectable footprint | plt | P1 | `TRC-006.1`–`TRC-006.3` | [TRD-PLT-001.md](TRD-PLT-001.md) | Implemented |

---

14 feature requirements, 6 technical requirements.
`REQ-007` is `Decommissioned`, superseded by `REQ-008`; it keeps its id rather than being renumbered.
