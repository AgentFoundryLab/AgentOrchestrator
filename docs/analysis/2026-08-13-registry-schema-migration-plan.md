# Registry Schema Migration Plan

Date: 2026-08-13
Status: accepted — Phase A go/no-go decided **go** on 2026-08-14. The `reports/validation/` → `docs/validation/` and `reports/analysis/` → `docs/analysis/` remap below is executed; `reports/research/` and `reports/meta-optimization/` stay where they are, as this plan's remap table always specified.
Scope: migrate AgentOrchestrator's artifact ids and document taxonomy to the Factory record schema, without the Factory CLI

## Objective

Replace the current ad-hoc id conventions with the Factory record schema so the package and the repo speak one artifact model:

| Current | Count (measured 2026-08-13) | Target |
|---|---|---|
| `FR<n>` groups / `FR<n>.<m>` sub-requirements | 8 / 36 | `REQ-NNN` / `AC-NNN.n` |
| `NFR<n>` | 6 | `TR-NNN` + `TRC-NNN.n` |
| `US<n>` | 6 | folded into `REQ`/`AC` |
| `T-nnn` (81 active in BACKLOG, 180 incl. archive) | 180 | `WO-NNN` |
| `I-nnn` / `G-nnn` | 3 | `ISS-NNN` + `REG-NNN` (concrete symptoms) / `TD-NNN` (drift) |
| `ADR-nnn` files | 14 | `ADR-<TIER>-NNN` |
| `ARCHITECTURE.md` (single doc) | 1 | `FBP-<TIER>-NNN` blueprint set |
| ROADMAP milestones | 10 | `PLAN-NNN` + `M<n>` |
| `reports/validation/` | 1 | AC/TRC coverage contract |
| — | — | `FB-NNN` (new: raw report intake) |

## Target schema

Taken from the Factory `factory-cli` contract, not from memory.

**Id grammars**

- Flat: `REQ` `TR` `WO` `ISS` `REG` `TD` `FB` → `TYPE-NNN`
- Parent-scoped: `AC` under a `REQ` → `AC-001.1`; `TRC` under a `TR` → `TRC-001.1`
- Tier-scoped: `FBP` `ADR` → `TYPE-<TIER>-NNN`, tier ∈ `SYS|FND|FEAT`, one counter per tier
  - `foundation`/`container`/`component` → `FND`; `feature` → `FEAT`; `system` → `SYS`
  - An ADR's tier matches the blueprint it governs

**Per-type identity fields** — an allocation missing one is invalid, not a partial record:

| Type | Required |
|---|---|
| `WO` | Phase · Milestone · Category · Scope · Title |
| `ISS` | Category · Scope · IssueType · Severity · Title · RootCauseState |
| `REG` | Category · Scope · Title · parent Issue *(no severity — inherits its ISS)* |
| `TD` | Category · Scope · Severity · Title |
| `FB` | Category · Scope · ReportKind · Report · Title · LinkedTo · Status |
| `REQ`/`TR`/`FBP`/`ADR` | Category · Scope · Title (+ priority / tier / kind) |

**Vocabularies** — `category`, `scope`, `issueType`, `area` extensible; `severity`, `priority` (`P0`–`P3`), `complexity` fixed closed sets that never borrow each other's words.

**Status vocabularies**

- `WO`: `Open | Implementing | Validating | Validated | Deferred | Closed | Decommissioned | Blocked` (`Blocked` requires ≥1 blocker id)
- `REQ`/`AC`/`TR`/`TRC`: `Not Implemented | Partial | Implemented | Postponed | Decommissioned`

**Titles** ≤ 80 chars, rephrased never truncated. `AC`/`TRC` titles are single-line handles; criterion prose lives in the requirement document.

## Allocation model — decided

**The orchestrator is the sole id allocator.** Already implemented this session in `orchestrate/SKILL.md`, `policy/RULES.md`, and the `planner`/`validate`/`security-review` skills.

- Only the orchestrator (Orchestration Mode) or the primary session (Solo Mode) reads the index, takes the next unused number, and writes the row — **before** dispatch.
- Every delegated brief carries the ids its slice may use. A sub-agent never mints one.
- A sub-agent needing an unlisted record returns a blocker naming it; the orchestrator allocates and re-dispatches or defers to the next slice.
- A crashed lane is an unknown-state event: read the index for rows it may already have written, then brief the replacement to reuse those ids and mint nothing.

This makes parallel worktree fan-out collision-safe by construction — single writer, no reservation bookkeeping.

**What this model does not give us**, and where each guarantee moves instead:

| CLI guarantee | Replacement |
|---|---|
| Collision-free minting | Sole-allocator rule (structural) |
| Vocabulary refusal on typo | `$review` cross-artifact gate; `$validate` checklist |
| Referential guards (REG parent, `blockers`, `dependsOn`) | `$review` gate |
| `reg:render` generated indexes | Hand-authored indexes; `$status-update` owns refresh |
| `reg:source` verbatim hydration | `$context-compiler` (already does this) |
| Schema versioning / migration | The id map below, plus this document |

State this honestly in the skills: these are review-time checks, not write-time refusals.

## Phase A — package (no repo artifacts touched)

1. **`policy/RULES.md`** — replace the id list in *Status and Immutable IDs* with the grammars, identity fields, vocabularies, and status vocabularies above. Keep it a naming-of-owners: the detail tables belong to the owning skills, not the always-loaded contract.
2. **`spec`** — `PRD.md` → `REQ`/`AC` + `TR`/`TRC` documents. Requires deciding whether feature and technical requirements split into separate files (Factory) or stay sections of one (current).
3. **`architect`** — `ARCHITECTURE.md` → `FBP-<TIER>-NNN` blueprints; ADRs gain tier namespacing. This is the largest single skill change: the Factory blueprint model (`component`/`model` blocks, mention syntax, per-kind baseline sections) replaces the single-architecture-doc model, and the five bundled blueprint templates need to come across.
4. **`planner`** — `T-nnn` → `WO-NNN`; task-detail → implementation-plan shape; ROADMAP milestones → `PLAN`/`M<n>`.
5. **`validate`** — validation report → AC/TRC coverage contract keyed on `AC`/`TRC` ids; `I-nnn`/`G-nnn` → `ISS`/`REG`/`TD` with the extract/reclassify/relink relationship rules.
6. **`reconcile`** — feedback taxonomy → `ISS`/`REG`/`TD`/`FB`, including `FB` intake provenance (verbatim, write-once, untrusted text) which has no current equivalent.
7. **`status-update`** — status vocabularies per type; index refresh ownership.
8. **`context-compiler`, `scout`, `review`, `security-review`, `implement`, `cleanup`, `orchestrate`** — id vocabulary sweep.
9. **`document`** — delete its duplicated propagation-path table; cite `RULES.md`/`$reconcile` as owner. (Its dangling `/hitl` blocks were fixed 2026-08-13.)
10. **`package/templates/`** — new templates per record type; retire superseded ones.

Gate: `install.sh --check`, `tests/install/smoke.sh`, frontmatter parse, cross-reference resolution — the same four that passed this session.

## Phase B — the repo's own 180 records

1. **Author the id map first**, as a committed document. Old→new is permanent and consulted forever: `T-101 → WO-101`, `FR3.2 → AC-003.2`, `ADR-014 → ADR-FND-014`. Neither side is ever reused for anything else.
2. **Preserve numbers where possible.** `T-101 → WO-101` keeps the number and only changes the type prefix, which makes the archive and every historical ADR/report still readable. Renumbering 180 rows for cosmetic contiguity would break every historical reference for no gain.
3. **Do not rewrite historical records.** ADRs, `docs/development/archive/`, `docs/development/tasks/v0.md`, and `reports/` record what was true when written. They keep their old ids; the map is how a reader resolves them. Only the live indexes migrate.
4. **Migrate in dependency order**: requirements → architecture → plan → feedback → validation, so each layer's cross-references resolve against already-migrated upstream ids.
5. **Re-point cross-references** in the same commit as each layer, so no commit leaves a dangling id.

## Ordering and risk

- Phase A is safe and reversible. Phase B is a one-way rewrite of the live indexes; run it only after Phase A's gates pass, on a dedicated branch, in per-layer commits.
- Highest-risk item is **A3 (architect)** — it is a model change, not a rename, and it also decides whether `ARCHITECTURE.md` survives at all. Worth settling before A2, because the blueprint model affects what `spec` must hand downstream.
- `FB` has no current equivalent, so it is additive rather than a migration.
- The 180-row rewrite (B) is mechanical but wide. It is the natural first real exercise of the sole-allocator rule and of `$orchestrate`'s parallel fan-out — one lane per layer, ids from the brief.

## Resolved decisions

1. **Requirements file layout** — **Factory layout.** Separate `FRD-<SCOPE>-NNN.md` and `TRD-<SCOPE>-NNN.md` documents under `docs/requirements/`, with a generated `REQUIREMENTS.md` index. `PRD.md` is retired.
2. **Blueprint model** — **Factory layout.** Full Foundry blueprint set: `FBP-<TIER>-NNN.md` under `docs/architecture/{foundation,feature,system}/`, per-kind baseline sections, `component`/`model` blocks, mention syntax. ADRs move to `docs/architecture/ADR/ADR-<TIER>-NNN.md`. `ARCHITECTURE.md` is retired — its content decomposes into blueprints.
3. **Index generation** — hand-authored, `$status-update` owns refresh. No generator built; deferred, not needed.

## Document layout — verified against the Factory repo

Read from `factory/docs/` rather than inferred. Standalone repos use 3-digit ids (`REQ-001`); the Factory's own 4-digit form (`REQ-1001`) is Project-mode range indexing and does not apply here.

```
docs/
├── requirements/
│   ├── REQUIREMENTS.md                      generated index
│   ├── FRD-<SCOPE>-NNN.md                   Feature Requirements — holds REQ-* / AC-*
│   └── TRD-<SCOPE>-NNN.md                   Technical Requirements — holds TR-* / TRC-*
├── architecture/
│   ├── foundation/FBP-FND-NNN.md            foundation | container | component
│   ├── feature/FBP-FEAT-NNN.md              feature blueprints
│   ├── system/<NAME>.md                     system diagrams
│   └── ADR/ADR-<TIER>-NNN.md                + generated README.md index
├── development/
│   ├── ROADMAP.md
│   ├── WORKORDERS.md · ISSUES.md · TECH_DEBT.md · FEEDBACK.md    generated indexes
│   ├── workorders/WO-NNN.md, WO-NNN-implementation-plan.md
│   ├── issues/ISS-NNN.md, REG-NNN.md
│   ├── debt/TD-NNN.md
│   ├── plans/PLAN-NNN-<slug>.md
│   └── status/STATUS.md                     generated
├── validation/
├── objectives/                              VISION.md, BLUEPRINT.md
├── knowledge/                               retained — domain, patterns, decisions (TDR), runbooks
├── policy/                                  retained — STANDARDS.md, GUIDELINES.md
├── analysis/
└── archive/development/{ISSUES,TECH_DEBT,WORKORDERS}.md
```

### Path re-map

| Current | Target |
|---|---|
| `docs/architecture/PRD.md` | `docs/requirements/FRD-<SCOPE>-NNN.md` + `TRD-<SCOPE>-NNN.md` |
| `docs/architecture/ARCHITECTURE.md` | `docs/architecture/{foundation,feature}/FBP-<TIER>-NNN.md` |
| `docs/architecture/adr/NNN-<slug>.md` | `docs/architecture/ADR/ADR-<TIER>-NNN.md` |
| `docs/architecture/diagrams/` | `docs/architecture/system/` |
| `docs/architecture/technical/` | folded into the governing `FBP` |
| `docs/objectives/ROADMAP.md` | `docs/development/ROADMAP.md` + `docs/development/plans/PLAN-NNN-*.md` |
| `docs/development/BACKLOG.md` | `docs/development/WORKORDERS.md` + `workorders/WO-NNN.md` |
| `docs/development/tasks/*.md` | `workorders/WO-NNN-implementation-plan.md` |
| `docs/development/ISSUES.md` (I-/G-) | `ISSUES.md` + `issues/ISS-NNN.md`, `TECH_DEBT.md` + `debt/TD-NNN.md` |
| `docs/development/archive/` | `docs/archive/development/` |
| `reports/validation/` | `docs/validation/` |
| `reports/analysis/` | `docs/analysis/` |
| `docs/knowledge/`, `docs/policy/`, `docs/objectives/{VISION,BLUEPRINT}` | unchanged |

`docs/objectives/` keeps VISION and BLUEPRINT — the Factory has no equivalent and they are orchestrator product framing, not a Refinery artifact.

## Delivery records

- **WO-181** — Phase A (package). Branch `task/WO-181`.
- **WO-182** — Phase B (repo artifacts).

Numbering starts at 181 because `T-180` is the highest existing id and numbers are preserved across the type change.
