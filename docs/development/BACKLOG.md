# AgentOrchestrator Backlog

**Version**: 0.3.0
**Updated**: 2026-02-25 (98/100 v0 done; 0/20 v0.3 done; 0/60 v1 planned)
**Scope**: v0 Milestone + v0.3 (Subagents Extension + Installer Redesign) + v1 (Full Orchestrator Vision)

---

## v0 / v0.3 Tasks

_Completed task history (98 tasks) → [docs/development/tasks/v0.md](tasks/v0.md)._

| ID | Milestone | Phase | Epic | Task | Requirement Trace | Linkage | Priority | Status |
|----|-----------|-------|------|------|-------------------|---------|----------|:------:|
| T-097 | v0 | Installer Extension | Gemini Capability Alignment | Align Gemini capability flags + install paths/tests with validated docs baseline (skills/subagents support model; hooks excluded by policy) | FR1.1, FR2.1, NFR4 | I-002 | P1 | 🔄 |
| T-101 | v0.3 | Subagents Extension | Claude Agent Teams | Add `--subagents` and `--experimental` flags to installer | FR1.2, NFR4 | T-115 | P0 | 🔲 |
| T-102 | v0.3 | Subagents Extension | Claude Agent Teams | Install Claude subagent `.md` files to `.claude/agents/` (project + global) | FR1.2, NFR4 | T-101 | P0 | 🔲 |
| T-103 | v0.3 | Subagents Extension | Claude Agent Teams | Inject `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` into `settings.json` env block when `--experimental` passed | FR1.2, NFR4 | T-101 | P1 | 🔲 |
| T-104 | v0.3 | Subagents Extension | Codex Multi-agent Roles | Install Codex multi-agent role config to `~/.codex/config.toml` `[agents]` section | FR1.2, NFR4 | T-101 | P1 | 🔲 |
| T-105 | v0.3 | Subagents Extension | Codex Multi-agent Roles | Install per-role TOML files to `~/.codex/agents/<name>.toml` | FR1.2, NFR4 | T-104 | P1 | 🔲 |
| T-106 | v0.3 | Subagents Extension | Codex Multi-agent Roles | Enable `features.multi_agent = true` in Codex config when `--experimental` passed | FR1.2, NFR4 | T-104 | P1 | 🔲 |
| T-107 | v0.3 | Subagents Extension | Gemini Subagents | Install Gemini subagent `.md` files to `.gemini/agents/` (project + global) | FR1.2, NFR4 | T-101 | P1 | 🔲 |
| T-108 | v0.3 | Subagents Extension | Gemini Subagents | Inject `experimental.enableAgents: true` into Gemini `settings.json` when `--experimental` passed | FR1.2, NFR4 | T-107 | P1 | 🔲 |
| T-109 | v0.3 | Subagents Extension | Gemini Subagents | Validate Gemini subagent frontmatter schema on install | FR1.2, NFR4 | T-107 | P1 | 🔲 |
| T-110 | v0.3 | Subagents Extension | Subagents Validation & CI | Update smoke tests for subagent artifact paths (all 3 runtimes) | FR1.2, NFR4 | T-102, T-105, T-107 | P0 | 🔲 |
| T-111 | v0.3 | Subagents Extension | Subagents Validation & CI | Add conformance tests for `--subagents`: correct paths + schema per runtime | FR1.2, NFR4 | T-110 | P0 | 🔲 |
| T-112 | v0.3 | Subagents Extension | Subagents Validation & CI | Add `--experimental` flag guard tests | FR1.2, NFR4 | T-110 | P1 | 🔲 |
| T-113 | v0.3 | Subagents Extension | Subagents Validation & CI | Update CI capability baseline checks to include `subagents` dimension | FR1.2, NFR4 | T-110 | P0 | 🔲 |
| T-114 | v0.3 | Subagents Extension | Subagents UX & Docs | Document `--subagents`/`--experimental` flags; update README capability matrix with `subagents` column | FR1.2, NFR4 | T-111 | P1 | 🔲 |
| T-115 | v0.3 | Installer Redesign | Architecture Decision | Write ADR-015: installer redesign from bash to Python (rationale, alternatives, migration path, Python toolchain choice) | NFR3, NFR4 | ADR-014 | P0 | 🔲 |
| T-116 | v0.3 | Installer Redesign | Module Decomposition Design | Design Python installer module decomposition: package structure, runtime module interfaces, shared-lib contract, CLI interface (entry point + flag contract) | NFR3, NFR4 | T-115 | P0 | 🔲 |
| T-117 | v0.3 | Installer Redesign | Python Package Bootstrap | Bootstrap Python installer package: pyproject.toml, CLI entry point (`orchestrator-install`), runtime dispatcher stub, uvx/pipx installable | NFR3, NFR4 | T-116 | P0 | 🔲 |
| T-118 | v0.3 | Installer Redesign | Runtime Modules | Implement runtime-scoped Python modules (claude, codex, gemini, opencode, qwen): each with install/uninstall/check functions; no cross-module coupling | NFR3, NFR4 | T-117 | P1 | 🔲 |
| T-119 | v0.3 | Installer Redesign | Shared Library | Implement shared Python library (`orchestrator_install/lib/`): JSON/YAML transforms, path resolution, idempotency helpers, settings-merge utilities | NFR3, NFR4 | T-117 | P1 | 🔲 |
| T-120 | v0.3 | Installer Redesign | Test Suite & CI | Write pytest suite for Python installer: unit tests per module + smoke integration tests replacing bash smoke.sh; CI integration | NFR3, NFR4 | T-118, T-119 | P0 | 🔲 |

---

## v1 Tasks

| ID | Milestone | Phase | Epic | Task | Requirement Trace | Linkage | Priority | Status |
|----|-----------|-------|------|------|-------------------|---------|----------|:------:|
| T-121 | v1 | POC | Setup | Build Orchestrator as globally installable Python binary (uvx/pipx) | NFR1, NFR3 | T-117 | P0 | 🔲 |
| T-122 | v1 | POC | Setup | Devcontainer/Docker image with pre-installed dependencies | NFR1 | T-121 | P0 | 🔲 |
| T-123 | v1 | POC | Setup | Global installation support (`orchestrator install`) | NFR1, NFR3 | T-121, T-122 | P0 | 🔲 |
| T-124 | v1 | POC | Strands Framework Integration | Strands Framework setup | FR4 | T-121 | P0 | 🔲 |
| T-125 | v1 | POC | Strands Framework Integration | Custom Anthropic provider with Claude SDK (not Client SDK) | FR4 | T-124 | P0 | 🔲 |
| T-126 | v1 | POC | Strands Framework Integration | Orchestrator standard SWE Workflow implementation | FR4, US4 | T-125 | P0 | 🔲 |
| T-127 | v1 | POC | Strands Framework Integration | Git Worktree per Agent (branch off feature branch, merge back after AC self-validation) | FR4 | T-126 | P1 | 🔲 |
| T-128 | v1 | POC | Structured Memory | Well-defined file-based KB with TOC file and index refs | FR5 | T-121 | P1 | 🔲 |
| T-129 | v1 | POC | Structured Memory | Well-defined Serena memory structure with proper refs across related docs/skills | FR5 | T-128 | P1 | 🔲 |
| T-130 | v1 | POC | Structured Memory | Context Manager agent to gather high-signal data and structure before handing back to Orchestrator | FR5 | T-128, T-129 | P1 | 🔲 |
| T-131 | v1 | MVP | Multi-Provider Support | A2A-MCP-Server for Gemini | FR1.2 | T-124 | P0 | 🔲 |
| T-132 | v1 | MVP | Multi-Provider Support | A2A-MCP-Server for Codex | FR1.2 | T-124 | P0 | 🔲 |
| T-133 | v1 | MVP | Multi-Provider Support | Strands A2A Configuration and Discovery Setup | FR1.2 | T-131, T-132 | P0 | 🔲 |
| T-134 | v1 | MVP | Workflow Refinement | Replace CC Hooks with Workflow steps | FR4 | T-126 | P0 | 🔲 |
| T-135 | v1 | MVP | Workflow Refinement | HITL controls integration | FR6 | T-134 | P0 | 🔲 |
| T-136 | v1 | MVP | Observability Foundation | OTEL (claude-code-otel) for Orchestrator | NFR2 | T-124 | P0 | 🔲 |
| T-137 | v1 | MVP | Observability Foundation | OTEL for Agents with parent span linkage | NFR2 | T-136 | P0 | 🔲 |
| T-138 | v1 | MVP | Observability Foundation | Prometheus + Loki integration | NFR2 | T-137 | P1 | 🔲 |
| T-139 | v1 | MVP | Observability Foundation | Grafana Dashboards | NFR2 | T-138 | P1 | 🔲 |
| T-140 | v1 | Foundation | Evaluations | Evaluation framework selection (Langfuse / Harbor / OpenEvals) | FR8 | T-139 | P0 | 🔲 |
| T-141 | v1 | Foundation | Evaluations | Evaluation framework integration | FR8 | T-140 | P0 | 🔲 |
| T-142 | v1 | Foundation | Evaluations | Automated quality assessment | FR8 | T-141 | P1 | 🔲 |
| T-143 | v1 | Foundation | Evaluations | Output validation | FR8 | T-141 | P1 | 🔲 |
| T-144 | v1 | Foundation | Data Foundation | Database selection (SQL/NoSQL/Graph/TS/OLAP) | NFR6 | T-130 | P0 | 🔲 |
| T-145 | v1 | Foundation | Data Foundation | Ontology schema (entities, relationships) | NFR6 | T-144 | P0 | 🔲 |
| T-146 | v1 | Foundation | Data Foundation | Knowledge GraphDB integration | NFR6 | T-145 | P1 | 🔲 |
| T-147 | v1 | Foundation | Data Foundation | Time-series DB (prices/metrics) | NFR2, NFR6 | T-144 | P1 | 🔲 |
| T-148 | v1 | Foundation | Data Foundation | Analytics OLAP | NFR6 | T-147 | P2 | 🔲 |
| T-149 | v1 | Foundation | Advanced Workflow Engine | L2 Graph: conditional routing via Strands Graph + A2A | FR4 | T-133 | P0 | 🔲 |
| T-150 | v1 | Foundation | Advanced Workflow Engine | L3 Swarm: autonomous mesh via Strands Swarm + A2A native | FR4 | T-149 | P0 | 🔲 |
| T-151 | v1 | Foundation | Advanced Workflow Engine | Result aggregation | FR4 | T-150 | P1 | 🔲 |
| T-152 | v1 | Foundation | Advanced Workflow Engine | Conflict resolution | FR4 | T-150 | P1 | 🔲 |
| T-153 | v1 | Foundation | Policy Engine | Steering contextual feedback | NFR5 | T-145 | P1 | 🔲 |
| T-154 | v1 | Foundation | Policy Engine | Policy-as-Code (OPA) integration | NFR5 | T-153 | P0 | 🔲 |
| T-155 | v1 | Foundation | Policy Engine | Agents RBAC/permissions management | NFR5 | T-154 | P0 | 🔲 |
| T-156 | v1 | Foundation | Policy Engine | Dynamic policy evaluation | NFR5 | T-155 | P1 | 🔲 |
| T-157 | v1 | Factory | Cloud Runtime | Docker in K8s/CloudRun | NFR1 | T-122 | P0 | 🔲 |
| T-158 | v1 | Factory | Cloud Runtime | Infra provisioning (Terraform/Pulumi) | NFR1 | T-157 | P0 | 🔲 |
| T-159 | v1 | Factory | Cloud Runtime | Environment isolation (ephemeral containers per run) | NFR4 | T-157 | P0 | 🔲 |
| T-160 | v1 | Factory | Cloud Runtime | VPC/INET isolation | NFR4 | T-158 | P1 | 🔲 |
| T-161 | v1 | Factory | Build Pipeline | GitOps integration (ArgoCD/Flux) | NFR1 | T-157 | P0 | 🔲 |
| T-162 | v1 | Factory | Build Pipeline | MLOps integration (model/prompt registry) | NFR6 | T-161 | P2 | 🔲 |
| T-163 | v1 | Factory | Build Pipeline | CI/CD workflow definitions | NFR1 | T-161 | P0 | 🔲 |
| T-164 | v1 | Factory | Build Pipeline | Artifact registry management | NFR1 | T-163 | P1 | 🔲 |
| T-165 | v1 | Factory | Security Controls | Secret Manager (1P/KeePass/GCP) integration | NFR4 | T-157 | P0 | 🔲 |
| T-166 | v1 | Factory | Security Controls | Agents OAuth and Authentication (subscription-based) | NFR4 | T-165 | P0 | 🔲 |
| T-167 | v1 | Factory | Security Controls | Cross-container restrictions | NFR4 | T-165 | P1 | 🔲 |
| T-168 | v1 | Factory | Security Controls | Runtime/CI/Cloud permissions escalation controls | NFR4 | T-166 | P1 | 🔲 |
| T-169 | v1 | Factory | OpenGuardrails | Command restriction in "Bypass permissions" mode | NFR4, NFR5 | T-165 | P0 | 🔲 |
| T-170 | v1 | Factory | OpenGuardrails | Content filtering | NFR4, NFR5 | T-169 | P1 | 🔲 |
| T-171 | v1 | Factory | OpenGuardrails | PII/secrets redaction | NFR4 | T-169 | P0 | 🔲 |
| T-172 | v1 | Factory | OpenGuardrails | Policy enforcement hooks | NFR4, NFR5 | T-170, T-171 | P0 | 🔲 |
| T-173 | v1 | Factory | Resource Management | Token budget allocation | NFR2, NFR3 | T-136 | P0 | 🔲 |
| T-174 | v1 | Factory | Resource Management | Compute resource limits | NFR2, NFR3 | T-157 | P1 | 🔲 |
| T-175 | v1 | Factory | Resource Management | Cost tracking | NFR2, NFR3 | T-173, T-174 | P1 | 🔲 |
| T-176 | v1 | Factory | Resource Management | Circuit breakers and rate limiting | NFR2, NFR3 | T-175 | P1 | 🔲 |
| T-177 | v1 | Factory | Autonomous Agents | Sensor/Ambient agent framework | FR4 | T-150, T-169 | P1 | 🔲 |
| T-178 | v1 | Factory | Autonomous Agents | Background monitoring routines | FR4 | T-177 | P1 | 🔲 |
| T-179 | v1 | Factory | Autonomous Agents | Goal-oriented research agents | FR4 | T-177 | P1 | 🔲 |
| T-180 | v1 | Factory | Autonomous Agents | Proactive collaboration | FR4 | T-178, T-179 | P2 | 🔲 |

---

## Task Details

Task details were decomposed per milestone.

- Active task details index: [docs/development/tasks/INDEX.md](tasks/INDEX.md)
- v0 tasks (completed + active): [docs/development/tasks/v0.md](tasks/v0.md)
- v0.3 task details: [docs/development/tasks/v0.3.md](tasks/v0.3.md)
- v1 task details: [docs/development/tasks/v1.md](tasks/v1.md)
- Completed v0 AC archive: [docs/development/archive/tasks-v0-completed.md](archive/tasks-v0-completed.md)

## Legends

### Priority

| Priority | Meaning |
|----------|---------|
| P0 | Critical path - blocks other tasks |
| P1 | Important - core functionality |
| P2 | Nice to have - can defer |

### Status

| Icon | Meaning |
|:----:|---------|
| ✅ | Done - implemented and committed |
| 🔲 | Pending - not yet started |
| 🔄 | In Progress - actively being worked on |
| 🚫 | Blocked - waiting on dependency |

---

## References

- **ROADMAP**: [ROADMAP.md](../objectives/ROADMAP.md)
- **PRD**: [PRD.md](../architecture/PRD.md)
- **Architecture**: [ARCHITECTURE.md](../architecture/ARCHITECTURE.md)
- **Task Hierarchy**: [ADR-005](../architecture/adr/005-task-decomposition-hierarchy.md)
