---
name: onboard
description: Analyze an existing project and generate concise STANDARDS.md, GUIDELINES.md, and INDEX.md
argument-hint: project path or current directory
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Grep
  - Glob
  - Bash
  - AskUserQuestion
context: fork
agent: architect
---

# /onboard - Project Onboarding

Analyze a brownfield project and generate concise governance docs from repository evidence.

## Ownership

`/onboard` owns generation of:
- `docs/policy/STANDARDS.md`
- `docs/policy/GUIDELINES.md`
- `docs/INDEX.md`

Generate from templates:
- `.claude/templates/standards.md` (project) or `~/.claude/templates/standards.md` (global)
- `.claude/templates/guidelines.md` (project) or `~/.claude/templates/guidelines.md` (global)
- `.claude/templates/index.md` (project) or `~/.claude/templates/index.md` (global)

These files are generated artifacts. Do not hand-author policy/index content outside `/onboard` output updates.

If `AGENTS.md` does not reference `docs/INDEX.md`, update it and remove duplicated layout tables.

## Inputs

- `$ARGUMENTS`: Project path (defaults to current directory)
- Global policies: `~/.claude/policy/PRINCIPLES.md`, `~/.claude/policy/RULES.md`

## Output Contract

All outputs include:
```markdown
**Version**: 1.0.0 | **Updated**: YYYY-MM-DD
> Amend with rationale. Bump: MAJOR (breaking), MINOR (additions), PATCH (clarifications).
```

### Boundary Model (strict)

Classify each statement into exactly one bucket:

| File | Contains | Must not contain |
|------|----------|------------------|
| `STANDARDS.md` | Project-specific MUST constraints | Workflow mechanics, architecture rationale, templates/contracts, repeated global policy |
| `GUIDELINES.md` | Project-specific SHOULD practices | Detailed procedures already defined elsewhere |
| `INDEX.md` | Directory map + artifact ownership + canonical doc locations | Rules/process guidance that belong in policy docs |

If a detail already has a canonical source, reference it instead of reproducing it.

## Workflow

### 1) Load Global Context
Read:
- `~/.claude/policy/PRINCIPLES.md`
- `~/.claude/policy/RULES.md`

### 2) Inspect Project Evidence
Sample only high-signal sources:
- Config/runtime files (stack, tooling)
- Directory and naming patterns
- Git conventions (branching, commits)
- Existing docs with explicit process constraints

### 3) Extract Candidate Statements
Convert observed patterns into short, testable statements.

### 4) Classify by Boundary
Route each statement using the Boundary Model table. Drop statements that duplicate global or canonical local docs.

### 5) Generate Outputs
- Keep files concise and scannable.
- Start from the matching template skeleton and fill only evidence-backed content.
- Use section headers plus one bullet per statement.
- Prefer references over copied detail.

Target lengths:
- `STANDARDS.md`: <= 35 content lines (excluding title/header)
- `GUIDELINES.md`: <= 35 content lines
- `INDEX.md`: <= 50 content lines

### 6) Conflict Check
Flag:
- Contradictions with global policy
- Missing project-specific constraints that should exist
- Any remaining duplication across generated files

### 7) Report Summary
Return:
- Detected stack/tooling
- Key standards/guidelines captured
- Boundary conflicts or unresolved gaps

## Validation Checklist

- [ ] Global policies read before generation
- [ ] Outputs are evidence-based, not aspirational
- [ ] Strict boundary separation across STANDARDS/GUIDELINES/INDEX
- [ ] No duplication of workflow docs, architecture docs, templates, or global policy
- [ ] `AGENTS.md` references `docs/INDEX.md` and avoids duplicated layout tables
