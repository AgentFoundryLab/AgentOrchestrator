# WO-183 Implementation Plan

## Objective

Land one rule owner per failure mode, with each skill citing that owner rather than restating it, in
surface-scoped commits on `dev`. On 2026-09-29 the user chose direct commits to `dev` with no PR.

## Assumptions and Dependencies

- `REQ-015`, `AC-004.5`, `AC-011.5`/`.6`, and `AC-012.8`/`.9` are committed (`aac8cdf`).
- The work runs through `$meta-learn` inline, because instruction surfaces are out of bounds for a delivery lane.

## Target Files and Surfaces

- `package/policy/RULES.md` — tier table, readiness, hydration, minting
- `package/skills/orchestrate/SKILL.md` — mechanisms for D, E, and the scope controls
- `package/skills/context-compiler/SKILL.md` — fail-closed bundle
- `package/skills/planner/SKILL.md`, `package/templates/*` — done condition, boilerplate removal, `Protects`
- `package/skills/{validate,status-update}/SKILL.md`, `package/agents/validator.md` — verdict levels, release picture
- `package/skills/{review,reconcile,security-review}/SKILL.md` — protected-behaviour triage, tier-scaled security
- `package/workflows/SWE.md`, `docs/architecture/feature/FBP-FEAT-00{1,2}.md`

## Delegation Map

- Primary-only, for all of it. `$meta-learn` must run inline, and the surfaces share one vocabulary rooted in `RULES.md`.

## Verification

- The CI gate trio, `pre-commit run --all-files`, the restatement sweep, and a throwaway-`HOME` install.
- The `$meta-learn` step 7 re-validation table, in `reports/meta-optimization/`.

## Risks

- A restatement of the universal chain survives somewhere and contradicts the tier table. The restatement sweep is the mitigation.
- The T0 in-session status and security steps could read as a delegation bypass. The tier table must name them as sanctioned depth, not as skips.
