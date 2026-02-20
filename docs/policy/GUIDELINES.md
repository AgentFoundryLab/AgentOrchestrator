# Project Guidelines

**Version**: 1.0.0 | **Updated**: 2026-02-20
> Amend with rationale. Bump: MAJOR (breaking), MINOR (additions), PATCH (clarifications).

## Workflow

- Use Full workflow (`/spec → /design → /plan → /review → /implement → /validate → /deploy → /document`) for new skills, agents, or architectural changes
- Use Medium workflow for feature additions to existing skills or agents
- Use Light workflow for hook script fixes and documentation updates
- `/review` gate SHOULD be run before `/implement` in full-depth workflows to catch spec drift
- Workflow depth selection and mechanics are defined in `package/workflows/SWE.md`

## Validation

- New skills SHOULD be validated by running install.sh in a test project and verifying skill invocation
- Hook scripts SHOULD be tested by checking their output is injected as `<system-reminder>` blocks
- JSON settings patches SHOULD be verified with `jq` after `install.sh` runs
- ADRs SHOULD be written for decisions involving trade-offs between alternatives; lightweight decision records in `docs/knowledge/decisions/` are sufficient for operational protocol choices

## Documentation

- New skills MUST have their artifact output location documented in the skill's `## Outputs` section
- ADRs SHOULD cross-reference related ADRs and decision records
- `docs/knowledge/decisions/` entries SHOULD include status, context, decision, consequences, and references
- Diagrams live in `docs/architecture/diagrams/` — reference from ARCHITECTURE.md, do not embed inline
- `docs/INDEX.md` SHOULD be updated when new top-level directories or artifact types are added

## Collaboration

- HITL escalation MUST use the `## QUESTIONS FOR USER` block pattern defined in `package/skills/hitl/SKILL.md` — sub-agents MUST NOT call `AskUserQuestion` directly
- Install changes SHOULD be tested with both `--global` and `--project` flags before merge
- Namespace behavior (`--namespace`, `--no-namespace`) SHOULD be verified when modifying `install.sh` path logic
