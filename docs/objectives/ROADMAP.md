# AgentOrchestrator Roadmap

**Version**: 0.3.4
**Updated**: 2026-02-20

---

## Milestone Overview

| Milestone | Goal | Phases |
|-----------|------|--------|
| **v0** | Minimal viable multi-agent orchestration | Initial → Validation |
| **v0.1.1** | Installer multi-agent extension | Installer Extension |
| **v1** | Full Orchestrator vision | POC → MVP → Foundation → Factory |

---

# v0 Milestone

**Goal**: Minimal viable multi-agent orchestration framework for Claude Code.

**Scope**: 7 agents, 14 skills, 5 hooks, 2 workflows, 8 templates, 2 policies

---

## Initial Phase

Core orchestration with file-based memory and MD workflow templates.

### Epic: Hook System
**Depends on**: None

- [x] `inject-context.sh` (SessionStart)
- [x] `remind-validate.sh` (SubagentStop)
- [x] `remind-reflexion.sh` (SubagentStop)
- [x] `remind-reflect.sh` (Stop)
- [x] `checkpoint-session.sh` (SessionEnd)

### Epic: Core Agents
**Depends on**: Hook System

- [x] `business-analyst.md`
- [x] `architect.md`
- [x] `project-manager.md`
- [x] `developer.md`

### Epic: Support Agents
**Depends on**: Hook System

- [x] `validator.md`
- [x] `deployer.md`
- [x] `tech-writer.md`

### Epic: Agent-Backed Skills
**Depends on**: Core Agents, Support Agents

- [x] `spec/SKILL.md`
- [x] `design/SKILL.md`
- [x] `plan/SKILL.md`
- [x] `implement/SKILL.md`
- [x] `validate/SKILL.md`
- [x] `deploy/SKILL.md`
- [x] `document/SKILL.md`

### Epic: Utility Skills
**Depends on**: None

- [x] `reflexion/SKILL.md`
- [x] `reflect/SKILL.md`
- [x] `optimize/SKILL.md`
- [x] `analyse/SKILL.md`
- [x] `research/SKILL.md`
- [x] `distill/SKILL.md`

### Epic: Orchestration
**Depends on**: Agent-Backed Skills

- [x] `orchestrate/SKILL.md`

### Epic: Policy
**Depends on**: None

- [x] `RULES.md`
- [x] `PRINCIPLES.md`

### Epic: Workflows
**Depends on**: None

- [x] `SWE.md`
- [x] `meta-learning.md`

### Epic: Templates
**Depends on**: None

- [x] `vision.md`
- [x] `blueprint.md`
- [x] `prd.md`
- [x] `architecture.md`
- [x] `adr.md`
- [x] `roadmap.md`
- [x] `backlog.md`
- [x] `issues.md`

### Epic: Settings & Installer
**Depends on**: None

- [x] Global `settings.json`
- [x] Project `settings.json`
- [x] `.claude/settings.json`
- [x] `install.sh` (global + project modes)
- [x] Add MCP servers: Serena, Context7, DeepWiki, Parallel Search, Parallel Task, Playwright

---

## Validation Phase

Integration testing and documentation.

### Epic: Integration Validation
**Depends on**: All Initial Phase epics

- [x] End-to-end test: `/orchestrate` workflow
- [x] Dogfood: use Orchestrator to build Orchestrator docs
- [x] Update README.md

**→ TAG: v0.1.0 ✅**

---

# v0.1.1 Multi-Agent Milestone

**Goal**: Extend installer for multi-agent runtimes with namespaced (dot-notation) install paths.

**Prerequisite**: v0.1.0 complete

---

## Installer Extension Phase

Runtime expansion and namespace standardization for install/restore/cleanup workflows.

### Epic: Runtime Matrix & Canonical Paths
**Depends on**: v0.1.0 complete

- [ ] Define canonical runtime registry for `claude`, `gemini`, `codex`, `opencode`, `qwen`
- [ ] Add installer targets for `--opencode` and `--qwen` (alongside existing runtime flags)
- [ ] Codify per-runtime command/context/skills path map in installer constants
- [ ] Add runtime path drift checks (installer map vs package layout)

### Epic: Namespace & Dot-Notation Semantics
**Depends on**: Runtime Matrix & Canonical Paths

- [ ] Define namespace grammar and validation (`<segment>[.<segment>...]`)
- [ ] Map dot-notation namespace to agent paths (directory tree) and skill names (`<ns>.<skill>`)
- [ ] Preserve flat mode as backward-compatible default when `--namespace` is omitted
- [ ] Ensure namespace-safe restore/cleanup semantics for global and project modes

### Epic: Capability-Scoped Installer Profiles
**Depends on**: Runtime Matrix & Canonical Paths

- [ ] Split install profiles by capability (`commands`, `skills`, `hooks`, `scripts`)
- [ ] Restrict non-Claude runtimes to supported capabilities; emit explicit warnings for unsupported ones
- [ ] Make policy-ref injection runtime-aware and idempotent across selected targets
- [ ] Prevent cross-runtime collisions in context docs/files (e.g., shared root docs)

### Epic: UX & Documentation
**Depends on**: Namespace & Dot-Notation Semantics, Capability-Scoped Installer Profiles

- [ ] Update `install.sh --help` with multi-agent + namespaced examples
- [ ] Update `README.md` install matrix for Claude/Codex/Gemini/OpenCode/Qwen
- [ ] Document migration notes for legacy namespace and runtime path behavior

### Epic: Validation & CI
**Depends on**: All Installer Extension epics

- [ ] Add install smoke tests for runtime matrix (`global`, `project`)
- [ ] Add restore/cleanup regression tests for namespaced installs (dot-notation)
- [ ] Add idempotency tests for repeated installs with mixed runtime subsets
- [ ] Add CI guardrail to fail on runtime/path drift

**→ TAG: v0.1.1 (planned)**

---

# v1 Milestone (Orchestrator)

**Goal**: Full Orchestrator vision with observability, execution engine, and advanced workflows.

**Prerequisite**: v0.1.1 complete

---

## POC Phase

Strands Framework integration with A2A protocol foundation.

**Prerequisite**: v0.1.1 complete

### Epic: Setup
**Depends on**: v0 complete

- [ ] Build Orchestrator as globally installable Python binary (uvx/pipx)
- [ ] Devcontainer/Docker image with pre-installed dependencies
- [ ] Global installation support (`orchestrator install`)

### Epic: Strands Framework Integration
**Depends on**: v1 Setup

- [ ] Strands Framework setup
- [ ] Custom Anthropic provider with Claude SDK (not Client SDK)
- [ ] Orchestrator standard SWE Workflow implementation
- [ ] Git Worktree per Agent (branch off current feature branch, merge back by Agent after acceptance criteria self-validation)

### Epic: Structured Memory
**Depends on**: v0 Memory System

- [ ] Well-defined file-based KB with TOC file & index refs
- [ ] Well-defined Serena memory structure with proper refs across related docs/skills
- [ ] Context Manager skill/agent to gather high-signal data and structure properly before handing back to Orchestrator

---

## MVP Phase

A2A protocol, Strands Agents, HITL controls, and Observability.

**Prerequisite**: POC Phase complete

### Epic: Multi-Provider Support
**Depends on**: Strands Framework Integration

- [ ] A2A-MCP-Server for Gemini
- [ ] A2A-MCP-Server for Codex
- [ ] Strands A2A Configuration & Discovery Setup

### Epic: Workflow Refinement
**Depends on**: Orchestrator standard SWE Workflow

- [ ] Replace CC Hooks with Workflow steps
- [ ] HITL controls integration

### Epic: Observability Foundation
**Depends on**: POC complete

- [ ] OTEL (claude-code-otel) for Orchestrator
- [ ] OTEL for Agents with parent span linkage
- [ ] Prometheus + Loki integration
- [ ] Grafana Dashboards

---

## Foundation Phase

Ontology, Graph DB, Evaluations, Advanced Workflows, Policy Engine.

**Prerequisite**: MVP Phase complete

### Epic: Evaluations
**Depends on**: Observability Foundation

- [ ] Evaluation framework selection (Langfuse OR Harbor OR OpenEvals)
- [ ] Framework integration
- [ ] Automated quality assessment
- [ ] Output validation

### Epic: Data Foundation
**Depends on**: Structured Memory

- [ ] Database selection (SQL/NoSQL/Graph/TS/OLAP)
- [ ] Ontology schema (entities, relationships)
- [ ] Knowledge GraphDB integration
- [ ] Time-series DB (prices/metrics)
- [ ] Analytics OLAP

### Epic: Advanced Workflow Engine
**Depends on**: Strands Agents

- [ ] L2 Graph: Conditional routing via Strands Graph + A2A
- [ ] L3 Swarm: Autonomous mesh via Strands Swarm + A2A native
- [ ] Result aggregation
- [ ] Conflict resolution

### Epic: Policy Engine
**Depends on**: Data Foundation

- [ ] Steering contextual feedback
- [ ] Policy-as-Code (OPA) integration
- [ ] Agents RBAC/permissions management
- [ ] Dynamic policy evaluation

---

## Factory Phase

Cloud Runtime, Build Pipeline, Security, Resource Management, Guardrails.

**Prerequisite**: Foundation Phase complete

### Epic: Cloud Runtime
**Depends on**: POC Devcontainer

- [ ] Docker in K8s/CloudRun
- [ ] Infra provisioning
- [ ] Environment isolation
- [ ] VPC/INET isolation

### Epic: Build Pipeline
**Depends on**: Cloud Runtime

- [ ] GitOps integration
- [ ] MLOps integration
- [ ] CI/CD workflow definitions
- [ ] Artifact registry management

### Epic: Security Controls
**Depends on**: Cloud Runtime

- [ ] Secret Manager (1P/KeePass/GCP) integration
- [ ] Agents OAuth & Authentication (subscription-based)
- [ ] Cross-container restrictions
- [ ] Runtime/CI/Cloud permissions escalation

### Epic: OpenGuardrails
**Depends on**: Security Controls

- [ ] Command restriction in "Bypass permissions" mode
- [ ] Content filtering
- [ ] PII/secrets redaction
- [ ] Policy enforcement hooks

### Epic: Resource Management
**Depends on**: Observability Foundation

- [ ] Token budget allocation
- [ ] Compute resource limits
- [ ] Cost tracking
- [ ] Circuit breakers & rate limiting

### Epic: Autonomous Agents
**Depends on**: Advanced Workflow Engine, OpenGuardrails

- [ ] Sensor/Ambient agent framework
- [ ] Background monitoring routines
- [ ] Goal-oriented research agents
- [ ] Proactive collaboration

**→ TAG: v1.0.0**

---

## Dependency Graph

```
v0 Milestone
├── Initial Phase
│   ├── Hook System ─────────────────┬──────────────────────┐
│   │                                │                      │
│   ├── Core Agents ◄────────────────┤                      │
│   │                                │                      │
│   ├── Support Agents ◄─────────────┘                      │
│   │                                                       │
│   ├── Agent-Backed Skills ◄── Core + Support Agents       │
│   │                                                       │
│   ├── Utility Skills (parallel) ──────────────────────────┤
│   ├── Policy (parallel) ──────────────────────────────────┤
│   ├── Workflows (parallel) ───────────────────────────────┤
│   ├── Templates (parallel) ───────────────────────────────┤
│   ├── Settings & Installer (parallel) ────────────────────┘
│   │
│   └── Orchestration ◄── Agent-Backed Skills
│
└── Validation Phase ◄── All Initial Phase epics
    └── Integration Validation
        → TAG: v0.1.0

v0.1.1 Patch Milestone
└── Installer Extension Phase ◄── v0.1.0
    ├── Runtime Matrix & Canonical Paths
    ├── Namespace & Dot-Notation Semantics
    ├── Capability-Scoped Installer Profiles
    ├── UX & Documentation
    └── Validation & CI
        → TAG: v0.1.1

v1 Milestone
├── POC Phase ◄── v0.1.1
│   ├── Strands Framework Integration
│   ├── MCP Enhancement
│   └── Structured Memory
├── MVP Phase ◄── POC
│   ├── Multi-Provider Support
│   ├── Workflow Refinement
│   └── Observability Foundation
├── Foundation Phase ◄── MVP
│   ├── Data Foundation
│   ├── Evaluations
│   ├── Advanced Workflow Engine
│   └── Policy Engine
└── Factory Phase ◄── Foundation
    ├── Cloud Runtime
    ├── Build Pipeline
    ├── Security Controls
    ├── OpenGuardrails
    ├── Resource Management
    └── Autonomous Agents
        → TAG: v1.0.0
```

---

## Progress Tracking

| Milestone | Phase | Epics | Tasks | Status |
|-----------|-------|-------|-------|--------|
| v0 | Initial | 10 | 40 | ✅ Complete |
| v0 | Validation | 1 | 3 | ✅ Complete |
| v0.1.1 | Installer Extension | 5 | 19 | 🔲 Not started |
| v1 | POC | 3 | 8 | 🔲 Not started |
| v1 | MVP | 3 | 9 | 🔲 Not started |
| v1 | Foundation | 4 | 16 | 🔲 Not started |
| v1 | Factory | 6 | 24 | 🔲 Not started |

---

## References

- **PRD**: [PRD.md](../architecture/PRD.md)
- **Architecture**: [ARCHITECTURE.md](../architecture/ARCHITECTURE.md)
- **Blueprint**: [BLUEPRINT.md](BLUEPRINT.md)
- **Task Hierarchy**: [ADR-005](../architecture/adr/005-task-decomposition-hierarchy.md)
