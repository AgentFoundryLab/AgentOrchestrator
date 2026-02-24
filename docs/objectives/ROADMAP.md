# AgentOrchestrator Roadmap

**Version**: 0.4.0
**Updated**: 2026-02-24

---

## Milestone Overview

| Milestone | Goal | Phases |
|-----------|------|--------|
| **v0** | Minimal viable multi-agent orchestration | Initial → Validation → Multi-Agent Installer → Governance & Quality |
| **v1** | Full Orchestrator vision | POC → MVP → Foundation → Factory |

---

# v0 Milestone

**Goal**: Minimal viable multi-agent orchestration framework for Claude Code.

**Scope**: 7 agents, 17 skills, 5 hooks, 2 workflows, 8 templates, 2 policies

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

## v0.1.1: Governance and Quality Controls

**Goal**: Governance bootstrapping (`/onboard`), cross-artifact review gate (`/review`), and unified HITL escalation protocol (`/hitl`).

**ADR**: [ADR-013](../architecture/adr/013-extended-skills.md)

---

### Governance & Quality Phase

Three skill additions addressing governance bootstrapping, pre-implementation review, and HITL consistency.

#### Epic: Governance and Quality Controls
**Depends on**: v0.1.0 complete

- [x] `onboard/SKILL.md` — codebase → STANDARDS.md + GUIDELINES.md (Architect)
- [x] `review/SKILL.md` — cross-artifact consistency gate (Tech Writer)
- [x] `hitl/SKILL.md` — shared HITL escalation protocol (non-invocable)
- [x] Update `architect.md` — add `onboard` to skills list
- [x] Update `tech-writer.md` — add `review` to skills list
- [x] Update `SWE.md` — insert /review gate between /plan and /implement (full workflow)
- [x] Update `PRD.md` — FR2 amended to 17 skills

**→ TAG: v0.1.1 ✅**

---

## v0.2.0: Multi-Agent Installer Extension

**Goal**: Extend installer for multi-agent runtimes with namespaced (dash/native) install paths.

---

### Installer Extension Phase

Runtime expansion and namespace standardization for install/restore/cleanup workflows.

Policy details are maintained in:
- `reports/research/2026-02-22-agent-capability-report.md` (Final capability policy, schema summary, and canonical mappings)
- `docs/knowledge/decisions/non-claude-hooks-policy.md` (Non-Claude hooks integration intentionally out of scope)
- `docs/knowledge/decisions/latest-compatible-only-policy.md` (Latest-native baseline; command-mode exception policy)

#### Epic: Runtime Matrix & Canonical Paths
**Depends on**: v0.1.0 complete

- [x] Define canonical runtime registry for `claude`, `gemini`, `codex`, `opencode`, `qwen`
- [x] Add installer targets for `--opencode` and `--qwen` (alongside existing runtime flags)
- [x] Codify Claude paths (`.claude/skills` canonical, `.claude/commands` compatibility)
- [x] Codify Codex paths (`.agents/skills` canonical; `.codex/prompts` legacy compatibility path)
- [x] Codify Gemini paths (`.gemini/skills` canonical; `.gemini/commands` compatibility profile; no hooks by policy)
- [x] Codify OpenCode paths (`.opencode/commands`, `.opencode/skills`, no hooks by policy)
- [x] Codify Qwen paths (`.qwen/commands`, `.qwen/skills`, no hooks)
- [x] Add runtime path drift checks (installer map vs package layout)
- [x] Define canonical frontmatter/schema transforms for `skills -> commands` conversion per runtime

#### Epic: Namespace Semantics
**Depends on**: Runtime Matrix & Canonical Paths

- [x] Define namespace grammar and validation (dash-notation token: `<namespace>`)
- [x] Map namespace to runtime-native command namespacing where supported, and dash fallback naming where not
- [x] Preserve flat mode as backward-compatible default when `--namespace` is omitted
- [x] Ensure namespace-safe restore/cleanup semantics for global and project modes

#### Epic: Capability-Scoped Installer Profiles
**Depends on**: Runtime Matrix & Canonical Paths

- [x] Split install profiles by capability (`commands`, `skills`, `hooks`, `scripts`)
- [x] Make `skills` the default profile when runtime supports skills
- [x] Add `commands` compatibility profile selectable by flag
- [x] Implement Claude profile (`commands+skills+hooks+scripts`)
- [x] Implement Codex profile (`skills+scripts` baseline, no hooks)
- [x] Remove Codex default prompts dual-write; keep prompts only in command-mode compatibility
- [x] Implement Gemini profile (`skills+scripts` baseline; commands compatibility profile; hooks excluded by policy)
- [x] Implement OpenCode profile (`commands+skills+scripts`, no hooks by policy)
- [x] Implement Qwen profile (`commands+skills+scripts`, no hooks)
- [x] Emit explicit warnings when user requests unsupported capabilities for selected runtime
- [x] Make policy-ref injection runtime-aware and idempotent across selected targets
- [x] Prevent cross-runtime collisions in context docs/files (e.g., shared root docs)

#### Epic: UX & Documentation
**Depends on**: Namespace Semantics, Capability-Scoped Installer Profiles

- [x] Update `install.sh --help` with multi-agent + namespaced examples
- [x] Document `skills` default and `commands` compatibility mode behavior
- [x] Document per-agent schema/frontmatter differences in commands mode
- [x] Update `README.md` install matrix for Claude/Codex/Gemini/OpenCode/Qwen
- [x] Document migration notes for legacy namespace and runtime path behavior

#### Epic: Validation & CI
**Depends on**: All Installer Extension epics

- [x] Add install smoke tests for runtime matrix (`global`, `project`)
- [x] Add capability conformance tests per runtime (commands/skills/hooks/scripts assertions)
- [x] Add restore/cleanup regression tests for namespaced installs
- [x] Add idempotency tests for repeated installs with mixed runtime subsets
- [x] Add CI guardrail to fail on runtime/path drift

**→ TAG: v0.2.0 ✅**

---

## v0.3: Subagents & Installer Modularization

**Goal**: (1) Decompose the monolithic `install.sh` into cohesive, single-responsibility runtime modules. (2) Extend installer with subagent artifacts for Claude Agent Teams (experimental), Codex multi-agent roles, and Gemini subagents.

**Sources**:
- `reports/research/2026-02-22-agent-capability-report.md` (updated 2026-02-24)
- `docs/knowledge/decisions/installer-modularity.md` (TDR, T-117)

---

### Installer Modularization Phase

Decompose `install.sh` (2300+ lines) before adding subagent features to prevent growth into an unmanageable monolith.

#### Epic: Installer Decomposition
**Depends on**: v0.2.0 complete

- [ ] Split `install.sh` into runtime-scoped modules (`claude`, `codex`, `gemini`, `opencode`, `qwen`) + main dispatcher (T-115)
- [ ] Extract shared installer library (`transforms`, `validation`, `utils`) (T-116)
- [ ] Write TDR: installer modularity principles — single-responsibility per module, no cross-runtime coupling (T-117)

---

### Subagents Extension Phase

Three runtime-specific subagent install epics run in parallel. Starts after Installer Modularization to avoid adding features into the monolith.

#### Epic: Claude Agent Teams (Experimental)
**Depends on**: Installer Decomposition complete
**Parallel**: Codex Multi-agent Roles, Gemini Subagents

- [ ] Add `--subagents` and `--experimental` flags to installer (T-101)
- [ ] Install Claude subagent `.md` files to `.claude/agents/` (project + global) (T-102)
- [ ] Inject `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` into `settings.json` `env` block when `--experimental` passed (T-103)

#### Epic: Codex Multi-agent Roles
**Depends on**: Installer Decomposition complete
**Parallel**: Claude Agent Teams, Gemini Subagents

- [ ] Install Codex multi-agent role config to `~/.codex/config.toml` `[agents]` section (T-104)
- [ ] Install per-role TOML files to `~/.codex/agents/<name>.toml` (T-105)
- [ ] Enable `features.multi_agent = true` in Codex config when `--experimental` passed (T-106)

#### Epic: Gemini Subagents
**Depends on**: Installer Decomposition complete
**Parallel**: Claude Agent Teams, Codex Multi-agent Roles

- [ ] Install Gemini subagent `.md` files to `.gemini/agents/` (project + global) (T-107)
- [ ] Inject `experimental.enableAgents: true` into Gemini `settings.json` when `--experimental` passed (T-108)
- [ ] Validate Gemini subagent frontmatter schema on install (T-109)

#### Epic: Subagents Validation & CI
**Depends on**: Claude Agent Teams, Codex Multi-agent Roles, Gemini Subagents

- [ ] Update `tests/install/smoke.sh` for subagent artifact paths (all 3 runtimes) (T-110)
- [ ] Add conformance tests for `--subagents`: correct paths + schema per runtime (T-111)
- [ ] Add `--experimental` flag guard tests (T-112)
- [ ] Update CI capability baseline checks to include `subagents` dimension (T-113)

#### Epic: Subagents UX & Documentation
**Depends on**: Subagents Validation & CI

- [ ] Document `--subagents`/`--experimental` flags; update README capability matrix with `subagents` column (T-114)

**→ TAG: v0.3.0**

---

# v1 Milestone (Orchestrator)

**Goal**: Full Orchestrator vision with observability, execution engine, and advanced workflows.

**Prerequisite**: v0.2.0 complete

---

## POC Phase

Strands Framework integration with A2A protocol foundation.

**Prerequisite**: v0.2.0 complete

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
├── Validation Phase ◄── All Initial Phase epics
│   └── Integration Validation
│       → TAG: v0.1.0
│
├── v0.2.0: Installer Extension ◄── v0.1.0
│   ├── Runtime Matrix & Canonical Paths
│   ├── Namespace Semantics
│   ├── Capability-Scoped Installer Profiles
│   ├── UX & Documentation
│   └── Validation & CI
│       → TAG: v0.2.0 (complete)
│
├── v0.3: Subagents & Installer Modularization ◄── v0.2.0
│   ├── Installer Decomposition (T-115–T-117)
│   │   └── Split install.sh → runtime modules + lib + TDR
│   ├── Claude Agent Teams ──────────────────────────────────┐
│   ├── Codex Multi-agent Roles ─────────────────────────────┤ (parallel, after T-115)
│   ├── Gemini Subagents ────────────────────────────────────┘
│   ├── Subagents Validation & CI ◄── all three above
│   └── Subagents UX & Documentation ◄── Validation & CI
│       → TAG: v0.3.0
│
└── v0.1.1: Governance & Quality ◄── v0.1.0
    └── Governance and Quality Controls (onboard, review, hitl + agent/workflow updates)
        → TAG: v0.1.1

v1 Milestone
├── POC Phase ◄── v0.2.0
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
| v0 | Initial | 14 | 47 | ✅ Complete |
| v0 | Validation | 1 | 3 | ✅ Complete |
| v0 | Installer Extension (v0.2.0) | 10 | 40 | ✅ Complete |
| v0 | Governance & Quality (v0.1.1) | 1 | 7 | ✅ Complete |
| v0 | Installer Modularization (v0.3) | 1 | 3 | 🔲 Not started |
| v0 | Subagents Extension (v0.3) | 5 | 14 | 🔲 Not started |
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
