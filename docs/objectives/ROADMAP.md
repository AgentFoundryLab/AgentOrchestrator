# AgentOrchestrator Roadmap

**Version**: 0.4.1
**Updated**: 2026-02-24

---

## Milestone Overview

| Milestone | Goal | Status |
|-----------|------|--------|
| v0.1.0 | Core orchestration foundation | ✅ Complete |
| v0.1.1 | Governance and quality controls | ✅ Complete |
| v0.2.0 | Multi-runtime installer extension | ✅ Complete |
| v0.3.0 | Subagents extension + installer modularization | 🔄 In progress |
| v1.0.0 | Full orchestrator platform vision | 🔲 Planned |

---

## v0 Milestone (Completed Foundation)

**Goal**: Deliver a usable multi-agent orchestration baseline with executable workflows and policy controls.

### Initial Phase

#### Epic: Hook System
**Depends on**: None
**Status**: Complete
**Outcomes**:
- Standardized reminder/checkpoint lifecycle in orchestration flow.
- Stable session context injection and validation signaling.

#### Epic: Agent System
**Depends on**: Hook System
**Status**: Complete
**Outcomes**:
- Core and support agent roles established with clear boundaries.
- Skill-agent mapping operationalized for delivery workflow.

#### Epic: Skills and Workflow Engine
**Depends on**: Agent System
**Status**: Complete
**Outcomes**:
- End-to-end workflow path from specification through documentation.
- Utility skills for investigation, learning capture, and optimization.

#### Epic: Policy and Templates
**Depends on**: None
**Status**: Complete
**Outcomes**:
- Governance baseline codified for execution quality and artifact flow.
- Reusable artifact templates established across planning/design/delivery.

#### Epic: Installer Baseline
**Depends on**: None
**Status**: Complete
**Outcomes**:
- Project/global installation foundations in place.
- Baseline runtime/tooling setup standardized.

### Validation Phase

#### Epic: Integration Validation
**Depends on**: All Initial Phase epics
**Status**: Complete
**Outcomes**:
- Workflow integration validated through end-to-end execution.
- Core documentation and onboarding surfaces aligned with implemented behavior.

---

## v0.1.1 Milestone (Governance Extension)

**Goal**: Strengthen planning quality with onboarding, review gating, and shared HITL protocol.

#### Epic: Governance and Quality Controls
**Depends on**: v0.1.0 complete
**Status**: Complete
**Outcomes**:
- Governance onboarding flow added for project policy bootstrapping.
- Cross-artifact review gate integrated before implementation.
- HITL escalation path normalized across agents and workflows.

---

## v0.2.0 Milestone (Installer Extension)

**Goal**: Expand installer to multiple runtimes with consistent capability semantics.

### Installer Extension Phase

#### Epic: Runtime Matrix and Canonical Paths
**Depends on**: v0.1.0 complete
**Status**: Complete
**Outcomes**:
- Runtime support matrix formalized with canonical install targets.
- Drift detection between policy and installer behavior established.

#### Epic: Namespace Semantics
**Depends on**: Runtime Matrix and Canonical Paths
**Status**: Complete
**Outcomes**:
- Namespace behavior unified with explicit flat/default handling.
- Restore/cleanup behaviors aligned to namespace mode expectations.

#### Epic: Capability-Scoped Installer Profiles
**Depends on**: Runtime Matrix and Canonical Paths
**Status**: Complete
**Outcomes**:
- Installer profile model aligned to runtime capability boundaries.
- Compatibility behavior clarified without changing default strategic direction.

#### Epic: UX and Documentation
**Depends on**: Namespace Semantics, Capability-Scoped Installer Profiles
**Status**: Complete
**Outcomes**:
- Installer usage guidance aligned with capability model.
- Runtime behavior and compatibility messaging made consistent.

#### Epic: Validation and CI
**Depends on**: All Installer Extension epics
**Status**: Complete
**Outcomes**:
- Automated checks established for runtime conformance and drift detection.
- Regression coverage expanded for install/restore/cleanup consistency.

---

## v0.3.0 Milestone (Current Execution Stream)

**Goal**: Add subagent-oriented runtime support while reducing installer monolith risk through modularization.

### Phase: Installer Modularization

#### Epic: Installer Decomposition
**Depends on**: v0.2.0 complete
**Status**: In progress
**Outcomes**:
- Runtime-specific installer concerns isolated into modular boundaries.
- Shared transformation/validation concerns centralized for reuse.
- Modularity principles codified as operational policy.

### Phase: Subagents Extension

#### Epic: Runtime Subagents Enablement
**Depends on**: Installer Decomposition
**Status**: Planned
**Parallel**: Claude, Codex, Gemini runtime tracks
**Outcomes**:
- Runtime-specific subagent delivery paths enabled under unified policy model.
- Experimental-control behavior defined consistently for subagent flows.

#### Epic: Subagents Validation and Documentation
**Depends on**: Runtime Subagents Enablement
**Status**: Planned
**Outcomes**:
- Capability conformance and regression validation extended for subagents.
- User-facing guidance updated to reflect subagent support boundaries.

---

## v1 Milestone (Platform Expansion)

**Goal**: Evolve from framework baseline to production-grade orchestrator platform.
**Tactical details**: [docs/development/tasks/v1.md](../development/tasks/v1.md)

### POC Phase

#### Epic: Platform Setup
**Depends on**: v0 stream stability
**Status**: Planned
**Outcomes**:
- Executable platform packaging and repeatable development environment.
- Baseline operational install/run path for orchestrator runtime.

#### Epic: Framework Integration
**Depends on**: Platform Setup
**Status**: Planned
**Outcomes**:
- Workflow orchestration integrated with target execution framework.
- Multi-agent collaboration model formalized for implementation lifecycle.

#### Epic: Structured Memory
**Depends on**: v0 memory patterns
**Status**: Planned
**Outcomes**:
- Durable knowledge representation and retrieval structure.
- Stronger context handoff quality across agents.

### MVP Phase

#### Epic: Multi-Provider Support
**Depends on**: Framework Integration
**Status**: Planned
**Outcomes**:
- Provider interoperability layer for multi-runtime orchestration.
- Standard discovery/configuration flow across providers.

#### Epic: Workflow Refinement
**Depends on**: Framework Integration
**Status**: Planned
**Outcomes**:
- Hook-era behaviors migrated into explicit workflow steps.
- Human-in-the-loop controls embedded in runtime flow.

#### Epic: Observability Foundation
**Depends on**: POC completion
**Status**: Planned
**Outcomes**:
- Baseline tracing, metrics, and dashboarding for orchestrator + agents.
- Parent/child execution visibility across multi-agent runs.

### Foundation Phase

#### Epic: Evaluations
**Depends on**: Observability Foundation
**Status**: Planned
**Outcomes**:
- Measurable quality gates and automated output evaluation.

#### Epic: Data Foundation
**Depends on**: Structured Memory
**Status**: Planned
**Outcomes**:
- Core data layer for entities, relationships, and longitudinal signals.

#### Epic: Advanced Workflow Engine
**Depends on**: Agent framework maturity
**Status**: Planned
**Outcomes**:
- Conditional/graph/swarm workflow strategies with conflict management.

#### Epic: Policy Engine
**Depends on**: Data Foundation
**Status**: Planned
**Outcomes**:
- Dynamic policy controls for permissions, steering, and runtime governance.

### Factory Phase

#### Epic: Cloud Runtime
**Depends on**: Foundation readiness
**Status**: Planned
**Outcomes**:
- Isolated, scalable runtime deployment baseline.

#### Epic: Build Pipeline
**Depends on**: Cloud Runtime
**Status**: Planned
**Outcomes**:
- End-to-end delivery automation for platform artifacts.

#### Epic: Security Controls
**Depends on**: Cloud Runtime
**Status**: Planned
**Outcomes**:
- Identity, secret, and permission boundaries enforced across environments.

#### Epic: Guardrails and Resource Management
**Depends on**: Security and Observability maturity
**Status**: Planned
**Outcomes**:
- Runtime guardrails, budget controls, and stability protections.

#### Epic: Autonomous Operations
**Depends on**: Advanced Workflow Engine and Guardrails
**Status**: Planned
**Outcomes**:
- Background autonomous behaviors with safe operational boundaries.

---

## Dependency Summary

- v0.1.0 is the operational foundation for all subsequent releases.
- v0.2.0 depends on v0.1.0 governance and baseline installer stability.
- v0.3.0 depends on v0.2.0 and prioritizes modularity before feature expansion.
- v1.0.0 depends on v0 stream stabilization and validated multi-runtime behavior.

---

## Progress Tracking

| Stream | Current State |
|--------|---------------|
| v0.1.0 Foundation | ✅ Complete |
| v0.1.1 Governance | ✅ Complete |
| v0.2.0 Installer Extension | ✅ Complete |
| v0.3.0 Modularization + Subagents | 🔄 In progress |
| v1.0.0 Platform Expansion | 🔲 Planned |

---

## References

- **PRD**: [PRD.md](../architecture/PRD.md)
- **Architecture**: [ARCHITECTURE.md](../architecture/ARCHITECTURE.md)
- **Blueprint**: [BLUEPRINT.md](BLUEPRINT.md)
- **Task Hierarchy**: [ADR-005](../architecture/adr/005-task-decomposition-hierarchy.md)
- **Backlog Index**: [BACKLOG.md](../development/BACKLOG.md)
