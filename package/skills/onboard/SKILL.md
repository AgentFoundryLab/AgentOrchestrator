---
name: onboard
description: Analyze an existing project and generate tailored STANDARDS.md and GUIDELINES.md
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

Analyze an existing (brownfield) project and generate project-specific technical standards and process guidelines.

## Purpose

Bootstrap governance for an existing project by:
- Reading global PRINCIPLES.md + RULES.md (understand the framework)
- Analyzing the project's codebase, config, and conventions
- Deriving technical standards from observed patterns
- Deriving process guidelines from observed practices
- Generating `docs/policy/STANDARDS.md` and `docs/policy/GUIDELINES.md`
- Flagging conflicts with global policies

**NOT hardcoded articles** — content is dynamically derived from project context.

## Inputs

- `$ARGUMENTS`: Project path (defaults to current directory)
- Global policies: `~/.claude/policy/PRINCIPLES.md`, `~/.claude/policy/RULES.md`

## Outputs

- `docs/policy/STANDARDS.md` — project technical standards
- `docs/policy/GUIDELINES.md` — project process guidance

Both files include a version header:
```markdown
**Version**: 1.0.0 | **Updated**: YYYY-MM-DD
> Amend with rationale. Bump: MAJOR (breaking), MINOR (additions), PATCH (clarifications).
```

## Output Scope Contract

**STANDARDS.md** and **GUIDELINES.md** MUST be short reference documents — not architecture reproductions.

### What belongs here
- **STANDARDS.md**: MUST-level constraints — stack, naming, tooling, critical conventions. One bullet per rule. No schemas, no explanations, no architecture descriptions.
- **GUIDELINES.md**: SHOULD-level process guidance — branching, commit style, review, deployment. One bullet per guideline.

### What does NOT belong here
- Architecture patterns, ADR content, or design decisions → belongs in `docs/architecture/`
- YAML/JSON schema examples → belongs in source docs or ADRs
- Artifact locations → belongs in `AGENTS.md`
- How things work internally → belongs in architecture docs
- Anything already in `~/.claude/policy/PRINCIPLES.md` or `RULES.md`

If a detail is documented elsewhere, **reference it, don't reproduce it**.

Target: each file is **under 40 lines of content** (excluding header). If you're going over, you're duplicating docs. Prefer fewer, sharper rules over exhaustive lists.

## Workflow

### 1. Read Framework Context
Load and understand global policies:
- `~/.claude/policy/PRINCIPLES.md` — engineering philosophy
- `~/.claude/policy/RULES.md` — agent behavioral rules

These define what the framework already covers. Project policies must not duplicate them.

### 2. Analyze Project

Scan to identify the key signals — do not exhaustively document everything:

- Config files to identify **stack and tooling** (language, runtime, linter, formatter, CI)
- Directory structure to identify **naming conventions** (files, dirs, artifacts)
- Git log to identify **commit style and branching strategy**
- README / contributing docs to identify **explicit process rules**

### 3. Derive Standards (STANDARDS.md)

Write one bullet per rule. Group into sections:
- **Stack**: language, runtime, required tools
- **Naming**: file/dir/artifact naming conventions
- **Tooling**: linter, formatter, build commands
- **Testing**: framework and minimum requirements (if any)
- Any other hard constraints not covered by global policy

Rules must be:
- Actionable and verifiable ("Use X", "Never Y", "Run Z before commit")
- Observed from the codebase — not invented
- Not already in global PRINCIPLES.md or RULES.md

### 4. Derive Guidelines (GUIDELINES.md)

Write one bullet per practice. Group into sections:
- **Branching**: branch naming, base branch
- **Commits**: message format, scope, frequency
- **Review**: approval requirements, PR size
- **Deployment**: environment order, release process
- **Documentation**: what needs docs and where

Practices must match the project's **actual observed behavior**. Note gaps honestly rather than inventing aspirational rules.

### 5. Conflict Check

Compare against global PRINCIPLES.md and RULES.md:
- Flag contradictions
- Flag unnecessary duplication — if global policy already covers it, remove it

### 6. Generate Files

Write both files. Keep them **short and scannable**:
- Version header
- Section headers with bullet lists
- No prose paragraphs, no inline examples, no schemas
- Cross-reference other docs for details

### 7. Summary

Present:
- Stack/tooling detected
- Key conventions captured
- Any conflicts or gaps flagged

## Validation Checklist
- [ ] Global policies were read first
- [ ] Standards and guidelines are derived from observation, not invented
- [ ] No duplication with `PRINCIPLES.md`, `RULES.md`, `AGENTS.md`, or architecture docs
- [ ] No schemas, templates, or architecture descriptions in output
- [ ] Each file is under 60 lines of content
- [ ] Version headers present on both files
- [ ] Conflicts flagged if any
