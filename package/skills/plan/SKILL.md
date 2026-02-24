---
name: plan
description: Decompose architecture into milestones, epics, and tasks for the backlog
argument-hint: [architecture path or planning focus]
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Grep
  - Glob
  - TaskCreate
  - TaskUpdate
  - TaskList
  - AskUserQuestion
context: fork
agent: project-manager
---

# /plan - Project Planning

Decompose architecture into implementable tasks organized by milestones and epics.

## Purpose

Transform architecture into:
- ROADMAP with milestones and phases
- BACKLOG with prioritized, atomic tasks
- Clear dependencies and sequencing
- Traceability from requirements to tasks

## Inputs

- `$ARGUMENTS`: Architecture path or planning focus (optional)
- Default architecture: `docs/architecture/ARCHITECTURE.md`
- PRD for requirements: `docs/architecture/PRD.md`
- ADRs for decisions: `docs/architecture/adr/`

## Outputs

- ROADMAP: `docs/objectives/ROADMAP.md`
- BACKLOG: `docs/development/BACKLOG.md`

## Task Hierarchy (ADR-005)

```
Milestone (Release)      -> Git Tag
  Phase (Workflow)       -> -
    Epic (Feature)       -> -
      Task (Atomic)      -> Git Commit
```

### Definitions

- **Milestone**: Shippable release with clear value (v0, v1, MVP)
- **Phase**: Workflow stage (Initial, Validation, Polish)
- **Epic**: Group of related tasks (feature area, component)
- **Task**: Atomic unit - testable, independent, committable

### Task Atomicity Rules
A task is atomic if:
1. It can be completed in one work session
2. It has clear acceptance criteria
3. It results in a single logical commit
4. It can be tested independently
5. It doesn't require context from incomplete tasks

## Workflow

### 1. Read Architecture
- Understand components and boundaries
- Identify dependencies between components
- Note constraints and risks

### 2. Define Milestones
```markdown
## v0 - [Milestone Name]
**Goal**: [What this milestone achieves]
**Scope**: [What's included]
**Success Criteria**: [How to verify completion]
```

### 3. Organize Phases
Within each milestone:
- **Initial**: Core implementation
- **Validation**: Testing and verification
- **Polish**: Documentation and refinement (if applicable)

### 4. Create Epics
Group related work:
```markdown
### Epic: [Feature Area]
**Components**: [Which architecture components]
**Dependencies**: [What must come first]
**Acceptance**: [Epic-level success criteria]
```

### 5. Decompose Tasks
For each epic, create atomic tasks:
```markdown
| ID | Task | Priority | Status |
|----|------|----------|--------|
| T-001 | [Task description] | P0 | pending |
```

**Task Details**:
```markdown
### T-001: [Task Name]
**AC**:
- [Acceptance criterion 1]
- [Acceptance criterion 2]
**Commit**: `type(scope): description`
```

**Write AC as test specifications** (enables TDD in `/implement`):
- Bad: "User can log in"
- Good: "Given valid credentials, POST /auth/login returns 200 with token"

### 6. Set Priorities
- **P0**: Critical path - blocks other tasks
- **P1**: Important - core functionality
- **P2**: Nice to have - can defer

### 7. Establish Dependencies + Parallelization Map

For each task, define:
- `blockedBy: [T-XXX, T-YYY]` — cannot start until these complete
- `parallel: [T-XXX, T-YYY]` — can run concurrently with these

**Parallelization Rules**:
- Tasks sharing no state/artifacts can run in parallel
- Tasks within same component are usually sequential
- Research tasks are almost always parallel
- Implementation tasks across independent components can parallel

**Output in BACKLOG**: Note blockedBy and parallel groups in task detail:
```
### T-005: Implement AuthService
**blockedBy**: T-001 (schema), T-002 (DB setup)
**parallel**: T-006 (implement UserService), T-007 (implement TokenService)
```

**ROADMAP output**: Include parallelization summary:
```
Parallel Group A: T-005, T-006, T-007 (all blocked by T-001, T-002)
```

- Ensure no circular dependencies
- Critical path is clear (P0 tasks that are not parallelizable)

## ROADMAP Template

```markdown
# [Project] Roadmap

**Version**: 0.1.0
**Updated**: [date]

---

## Milestones Overview

| Milestone | Goal | Status |
|-----------|------|--------|
| v0 | [goal] | In Progress |
| v1 | [goal] | Planned |

---

## v0 - [Milestone Name]

### Initial Phase
#### Epic: [Name]
- T-001: [Task]
- T-002: [Task]

### Validation Phase
#### Epic: [Name]
- T-XXX: [Task]
```

## BACKLOG Template

```markdown
# [Project] Backlog

**Version**: 0.1.0
**Updated**: [date]

---

## Tasks

| ID | Milestone | Phase | Epic | Task | Priority | Status |
|----|-----------|-------|------|------|----------|--------|
| T-001 | v0 | Initial | [Epic] | [Task] | P0 | pending |

---

## Task Details

### T-001: [Task Name]
**AC**:
- [Criterion 1]
- [Criterion 2]

---

## Priority Legend
| Priority | Meaning |
|----------|---------|
| P0 | Critical path - blocks other tasks |
| P1 | Important - core functionality |
| P2 | Nice to have - can defer |
```

## Template References

Template source: `package/templates/` (installed to `~/.claude/templates/` or `.claude/templates/`):
- `roadmap.md` - Complete ROADMAP structure
- `backlog.md` - Complete BACKLOG structure

## Validation Checklist
- [ ] All architecture components have corresponding tasks
- [ ] Tasks are atomic (testable, committable)
- [ ] Dependencies are explicit and acyclic
- [ ] Critical path is identified (P0 tasks)
- [ ] Parallelization opportunities identified and noted
- [ ] Traceability: FR -> Component -> Epic -> Task
