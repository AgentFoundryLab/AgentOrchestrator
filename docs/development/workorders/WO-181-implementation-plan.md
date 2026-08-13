# WO-181 Implementation Plan

## Objective

Land the record schema in every distributed instruction surface without breaking multi-runtime install
fidelity, in stage-scoped commits that each leave the gates green.

## Assumptions and Dependencies

- The Factory record schema is authoritative for grammars, identity fields, and vocabularies.
- No allocator ships with this package; enforcement moves to review time.
- The Factory's own bundled templates carry a stale `REQ-[PREFIX]-001` id form that its CLI never mints — verify id forms against real records, not templates.

## Target Files and Surfaces

- `package/policy/RULES.md` — schema section, propagation chain, citation rules
- `package/skills/{spec,architect,planner,validate,reconcile,status-update}/SKILL.md` — full retarget
- `package/skills/{implement,orchestrate,context-compiler,cleanup,review,scout,security-review,meta-learn,document,qmd}/SKILL.md` — vocabulary sweep
- `package/agents/*.md` — all nine profiles
- `package/templates/` — add `frd`, `trd`, `fbp-*`, `adr`, `work-order`, `implementation-plan`, `plan`, `iss`, `reg`, `td`, `fb`; retire `prd`, `architecture`, `backlog`, `task-detail`, `issues`
- `package/workflows/{SWE,meta-learning}.md`, `package/hooks/README.md`, `AGENTS.md`, `docs/INDEX.md`
- `tests/install/smoke.sh`

## Delegation Map

- **Developer slice per stage skill** — one lane per owning skill (`spec`, `architect`, `planner`, feedback trio). Each owns its skill plus its templates; no lane touches another's.
- **Developer slice for the sweep** — the remaining skills, agents, and docs. Sequenced after the stage skills, since it depends on the vocabulary they establish.
- **Validator slice** — the four gates independently: layout check, smoke suite, frontmatter parse, cross-reference resolution.
- **Primary-only** — `RULES.md`, because every other lane's vocabulary derives from it.

## Execution Steps

1. `RULES.md` first — it is the shared dependency, so it is a sequencing barrier, not a parallel slice.
2. Stage skills in dependency order: `spec` → `architect` → `planner` → feedback trio. Each with its templates, each committed scoped.
3. Sweep the remaining skills, agents, and workflow docs for residual vocabulary.
4. Repo-level docs: `AGENTS.md`, `docs/INDEX.md`.
5. Fix any test asserting a retired template.
6. Run all four gates.

## Verification

- `bash install.sh --check` — layout and registry declarations.
- `bash tests/install/smoke.sh` — 50 conformance cases.
- Frontmatter YAML parse across all agents and skills.
- Cross-reference resolution: agent `skills:` ↔ skill `agent:`.
- Grep sweep for surviving pre-migration id forms in live surfaces.

## Risks

- **Case-insensitive filesystem.** `adr/` and `ADR/` are the same directory here; git may record the wrong case. Verify with `git ls-files` after any case-only rename.
- **Retired templates break tests.** The smoke suite asserts specific template filenames; retiring one fails a conformance case that looks unrelated.
- **The sweep is wide.** A missed reference is a dangling id in an instruction surface, which is worse than a stale doc because an agent will act on it. Gate on a full grep, not on spot checks.
