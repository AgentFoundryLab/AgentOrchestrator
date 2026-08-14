# Orchestrator Design Blueprint

**Version**: 0.4.0
**Status**: Accepted
**Updated**: 2026-08-14

Solution scope and capability matrix. Distinct from an `FBP-*` Foundry blueprint, which specifies
technical structure.

**Two halves, and the split is the point.** *Delivered Capability* is what the package installs and
runs today. *Target Architecture* is `PLAN-003` scope: designed, not built, and not a description of
current behavior. The two used to be one undivided list, which is how this document came to assert
a 7-agent, 14-skill system with a live four-tier memory store — none of which was true.

---

## Target Architecture — `PLAN-003`, not built

### Core Design

### Protocol Stack
**Active Protocols:**
- **MCP**: Agent ↔ Tools/Resources (client-server)
- **A2A**: Orchestrator ↔ Agent (task-based coordination)

**Coordination Levels:**
- **L1 (Workflow)**: Sequential/DAG execution via Strands + A2A
- **L2 (Graph)**: Conditional routing via Strands Graph + A2A
- **L3 (Swarm)**: Autonomous coordination via Strands Swarm + A2A native mesh

### Ontology Foundation
1. Data (concepts/categories/objects/properties/links/events)
  - Knowledge Base (file-based/semantic)
  - Knowledge Graph (relations)
  - Time-series (prices/metrics)
  - Analytics (OLAP)
  - Observability Data Plane (logs/traces/metrics/evals captured as immutable facts)
2. Logic
  - Incentives (Goals/Roadmap/Tasks)
  - Policy (principles/rules/guidelines/guardrails)
  - Workflow/Graph/Swarm coordination
  - ML model, LLM-function
3. Actions
  - Runtime/Orchestration/Workflow Engine execution
  - Procedures (SOP/workflows/skills)
  - Data Retrieval (KB/Graph/Mon/Evals)

---

## Delivered Capability

Counts derived from `package/` on 2026-08-14.

### Agents (9)
Business Analyst, Architect, Planner, Developer, Validator, Security, Scout, Deployer, Tech Writer.
Each profile constrains its own tool grant; the boundaries are the product, not the count.

### Skills (23)
- **Agent-backed (12)**: spec, architect, planner, review, implement, validate, security-review,
  status-update, deploy, document, onboard, scout
- **Support (11)**: orchestrate, reconcile, context-compiler, meta-learn, cleanup, anneal, analyse,
  research, qmd, codebase-memory, distill

`$reflexion`, `$reflect`, and `$optimize` no longer exist — `$meta-learn` absorbed all three, and
`REQ-007` is `Decommissioned` in favor of `REQ-008`.

### Runtimes (5)
Claude Code, Codex CLI, Gemini CLI, OpenCode, Qwen Code — one package, per-runtime transforms driven
by the registry in `package/install/runtimes.sh`.

### Hooks (Claude Code only, opt-in via `--hooks`)
- **SessionStart** → inject session id, `PROJECT_NAME`, and the project knowledge index
- **SubagentStart** → inject agent identity
- **SubagentStop** → validation reminder, then a prompt to report the learning signal
- **Stop** → prompt `$meta-learn` for session learning
- **SessionEnd** → cleanup and logging

**Hooks remind; they never enforce** (`ADR-FND-001`). No hook blocks. Any capability described here
as gated is gated by a stage agent, not by a hook.

### Memory
Durable state is versioned files: `docs/knowledge/`, `docs/analysis/`, `docs/validation/`,
`reports/`. The tiered memory store in `ADR-FND-002` is **designed, not implemented** — no skill
issues `write_memory` or `read_memory`. `WO-128`/`WO-129`/`WO-130` own building it.

### MCP (5)

| Server | Purpose | Use When |
|--------|---------|----------|
| **Serena** | Memory, symbolic code ops | Recommended — no skill currently invokes it |
| **Context7** | Library/framework API docs | Need versioned lib docs, code examples |
| **DeepWiki** | GitHub repo documentation | Need to understand external repo architecture |
| **Parallel** | Search (web research), Task (deep research, data enrichment) | Web lookups, analyst reports, batch processing |
| **Playwright** | Browser automation | E2E testing, web scraping (optional) |

**Documentation lookup priority**: Context7 → DeepWiki → Parallel Search → WebSearch

---

## Target Architecture — component reference

Everything below is `PLAN-003` scope.

### Runtime Engine
1. Devcontainer (local)
2. Runtime Environment (Docker/K8s/CloudRun)
3. Git Worktree Isolation (per Agent/Task)
4. Build Pipeline (GitOps/MLOps)
5. Security Controls
6. Resource Management (Token/Compute budgets)

### Orchestrator Engine
1. Agent Lifecycle
  - Discovery & registration (A2A Agent Cards, MCP for tools)
  - Spawning & termination (A2A task creation)
  - Health monitoring & recovery (A2A task status polling)
2. Task Management
  - Decomposition & delegation
  - Dependency resolution and status tracking
  - Priority & resource allocation
3. Context Propagation
  - Shared state distribution
  - Knowledge graph sync
  - Session & project context via Context Manager
4. Coordination
  - **L1 Workflow**: Hub-spoke via Strands + A2A (orchestrator delegates tasks sequentially)
  - **L2 Graph**: Conditional routing via Strands Graph + A2A (orchestrator controls flow, optional peer A2A)
  - **L3 Swarm**: Autonomous mesh via Strands Swarm + A2A native (agents collaborate via A2A peer protocol)
  - Result aggregation via A2A task artifacts and Strands state
  - Conflict resolution via policy engine
5. Control Plane
  - Execution monitoring
  - Performance tracking
  - Circuit breakers & rate limiting

### Workflow Engine
1. Engine (Strands Framework)
  - Initiation - reactive (trigger/webhook), proactive (time/event)
  - 3-tier coordination (Workflow/Graph/Swarm)
  - Framework: Strands Agents (native A2A support)
  - Native OpenTelemetry observability
  - Human-in-the-Loop (HITL): A2A INPUT_REQUIRED state + Strands Interrupt
  - Persistent & shared state (A2A task history + Strands durable agent)
  - Failure management (A2A FAILED/CANCELED states)
2. Workflow templates
  - SWE: spec -> architect -> planner -> review -> delivery (`FRD`/`TRD` -> `FBP`/`ADR` -> `PLAN`/`WO` -> code/evidence/status)
  - Meta-Learning: session transcripts -> failure modes -> instruction patch plan -> approval -> apply -> re-validate
  - Background: Sensor Agents -> Background routines
  - Autonomous: Ambient Agents -> Goal-oriented Research -> Meta-Opt Plan, Implementation

### Workflow Services
1. Data Connectors (MCP for tools, A2A-MCP for agents)
2. Context Manager
3. Agents — see **Delivered Capability** above for the current nine; this list is the target set
4. Commands/Skills/MCP
  - Orchestrate (default Orchestrator instructions)
  - Spec (requirements, acceptance criteria)
  - Architect (blueprints/constraints/risks/trade-offs/ADR)
  - Planner (Plans, Milestones, Work Orders, dependencies)
  - Implement (code, tests, build)
  - Validate (quality, acceptance criteria)
  - Security-review (adversarial gate before status)
  - Status-update (assessed status across record indexes)
  - Deploy (build, release)
  - Document (docs, runbooks)
  - Meta-learn (session analysis, instruction fixes, re-validation)
  - Analyse (investigation/troubleshooting)
  - Research (parallel MCP)
  - Distill (compaction/distillation/adjustable granularity)
  - Evaluate
5. Hooks (Transitioning from CC Hooks to Strands Workflow steps)
6. Observability Service Plane
  - OpenTelemetry pipeline (claude-code-otel logs/traces/metrics)
  - Prometheus (metrics) + Loki (events/logs)
  - Grafana Dashboards/alerts
7. Evaluations
  - Framework: Langfuse OR Harbor OR OpenEvals

### Security Layer
- Isolation (devcontainer/docker/VM/VPC/INET)
- Secret Manager (1P/KeePass/GCP)
- OAuth & Authentication (Hybrid A2A-MCP Bridge for Claude, Gemini, Codex)
- Policy-as-Code (OPA)
- RBAC & Agent permissions management
- Approvals (HITL)
- OpenGuardrails (Content filtering, PII/secrets redaction, command restriction)

---

## Related Documents

- [VISION.md](VISION.md) - Why and for whom
- [REQUIREMENTS.md](../requirements/REQUIREMENTS.md) - REQ/AC and TR/TRC index
- [Blueprints](../architecture/) - Foundation, container, component, and feature blueprints
- [ROADMAP.md](../development/ROADMAP.md) - Phase ordering and rationale
- [ADRs](../architecture/ADR/README.md) - Architecture decision records
