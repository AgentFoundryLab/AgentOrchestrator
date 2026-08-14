# AGENTS.md

Guidance for agents working with AgentOrchestrator.

`CLAUDE.md`, `GEMINI.md`, and every other runtime entry point read this file. Put guidance here, never in the pointer files.

## Commands

Bash and Markdown only — no package manager, no build step. Requires bash 4+ (macOS ships 3.2: `brew install bash`), `jq` for settings merges, and `uvx` for Serena provisioning.

| Task | Command |
|---|---|
| Registry-vs-package path drift, no writes | `bash install.sh --check` |
| Install, conformance, restore, idempotency suite | `bash tests/install/smoke.sh` |
| Retired-vocabulary gate on instruction surfaces | `bash tests/package/vocabulary.sh` |
| Shell + Python lint (shellcheck, ruff, whitespace) | `pre-commit run --all-files` |
| Deploy this working tree onto the machine | `bash install.sh --global --claude` |

The first three are the CI gate (`.github/workflows/install-ci.yml`); it fires on any change to `install.sh`, `package/**`, or `tests/**`. Run all three before a handoff — the suites are seconds, not minutes.

`smoke.sh` executes every case at source time and has no selector. To exercise one behavior, drive the installer directly against a throwaway `HOME`:

```bash
tmp=$(mktemp -d); HOME="$tmp" bash install.sh --global --gemini; ls "$tmp/.gemini/skills"; rm -rf "$tmp"
```

Never point an install at your real `HOME` — every test case uses a temp `HOME` for that reason.

## Repository Shape

Two boundaries matter more than the file tree.

**Source vs installed.** `package/` is authoring context that nothing reads at runtime; `install.sh` deploys it into runtime roots (`~/.claude/`, `~/.agents/`, `~/.gemini/`, `~/.config/opencode/`, `~/.qwen/`) and project-local equivalents. Instruction bodies must be valid at the *installed* path — a source-relative reference like `package/skills/...` is broken for every agent that reads the deployed copy. See the Install Context Boundary section below.

**Registry vs mechanism.** `package/install/runtimes.sh` is the canonical per-runtime table — config dir, artifact paths, capability flags, namespace modes, doc format — declared as bash 4 associative arrays and sourced with no side effects. `install.sh` owns the copy/transform/restore mechanism and resolves every path through that registry. Support a runtime by extending the arrays; never hard-code a path in the mechanism. `install.sh --check` fails when the two disagree, and the CI drift job runs exactly that.

This repository is also its own first consumer: `docs/` holds AgentOrchestrator's own records, produced by the skills in `package/skills/`.

## Artifact Layers

- Strategic: `VISION` → `BLUEPRINT`
- Requirements: `FRD` (`REQ`/`AC`) · `TRD` (`TR`/`TRC`)
- Architecture: `FBP` blueprints → `ADR`
- Knowledge: `KNOWLEDGE` (incl. `TDR`)
- Execution: `ROADMAP` → `PLAN` (Milestones) → `WO` (+ implementation plan)
- Feedback: `ISS` → `REG` · `TD` · `FB`
- Validation: `AC`/`TRC` coverage

## Artifact Definitions

Record ids are immutable and never recycled. `policy/RULES.md` owns the id grammars, identity fields, vocabularies, and status vocabularies.

**This repository's registry is its Markdown record set** — the documents under `docs/` plus the indexes below them. There is no attached Factory Project here: the `factory` CLI on this machine is bound to the `factory` Project, whose only member is a sibling repository, so `factory reg:allocate` run from this tree mints into the wrong store. Allocate by reading the owning index's footer, which states the next free number for its type; `docs/development/ID-MAP.md` resolves every pre-migration `FR`/`NFR`/`US`/`T-`/`I-`/`G-` form. Skipped numbers are deliberate and stay skipped.

| Artifact | Layer | Id | Location |
|---|---|---|---|
| **VISION** | Strategic | — | `docs/objectives/VISION.md` |
| **BLUEPRINT** | Strategic | — | `docs/objectives/BLUEPRINT.md` — *solution* scope and capability matrix, distinct from an `FBP` |
| **FRD** | Requirements | `REQ-NNN`, `AC-NNN.n` | `docs/requirements/FRD-<SCOPE>-NNN.md` |
| **TRD** | Requirements | `TR-NNN`, `TRC-NNN.n` | `docs/requirements/TRD-<SCOPE>-NNN.md` |
| **FBP** | Architecture | `FBP-<TIER>-NNN` | `docs/architecture/{foundation,feature}/`, diagrams in `system/` |
| **ADR** | Architecture | `ADR-<TIER>-NNN` | `docs/architecture/ADR/` — tier matches the blueprint it governs |
| **TDR** | Knowledge | — | `docs/knowledge/decisions/` — operational/policy choices below ADR scope |
| **Knowledge Base** | Knowledge | — | `docs/knowledge/` — domain, patterns, runbooks, learnings |
| **ROADMAP** | Execution | — | `docs/development/ROADMAP.md` — ordering and rationale only |
| **PLAN** | Execution | `PLAN-NNN` | `docs/development/plans/` — one delivery Phase, holding Milestone gates |
| **WO** | Execution | `WO-NNN` | `docs/development/workorders/` (+ `-implementation-plan.md`) |
| **ISS** | Feedback | `ISS-NNN` | `docs/development/issues/` — generalized root cause |
| **REG** | Feedback | `REG-NNN` | `docs/development/issues/` — one concrete symptom under an `ISS` |
| **TD** | Feedback | `TD-NNN` | `docs/development/debt/` — blueprint-vs-code drift with a removal trigger |
| **FB** | Feedback | `FB-NNN` | `docs/development/feedback/` — verbatim intake provenance |
| **Coverage** | Validation | — | `docs/validation/` — keyed on `AC`/`TRC`, never on a `WO` number |
| **Indexes** | — | — | `REQUIREMENTS.md`, `WORKORDERS.md`, `ISSUES.md`, `TECH_DEBT.md`, `FEEDBACK.md`, `status/STATUS.md` |

**Two meanings of "blueprint":** `docs/objectives/BLUEPRINT.md` is the *solution* blueprint (product capability scope). An `FBP-*` is a *Foundry* blueprint (architecture). They are different artifacts at different layers.

## Skill → Agent → Artifact

| Skill | Agent | Creates |
|-------|-------|---------|
| `/spec` | Business Analyst | `FRD`/`TRD` requirements |
| `/architect` | Architect | `FBP` blueprints, `ADR`s, diagrams |
| `/planner` | Planner | `ROADMAP`, `PLAN`s, `WO`s + implementation plans |
| `/review` | Tech Writer | Review report, `ISS`/`TD` |
| `/implement` | Developer | Code, tests |
| `/validate` | Validator | Coverage document, `ISS`/`REG`/`TD` |
| `/security-review` | Security | Security verdict, `ISS`/`REG` |
| `/status-update` | Validator | Assessed status in every record index |
| `/deploy` | Deployer | Deployment artifacts |
| `/document` | Tech Writer | Documentation, README |

Support skills (no dedicated artifact): `/orchestrate` (delegation), `/reconcile` (feedback routing), `/context-compiler` (context bundles), `/scout` + `/research` (evidence), `/qmd` + `/codebase-memory` (retrieval), `/analyse` (investigation), `/anneal` (complexity audit), `/distill` (compression), `/onboard` (policy bootstrap), `/cleanup` (lane teardown), `/meta-learn` (session and rule learning).

## Workflow (High Level)

```text
/spec → /architect → /planner → /review → /implement → /validate → /security-review → /status-update
```

Delivery (`/implement` → `/validate` → `/security-review` → `/status-update`) runs in every chain; the depth selects only which planning stages precede it. `/deploy` and `/document` follow delivery when the work ships or needs docs.

Detailed mechanics and depth selection are defined in:
- `package/skills/orchestrate/SKILL.md` — depth selection, delegation, lane lifecycle
- `package/workflows/SWE.md`

## Docs Index

Canonical directory layout and artifact ownership live in `docs/INDEX.md` (generated by `/onboard`).

## Policy Governance

Two-tier policy model:

```text
package/policy/        # Framework source
├── PRINCIPLES.md
└── RULES.md

docs/policy/           # Project policy
├── STANDARDS.md
└── GUIDELINES.md
```

Loading behavior:

- Global runtime loads `policy/PRINCIPLES.md` and `policy/RULES.md` from the active runtime root (for example `~/.claude/`, `~/.agents/`, `~/.gemini/`, `~/.config/opencode/`, or `~/.qwen/`).
- Project runtime loads `docs/policy/STANDARDS.md` and `docs/policy/GUIDELINES.md` when present.
- Sub-agents receive principles plus project standards/guidelines via injected references.
- `RULES.md` remains orchestrator-level.

### Install Context Boundary (Project-Only)

- `package/` is framework source authoring context.
- Installed/runtime execution context is project/global runtime paths (for example `.claude/`, `.agents/`, `.gemini/`, `.opencode/`, `.qwen/`, their matching `~/` roots, and project `docs/` outputs).
- Any agent/skill instruction intended to run after install must be valid in runtime context, not source-only context.
- Source-internal references belong in maintainer/build docs, not runtime instruction bodies.

For installation and provisioning details, use `README.md` and operational runbooks.

## HITL Escalation

Agents ask the user directly with `AskUserQuestion`; there is no separate relay protocol. `/orchestrate` lists the decision points that require a user answer.

The superseded relay protocol is recorded in `docs/knowledge/decisions/hitl-escalation.md`.

## Scope Notes

- Templates are for sub-agents and workflow-driven generation, not primary guidance for the main agent.
- Keep this file concise; detailed process/governance mechanics belong in workflow docs and knowledge/decisions.
