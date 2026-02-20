# Documentation Index

**Version**: 1.0.0 | **Updated**: 2026-02-20
> Amend with rationale. Bump: MAJOR (breaking), MINOR (additions), PATCH (clarifications).

## Top-Level Layout

```
orchestrator/
├── CLAUDE.md / AGENTS.md      # Runtime entry points
├── README.md                  # Project overview, quick start, reference tables
├── install.sh                 # Installer (--global, --project, --namespace)
├── package/                   # Framework source — deployed by install.sh
│   ├── agents/                # 7 agent definitions
│   ├── skills/                # 17 skill directories
│   ├── hooks/scripts/         # 5 lifecycle hook scripts + lib
│   ├── policy/                # PRINCIPLES.md, RULES.md (global source)
│   ├── workflows/             # SWE.md, meta-learning.md
│   ├── templates/             # 11 artifact templates
│   └── settings.json / mcp.json
├── docs/                      # Orchestrator's own project docs
│   ├── objectives/            # VISION.md, BLUEPRINT.md, ROADMAP.md
│   ├── architecture/          # PRD.md, ARCHITECTURE.md, adr/, diagrams/
│   ├── development/           # BACKLOG.md, ISSUES.md
│   ├── policy/                # STANDARDS.md, GUIDELINES.md (project tier)
│   └── knowledge/             # decisions/ + README.md
└── reports/                   # analysis/, research/ outputs
```

## Artifact Ownership

| Artifact | Path | Owner Skill |
|----------|------|-------------|
| VISION.md, BLUEPRINT.md | `docs/objectives/` | `/spec` |
| ROADMAP.md | `docs/objectives/ROADMAP.md` | `/plan` |
| PRD.md | `docs/architecture/PRD.md` | `/spec` |
| ARCHITECTURE.md, ADRs | `docs/architecture/` | `/design` |
| BACKLOG.md | `docs/development/BACKLOG.md` | `/plan` |
| ISSUES.md | `docs/development/ISSUES.md` | `/review`, `/validate` |
| STANDARDS.md, GUIDELINES.md | `docs/policy/` | `/onboard` |
| INDEX.md | `docs/INDEX.md` | `/onboard` |
| Decision records | `docs/knowledge/decisions/` | `/design` |
| Review / analysis reports | `reports/analysis/` | `/review`, `/analyse` |
| Research reports | `reports/research/` | `/research` |

## Canonical References

| Topic | Canonical Source |
|-------|-----------------|
| Workflow depth and mechanics | `package/workflows/SWE.md` |
| HITL escalation protocol | `package/skills/hitl/SKILL.md` + `docs/knowledge/decisions/hitl-escalation.md` |
| Skill interface contract | `docs/architecture/ARCHITECTURE.md` §1.2 |
| Hook behavior | `docs/architecture/ARCHITECTURE.md` §4 + ADR-001 |
| Memory architecture | `docs/architecture/ARCHITECTURE.md` §5 + ADR-002 |
| Policy loading flow | `docs/architecture/ARCHITECTURE.md` §6.2 |
| Installation behavior | `README.md` + `install.sh` |
| All ADRs | `docs/architecture/adr/` |
