# AgentOrchestrator

Minimalist multi-agent orchestration framework for Claude Code.
Inspired by SuperClaude.

**Version**: 0.2.0  | **Status**: v0.2.0 Multi-Runtime Install

---

## Overview

AgentOrchestrator transforms Claude Code from a single-turn assistant into an orchestrated multi-agent system with:

- **9 Specialized Agents**: Business Analyst, Architect, Planner, Developer, Validator, Security, Scout, Deployer, Tech Writer
- **23 Skills**: Workflow stages from `/spec` to `/status-update`, plus retrieval, research, audit, and session-learning support
- **3 Workflow Depths**: Full, Medium, Light based on complexity
- **Hook System**: Lifecycle events for validation and learning
- **Memory Integration**: Serena MCP for persistent knowledge

---

## Quick Start

### Prerequisites

- **uv**: Required for Python operations and Serena MCP (`curl -LsSf https://astral.sh/uv/install.sh | sh`)
- **jq**: Required for JSON merging during installation (`apt install jq` or `brew install jq`)

### Runtime Support Matrix

| Runtime     | Install flag  | SubAgents         | Skills | Hooks | Commands       |
|-------------|---------------|-------------------|--------|-------|----------------|
| Claude Code | `--claude`    | Yes               | Yes    | Yes   | Yes            |
| Codex CLI   | `--codex`     | Yes (experimental)| Yes    | No    | Yes (compat)   |
| Gemini CLI  | `--gemini`    | Partial (exp)     | Yes    | No (policy) | Yes (compat) |
| OpenCode    | `--opencode`  | Yes               | Yes    | No    | Yes            |
| Qwen Code   | `--qwen`      | Yes               | Yes    | No    | Yes            |

`skills` is the default profile for all five runtimes. Hooks are disabled by default and installed only when `--hooks` is passed. `commands` remains available via `--profile commands` as compatibility mode. For Codex, skills/agents stay in `~/.agents/`, while compatibility commands are written to `~/.codex/prompts/`.

### Installation

```bash
# Install globally to Claude Code (default runtime)
./install.sh --global

# Install globally with hooks enabled
./install.sh --global --hooks

# Install to multiple runtimes in one run
./install.sh --global --codex --qwen

# Install to all five runtimes
./install.sh --global --claude --codex --gemini --opencode --qwen

# Namespaced install (runtime-aware namespace translation)
./install.sh --global --claude --namespace orchestrator

# Install with commands compatibility profile
./install.sh --global --gemini --profile commands

# Install project templates to a target project
./install.sh --project /path/to/your/project

# Install both global and project in one run
./install.sh --global --project /path/to/your/project

# Overwrite existing markdown files during reinstall
./install.sh --global --overwrite

# Validate registry paths against package layout (no writes)
./install.sh --check
```

### What Gets Installed

**`--global` installs per runtime (default: `--claude`):**

| Artifact          | claude (`~/.claude/`) | codex (skills/agents: `~/.agents/`; commands compat: `~/.codex/prompts/`) | gemini (`~/.gemini/`) | opencode (`~/.config/opencode/`) | qwen (`~/.qwen/`) |
|-------------------|-----------------------|-----------------------|-----------------------|----------------------------------|-------------------|
| agents/           | Yes                   | Yes                   | No                    | Yes                              | Yes               |
| skills/           | Yes (default)         | Yes (default)         | Yes (default)         | Yes (default)                    | Yes (default)     |
| commands/         | Yes (`--profile commands`) | Yes (`~/.codex/prompts`, `--profile commands`) | Yes (`--profile commands`) | Yes (`--profile commands`) | Yes (`--profile commands`) |
| hooks/            | Yes (`--hooks`)       | No                    | No                    | No                               | No                |
| settings.json     | Yes                   | No                    | No                    | No                               | No                |
| policy/           | Yes                   | No                    | No                    | No                               | No                |
| workflows/        | Yes                   | No                    | No                    | No                               | No                |
| templates/        | Yes                   | No                    | No                    | No                               | No                |

Codex note: default install is skills-first under `~/.agents/skills`; `~/.codex/prompts` is written only with `--profile commands`.

Pass `--namespace <name>` to enable runtime-aware namespace translation:
- Skills/agents on flat runtimes use dash fallback naming (`<ns>-<name>`).
- Gemini and Qwen commands use native directory namespaces (`commands/<ns>/<name>` => `/<ns>:<name>`).

**`--project` installs to `<path>/`:**
- `<runtime-root>/agents/` - Project-local agents for each selected runtime (`.claude/`, `.agents/`, `.gemini/`, `.opencode/`, `.qwen/` as applicable)
- `<runtime-root>/skills/` - Project-local skills for each selected runtime
- `<runtime-root>/templates/` - Project-local template copies for each selected runtime
- `<runtime-root>/policy/` - Project-local policy copies for each selected runtime
- `<runtime-root>/workflows/` - Project-local workflow copies for each selected runtime
- `.serena/project.yml` - Auto-generated via `uvx` (language auto-detection)
- `docs/policy/` - RULES.md, GUIDELINES.md templates
- `docs/knowledge/` - Project knowledge base
- `reports/` - Analysis and research directories

### Basic Usage

```bash
# Start a new Claude Code session in your project
cd /path/to/your/project
claude

# Use the orchestrator for guided workflows
/orchestrate Build a CLI tool for managing tasks

# Or use individual skills directly
/spec Build a task management CLI
/architect
/planner
/implement T-001
```

---

## Skills Reference

### Workflow Skills (Agent-Backed)

| Skill | Agent | Purpose | Output |
|-------|-------|---------|--------|
| `/spec` | Business Analyst | Requirements elicitation | `docs/requirements/FRD-*`, `TRD-*` |
| `/architect` | Architect | Blueprints and decisions | `docs/architecture/{foundation,feature,system,ADR}/` |
| `/planner` | Planner | Work Order decomposition | `docs/development/{ROADMAP.md,plans/,workorders/}` |
| `/review` | Tech Writer | Cross-surface consistency review | Findings, `reports/analysis/`, ISSUES rows |
| `/implement` | Developer | Code implementation | Source files, tests |
| `/validate` | Validator | Testing and verification | `docs/validation/`, `ISS`/`REG`/`TD` |
| `/security-review` | Security | Adversarial security gate | Verdict, ISSUES rows |
| `/status-update` | Validator | Implementation assessment | Status in BACKLOG / ISSUES / ROADMAP |
| `/deploy` | Deployer | Build and deployment | Deployment artifacts |
| `/document` | Tech Writer | Documentation | `docs/`, `README.md` |
| `/onboard` | Architect | Project policy bootstrap | `docs/policy/`, `docs/INDEX.md` |
| `/scout` | Scout | Bounded docs/code research | Scout report |

### Utility Skills (Inline)

| Skill | Purpose | Output |
|-------|---------|--------|
| `/orchestrate` | Delegated multi-agent orchestration | Coordinates agents, owns lane lifecycle |
| `/reconcile` | Route downstream findings to the right stage | Routing decision, `reports/analysis/` |
| `/context-compiler` | Compact persisted context bundles | `context/<area>/<task>.md` |
| `/meta-learn` | Session analysis and instruction-rule fixes | `reports/meta-optimization/`, `reports/analysis/` |
| `/cleanup` | Prune stale worktrees, branches, runtime stacks | Triage table, removals |
| `/anneal` | Complexity, duplication, and drift audit | Ranked simplification plan |
| `/analyse` | Code investigation | `reports/analysis/` |
| `/research` | External documentation lookup | `reports/research/` |
| `/qmd` | Local markdown/doc retrieval | Cited doc text |
| `/codebase-memory` | Structural code-graph retrieval | Symbols, call paths, snippets |
| `/distill` | Lossless document compression | Distillate |

---

## Agents Reference

| Agent | Domain | Key Tools | Boundaries |
|-------|--------|-----------|------------|
| **Business Analyst** | Requirements | Read, Write, Edit, Grep, Glob, WebSearch | No code, no architecture, no Bash |
| **Architect** | Design | Read, Write, Edit, Grep, Glob, Bash, WebSearch | No implementation, no product scope |
| **Planner** | Planning | Read, Write, Grep, Glob, TaskCreate | No code, no design, no Edit, never sets status |
| **Developer** | Implementation | All tools | No architecture decisions, no scope changes |
| **Validator** | Testing | Read, Write, Grep, Glob, Bash | No fixes, no relaxed criteria, never sets status during validation |
| **Security** | Security gate | Read, Write, Grep, Glob, Bash, WebSearch | No fixes, no downgraded findings, never sets status |
| **Scout** | Research | All tools | No source edits unless assigned a write task |
| **Deployer** | Deployment | Read, Write, Bash | No code changes, `permissionMode: plan` |
| **Tech Writer** | Documentation | Read, Write, Grep, Glob, AskUserQuestion | No code, no Edit |

### Agent Details

**Validator**: Runs tests, verifies acceptance criteria, checks code quality. Cannot modify code - reports findings only.

**Deployer**: Manages build and deployment operations. Runs in `permissionMode: plan` requiring user approval for destructive operations.

**Tech Writer**: Creates and maintains documentation. Uses `AskUserQuestion` for conflict detection - never silently overwrites docs when inconsistencies are detected between documents, code, or ADR decisions.

---

## Workflow Depths

Orchestrator assesses complexity and recommends appropriate workflow depth:

Delivery (`/implement` -> `/validate` -> `/security-review` -> `/status-update`) runs in every depth; the
depth selects only which planning stages precede it.

### Full Workflow
**Use when**: New product, complex system, multiple components

```
/onboard -> /spec -> /architect -> /planner -> /review -> delivery
```

### Medium Workflow
**Use when**: New feature, moderate complexity

```
/spec -> /planner -> /review -> delivery
```

### Light Workflow
**Use when**: Simple change, clear task

```
/planner -> delivery
```

### Direct Fix
**Use when**: Diagnosed, bounded defect with no new planning need

```
delivery only, against an existing I-nnn / G-nnn
```

---

## Project Structure

After installation, your project will have:

```
your-project/
├── .claude/
│   ├── agents/
│   │   └── *.md          # Project-local AgentOrchestrator agents
│   ├── skills/
│   │   └── <skill>/      # Project-local AgentOrchestrator skills
│   ├── templates/        # Project-local templates
│   ├── policy/           # Project-local policy copies
│   └── workflows/        # Project-local workflow copies
├── .serena/
│   └── project.yml       # Auto-generated Serena project config
├── docs/
│   ├── objectives/       # VISION.md, BLUEPRINT.md, ROADMAP.md
│   ├── requirements/     # FRD-*, TRD-*, REQUIREMENTS.md
│   ├── architecture/     # foundation/, feature/, system/, ADR/
│   ├── development/      # BACKLOG.md, ISSUES.md, tasks/
│   └── knowledge/        # Project knowledge base
├── reports/
│   ├── analysis/         # /analyse, /review, /reconcile outputs
│   ├── research/         # /research outputs
│   ├── validation/       # /validate outputs
│   └── meta-optimization/ # /meta-learn instruction-fix memos
└── context/
    └── <area>/<task>.md  # /context-compiler bundles
```

---

## Artifact Hierarchy

Orchestrator follows a layered artifact structure:

```
Strategic (locked after PRD)
├── VISION.md        # Why, target users, success metrics
└── BLUEPRINT.md     # Technical scope, capabilities, feature matrix

Specification (changes with approval)
├── PRD.md           # Features, user stories, acceptance criteria
├── architecture/    # FBP blueprints, ADRs, system diagrams
└── adr/             # Decision rationale, alternatives, consequences

Execution (changes frequently)
├── ROADMAP.md       # Milestones, phases, epics + dependencies
├── BACKLOG.md       # Task index, status, traceability, refs
├── tasks/*.md       # Canonical task-detail docs for complex work
└── ISSUES.md        # Discovered bugs, blockers, tech debt
```

---

## MCP Requirements

| Server | Purpose | Status |
|--------|---------|--------|
| **Serena** | Memory persistence, symbolic code ops | Required |
| **Context7** | Documentation lookup | Recommended |
| **DeepWiki** | GitHub repository documentation | Recommended |
| **Parallel Search** | Fast parallel web lookup for research workflows | Recommended |
| **Parallel Task** | Deep research and batch enrichment task execution | Recommended |
| **Playwright** | Browser automation | Optional |

MCP servers are pre-configured in `settings.json`. Serena requires `uvx` for dynamic project initialization.

---

## Hook System

Orchestrator can use Claude Code hooks for lifecycle management when installed with `--hooks`.

### Global Hooks (command-based)

Installed to `~/.claude/settings.json` when `--hooks` is passed:

| Event | Script | Purpose |
|-------|--------|---------|
| SessionStart | `inject-context.sh` | Inject context, log session start |
| SubagentStart | `inject-context.sh` | Inject context, log agent start |
| SubagentStop | `remind-validate.sh`, `remind-agent-learn.sh` | Validation + `$meta-learn` prompt |
| Stop | `remind-session-learn.sh` | Prompt `$meta-learn` for session learning |
| SessionEnd | `checkpoint-session.sh` | Cleanup and logging |

### Project Hooks (prompt-based)

Optional in `.claude/settings.json` (not auto-provisioned by `--project`):

| Event | Type | Purpose |
|-------|------|---------|
| Stop | prompt | Evaluate task completion before stopping |
| SubagentStop | prompt | Validate subagent completion |

Prompt-based hooks use Claude to evaluate conditions and return JSON responses.

Hooks provide **reminders**, not enforcement. Agents decide whether to act (ADR-001).

---

## Configuration

### Global Settings (`~/.claude/settings.json`)

Installed by `--global` flag. Contains:
- Hook configurations (command-based, only when `--hooks` is passed)
- MCP server definitions (Serena, Context7, DeepWiki, Parallel Search, Parallel Task, Playwright)
- Default permissions

### Project Settings (`.claude/settings.json`)

Not auto-installed by `--project` (add manually if needed). Typical contents:
- Project-specific hooks (prompt-based examples)
- Inherits MCP and permissions from global

---

## Policy Files

Three-tier policy structure:

| Location | Purpose | Installed To |
|----------|---------|--------------|
| `package/policy/` | Framework-wide policy source in this repo | `<runtime-root>/policy/` globally and project-locally for the selected runtime(s) |
| `docs/policy/` | Orchestrator repo policy docs | In-repo only |
| `<project>/docs/policy/` | Project template output (STANDARDS, GUIDELINES) | `<project>/docs/policy/` |

**Policy files**:
- `PRINCIPLES.md` - Core software engineering principles
- `RULES.md` - Actionable behavioral rules with priorities
- `GUIDELINES.md` - Usage guidance and best practices

Projects can customize `<project>/docs/policy/` files to supplement (not replace) global policies.

---

## Templates

Orchestrator template source lives in `package/templates/` and is installed to `<runtime-root>/templates/` globally and project-locally for the selected runtime(s) (`~/.claude/`, `~/.agents/`, `~/.gemini/`, `~/.config/opencode/`, `~/.qwen/`, and matching project-local roots):

| Template | Purpose | Output Location |
|----------|---------|-----------------|
| `vision.md` | Project vision and OKRs | `docs/objectives/VISION.md` |
| `blueprint.md` | Technical scope and capabilities | `docs/objectives/BLUEPRINT.md` |
| `frd.md` / `trd.md` | Feature / technical requirements | `docs/requirements/` |
| `fbp-*.md` | Foundation / container / component / feature blueprints | `docs/architecture/{foundation,feature}/` |
| `adr.md` | Architecture decision records | `docs/architecture/ADR/` |
| `roadmap.md` / `plan.md` | Phase ordering / delivery Plan | `docs/development/{ROADMAP.md,plans/}` |
| `work-order.md` / `implementation-plan.md` | Work Orders | `docs/development/workorders/` |
| `issues.md` | Bugs, blockers, tech debt | `docs/development/ISSUES.md` |

---

## Development

### Task Hierarchy (ADR-005)

```
Milestone (v0, v1)     -> Git Tag
└── Phase (Initial, Validation)
    └── Epic (Hook System, Core Agents, ...)
        └── Task (atomic, testable) -> Git Commit
```

### Contributing

1. Fork the repository
2. Create a feature branch
3. Use Orchestrator to plan and implement (`/orchestrate your feature`)
4. Submit a pull request

---

## Documentation

- [Vision](docs/objectives/VISION.md) - Project vision and goals
- [Blueprint](docs/objectives/BLUEPRINT.md) - Technical scope
- [Requirements](docs/requirements/REQUIREMENTS.md) - REQ/AC and TR/TRC index
- [Blueprints](docs/architecture/) - Foundation, container, component, feature
- [ADRs](docs/architecture/ADR/README.md) - Architecture decisions
- [Roadmap](docs/development/ROADMAP.md) - Phase ordering and rationale
- [Work Orders](docs/development/WORKORDERS.md) - Delivery index
- [Serena Integration](.serena/README.md) - Memory system guide
- [Hook System](package/hooks/README.md) - Hook documentation
- [Principles](package/policy/PRINCIPLES.md) - Software engineering principles
- [Rules](package/policy/RULES.md) - Agent behavioral rules
- [Standards](docs/policy/STANDARDS.md) - Project technical standards
- [Guidelines](docs/policy/GUIDELINES.md) - User guidance

---

## Current Constraints

- Codex multi-agent flow follows official role-config model: enable `/experimental` (or `[features] multi_agent = true`), define `[agents.<role>]` in config, spawn via prompt, switch/check threads with `/agent`.
- Codex default install is skills-first (`~/.agents/skills`); compatibility prompts are emitted to `~/.codex/prompts` only with explicit `--profile commands`.
- Gemini default install is skills-first; `.toml` commands are emitted only with explicit `--profile commands`.
- Non-Claude hook integration is intentionally out of scope (`docs/knowledge/decisions/non-claude-hooks-policy.md`).
- `--profile commands` is a functional conversion mode that installs command-format artifacts for selected runtimes.

---

## License

MIT License - see [LICENSE](LICENSE) for details.

---

## Acknowledgments

Built for Claude Code by Anthropic.
