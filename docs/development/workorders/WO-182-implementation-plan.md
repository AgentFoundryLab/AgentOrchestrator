# WO-182 Implementation Plan

## Objective

Rewrite this repository's live artifact set into the typed record schema in dependency order, so each
layer's cross-references resolve against an already-migrated upstream layer.

## Assumptions and Dependencies

- `WO-181` has landed: the package speaks the record schema before the repository's artifacts do.
- Numbers are preserved across the type change; renumbering would break every historical reference.
- Historical records are not rewritten. The id map is what resolves them.

## Target Files and Surfaces

- `docs/development/ID-MAP.md` — authored first, before any artifact moves
- `docs/requirements/` — 8 `FRD-*`, 1 `TRD-*`, `REQUIREMENTS.md`
- `docs/architecture/{foundation,feature,system,ADR}/` — 10 blueprints, 14 ADRs, ADR index
- `docs/development/{ROADMAP.md,plans/,workorders/,WORKORDERS.md}`
- `docs/development/{issues/,debt/,feedback/,ISSUES.md,TECH_DEBT.md,FEEDBACK.md}`
- `docs/archive/development/WORKORDERS.md`
- `docs/validation/`, `docs/analysis/`

## Delegation Map

- **One lane per layer**, strictly sequenced — requirements, then architecture, then plan, then feedback. Layers cannot run in parallel because each cites the one before it.
- **Validator slice** — after each layer: assert no dangling id and that every citation resolves.
- **Primary-only** — the id map, since every lane reads it and none may extend it.

## Execution Steps

1. Author the id map. Nothing moves before it exists.
2. Requirements: decompose the PRD into `FRD`/`TRD` documents, mapping `FR<n>.<m>` → `AC-<n>.<m>` and promoting user stories to their own requirements. Generate the index.
3. Architecture: decompose `ARCHITECTURE.md` into blueprints; rename ADRs to tier-scoped ids and generate their index; move diagrams to `system/`.
4. Plan: reduce `ROADMAP.md` to ordering and rationale, mint the `PLAN-*` documents, convert backlog rows to `WO` index rows, and split closed records into the archive index.
5. Feedback: convert `I-`/`G-` rows into `ISS`/`TD` records with their own documents and indexes.
6. Retire `PRD.md`, `ARCHITECTURE.md`, and `BACKLOG.md` once their content has moved.
7. Re-point every cross-reference in the same commit as its layer.

## Verification

- After each layer: grep for pre-migration id forms in live artifacts; confirm every cited id resolves.
- After the plan layer: confirm the archive and active indexes together account for every `T-nnn`.
- Throughout: `install.sh --check` and the smoke suite stay green.

## Risks

- **A layer committed with dangling ids.** Mitigated by re-pointing references in the same commit as the layer, never in a follow-up.
- **Carried-forward statuses read as verified.** They are not. The index states the provenance explicitly; a `$status-update` pass is required before any row is cited as evidence.
- **Case-insensitive filesystem** on the `adr/` → `ADR/` rename. Verify the recorded case with `git ls-files`.
- **Speculative Work Order documents.** Authoring documents for 79 unscheduled Open items would fabricate scope. Only genuinely active items get documents; the rest are index rows until `$planner` schedules them.
