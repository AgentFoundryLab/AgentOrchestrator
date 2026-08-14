# Documentation Index

**Version**: 1.0.1 | **Updated**: 2026-02-24
> Amend with rationale. Bump: MAJOR (breaking), MINOR (additions), PATCH (clarifications).

## Top-Level Layout

```
orchestrator/
├── CLAUDE.md / AGENTS.md      # Runtime entry points
├── README.md                  # Project overview, quick start, reference tables
├── install.sh                 # Installer (--global, --project, --namespace)
├── package/                   # Framework source — deployed by install.sh
│   ├── agents/                # 7 agent definitions
│   ├── skills/                # 23 skill directories
│   ├── hooks/scripts/         # 5 lifecycle hook scripts + lib
│   ├── policy/                # PRINCIPLES.md, RULES.md (global source)
│   ├── workflows/             # SWE.md, meta-learning.md
│   ├── templates/             # per-record-type artifact templates
│   └── settings.json / mcp.json
├── docs/                      # Orchestrator's own project docs
│   ├── objectives/            # VISION.md, BLUEPRINT.md
│   ├── requirements/          # FRD-*, TRD-*, REQUIREMENTS.md
│   ├── architecture/          # foundation/, feature/, system/, ADR/
│   ├── development/           # ROADMAP.md, plans/, workorders/, issues/,
│   │                          #   debt/, feedback/, status/, + indexes
│   ├── validation/            # AC/TRC coverage documents
│   ├── policy/                # STANDARDS.md, GUIDELINES.md (project tier)
│   ├── knowledge/             # decisions/ (TDR), domain/, patterns/, runbooks/
│   ├── analysis/              # review, reconcile, analyse, meta-learn repo memos
│   └── archive/development/   # closed + decommissioned records
└── reports/                   # research/ and meta-optimization/ outputs
```

## Artifact Ownership

| Artifact | Path | Owner Skill |
|----------|------|-------------|
| VISION.md, BLUEPRINT.md | `docs/objectives/` | `/spec` |
| ROADMAP.md | `docs/development/ROADMAP.md` | `/planner` |
| FRD / TRD + REQUIREMENTS.md | `docs/requirements/` | `/spec` |
| FBP blueprints, ADRs, diagrams | `docs/architecture/{foundation,feature,system,ADR}/` | `/architect` |
| PLANs, WOs + WORKORDERS.md | `docs/development/{plans,workorders}/` | `/planner` |
| ISS/REG, TD, FB + indexes | `docs/development/{issues,debt,feedback}/` | `/review`, `/validate`, `/security-review` |
| STANDARDS.md, GUIDELINES.md | `docs/policy/` | `/onboard` |
| INDEX.md | `docs/INDEX.md` | `/onboard` |
| TDRs (operational/policy decisions) | `docs/knowledge/decisions/` | `/architect` |
| Review / analysis reports | `docs/analysis/` | `/review`, `/analyse` |
| Research reports | `reports/research/` | `/research` |
| Coverage documents | `docs/validation/` | `/validate` |
| Context bundles | `context/<area>/<task>.md` | `/context-compiler` |
| Instruction-fix memos | `reports/meta-optimization/` | `/meta-learn` |

## Canonical References

| Topic | Canonical Source |
|-------|-----------------|
| Record schema — id grammars, identity fields, vocabularies, statuses | `package/policy/RULES.md` |
| Model tier → model bindings per harness | `package/skills/orchestrate/SKILL.md` |
| Workflow depth and mechanics | `package/skills/orchestrate/SKILL.md` + `package/workflows/SWE.md` |
| HITL escalation (superseded by `AskUserQuestion`) | `docs/knowledge/decisions/hitl-escalation.md` |
| Skill interface contract | the governing `FBP-FND-*` blueprint |
| Hook behavior | the governing `FBP-FND-*` blueprint + `ADR-FND-001` |
| Memory architecture | the governing `FBP-FND-*` blueprint + `ADR-FND-002` |
| Policy loading flow | the governing `FBP-FND-*` blueprint |
| Installation behavior | `README.md` + `install.sh` |
| All ADRs | `docs/architecture/ADR/` (+ generated `README.md` index) |
