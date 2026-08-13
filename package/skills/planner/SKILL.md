---
name: planner
description: Generate Work Orders, implementation plans, and delivery Plans from requirements and blueprints
argument-hint: requirement id, blueprint id, or planning focus
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Grep
  - Glob
  - Bash
  - TaskCreate
  - TaskUpdate
  - TaskList
  - AskUserQuestion
context: fork
agent: planner
---

# /planner - Work Orders and Plans

- Create executable planning artifacts from requirements and blueprints.

## Purpose

Transform upstream artifacts into:
- **Work Orders** — `WO-NNN`, one per coherent deliverable, cross-referencing requirements by id
- **Implementation Plans** — attached to a WO when work needs stepwise execution guidance
- **Delivery Plans** — `PLAN-NNN`, one per delivery Phase, holding Milestone coordination gates
- A refreshed `WORKORDERS.md` index

## Document and id grammar

| Artifact | Path | Holds |
|---|---|---|
| Work Order | `docs/development/workorders/WO-NNN.md` | scope, requirements, blueprints, test plan |
| Implementation plan | `docs/development/workorders/WO-NNN-implementation-plan.md` | execution steps, delegation map |
| Delivery Plan | `docs/development/plans/PLAN-NNN-<slug>.md` | Milestones `M<n>` + cross-plan edges |
| WO index | `docs/development/WORKORDERS.md` | one row per Work Order |
| Roadmap | `docs/development/ROADMAP.md` | ordering and rationale only |

## Artifact Roles

Keep these distinct; collapsing them is the failure mode this split exists to prevent.

| Artifact | Exists to | Never holds |
|---|---|---|
| `ROADMAP.md` | bridge vision → planning; own **ordering and rationale** | scope decomposition, schedule, WO or Milestone listings |
| `PLAN-NNN` | one delivery **Phase**; hold Milestone gates + cross-plan edges | stages, lanes, or a WO listing |
| `WO-NNN` | the execution contract for one deliverable | verbatim requirement text |
| `WO-NNN-implementation-plan` | stepwise guidance for multi-file or risky work | scope redefinition |
| `WORKORDERS.md` | the lookup index | prose that belongs in the WO |

**Author each membership fact once.** A Work Order's own record states its `Phase` and `Milestone`. The Plan document never lists its Work Orders — ask what a Phase or Milestone contains by filtering the index. A second listing drifts the moment either side changes.

**One Plan is one delivery Phase.** A Milestone is a coordination gate — integration validation, merge, or promotion — never a work container. Plan *structure* is revisable (a wrong Milestone shape is meant to be fixed); record *ids* never are.

## Inputs

- `$ARGUMENTS`: requirement id, blueprint id, work slice, or planning focus
- Requirements under `docs/requirements/` + the `REQUIREMENTS.md` index
- Blueprints under `docs/architecture/` + the ADR index
- Existing plan: `docs/development/ROADMAP.md`, `plans/`, `workorders/`, `WORKORDERS.md`
- Templates from the active runtime root's `templates/` directory (`work-order.md`, `implementation-plan.md`, `plan.md`, `roadmap.md`)

## Outputs

- Create/update `WO-NNN.md` and optional `WO-NNN-implementation-plan.md` under `docs/development/workorders/`
- Create/update `PLAN-NNN-<slug>.md` under `docs/development/plans/`
- Refresh `docs/development/WORKORDERS.md` rows for every WO touched
- Update `ROADMAP.md` only when phase ordering or its rationale changed

## Id allocation

`WO` and `PLAN` ids are immutable and never recycled. **Under `$orchestrate`, ids come from the brief** — the orchestrator is the sole allocator so parallel lanes cannot claim the same number. Working solo, read `WORKORDERS.md` for the highest existing `WO` and take the next. If a delegated slice needs an id the brief did not provide, return a blocker naming it rather than minting.

Every Work Order carries its identity fields at allocation — **`Phase`, `Milestone`, `Category`, `Scope`, `Title`**. Placement is set here, not deferred. `category` and `scope` must come from the project's recorded vocabulary; a new value is a deliberate extension, recorded before first use.

## Delegation Guidance

- On a delegated planning slice: follow the brief's scope, file/surface ownership, exclusions, validation expectations. Do not expand scope or assume orchestration ownership. Return artifacts changed, ids authored, sequencing assumptions, blockers, residual risk.

## Workflow

### 1. Read upstream artifacts
- Load relevant requirements from `docs/requirements/` first
- Load the governing blueprints and their ADRs
- Ignore any legacy PRD/BACKLOG/task-detail flow

### 2. Extract the right Work Order set
- Start from updated blueprints and requirements, not ad hoc task guesses
- For domain/data model changes, require an explicit Architect adversarial-validation reference before scheduling implementation
- Split by coherent deliverable or feature slice
- Refresh Work Orders when upstream artifacts changed materially

### 3. Define Work Order boundaries
- One Work Order per coherent deliverable
- Keep scope explicit with `In Scope` and `Out of Scope`
- Split large or mixed concerns into separate Work Orders

### 4. Write the Work Order
Use the template's sections exactly: `Summary`, `In Scope`, `Out of Scope`, `Requirements`, `Blueprints`, `Test Plan`.

- Keep `Summary` to the delivery outcome in 2-3 sentences, not background narrative
- Immediately after the summary add `Implementation Plan: [WO-NNN-implementation-plan.md](WO-NNN-implementation-plan.md)`, or `Implementation Plan: None required.`
- **Cross-reference requirements by immutable id with a one-line description each.** The requirements document is the single source of truth; never copy `REQ`/`AC`/`TR`/`TRC` text verbatim — copies go stale, and `$context-compiler` hydrates the full text on demand at implementation time
- List governing blueprints with one-line summaries; implementers read the full blueprint directly
- When the objective is reference-parity, carry the spec's flow-completeness and visual-parity criteria into WO scope and test plan; do not narrow the WO to behavioral minimums
- `Test Plan` uses `Unit Tests`, `Integration Tests`, `E2E Tests`. Keep unit and integration concise and behavior-first; reserve structured scenario detail for E2E with `COV_` group ids and `@COV_` case tags
- **Tag tests by the acceptance criterion they prove, never by the Work Order number.** Test files, titles, assertion tags, fixtures, and helpers named after a WO become unreadable the moment the WO closes
- For regression work, preserve the reported regression evidence and plan TDD-first remediation: broken-behavior characterization passing against the current regression, corrected `AC`/`TRC` update, failing corrected tests, implementation, then green validation
- New Work Orders enter at `Open`. Never invent implementation status — `$status-update` owns it

### 5. Sequence the work
- Set `dependsOn` accurately: this is the graph `$orchestrate` uses to parallelize a Phase — Work Orders with no unmet dependency fan out concurrently, one worktree each. Omit only when the WO is truly independent
- A shared surface touched by multiple Work Orders (schema, contract, interface) is a **sequencing barrier, not a parallel slice** — say so explicitly
- Assign `Phase` (a `PLAN-*` id) and `Milestone` (an `M-*` id) on the record

### 6. Add an Implementation Plan only when needed
- Required for multi-file, high-risk, or dependency-sensitive work
- Sections exactly: `Objective`, `Assumptions and Dependencies`, `Target Files and Surfaces`, `Delegation Map`, `Execution Steps`, `Verification`, `Risks`
- Keep it file-level and sequence-oriented; validate one isolated change at a time
- `Delegation Map` names the developer and validator slices suitable for sub-agents, plus any primary-only work
- When a plan exists, the owning WO must link it explicitly in `Summary`

### 7. Maintain the Plan and Roadmap
- A new delivery Phase mints a `PLAN-NNN` document with its Milestone gates and cross-plan edges — and no WO listing
- Declare no Milestones when the Phase is sequenced by `dependsOn` alone, and say so rather than leaving the section empty
- `ROADMAP.md` gains a row only when phase **ordering or rationale** changes. Never add a Work Order, Milestone gate, acceptance criterion, or piece of evidence to it

### 8. Refresh the index
Update `docs/development/WORKORDERS.md` for every Work Order touched. One row each:

```md
| WO | Area | Phase | Milestone | Category | Scope | Title | Depends On | Complexity | Size | Story Points | Priority | Requirements | Blockers | Status |
```

- `Complexity` is `Low` | `Medium` | `High` — it **selects the delivery model tier**, so set it deliberately (see `$orchestrate` for the tier→model table)
- `Priority` is `P0`–`P3`; `severity` is not a priority and never appears here
- `Blockers` is an id list and is **required** whenever status is `Blocked`
- Never hand-invent a status value; the vocabulary is `Open | Implementing | Validating | Validated | Deferred | Closed | Decommissioned | Blocked`

## Template References

From the active runtime root's `templates/` directory:
- `work-order.md`
- `implementation-plan.md`
- `plan.md`
- `roadmap.md`

## Validation Checklist

- [ ] Work Order scope is explicit and bounded, at the right path, with the template's sections
- [ ] Requirements cross-referenced by immutable id with brief descriptions, not copied verbatim
- [ ] Blueprint references sufficient for implementation
- [ ] Test plan covers unit, integration, and E2E where applicable; nothing named after the WO number
- [ ] Regression plans preserve original evidence and include TDD-first corrected-criteria validation
- [ ] Domain/data model plans cite Architect adversarial validation
- [ ] Implementation Plan exists only when the work needs it, and the WO links it or states `None required`
- [ ] `dependsOn` reflects the real dependency graph; shared surfaces called out as sequencing barriers
- [ ] Every WO carries `Phase`, `Milestone`, `Category`, `Scope`, `Title`, `Complexity`, `Priority`
- [ ] Plan document holds Milestones and edges only — no WO listing
- [ ] `ROADMAP.md` still owns only ordering and rationale
- [ ] No `WO`/`PLAN` id renumbered or recycled; no status invented
