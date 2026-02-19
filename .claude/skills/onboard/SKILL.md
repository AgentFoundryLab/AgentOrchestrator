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

## Workflow

### 1. Read Framework Context
Load and understand global policies:
- `~/.claude/policy/PRINCIPLES.md` — engineering philosophy
- `~/.claude/policy/RULES.md` — agent behavioral rules

These define what the framework already covers. Project policies must not duplicate them.

### 2. Analyze Project

Scan the project to discover conventions:

**Configuration files** (detect stack):
- `package.json`, `tsconfig.json` → Node/TypeScript
- `pyproject.toml`, `setup.py`, `requirements.txt` → Python
- `Cargo.toml` → Rust
- `go.mod` → Go
- `Makefile`, `Dockerfile`, `docker-compose.yml` → Build/deploy
- `.eslintrc`, `.prettierrc`, `biome.json` → Linting/formatting
- CI config (`.github/workflows/`, `.gitlab-ci.yml`)

**Codebase patterns** (derive standards):
- Directory structure and organization
- Naming conventions (files, functions, variables)
- Import patterns and module organization
- Error handling patterns
- Testing framework and patterns
- API design patterns (REST, GraphQL, RPC)

**Process signals** (derive guidelines):
- Git history: commit message patterns, branching strategy
- README: setup instructions, contribution guidelines
- CI/CD: test requirements, deployment process
- PR templates, issue templates

### 3. Derive Standards

From observed patterns, generate `STANDARDS.md` covering:

- **Language/Framework**: Version constraints, preferred patterns
- **Architecture**: Component organization, data flow patterns
- **Naming**: File naming, function naming, variable naming conventions
- **Error Handling**: Error types, response formats, logging patterns
- **Testing**: Framework, coverage expectations, test organization
- **API Design**: Endpoint patterns, request/response formats
- **Dependencies**: Preferred libraries, version policies

Only include standards that are **actually observed** or clearly needed. Do not invent standards for things the project doesn't do.

### 4. Derive Guidelines

From observed practices, generate `GUIDELINES.md` covering:

- **Development Workflow**: Branch strategy, commit conventions
- **Testing Practice**: What requires tests, integration vs unit
- **Code Review**: Review requirements, approval process
- **Deployment**: Environment strategy, release process
- **Documentation**: What needs docs, where they live

Only include guidelines that match the project's **actual practices** or fill clear gaps.

### 5. Conflict Check

Compare derived standards against global PRINCIPLES.md and RULES.md:
- Flag any contradictions
- Flag any unnecessary duplication
- Present conflicts to user for resolution

### 6. Generate Files

Write both files with:
- Version header
- Clear section organization
- Concrete, actionable items (not vague aspirations)
- References to project examples where helpful

### 7. Summary

Present to user:
- What was detected (stack, patterns, practices)
- What standards were derived
- What guidelines were derived
- Any conflicts with global policies
- Suggestions for standards the project might want to add

## Validation Checklist
- [ ] Global policies were read first
- [ ] Project codebase was analyzed (not just config)
- [ ] Standards are derived from observation, not invented
- [ ] Guidelines match actual project practices
- [ ] No duplication with global PRINCIPLES.md or RULES.md
- [ ] Version headers present on both files
- [ ] Conflicts flagged if any
