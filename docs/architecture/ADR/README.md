# Architecture Decision Record Index

Tier-scoped decision records. The tier names the blueprint family a decision governs —
`SYS` system, `FND` foundation/container/component, `FEAT` feature — and each tier has its own
counter. Every record is cross-referenced from the blueprint it governs and never inlined there.

Ids are immutable. `docs/development/ID-MAP.md` resolves the pre-migration `ADR-NNN` form.

| ADR | Title | Status |
| --- | --- | --- |
| [ADR-FND-001](ADR-FND-001.md) | Hook Behavior Pattern | Accepted |
| [ADR-FND-002](ADR-FND-002.md) | Four-Tier Memory System | Accepted |
| [ADR-FND-003](ADR-FND-003.md) | Minimal MCP Footprint | Accepted |
| [ADR-FND-004](ADR-FND-004.md) | Skill-Agent Invocation Paths | Accepted |
| [ADR-FND-005](ADR-FND-005.md) | Task Decomposition Hierarchy | Accepted |
| [ADR-FND-006](ADR-FND-006.md) | Policy Modularization | Accepted |
| [ADR-FND-007](ADR-FND-007.md) | Multi-Agent Protocol Selection (A2A over ACP) | Accepted |
| [ADR-FND-008](ADR-FND-008.md) | Multi-Provider Integration Strategy (Hybrid MCP + A2A) | Accepted |
| [ADR-FND-009](ADR-FND-009.md) | Orchestration Framework Selection (Strands Agents) | Accepted |
| [ADR-FND-010](ADR-FND-010.md) | Observability Architecture (OpenTelemetry Trace Propagation) | Accepted |
| [ADR-FND-011](ADR-FND-011.md) | Coordination Level Strategy (Progressive L1→L2→L3) | Accepted |
| [ADR-FND-012](ADR-FND-012.md) | Governance Rationalization | Accepted |
| [ADR-FND-013](ADR-FND-013.md) | Extended Skill Additions (onboard, review, hitl) | Accepted |
| [ADR-FND-014](ADR-FND-014.md) | Multi-Agent Installer v0.2 Design Decisions | Accepted |

---

14 records, all `FND` tier. No `SYS` or `FEAT` record is minted: inventing a tier split
with no blueprint behind it would encode structure in the id that nothing downstream can resolve.
