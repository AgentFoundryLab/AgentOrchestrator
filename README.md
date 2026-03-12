# AgentOrchestrator

Minimalist multi-agent orchestration framework for Claude Code.
Inspired by SuperClaude.

**Version**: 0.2.0  | **Status**: v0.2.0 Multi-Runtime Install

---

## Overview

AgentOrchestrator transforms Claude Code from a single-turn assistant into an orchestrated multi-agent system with:

- **7 Specialized Agents**: Business Analyst, Architect, Project Manager, Developer, Validator, Deployer, Tech Writer
- **15 Skills**: Workflow commands from `/spec` to `/deploy` plus shared HITL protocol
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
/design
/plan
/implement T-001
```

---

## Skills Reference

### Workflow Skills (Agent-Backed)

| Skill | Agent | Purpose | Output |
|-------|-------|---------|--------|
| `/spec` | Business Analyst | Requirements elicitation | `docs/architecture/PRD.md` |
| `/design` | Architect | System architecture | `docs/architecture/ARCHITECTURE.md`, ADRs |
| `/plan` | Project Manager | Task decomposition | `docs/objectives/ROADMAP.md`, `docs/development/BACKLOG.md` |
| `/implement` | Developer | Code implementation | Source files, tests |
| `/validate` | Validator | Testing and verification | Validation report |
| `/deploy` | Deployer | Build and deployment | Deployment artifacts |
| `/document` | Tech Writer | Documentation | `docs/`, `README.md` |

### Utility Skills (Inline)

| Skill | Purpose | Output |
|-------|---------|--------|
| `/orchestrate` | Guided workflow orchestration | Coordinates agents |
| `/reflexion` | Error learning capture | Serena memory |
| `/reflect` | Session meta-learning | Serena memory |
| `/optimize` | System improvement proposals | Meta-opt plan |
| `/analyse` | Code investigation | `reports/analysis/` |
| `/research` | Documentation lookup | `reports/research/` |
| `/distill` | Content distillation (5-level granularity) | Replace original |

---

## Agents Reference

| Agent | Domain | Key Tools | Boundaries |
|-------|--------|-----------|------------|
| **Business Analyst** | Requirements | Read, Grep, Glob, WebSearch | No code, no architecture |
| **Architect** | Design | Read, Grep, Glob, WebSearch | No implementation |
| **Project Manager** | Planning | Read, Write, TaskCreate | No code, no design |
| **Developer** | Implementation | Read, Write, Edit, Bash, Task | No architecture decisions |
| **Validator** | Testing | Read, Grep, Glob, Bash | No fixes, no writes |
| **Deployer** | Deployment | Read, Write, Bash | No code changes, `permissionMode: plan` |
| **Tech Writer** | Documentation | Read, Write, Grep, Glob, AskUserQuestion | No code, no Edit |

### Agent Details

**Validator**: Runs tests, verifies acceptance criteria, checks code quality. Cannot modify code - reports findings only.

**Deployer**: Manages build and deployment operations. Runs in `permissionMode: plan` requiring user approval for destructive operations.

**Tech Writer**: Creates and maintains documentation. Uses `AskUserQuestion` for conflict detection - never silently overwrites docs when inconsistencies are detected between documents, code, or ADR decisions.

---

## Workflow Depths

Orchestrator assesses complexity and recommends appropriate workflow depth:

### Full Workflow
**Use when**: New product, complex system, multiple components

```
/spec -> /design -> /plan -> /implement -> /validate -> /deploy -> /document
```

### Medium Workflow
**Use when**: New feature, moderate complexity

```
/spec -> /plan -> /implement -> /validate
```

### Light Workflow
**Use when**: Simple change, bug fix

```
/plan -> /implement
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
│   ├── architecture/     # PRD.md, ARCHITECTURE.md, adr/
│   ├── development/      # BACKLOG.md, ISSUES.md
│   └── knowledge/        # Project knowledge base
└── reports/
    ├── analysis/         # /analyse outputs
    └── research/         # /research outputs
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
├── ARCHITECTURE.md  # System design, risks, dependencies
└── adr/             # Decision rationale, alternatives, consequences

Execution (changes frequently)
├── ROADMAP.md       # Milestones, phases, epics + dependencies
├── BACKLOG.md       # Prioritized tasks from ROADMAP epics
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
| SubagentStop | `remind-validate.sh`, `remind-reflexion.sh` | Validation + reflexion prompt |
| Stop | `remind-reflect.sh` | Prompt /reflect for session learning |
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
| `prd.md` | Product requirements document | `docs/architecture/PRD.md` |
| `architecture.md` | System architecture | `docs/architecture/ARCHITECTURE.md` |
| `adr.md` | Architectural decision records | `docs/architecture/adr/` |
| `roadmap.md` | Milestones, phases, epics | `docs/objectives/ROADMAP.md` |
| `backlog.md` | Prioritized task list | `docs/development/BACKLOG.md` |
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
- [PRD](docs/architecture/PRD.md) - Product requirements
- [Architecture](docs/architecture/ARCHITECTURE.md) - System design
- [ADRs](docs/architecture/adr/) - Architectural decisions
- [Roadmap](docs/objectives/ROADMAP.md) - Milestones and phases
- [Backlog](docs/development/BACKLOG.md) - Task tracking
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
