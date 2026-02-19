# AGENTS.md

Guidance for Agents when working with AgentOrchestrator.

---

## Artifact Layers

```
┌─────────────────────────────────────────────────────────────────────┐
│  STRATEGIC (locked after PRD)                                       │
│  VISION ───▶ BLUEPRINT                                              │
├─────────────────────────────────────────────────────────────────────┤
│  SPECIFICATION (changes with approval)                              │
│  PRD ───▶ ARCHITECTURE ───▶ ADR                                     │
├─────────────────────────────────────────────────────────────────────┤
│  EXECUTION (changes frequently)                                     │
│  ROADMAP ───▶ BACKLOG                                               │
└─────────────────────────────────────────────────────────────────────┘
```

## Artifact Definitions

| Artifact | Layer | Contains |
|----------|-------|----------|
| **VISION** | Strategic | Why, target users, success metrics |
| **BLUEPRINT** | Strategic | Technical scope, capabilities, feature matrix |
| **PRD** | Specification | Features, user stories, acceptance criteria |
| **ARCHITECTURE** | Specification | System design, risks, dependencies |
| **ADR** | Specification | Decision rationale, alternatives, consequences |
| **ROADMAP** | Execution | Milestones, phases, epics + dependencies |
| **BACKLOG** | Execution | Prioritized tasks from ROADMAP epics |
| **ISSUES** | Execution | Discovered bugs, blockers, tech debt |

## Artifact Locations

```
docs/
├── objectives/           # Strategic
│   ├── VISION.md
│   ├── BLUEPRINT.md
│   └── ROADMAP.md
├── architecture/         # Specification
│   ├── PRD.md
│   ├── ARCHITECTURE.md
│   ├── adr/
│   └── diagrams/
└── development/          # Execution
    ├── BACKLOG.md        # Prioritized tasks
    └── ISSUES.md         # Discovered bugs/blockers
```

## Skill → Agent → Artifact

| Skill | Agent | Creates |
|-------|-------|---------|
| `/spec` | Business Analyst | PRD |
| `/design` | Architect | ARCHITECTURE, ADRs |
| `/plan` | Project Manager | ROADMAP, BACKLOG |
| `/review` | Tech Writer | Review Report, ISSUES |
| `/implement` | Developer | Code, Tests |
| `/validate` | Validator | Validation Report |
| `/deploy` | Deployer | Deployment Artifacts |
| `/document` | Tech Writer | Documentation, README |

## Workflow

```
/spec → PRD → /design → ARCHITECTURE + ADRs → /plan → ROADMAP + BACKLOG → /review → /implement → /validate → /deploy → /document
```

## Task Hierarchy (ADR-005)

```
Milestone (Release)      → Tag
└── Phase (Workflow)     → —
    └── Epic (Feature)   → —
        └── Task (Atomic) → Commit
```

| Level | Definition | Git Artifact |
|-------|------------|--------------|
| Milestone | Shippable release | Tag |
| Phase | Research, Design, Implement, Validate | — |
| Epic | Group of related tasks | — |
| Task | Atomic, testable, committable | Commit |

## Traceability

```
US-001 → COMP-003 → ADR-005 → EPIC-007 → TASK-015 → commit [refs: US-001]
```

---

## HITL Escalation

Sub-agents spawned via `Task` tool cannot call `AskUserQuestion`. When an agent needs
clarification before proceeding, it must return a structured QUESTIONS block:

```
## QUESTIONS FOR USER

Q1: [Question] *(Required before proceeding)*
- Option A: [description]
- Option B: [description]

Q2: [Question] *(Optional — default: [default])*
- Option A: [description]
- Option B: [description]
```

The Orchestrator detects this block, relays questions via `AskUserQuestion`, then
re-invokes the agent with answers prepended to the prompt.

---

## Change Impact Classification

Changes are classified by two orthogonal dimensions: **Area** (what changed) and **Criticality** (severity).

### Impact Areas

| Area | Boundary | Entry Point |
|------|----------|-------------|
| **System** | Core functionality broken (hooks, MCP, install, agents) | ISSUES |
| **Product** | Vision, goals, target users, success metrics | VISION |
| **Solution** | Capabilities, feature matrix, technical scope | BLUEPRINT |
| **Specification** | Features, requirements, user stories, acceptance criteria | PRD |
| **Architecture** | Components, patterns, dependencies, decisions | ARCHITECTURE |
| **Development** | Task organization, priorities, status | ROADMAP/BACKLOG |
| **Documentation** | All docs: arch docs, policies, knowledge, runbooks | Varies |

### Criticality Levels

| Level | Definition | Response |
|-------|------------|----------|
| **CRITICAL** | Blocking, broken functionality, data loss risk | Immediate action required |
| **HIGH** | Significant impact, major feature affected | Address in current session |
| **MEDIUM** | Moderate impact, standard priority | Address in current sprint |
| **LOW** | Minor, cosmetic, can defer | Backlog for later |

### Propagation Paths by Area

```
SYSTEM        → ISSUES → BACKLOG
PRODUCT       → VISION → BLUEPRINT → PRD → ARCHITECTURE → ADR → ROADMAP → BACKLOG
SOLUTION      → BLUEPRINT → PRD → ARCHITECTURE → ADR → ROADMAP → BACKLOG
SPECIFICATION → PRD → ARCHITECTURE → ADR → ROADMAP → BACKLOG
ARCHITECTURE  → ARCHITECTURE → ADR → ROADMAP → BACKLOG
DEVELOPMENT   → ROADMAP → BACKLOG (or BACKLOG only)
DOCUMENTATION → Direct to target doc (README, CLAUDE.md, docs/policy/, docs/knowledge/)
```

### Examples (Area × Criticality)

| Change | Area | Criticality | Path |
|--------|------|-------------|------|
| Hooks not firing | System | CRITICAL | ISSUES → BACKLOG |
| New target user segment | Product | HIGH | VISION → BLUEPRINT → ... → BACKLOG |
| New capability added | Solution | HIGH | BLUEPRINT → PRD → ARCH → ROADMAP → BACKLOG |
| New skill behavior | Specification | MEDIUM | PRD → ARCHITECTURE → BACKLOG |
| New hook utils library | Architecture | MEDIUM | ARCHITECTURE → BACKLOG |
| Component refactor | Architecture | HIGH | ARCHITECTURE → ADR → BACKLOG |
| Task completed | Development | LOW | BACKLOG |
| ARCHITECTURE.md outdated | Documentation | MEDIUM | ARCHITECTURE.md directly |
| README typo | Documentation | LOW | README.md directly |
| Policy update | Documentation | MEDIUM | docs/policy/ or package/policy/ |

### Policy Locations

Two-tier policy structure:

```
package/policy/             # Framework source (→ ~/.claude/policy/, auto-loaded)
├── PRINCIPLES.md           # SW engineering principles
└── RULES.md                # Agent behavioral rules

<project>/docs/policy/      # Project-specific (generated by /onboard)
├── STANDARDS.md            # Technical standards & conventions
└── GUIDELINES.md           # Process & workflow guidance
```

**Installation flow**:
- `./install.sh --global` → `package/*` → `~/.claude/` (`agents/`, `skills/`, policy/workflows/templates/hooks/settings) + injects `@`-refs into runtime docs
- `./install.sh --project <path>` → provisions docs tree + deploys `.claude/agents`, `.claude/skills`, templates, policy, workflows + injects `@`-refs
- Optional: `--namespace <name>` installs agents/skills under namespaced paths instead of flat
- `/onboard` → analyzes project, hydrates STANDARDS.md + GUIDELINES.md from templates

### Policy Loading

**Global** (auto-loaded via `@`-references in `~/.claude/CLAUDE.md`):
1. `~/.claude/policy/PRINCIPLES.md` — always in context
2. `~/.claude/policy/RULES.md` — always in context (orchestrator-level)

**Project** (auto-loaded via `@`-references in project `CLAUDE.md`):
1. `docs/policy/STANDARDS.md` — MUST: conventions, constraints, limitations
2. `docs/policy/GUIDELINES.md` — SHOULD: best practices, recommendations

Sub-agents receive PRINCIPLES + STANDARDS/GUIDELINES via `@`-refs in agent definitions.
RULES is orchestrator-level only (not injected into sub-agents).

Files may not exist until `/onboard` runs — missing `@`-refs are silently skipped.

### Docs Index

| Directory | Contents |
|-----------|----------|
| `docs/policy/` | STANDARDS.md (MUST), GUIDELINES.md (SHOULD) |
| `docs/objectives/` | VISION.md, BLUEPRINT.md, ROADMAP.md |
| `docs/architecture/` | PRD.md, ARCHITECTURE.md, adr/ |
| `docs/development/` | BACKLOG.md, ISSUES.md |
| `docs/knowledge/` | Domain concepts, patterns, runbooks |

### Templates

Source in `package/templates/`, installed to `~/.claude/templates/` (global) and `<project>/.claude/templates/` (project-local):

| Template | Output | Hydrated by |
|----------|--------|-------------|
| `standards.md` | `docs/policy/STANDARDS.md` | `/onboard` |
| `guidelines.md` | `docs/policy/GUIDELINES.md` | `/onboard` |
| `prd.md` | `docs/architecture/PRD.md` | `/spec` |
| `architecture.md` | `docs/architecture/ARCHITECTURE.md` | `/design` |
| `adr.md` | `docs/architecture/adr/NNN-*.md` | `/design` |
| `roadmap.md` | `docs/objectives/ROADMAP.md` | `/plan` |
| `backlog.md` | `docs/development/BACKLOG.md` | `/plan` |
| `vision.md` | `docs/objectives/VISION.md` | `/spec` |
| `blueprint.md` | `docs/objectives/BLUEPRINT.md` | `/spec` |
| `issues.md` | `docs/development/ISSUES.md` | various |

---

## Development

```bash
# UV required for all Python operations
uv run pytest                    # Run tests
uv pip install package           # Install dependencies

# Installation
./install.sh --global            # Install to ~/.claude/
./install.sh --project <path>    # Install project templates
./install.sh --global --project <path>  # Both
```

### Python Script Convention

**All Python scripts must be self-contained via uvx shebang**:

```python
#!/usr/bin/env -S uvx --from package-name python
```

- **Execute directly**: `./script.py` (NOT `python script.py`)
- uvx automatically installs dependencies in isolated environment
- No manual dependency management required

Example shebangs:
- Claude SDK: `#!/usr/bin/env -S uvx --from claude-agent-sdk python`
- Multiple deps: `#!/usr/bin/env -S uvx --from "package1,package2" python`

---

## MCP Dependencies

| Server | Purpose | Required |
|--------|---------|----------|
| **Serena** | Memory persistence, symbolic code operations | Yes |
| **Context7** | Documentation lookup | Yes |
| **DeepWiki** | GitHub repository documentation | Yes |
| **Playwright** | Browser automation | Optional |
