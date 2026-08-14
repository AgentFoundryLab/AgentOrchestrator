# AgentOrchestrator

Minimalist multi-agent orchestration framework for coding agents.
Inspired by SuperClaude and 8090 SoftwareFactory.

**Installer version**: 0.2.0 · **Delivery state**: [ROADMAP](docs/development/ROADMAP.md) owns phase ordering, [STATUS](docs/development/status/STATUS.md) owns the current rollup.

---

## Overview

AgentOrchestrator turns a single-turn coding assistant into an orchestrated multi-agent system:

- **9 agents** with enforced role boundaries: Business Analyst, Architect, Planner, Developer, Validator, Security, Scout, Deployer, Tech Writer
- **23 skills** covering the delivery chain plus retrieval, research, audit, and session-learning support
- **5 runtimes** from one package: Claude Code, Codex CLI, Gemini CLI, OpenCode, Qwen Code
- **Typed record schema** — immutable `REQ`/`AC`/`TR`/`TRC`/`FBP`/`ADR`/`PLAN`/`WO`/`ISS`/`REG`/`TD`/`FB` ids carry traceability from requirement to validation evidence
- **Hook system** (Claude Code only, opt-in) for lifecycle reminders

The value is not the agent count. It is that role boundaries are enforceable and that independent work runs in parallel without agents overwriting each other.

---

## Quick Start

### Prerequisites

- **bash 4.0+** — the installer uses associative arrays. macOS ships 3.2: `brew install bash`
- **jq** — JSON merging during installation (`apt install jq` / `brew install jq`)
- **uv** — only for Serena MCP provisioning (`curl -LsSf https://astral.sh/uv/install.sh | sh`)
- **python3** — two bundled skill helpers (`/distill`, `/meta-learn`); stdlib only, nothing to install

### Runtime Support

| Runtime | Flag | Global root | Skills | Agents | Hooks | Commands (compat) |
|---|---|---|---|---|---|---|
| Claude Code | `--claude` (default) | `~/.claude/` | Yes | Yes | Yes, with `--hooks` | `commands/*.md` |
| Codex CLI | `--codex` | `~/.agents/` | Yes | Yes | No | `~/.codex/prompts/*.md` |
| Gemini CLI | `--gemini` | `~/.gemini/` | Yes | No | No | `commands/*.toml` |
| OpenCode | `--opencode` | `~/.config/opencode/` | Yes | Yes, plus `orchestrator` | No | `commands/*.md` |
| Qwen Code | `--qwen` | `~/.qwen/` | Yes | Yes | No | `commands/*.md` |

Runtime flags compose; `--trio` is `--claude --codex --gemini` and `--all` is all five. With no runtime flag, `--claude` applies.

`skills` is the default profile everywhere. Hooks are off unless `--hooks` is passed, and only Claude Code accepts them ([TD-001](docs/development/debt/TD-001.md) records why non-Claude hooks stay out of scope). `--profile commands` is a compatibility mode that emits command-format artifacts instead.

Gemini receives no agent files — its capability profile and the installer's emitted artifacts are known to disagree, tracked as [ISS-002](docs/development/issues/ISS-002.md) with [REG-002](docs/development/issues/REG-002.md).

### Installation

```bash
# Default runtime (Claude Code), global
./install.sh --global

# Global with hooks enabled
./install.sh --global --hooks

# Several runtimes in one run
./install.sh --global --codex --qwen

# All five
./install.sh --global --all

# Namespaced install (runtime-aware namespace translation)
./install.sh --global --claude --namespace orchestrator

# Commands compatibility profile
./install.sh --global --gemini --profile commands

# Project scaffolding
./install.sh --project /path/to/your/project

# Overwrite existing markdown on reinstall (backs up to .backup/)
./install.sh --global --overwrite

# Validate registry paths against package layout — no writes
./install.sh --check
```

`--restore` removes installed artifacts and restores settings from backup; `--uninstall` removes them and strips injected refs without restoring. `./install.sh --help` prints the full flag and per-runtime artifact reference.

### Basic Usage

```bash
cd /path/to/your/project

# Delegated multi-agent delivery
/orchestrate Build a CLI tool for managing tasks

# Or drive stages directly
/spec Build a task management CLI
/architect
/planner
/implement WO-101
```

---

## What Gets Installed

### `--global`, per selected runtime

| Artifact | Destination | Condition |
|---|---|---|
| `agents/` | `<root>/agents/` | Runtime declares an agents path (all but Gemini) |
| `skills/` | `<root>/skills/<skill>/` | Default profile |
| `policy/` | `<root>/policy/` | Always |
| `workflows/` | `<root>/workflows/` | Always |
| `templates/` | `<root>/templates/` | Always |
| `commands/` | `<root>/commands/` (Codex: `~/.codex/prompts/`) | `--profile commands` |
| `hooks/scripts/` | `~/.claude/hooks/scripts/` | `--hooks`, Claude only |
| `settings.json` | `~/.claude/settings.json` | Claude only; hook entries merged only with `--hooks` |

Two behaviors worth knowing before you debug an install:

- **Policy refs are injected, not copied.** Each runtime's context doc (`CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, `QWEN.md`, `opencode.json`) receives a sentinel-delimited `orchestrator:global-refs` block pointing at the installed policy. Re-running the installer never duplicates it.
- **Gemini native skills are pruned when the Codex alias path exists.** Gemini also loads `~/.agents/skills`, so installing both runtimes would make its loader report a skill conflict. The installer keeps the alias copy and removes the duplicate under `~/.gemini/skills`.

Pass `--namespace <name>` for namespace translation: skills and agents on flat runtimes take a `<ns>-<name>` prefix, while Gemini and Qwen commands use native directory namespaces (`commands/<ns>/<name>` → `/<ns>:<name>`).

### `--project <path>`

Runtime artifacts land under each selected runtime's project root (`.claude/`, `.agents/`, `.gemini/`, `.opencode/`, `.qwen/`): `agents/`, `skills/`, `templates/`, `policy/`, `workflows/`.

Alongside them, runtime-agnostic scaffolding:

```text
your-project/
├── docs/
│   ├── policy/           # STANDARDS.md + GUIDELINES.md from template
│   ├── objectives/       # VISION.md, BLUEPRINT.md land here
│   ├── architecture/     # blueprints, ADRs, diagrams
│   ├── development/      # plans, work orders, feedback records, indexes
│   └── knowledge/        # README.md + decisions/, domain/, patterns/, runbooks/
├── docs/analysis/        # /review, /analyse, /reconcile reports
├── docs/validation/      # AC/TRC coverage
├── reports/              # research/, meta-optimization/
└── .serena/project.yml   # generated via uvx, language auto-detected
```

Empty directories carry a `.gitignore` placeholder so the tree survives a commit. Project `settings.json` is not written — projects inherit MCP and permissions from the global install.

---

## Skills

### Delivery chain

| Skill | Agent | Purpose | Output |
|---|---|---|---|
| `/spec` | Business Analyst | Requirements elicitation | `docs/requirements/` `FRD-*`, `TRD-*` |
| `/architect` | Architect | Blueprints and decisions | `docs/architecture/{foundation,feature,system,ADR}/` |
| `/planner` | Planner | Phase and Work Order decomposition | `docs/development/{ROADMAP.md,plans/,workorders/}` |
| `/review` | Tech Writer | Cross-surface consistency review | `docs/analysis/`, `ISS`/`TD` records |
| `/implement` | Developer | Code implementation | Source files, tests |
| `/validate` | Validator | Testing and verification | `docs/validation/`, `ISS`/`REG`/`TD` records |
| `/security-review` | Security | Adversarial security gate | Verdict, `ISS`/`REG` records |
| `/status-update` | Validator | Implementation assessment | Assessed status in every record index |
| `/deploy` | Deployer | Build and deployment | Deployment artifacts |
| `/document` | Tech Writer | Documentation | `docs/`, `README.md` |
| `/onboard` | Architect | Project policy bootstrap | `docs/policy/`, `docs/INDEX.md` |
| `/scout` | Scout | Bounded docs and code research | Scout report |

### Support

| Skill | Purpose | Output |
|---|---|---|
| `/orchestrate` | Delegated multi-agent delivery; owns depth selection and lane lifecycle | Coordination, handoff commits |
| `/reconcile` | Route downstream findings back to the owning stage | Routing decision, `docs/analysis/` |
| `/context-compiler` | Compact persisted context bundles | `context/<area>/<task>.md` |
| `/meta-learn` | Session analysis and instruction-rule fixes | `reports/meta-optimization/`, `docs/analysis/` |
| `/cleanup` | Prune stale worktrees, branches, runtime stacks, claim leases | Triage table, removals |
| `/anneal` | Complexity, duplication, and drift audit | Ranked simplification plan |
| `/analyse` | Code investigation | `docs/analysis/` |
| `/research` | External documentation lookup | `reports/research/` |
| `/qmd` | Local markdown and doc retrieval | Cited doc text |
| `/codebase-memory` | Structural code-graph retrieval | Symbols, call paths, snippets |
| `/distill` | Lossless document compression | Distillate |

---

## Agents

| Agent | Domain | Boundaries |
|---|---|---|
| **Business Analyst** | Requirements | No code, no architecture, no Bash |
| **Architect** | Design | No implementation, no product scope |
| **Planner** | Planning | No code, no design, never sets status |
| **Developer** | Implementation | No architecture decisions, no scope changes |
| **Validator** | Testing | No fixes, no relaxed criteria, never sets status during validation |
| **Security** | Security gate | No fixes, no downgraded findings, never sets status |
| **Scout** | Research | No source edits unless assigned a write task |
| **Deployer** | Deployment | No code changes; runs in `permissionMode: plan` |
| **Tech Writer** | Documentation | No code |

Boundaries are the point. The Validator reports findings and never fixes them, so a green verdict cannot come from the agent that wrote the code. The Deployer needs user approval for destructive operations. The Tech Writer raises conflicts through `AskUserQuestion` rather than silently overwriting a doc that disagrees with the code or an ADR.

Each agent's tool grant lives in its own profile under `package/agents/`.

---

## Workflow Depths

Delivery — `/implement` → `/validate` → `/security-review` → `/status-update` — runs at every depth. The depth selects only which planning stages precede it.

| Depth | Chain | Use when |
|---|---|---|
| **Full** | `/onboard` → `/spec` → `/architect` → `/planner` → `/review` → delivery | New product, complex system, multiple components |
| **Medium** | `/spec` → `/planner` → `/review` → delivery | New feature, moderate complexity, clear scope |
| **Light** | `/planner` → delivery | Simple change, clear task |
| **Direct-fix** | delivery only, against an existing `ISS`/`TD` | Diagnosed, bounded defect needing no new planning |

Direct-fix drops the planning ceremony, never the scoped commit, focused validation, or status record. `package/skills/orchestrate/SKILL.md` owns depth scoring, delegation rules, and the model-tier table.

---

## Record Model

Every artifact carries an immutable, never-recycled id, and citation runs one way: a downstream record names the requirement it serves, and the requirement stays silent about it.

`AGENTS.md` holds the artifact layers, id grammars, and locations; `docs/INDEX.md` holds the directory layout and per-skill ownership. `package/policy/RULES.md` is the normative source for id grammars, identity fields, and status vocabularies — and it is installed globally, so every runtime reads it.

---

## MCP Servers

| Server | Purpose | Status |
|---|---|---|
| **Serena** | Memory persistence, symbolic code ops | Recommended |
| **Context7** | Library and framework documentation | Recommended |
| **DeepWiki** | GitHub repository documentation | Recommended |
| **Parallel Search** | Fast parallel web lookup | Recommended |
| **Parallel Task** | Deep research and batch enrichment | Recommended |
| **Playwright** | Browser automation | Optional |

Definitions live in `package/mcp.json` and reach Claude Code through the installed `settings.json`. Serena needs `uvx`; both Parallel servers read `PARALLEL_API_KEY` from the environment.

---

## Hook System

Claude Code only, and only with `--hooks`. Without the flag the installer merges `package/settings.no-hooks.json` instead, so an install carries MCP and permissions but no hook entries.

| Event | Script | Purpose |
|---|---|---|
| Setup | `setup-project.sh` | Provision project scaffolding |
| SessionStart | `inject-context.sh` | Inject context, log session start |
| SubagentStart | `inject-context.sh` | Inject context, log agent start |
| SubagentStop | `remind-validate.sh`, `remind-agent-learn.sh` | Validation and `$meta-learn` reminders |
| Stop | `remind-session-learn.sh` | Prompt `$meta-learn` for session learning |
| SessionEnd | `checkpoint-session.sh` | Cleanup and logging |

Hooks provide **reminders, not enforcement** — agents decide whether to act ([ADR-FND-001](docs/architecture/ADR/ADR-FND-001.md)). Prompt-based project hooks are possible in a project `.claude/settings.json` but are never auto-provisioned. See `package/hooks/README.md`.

---

## Policy

Two tiers, loaded from different places:

| Tier | Source in this repo | Loaded from |
|---|---|---|
| Framework | `package/policy/PRINCIPLES.md`, `RULES.md` | `<runtime-root>/policy/` — global and project-local |
| Project | `package/templates/{standards,guidelines}.md` | `<project>/docs/policy/STANDARDS.md`, `GUIDELINES.md` |

Project policy supplements the framework tier; it never replaces it. This repository's own project policy is `docs/policy/`.

**Install context boundary**: `package/` is authoring context. Every instruction that must work after install has to be valid at the installed path, not the source path.

---

## Templates

`package/templates/` is installed to `<runtime-root>/templates/` for every selected runtime. One template per record type:

| Templates | Output |
|---|---|
| `vision.md`, `blueprint.md` | `docs/objectives/` |
| `frd.md`, `trd.md` | `docs/requirements/` |
| `fbp-{foundation,container,component,feature}.md`, `fbp-system-diagram.md` | `docs/architecture/{foundation,feature,system}/` |
| `adr.md` | `docs/architecture/ADR/` |
| `roadmap.md`, `plan.md` | `docs/development/{ROADMAP.md,plans/}` |
| `work-order.md`, `implementation-plan.md` | `docs/development/workorders/` |
| `iss.md`, `reg.md`, `td.md`, `fb.md` | `docs/development/{issues,debt,feedback}/` |
| `knowledge.md`, `index.md`, `standards.md`, `guidelines.md` | `docs/knowledge/`, `docs/INDEX.md`, `docs/policy/` |

---

## Development

No build step and no package manager — this is bash and Markdown. `AGENTS.md` lists the commands, the CI gate, and how to exercise a single installer behavior.

```bash
bash install.sh --check          # registry-vs-package path drift
bash tests/install/smoke.sh      # install, conformance, restore, idempotency
bash tests/package/vocabulary.sh # retired vocabulary on instruction surfaces
pre-commit run --all-files       # shellcheck, ruff, whitespace
```

All three checks run in CI on any change to `install.sh`, `package/**`, or `tests/**`. Install tests use a temp `HOME`; never point one at your real one.

Contributions: fork, branch, plan and implement with the framework itself (`/orchestrate <your change>`), then open a pull request.

---

## Documentation

- [Vision](docs/objectives/VISION.md) — goals and success metrics
- [Blueprint](docs/objectives/BLUEPRINT.md) — solution scope and capability matrix
- [Docs Index](docs/INDEX.md) — canonical layout and artifact ownership
- [Requirements](docs/requirements/REQUIREMENTS.md) — `REQ`/`AC` and `TR`/`TRC` index
- [Architecture](docs/architecture/) — foundation and feature blueprints, diagrams
- [ADRs](docs/architecture/ADR/README.md) — architecture decisions
- [Roadmap](docs/development/ROADMAP.md) — phase ordering and rationale
- [Work Orders](docs/development/WORKORDERS.md) · [Issues](docs/development/ISSUES.md) · [Tech Debt](docs/development/TECH_DEBT.md) · [Status](docs/development/status/STATUS.md)
- [Principles](package/policy/PRINCIPLES.md) · [Rules](package/policy/RULES.md) — framework policy
- [Standards](docs/policy/STANDARDS.md) · [Guidelines](docs/policy/GUIDELINES.md) — project policy
- [Hook System](package/hooks/README.md) · [Serena Integration](.serena/README.md)

---

## Current Constraints

- Codex multi-agent flow follows the official role-config model: enable `/experimental` (or `[features] multi_agent = true`), define `[agents.<role>]` in config, spawn via prompt, switch threads with `/agent`.
- Codex and Gemini installs are skills-first; command artifacts are emitted only with explicit `--profile commands`.
- Non-Claude hook integration is out of scope by decision — `docs/knowledge/decisions/non-claude-hooks-policy.md`.
- No `AC`/`TRC` in this repository has coverage evidence under `docs/validation/` yet. Statuses in the record indexes are carried forward from the pre-migration assessment, not freshly verified; run `/status-update` before citing a row as evidence.

---

## License

MIT — see [LICENSE](LICENSE).
