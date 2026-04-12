---
name: design
description: Create architecture documentation and ADRs from PRD requirements
argument-hint: PRD path or architecture focus area
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
  - WebSearch
  - AskUserQuestion
context: fork
agent: architect
---

# /design - Architecture Design

Create architecture documentation and Architecture Decision Records from requirements.

## Purpose

Transform PRD requirements into:
- System architecture with components and interfaces
- Data flow and interaction patterns
- Constraints and risk analysis
- ADRs for significant decisions

## Inputs

- `$ARGUMENTS`: PRD path or specific focus area (optional)
- Default PRD location: `docs/architecture/PRD.md`
- Existing architecture: `docs/architecture/ARCHITECTURE.md`

## Outputs

- Architecture: `docs/architecture/ARCHITECTURE.md`
- ADRs: `docs/architecture/adr/NNN-decision-name.md`
- Data Model: `docs/architecture/technical/data-model.md` (entities, attributes, relationships)
- Contracts: `docs/architecture/technical/contracts.md` (API signatures, events, interfaces)

## Decision Artifact Taxonomy [CRITICAL]

- **ADR** (`docs/architecture/adr/`) is for significant architectural decisions.
- **Technical Decision Record (TDR)** (`docs/knowledge/decisions/`) is for technical/operational decisions that do not change system architecture.
- Never place architecture decisions in `docs/knowledge/decisions/`.
- Architecture outputs (`ARCHITECTURE.md`, ADRs) must use upstream inputs (PRD, standards, constraints), not downstream execution artifacts (`ROADMAP`, `BACKLOG`, `ISSUES`) as normative sources.
- If PRD changes during design, reconcile architecture artifacts in the same run and explicitly flag downstream replanning requirement for `/plan`.

## Workflow

### 0. Check Project Standards
If `docs/policy/STANDARDS.md` exists, read it to understand:
- Architecture patterns the project follows
- Naming conventions and code organization rules
- Technology constraints and preferences

These standards inform design decisions throughout the workflow.

### 1. Read Requirements
Load and understand the PRD:
- Functional requirements define WHAT to build
- Non-functional requirements define HOW it must perform
- User stories provide context for design decisions

### 1b. Gap & Constraint Check (HITL)
Before designing, identify:
- Underspecified functional areas (FR missing detail)
- Missing NFRs (performance, security, scalability targets)
- Unresolved technology constraints
- Competing design forces with no clear winner

If any blocking gaps found: return QUESTIONS block to Orch (see `/hitl` shared protocol).
Do NOT proceed to design with open blocking questions.

### 2. Research Patterns
- Search for established patterns matching requirements
- Look up framework/library documentation
- Review prior art and alternatives

### 3. Identify Components
For each major functional area:
- Define component name and responsibility
- Specify interface/API contract
- List dependencies (internal and external)

### 4. Design Data Flow
- Map request/response flows
- Identify data transformations
- Document async/sync boundaries

### 5. Analyze Constraints
- Technical limitations
- Platform requirements
- Integration dependencies
- Performance bounds

### 6. Assess Risks
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| [Risk description] | Low/Medium/High | Low/Medium/High | [Strategy] |

### 7. Document Trade-offs
For significant design choices:
- What alternatives were considered?
- Why was this option chosen?
- What are the consequences?

### 8. Create ADRs
For each significant decision, create an ADR:
```markdown
# ADR-NNN: [Decision Title]

**Status**: Proposed | Accepted | Deprecated
**Date**: [date]

## Context
[What is the issue/situation requiring a decision?]

## Decision
[What is the change/decision being made?]

## Rationale
[Why was this decision made?]

## Alternatives Considered
1. [Alternative 1]: [Why rejected]
2. [Alternative 2]: [Why rejected]

## Consequences
- [Positive consequence 1]
- [Positive consequence 2]
- [Negative consequence / trade-off]

## Related
- [Link to related ADRs]
- [Link to relevant requirements]
```

### 9. Define Data Model
Document the core data entities at `docs/architecture/technical/data-model.md`:
- Entity names and descriptions
- Attributes with types and constraints
- Relationships (1:1, 1:N, M:N)
- Lifecycle states if applicable

### 10. Define Contracts
Document API and integration contracts at `docs/architecture/technical/contracts.md`:
- API endpoint signatures (method, path, request/response shapes)
- Event schemas (name, payload, publisher, subscribers)
- Interface definitions (function signatures, type contracts)
- Error response formats

## Template Reference

Template source: installed templates directory under the active runtime root (`templates/` inside `~/.claude/`, `~/.agents/`, `~/.gemini/`, `~/.config/opencode/`, `~/.qwen/`, or the matching project-local runtime directory):
- `architecture.md` — Complete ARCHITECTURE structure
- `adr.md` — ADR template

## Architecture Template

```markdown
# [Project Name] Architecture

**Version**: 0.1.0
**Date**: [date]
**Source**: [PRD.md](PRD.md)

---

## Overview
[High-level system diagram or description]

## Components

### [Component Name]
- **Responsibility**: [Single responsibility description]
- **Interface**: [API/contract definition]
- **Dependencies**: [What it requires]
- **Artifacts**: [What it produces]

## Data Flow
[Sequence or flow diagrams]

## Constraints
- [Technical constraint 1]
- [Platform constraint 2]

## Risks
[Risk table]

## Trade-offs
[Design decision rationale]

## Design Decisions
- [ADR-001](adr/001-decision.md): [Summary]
- [ADR-002](adr/002-decision.md): [Summary]
```

## Validation Checklist
- [ ] Project standards checked (if `docs/policy/STANDARDS.md` exists)
- [ ] HITL gap check completed (step 1b) — no blocking questions pending
- [ ] Decision taxonomy enforced (ADR vs TDR)
- [ ] All FRs have corresponding components
- [ ] All components have clear responsibilities
- [ ] Interfaces are defined between components
- [ ] NFRs are addressed in design
- [ ] Risks are identified with mitigations
- [ ] Significant decisions have ADRs
- [ ] Data model documented (entities, relationships)
- [ ] Contracts defined (APIs, events, interfaces)
- [ ] No blocking QUESTIONS pending before passing to /plan
