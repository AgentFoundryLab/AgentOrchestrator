# AgentOrchestrator Backlog

**Version**: 0.3.0
**Updated**: 2026-02-24 (98/100 v0 done; 0/17 v0.3 done)
**Scope**: v0 Milestone + v0.3 (Subagents Extension + Installer Modularization)

---

## Tasks

| ID | Milestone | Phase | Epic | Task | Requirement Trace | Linkage | Priority | Status |
|----|-----------|-------|------|------|-------------------|---------|----------|:------:|
| T-001 | v0 | Initial | Hook System | inject-context.sh | FR5.4, FR5.6 | — | P0 | ✅ |
| T-002 | v0 | Initial | Hook System | remind-validate.sh | FR3.2, FR6 | — | P0 | ✅ |
| T-003 | v0 | Initial | Hook System | remind-reflexion.sh | FR3.2, FR7.1 | — | P0 | ✅ |
| T-004 | v0 | Initial | Hook System | remind-reflect.sh | FR3.3, FR8.1, US5 | — | P0 | ✅ |
| T-005 | v0 | Initial | Hook System | checkpoint-session.sh | FR3.4 | FR5.3.1 | P1 | ✅ |
| T-006 | v0 | Initial | Core Agents | business-analyst.md | FR1, US1 | — | P0 | ✅ |
| T-007 | v0 | Initial | Core Agents | architect.md | FR1, US2 | — | P0 | ✅ |
| T-008 | v0 | Initial | Core Agents | project-manager.md | FR1, US3 | — | P0 | ✅ |
| T-009 | v0 | Initial | Core Agents | developer.md | FR1 | — | P0 | ✅ |
| T-010 | v0 | Initial | Support Agents | validator.md | FR1 | — | P1 | ✅ |
| T-011 | v0 | Initial | Support Agents | deployer.md | FR1 | — | P1 | ✅ |
| T-012 | v0 | Initial | Support Agents | tech-writer.md | FR1 | — | P1 | ✅ |
| T-013 | v0 | Initial | Agent-Backed Skills | spec/SKILL.md | FR2, US1 | — | P0 | ✅ |
| T-014 | v0 | Initial | Agent-Backed Skills | design/SKILL.md | FR2, US2 | — | P0 | ✅ |
| T-015 | v0 | Initial | Agent-Backed Skills | plan/SKILL.md | FR2, US3 | — | P0 | ✅ |
| T-016 | v0 | Initial | Agent-Backed Skills | implement/SKILL.md | FR2 | — | P0 | ✅ |
| T-017 | v0 | Initial | Agent-Backed Skills | validate/SKILL.md | FR2, FR6 | — | P1 | ✅ |
| T-018 | v0 | Initial | Agent-Backed Skills | deploy/SKILL.md | FR2 | — | P1 | ✅ |
| T-019 | v0 | Initial | Agent-Backed Skills | document/SKILL.md | FR2 | — | P1 | ✅ |
| T-020 | v0 | Initial | Utility Skills | reflexion/SKILL.md | FR2, FR7 | — | P0 | ✅ |
| T-021 | v0 | Initial | Utility Skills | reflect/SKILL.md | FR2, FR8.1, US5 | — | P0 | ✅ |
| T-022 | v0 | Initial | Utility Skills | optimize/SKILL.md | FR2, FR8.2 | — | P2 | ✅ |
| T-023 | v0 | Initial | Utility Skills | analyse/SKILL.md | FR2, US6 | — | P1 | ✅ |
| T-024 | v0 | Initial | Utility Skills | research/SKILL.md | FR2 | — | P1 | ✅ |
| T-025 | v0 | Initial | Utility Skills | distill/SKILL.md | FR2 | — | P2 | ✅ |
| T-026 | v0 | Initial | Orchestration | orchestrate/SKILL.md | FR2, FR4, US4 | — | P0 | ✅ |
| T-027 | v0 | Initial | Policy | RULES.md | NFR5 | PRD | P1 | ✅ |
| T-028 | v0 | Initial | Policy | PRINCIPLES.md | NFR5 | PRD | P1 | ✅ |
| T-029 | v0 | Initial | Workflows | SWE.md | FR4 | — | P0 | ✅ |
| T-030 | v0 | Initial | Workflows | meta-learning.md | FR4, FR8 | — | P1 | ✅ |
| T-031 | v0 | Initial | Templates | prd.md | FR4.4 | — | P1 | ✅ |
| T-032 | v0 | Initial | Templates | architecture.md | FR4.4 | — | P1 | ✅ |
| T-033 | v0 | Initial | Templates | adr.md | FR4.4 | — | P1 | ✅ |
| T-034 | v0 | Initial | Templates | roadmap.md | FR4.4 | — | P1 | ✅ |
| T-047 | v0 | Initial | Templates | backlog.md | FR4.4 | — | P1 | ✅ |
| T-048 | v0 | Initial | Templates | issues.md | FR4.4 | — | P2 | ✅ |
| T-049 | v0 | Initial | Templates | vision.md | FR4.4 | — | P2 | ✅ |
| T-050 | v0 | Initial | Templates | blueprint.md | FR4.4 | — | P2 | ✅ |
| T-035 | v0 | Initial | Settings & Installer | package/settings.json | FR3, NFR2 | — | P0 | ✅ |
| T-036 | v0 | Initial | Settings & Installer | project-local install scaffolding | FR1.1, FR2.1, NFR3 | PRD | P1 | ✅ |
| T-037 | v0 | Initial | Settings & Installer | .claude/settings.json | FR3, NFR4 | — | P0 | ✅ |
| T-038 | v0 | Initial | Settings & Installer | install.sh | FR3, NFR1, NFR3 | — | P0 | ✅ |
| T-039 | v0 | Validation | Integration | E2E /orchestrate test | US4 | — | P0 | ✅ |
| T-040 | v0 | Validation | Integration | Dogfood Orchestrator docs | FR4.2 | PRD | P1 | ✅ |
| T-041 | v0 | Validation | Integration | Update README.md | FR1.1, FR2.1, NFR4 | PRD | P0 | ✅ |
| T-042 | v0 | Initial | Policy | DESIGN-PRINCIPLES.md | NFR5 | PRD | P1 | ✅ |
| T-043 | v0 | Initial | Hooks | package/hooks/README.md | FR3 | PRD | P2 | ✅ |
| T-044 | v0 | Initial | Project Templates | package-driven project scaffolding | FR4.4, NFR6 | — | P1 | ✅ |
| T-045 | v0 | Initial | Memory | .serena/README.md | FR5, NFR5 | — | P2 | ✅ |
| T-046 | v0 | Initial | Settings | Fix $schema in settings.json | NFR4 | PRD | P0 | ✅ |
| T-051 | v0 | Governance & Quality | Governance and Quality Controls | onboard/SKILL.md | FR2.1, FR2.3 | ADR-013 | P0 | ✅ |
| T-052 | v0 | Governance & Quality | Governance and Quality Controls | review/SKILL.md | FR2.1, FR2.3 | ADR-013 | P0 | ✅ |
| T-053 | v0 | Governance & Quality | Governance and Quality Controls | hitl/SKILL.md | FR2.1, FR2.3 | ADR-013 | P0 | ✅ |
| T-054 | v0 | Governance & Quality | Governance and Quality Controls | Update architect.md (add onboard skill) | FR1.5, FR2.3 | ADR-013 | P0 | ✅ |
| T-055 | v0 | Governance & Quality | Governance and Quality Controls | Update tech-writer.md (add review skill) | FR1.5, FR2.3 | ADR-013 | P0 | ✅ |
| T-056 | v0 | Governance & Quality | Governance and Quality Controls | Update SWE.md (/review gate in full workflow) | FR4.1 | ADR-013, T-029 | P0 | ✅ |
| T-057 | v0 | Governance & Quality | Governance and Quality Controls | Update PRD.md FR2 (17 skills) | FR2 | ADR-013 | P0 | ✅ |
| T-058 | v0 | Installer Extension | Runtime Matrix & Canonical Paths | Define canonical runtime registry | FR1.1, FR2.1, NFR4 | v0.2.0 | P0 | ✅ |
| T-059 | v0 | Installer Extension | Runtime Matrix & Canonical Paths | Add installer targets for --opencode and --qwen | FR1.1, FR2.1, NFR4 | v0.2.0 | P0 | ✅ |
| T-060 | v0 | Installer Extension | Runtime Matrix & Canonical Paths | Codify Claude paths | FR1.1, FR2.1, NFR4 | v0.2.0 | P0 | ✅ |
| T-061 | v0 | Installer Extension | Runtime Matrix & Canonical Paths | Codify Codex paths | FR1.1, FR2.1, NFR4 | v0.2.0 | P0 | ✅ |
| T-062 | v0 | Installer Extension | Runtime Matrix & Canonical Paths | Codify Gemini paths (reconciled to skills-first baseline) | FR1.1, FR2.1, NFR4 | v0.2.0, T-097 | P0 | ✅ |
| T-063 | v0 | Installer Extension | Runtime Matrix & Canonical Paths | Codify OpenCode paths | FR1.1, FR2.1, NFR4 | v0.2.0 | P0 | ✅ |
| T-064 | v0 | Installer Extension | Runtime Matrix & Canonical Paths | Codify Qwen paths | FR1.1, FR2.1, NFR4 | v0.2.0 | P0 | ✅ |
| T-065 | v0 | Installer Extension | Runtime Matrix & Canonical Paths | Add runtime path drift checks | FR1.1, FR2.1, NFR4 | v0.2.0 | P1 | ✅ |
| T-066 | v0 | Installer Extension | Runtime Matrix & Canonical Paths | Define frontmatter/schema transforms (skills->commands) | FR1.1, FR2.1, NFR4 | v0.2.0 | P1 | ✅ |
| T-067 | v0 | Installer Extension | Per-Runtime Namespace Semantics | Define namespace grammar and validation | FR1.1, FR2.1, NFR4 | v0.2.0 | P0 | ✅ |
| T-068 | v0 | Installer Extension | Per-Runtime Namespace Semantics | Map namespace input to runtime-native artifact paths | FR1.1, FR2.1, NFR4 | v0.2.0 | P0 | ✅ |
| T-069 | v0 | Installer Extension | Per-Runtime Namespace Semantics | Preserve flat mode as backward-compatible default | FR1.1, FR2.1, NFR4 | v0.2.0 | P0 | ✅ |
| T-070 | v0 | Installer Extension | Per-Runtime Namespace Semantics | Namespace-safe restore/cleanup semantics | FR1.1, FR2.1, NFR4 | v0.2.0 | P0 | ✅ |
| T-071 | v0 | Installer Extension | Capability-Scoped Installer Profiles | Split install profiles by capability | FR1.1, FR2.1, NFR4 | v0.2.0 | P0 | ✅ |
| T-072 | v0 | Installer Extension | Capability-Scoped Installer Profiles | Make skills the default profile when runtime supports skills | FR1.1, FR2.1, NFR4 | v0.2.0 | P0 | ✅ |
| T-073 | v0 | Installer Extension | Capability-Scoped Installer Profiles | Add commands compatibility profile selectable by flag | FR1.1, FR2.1, NFR4 | v0.2.0 | P1 | ✅ |
| T-074 | v0 | Installer Extension | Capability-Scoped Installer Profiles | Implement Claude profile (commands+skills+hooks+scripts) | FR1.1, FR2.1, NFR4 | v0.2.0 | P0 | ✅ |
| T-075 | v0 | Installer Extension | Capability-Scoped Installer Profiles | Implement Codex profile (skills+scripts baseline, no hooks) | FR1.1, FR2.1, NFR4 | v0.2.0 | P0 | ✅ |
| T-076 | v0 | Installer Extension | Capability-Scoped Installer Profiles | Implement Gemini profile (skills+scripts baseline, commands compat) | FR1.1, FR2.1, NFR4 | v0.2.0, T-097 | P0 | ✅ |
| T-077 | v0 | Installer Extension | Capability-Scoped Installer Profiles | Implement OpenCode profile (commands+skills+scripts, no hooks) | FR1.1, FR2.1, NFR4 | v0.2.0 | P0 | ✅ |
| T-078 | v0 | Installer Extension | Capability-Scoped Installer Profiles | Implement Qwen profile (commands+skills+scripts, no hooks) | FR1.1, FR2.1, NFR4 | v0.2.0 | P0 | ✅ |
| T-079 | v0 | Installer Extension | Capability-Scoped Installer Profiles | Emit warnings for unsupported capabilities per runtime | FR1.1, FR2.1, NFR4 | v0.2.0 | P1 | ✅ |
| T-080 | v0 | Installer Extension | Capability-Scoped Installer Profiles | Runtime-aware idempotent policy-ref injection | FR1.1, FR2.1, NFR4 | v0.2.0 | P1 | ✅ |
| T-081 | v0 | Installer Extension | Capability-Scoped Installer Profiles | Prevent cross-runtime collisions in shared context docs | FR1.1, FR2.1, NFR4 | v0.2.0 | P1 | ✅ |
| T-082 | v0 | Installer Extension | UX & Documentation | Update install.sh --help with multi-agent + namespaced examples | FR1.1, FR2.1, NFR4 | v0.2.0 | P1 | ✅ |
| T-083 | v0 | Installer Extension | UX & Documentation | Document skills default and commands compatibility mode | FR1.1, FR2.1, NFR4 | v0.2.0 | P1 | ✅ |
| T-084 | v0 | Installer Extension | UX & Documentation | Document per-agent schema/frontmatter differences in commands mode | FR1.1, FR2.1, NFR4 | v0.2.0 | P1 | ✅ |
| T-085 | v0 | Installer Extension | UX & Documentation | Update README.md install matrix for all 5 runtimes | FR1.1, FR2.1, NFR4 | v0.2.0 | P1 | ✅ |
| T-086 | v0 | Installer Extension | UX & Documentation | Document migration notes for legacy namespace and runtime paths | FR1.1, FR2.1, NFR4 | v0.2.0 | P2 | ✅ |
| T-087 | v0 | Installer Extension | Validation & CI | Add install smoke tests for runtime matrix (global + project) | FR1.1, FR2.1, NFR4 | v0.2.0 | P0 | ✅ |
| T-088 | v0 | Installer Extension | Validation & CI | Add capability conformance tests per runtime | FR1.1, FR2.1, NFR4 | v0.2.0 | P0 | ✅ |
| T-089 | v0 | Installer Extension | Validation & CI | Add restore/cleanup regression tests for namespaced installs | FR1.1, FR2.1, NFR4 | v0.2.0 | P1 | ✅ |
| T-090 | v0 | Installer Extension | Validation & CI | Add idempotency tests for repeated installs with mixed runtime subsets | FR1.1, FR2.1, NFR4 | v0.2.0 | P1 | ✅ |
| T-091 | v0 | Installer Extension | Validation & CI | Add CI guardrail for runtime/path drift | FR1.1, FR2.1, NFR4 | v0.2.0 | P0 | ✅ |
| T-092 | v0 | Installer Extension | Gemini Commands | Implement SKILL.md → Gemini TOML command transform | FR1.1, FR2.1, NFR4 | G-002 | P1 | ✅ |
| T-094 | v0 | Installer Extension | Frontmatter Transforms | Strip Claude-specific frontmatter keys for non-Claude runtime installs (minimal schema) | FR1.1, FR2.1, NFR4 | G-003 | P1 | ✅ |
| T-095 | v0 | Installer Extension | Frontmatter Transforms | Per-runtime key map + TOML transform pipeline (extend minimal schema) | FR1.1, FR2.1, NFR4 | G-003 | P2 | ✅ |
| T-096 | v0 | Installer Extension | Namespace Alignment | Align runtime namespace modes with ADR-014 D-2 | FR1.1, FR2.1, NFR4 | I-001 | P1 | ✅ |
| T-097 | v0 | Installer Extension | Gemini Capability Alignment | Align Gemini capability flags + install paths/tests with validated docs baseline (skills/subagents support model; hooks excluded by policy) | FR1.1, FR2.1, NFR4 | I-002 | P1 | 🔄 |
| T-098 | v0 | Installer Extension | Compatibility Debt Cleanup | Remove legacy compatibility/workaround bloat from installer UX/docs and normalize to current behavior spec | FR1.1, FR2.1, NFR4 | I-003 | P2 | ✅ |
| T-099 | v0 | Installer Extension | Codex Agent Invocation Alignment | Align Codex runtime planning/install model with official role-config + thread workflow | FR1.1, FR1.2, FR2.1, NFR4 | I-005 | P1 | ✅ |
| T-100 | v0 | Installer Extension | Codex Skills-First Baseline | Remove Codex default prompts dual-write; skills-only default; prompts emitted only in explicit command-mode compat flow | FR1.1, FR2.1, NFR4 | I-004 | P1 | ✅ |
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
| T-115 | v0.3 | Installer Modularization | Installer Decomposition | Split install.sh into runtime-scoped modules (claude, codex, gemini, opencode, qwen) + main dispatcher | NFR3, NFR4 | ADR-014 | P0 | 🔲 |
| T-116 | v0.3 | Installer Modularization | Installer Decomposition | Extract shared installer library (transforms, validation, utils) | NFR3, NFR4 | T-115 | P1 | 🔲 |
| T-117 | v0.3 | Installer Modularization | Installer Decomposition | Write TDR: installer modularity principles (single-responsibility per module, no cross-runtime coupling) | NFR3 | — | P1 | 🔲 |

---

## Task Details

Task details were decomposed per milestone.

- Active task details index: [docs/development/tasks/INDEX.md](tasks/INDEX.md)
- Active v0 details: [docs/development/tasks/v0.md](tasks/v0.md)
- Active v0.3 details: [docs/development/tasks/v0.3.md](tasks/v0.3.md)
- Planned v1 tactical details (preserved): [docs/development/tasks/v1.md](tasks/v1.md)
- Completed v0 archive: [docs/development/archive/tasks-v0-completed.md](archive/tasks-v0-completed.md)

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
