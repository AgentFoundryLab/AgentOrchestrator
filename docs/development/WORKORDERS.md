# Work Order Index

Active Work Orders. Closed and decommissioned records move to
[`../archive/development/WORKORDERS.md`](../archive/development/WORKORDERS.md).

Work Order prose lives in `workorders/WO-NNN.md`; this index is the lookup surface. `Phase` names the
`PLAN-*` this item belongs to and is authored here on the record — the Plan document never lists its
Work Orders.

`Complexity` selects the delivery model tier; see `$orchestrate` for the tier→model table. Status is
owned by `$status-update`. Ids are immutable — `../development/ID-MAP.md` resolves the pre-migration
`T-nnn` form.

| WO | Phase | Milestone | Category | Scope | Title | Depends On | Complexity | Priority | Requirements | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| WO-097 | PLAN-001 | — | test | installer | Align Gemini capability flags + install paths/tests with validated docs baseline (skills/subagents support model; hooks excluded by policy) | `ISS-002` | Medium | P1 | `AC-001.1`, `AC-002.1`, `TR-004` | Implementing |
| WO-101 | PLAN-002 | — | feature | installer | Add `--subagents` and `--experimental` flags to installer | `WO-115` | High | P0 | `AC-001.2`, `TR-004` | Open |
| WO-102 | PLAN-002 | — | feature | installer | Install Claude subagent `.md` files to `.claude/agents/` (project + global) | `WO-101` | High | P0 | `AC-001.2`, `TR-004` | Open |
| WO-103 | PLAN-002 | — | feature | agents | Inject `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` into `settings.json` env block when `--experimental` passed | `WO-101` | Medium | P1 | `AC-001.2`, `TR-004` | Open |
| WO-104 | PLAN-002 | — | feature | installer | Install Codex multi-agent role config to `~/.codex/config.toml` `[agents]` section | `WO-101` | Medium | P1 | `AC-001.2`, `TR-004` | Open |
| WO-105 | PLAN-002 | — | feature | installer | Install per-role TOML files to `~/.codex/agents/<name>.toml` | `WO-104` | Medium | P1 | `AC-001.2`, `TR-004` | Open |
| WO-106 | PLAN-002 | — | feature | agents | Enable `features.multi_agent = true` in Codex config when `--experimental` passed | `WO-104` | Medium | P1 | `AC-001.2`, `TR-004` | Open |
| WO-107 | PLAN-002 | — | feature | installer | Install Gemini subagent `.md` files to `.gemini/agents/` (project + global) | `WO-101` | Medium | P1 | `AC-001.2`, `TR-004` | Open |
| WO-108 | PLAN-002 | — | feature | subagents | Inject `experimental.enableAgents: true` into Gemini `settings.json` when `--experimental` passed | `WO-107` | Medium | P1 | `AC-001.2`, `TR-004` | Open |
| WO-109 | PLAN-002 | — | feature | installer | Validate Gemini subagent frontmatter schema on install | `WO-107` | Medium | P1 | `AC-001.2`, `TR-004` | Open |
| WO-110 | PLAN-002 | — | test | subagents | Update smoke tests for subagent artifact paths (all 3 runtimes) | `WO-102`, `WO-105`, `WO-107` | High | P0 | `AC-001.2`, `TR-004` | Open |
| WO-111 | PLAN-002 | — | test | subagents | Add conformance tests for `--subagents`: correct paths + schema per runtime | `WO-110` | High | P0 | `AC-001.2`, `TR-004` | Open |
| WO-112 | PLAN-002 | — | test | subagents | Add `--experimental` flag guard tests | `WO-110` | Medium | P1 | `AC-001.2`, `TR-004` | Open |
| WO-113 | PLAN-002 | — | test | subagents | Update CI capability baseline checks to include `subagents` dimension | `WO-110` | High | P0 | `AC-001.2`, `TR-004` | Open |
| WO-114 | PLAN-002 | — | docs | subagents | Document `--subagents`/`--experimental` flags; update README capability matrix with `subagents` column | `WO-111` | Medium | P1 | `AC-001.2`, `TR-004` | Open |
| WO-115 | PLAN-002 | — | test | installer | Write ADR-015: installer redesign from bash to Python (rationale, alternatives, migration path, Python toolchain choice) | `ADR-FND-014` | High | P0 | `TR-003`, `TR-004` | Open |
| WO-116 | PLAN-002 | — | feature | installer | Design Python installer module decomposition: package structure, runtime module interfaces, shared-lib contract, CLI interface (entry point + flag contract) | `WO-115` | High | P0 | `TR-003`, `TR-004` | Open |
| WO-117 | PLAN-002 | — | feature | installer | Bootstrap Python installer package: pyproject.toml, CLI entry point (`orchestrator-install`), runtime dispatcher stub, uvx/pipx installable | `WO-116` | High | P0 | `TR-003`, `TR-004` | Open |
| WO-118 | PLAN-002 | — | feature | installer | Implement runtime-scoped Python modules (claude, codex, gemini, opencode, qwen): each with install/uninstall/check functions; no cross-module coupling | `WO-117` | Medium | P1 | `TR-003`, `TR-004` | Open |
| WO-119 | PLAN-002 | — | feature | installer | Implement shared Python library (`orchestrator_install/lib/`): JSON/YAML transforms, path resolution, idempotency helpers, settings-merge utilities | `WO-117` | Medium | P1 | `TR-003`, `TR-004` | Open |
| WO-120 | PLAN-002 | — | test | installer | Write pytest suite for Python installer: unit tests per module + smoke integration tests replacing bash smoke.sh; CI integration | `WO-118`, `WO-119` | High | P0 | `TR-003`, `TR-004` | Open |
| WO-121 | PLAN-003 | — | feature | installer | Build Orchestrator as globally installable Python binary (uvx/pipx) | `WO-117` | High | P0 | `TR-001`, `TR-003` | Open |
| WO-122 | PLAN-003 | — | test | installer | Devcontainer/Docker image with pre-installed dependencies | `WO-121` | High | P0 | `TR-001` | Open |
| WO-123 | PLAN-003 | — | feature | installer | Global installation support (`orchestrator install`) | `WO-121`, `WO-122` | High | P0 | `TR-001`, `TR-003` | Open |
| WO-124 | PLAN-003 | — | feature | orchestration | Strands Framework setup | `WO-121` | High | P0 | `REQ-004` | Open |
| WO-125 | PLAN-003 | — | feature | orchestration | Custom Anthropic provider with Claude SDK (not Client SDK) | `WO-124` | High | P0 | `REQ-004` | Open |
| WO-126 | PLAN-003 | — | feature | orchestration | Orchestrator standard SWE Workflow implementation | `WO-125` | High | P0 | `REQ-004`, `REQ-012` | Open |
| WO-127 | PLAN-003 | — | test | agents | Git Worktree per Agent (branch off feature branch, merge back after AC self-validation) | `WO-126` | Medium | P1 | `REQ-004` | Open |
| WO-128 | PLAN-003 | — | feature | memory | Well-defined file-based KB with TOC file and index refs | `WO-121` | Medium | P1 | `REQ-005` | Open |
| WO-129 | PLAN-003 | — | docs | skills | Well-defined Serena memory structure with proper refs across related docs/skills | `WO-128` | Medium | P1 | `REQ-005` | Open |
| WO-130 | PLAN-003 | — | feature | agents | Context Manager agent to gather high-signal data and structure before handing back to Orchestrator | `WO-128`, `WO-129` | Medium | P1 | `REQ-005` | Open |
| WO-131 | PLAN-003 | — | feature | orchestration | A2A-MCP-Server for Gemini | `WO-124` | High | P0 | `AC-001.2` | Open |
| WO-132 | PLAN-003 | — | feature | orchestration | A2A-MCP-Server for Codex | `WO-124` | High | P0 | `AC-001.2` | Open |
| WO-133 | PLAN-003 | — | feature | orchestration | Strands A2A Configuration and Discovery Setup | `WO-131`, `WO-132` | High | P0 | `AC-001.2` | Open |
| WO-134 | PLAN-003 | — | feature | hooks | Replace CC Hooks with Workflow steps | `WO-126` | High | P0 | `REQ-004` | Open |
| WO-135 | PLAN-003 | — | feature | orchestration | HITL controls integration | `WO-134` | High | P0 | `REQ-006` | Open |
| WO-136 | PLAN-003 | — | feature | orchestration | OTEL (claude-code-otel) for Orchestrator | `WO-124` | High | P0 | `TR-002` | Open |
| WO-137 | PLAN-003 | — | feature | agents | OTEL for Agents with parent span linkage | `WO-136` | High | P0 | `TR-002` | Open |
| WO-138 | PLAN-003 | — | feature | orchestration | Prometheus + Loki integration | `WO-137` | Medium | P1 | `TR-002` | Open |
| WO-139 | PLAN-003 | — | feature | orchestration | Grafana Dashboards | `WO-138` | Medium | P1 | `TR-002` | Open |
| WO-140 | PLAN-003 | — | feature | orchestration | Evaluation framework selection (Langfuse / Harbor / OpenEvals) | `WO-139` | High | P0 | `REQ-008` | Open |
| WO-141 | PLAN-003 | — | feature | orchestration | Evaluation framework integration | `WO-140` | High | P0 | `REQ-008` | Open |
| WO-142 | PLAN-003 | — | feature | orchestration | Automated quality assessment | `WO-141` | Medium | P1 | `REQ-008` | Open |
| WO-143 | PLAN-003 | — | test | validation | Output validation | `WO-141` | Medium | P1 | `REQ-008` | Open |
| WO-144 | PLAN-003 | — | feature | orchestration | Database selection (SQL/NoSQL/Graph/TS/OLAP) | `WO-130` | High | P0 | `TR-006` | Open |
| WO-145 | PLAN-003 | — | feature | orchestration | Ontology schema (entities, relationships) | `WO-144` | High | P0 | `TR-006` | Open |
| WO-146 | PLAN-003 | — | feature | orchestration | Knowledge GraphDB integration | `WO-145` | Medium | P1 | `TR-006` | Open |
| WO-147 | PLAN-003 | — | feature | orchestration | Time-series DB (prices/metrics) | `WO-144` | Medium | P1 | `TR-002`, `TR-006` | Open |
| WO-148 | PLAN-003 | — | feature | orchestration | Analytics OLAP | `WO-147` | Low | P2 | `TR-006` | Open |
| WO-149 | PLAN-003 | — | feature | orchestration | L2 Graph: conditional routing via Strands Graph + A2A | `WO-133` | High | P0 | `REQ-004` | Open |
| WO-150 | PLAN-003 | — | feature | orchestration | L3 Swarm: autonomous mesh via Strands Swarm + A2A native | `WO-149` | High | P0 | `REQ-004` | Open |
| WO-151 | PLAN-003 | — | feature | orchestration | Result aggregation | `WO-150` | Medium | P1 | `REQ-004` | Open |
| WO-152 | PLAN-003 | — | feature | orchestration | Conflict resolution | `WO-150` | Medium | P1 | `REQ-004` | Open |
| WO-153 | PLAN-003 | — | feature | policy | Steering contextual feedback | `WO-145` | Medium | P1 | `TR-005` | Open |
| WO-154 | PLAN-003 | — | feature | policy | Policy-as-Code (OPA) integration | `WO-153` | High | P0 | `TR-005` | Open |
| WO-155 | PLAN-003 | — | feature | agents | Agents RBAC/permissions management | `WO-154` | High | P0 | `TR-005` | Open |
| WO-156 | PLAN-003 | — | feature | policy | Dynamic policy evaluation | `WO-155` | Medium | P1 | `TR-005` | Open |
| WO-157 | PLAN-003 | — | docs | orchestration | Docker in K8s/CloudRun | `WO-122` | High | P0 | `TR-001` | Open |
| WO-158 | PLAN-003 | — | feature | orchestration | Infra provisioning (Terraform/Pulumi) | `WO-157` | High | P0 | `TR-001` | Open |
| WO-159 | PLAN-003 | — | feature | orchestration | Environment isolation (ephemeral containers per run) | `WO-157` | High | P0 | `TR-004` | Open |
| WO-160 | PLAN-003 | — | feature | orchestration | VPC/INET isolation | `WO-158` | Medium | P1 | `TR-004` | Open |
| WO-161 | PLAN-003 | — | feature | orchestration | GitOps integration (ArgoCD/Flux) | `WO-157` | High | P0 | `TR-001` | Open |
| WO-162 | PLAN-003 | — | feature | orchestration | MLOps integration (model/prompt registry) | `WO-161` | Low | P2 | `TR-006` | Open |
| WO-163 | PLAN-003 | — | test | validation | CI/CD workflow definitions | `WO-161` | High | P0 | `TR-001` | Open |
| WO-164 | PLAN-003 | — | feature | orchestration | Artifact registry management | `WO-163` | Medium | P1 | `TR-001` | Open |
| WO-165 | PLAN-003 | — | feature | orchestration | Secret Manager (1P/KeePass/GCP) integration | `WO-157` | High | P0 | `TR-004` | Open |
| WO-166 | PLAN-003 | — | feature | agents | Agents OAuth and Authentication (subscription-based) | `WO-165` | High | P0 | `TR-004` | Open |
| WO-167 | PLAN-003 | — | feature | orchestration | Cross-container restrictions | `WO-165` | Medium | P1 | `TR-004` | Open |
| WO-168 | PLAN-003 | — | test | validation | Runtime/CI/Cloud permissions escalation controls | `WO-166` | Medium | P1 | `TR-004` | Open |
| WO-169 | PLAN-003 | — | feature | orchestration | Command restriction in "Bypass permissions" mode | `WO-165` | High | P0 | `TR-004`, `TR-005` | Open |
| WO-170 | PLAN-003 | — | feature | orchestration | Content filtering | `WO-169` | Medium | P1 | `TR-004`, `TR-005` | Open |
| WO-171 | PLAN-003 | — | feature | orchestration | PII/secrets redaction | `WO-169` | High | P0 | `TR-004` | Open |
| WO-172 | PLAN-003 | — | feature | hooks | Policy enforcement hooks | `WO-170`, `WO-171` | High | P0 | `TR-004`, `TR-005` | Open |
| WO-173 | PLAN-003 | — | feature | orchestration | Token budget allocation | `WO-136` | High | P0 | `TR-002`, `TR-003` | Open |
| WO-174 | PLAN-003 | — | feature | orchestration | Compute resource limits | `WO-157` | Medium | P1 | `TR-002`, `TR-003` | Open |
| WO-175 | PLAN-003 | — | feature | orchestration | Cost tracking | `WO-173`, `WO-174` | Medium | P1 | `TR-002`, `TR-003` | Open |
| WO-176 | PLAN-003 | — | test | validation | Circuit breakers and rate limiting | `WO-175` | Medium | P1 | `TR-002`, `TR-003` | Open |
| WO-177 | PLAN-003 | — | feature | agents | Sensor/Ambient agent framework | `WO-150`, `WO-169` | Medium | P1 | `REQ-004` | Open |
| WO-178 | PLAN-003 | — | feature | agents | Background monitoring routines | `WO-177` | Medium | P1 | `REQ-004` | Open |
| WO-179 | PLAN-003 | — | feature | agents | Goal-oriented research agents | `WO-177` | Medium | P1 | `REQ-004` | Open |
| WO-180 | PLAN-003 | — | feature | agents | Proactive collaboration | `WO-178`, `WO-179` | Low | P2 | `REQ-004` | Open |
| WO-181 | PLAN-004 | M1 | refactor | policy | Adopt the record schema across the distributed package | — | High | P0 | `REQ-002`, `AC-002.4`, `REQ-011`, `TR-004`, `TRC-004.2` | Implementing |
| WO-182 | PLAN-004 | M2 | refactor | orchestration | Migrate this repository's artifacts to the record schema | `WO-181` | High | P0 | `REQ-009`, `REQ-010`, `AC-010.3`, `REQ-011`, `AC-011.2` | Implementing |

---

83 active Work Orders. `WO-001`–`WO-096` and `WO-098`–`WO-100` are closed and live in the
archive index. The next free id is `WO-183`.

