---
name: plan
description: Decompose architecture into milestones, epics, and tasks for the backlog
argument-hint: architecture path or planning focus
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
- Task-detail docs for complex tasks when backlog alone would be too weak
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
- Task-detail docs when needed: `docs/development/tasks/*.md`

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
For each epic, create atomic tasks in BACKLOG:
```markdown
| ID | Task | Priority | Status |
|----|------|----------|--------|
| T-001 | [Task description] | P0 | pending |
```

Choose one execution-contract mode explicitly:
- **Simple mode**: embed task detail in BACKLOG when the task is short, low-risk, and self-contained.
- **Complex mode**: create a task-detail doc and link it from BACKLOG when the task has long AC, non-trivial dependencies, traps, or shape constraints.

**Simple mode example**:
```markdown
### T-001: [Task Name]
**AC**:
- [Acceptance criterion 1]
- [Acceptance criterion 2]
**Commit**: `type(scope): description`
```

**Complex mode example**:
```markdown
| ID | Task | Priority | Status | Canonical Refs |
|----|------|----------|--------|----------------|
| T-001 | [Task description] | P0 | pending | docs/development/tasks/v0.md#t-001 |
```

**Write AC as test specifications** (enables TDD in `/implement`):
- Bad: "User can log in"
- Good: "Given valid credentials, POST /auth/login returns 200 with token"

Externalize task details when:
- a milestone contains many tasks or long AC blocks
- the task needs explicit in-scope/out-of-scope boundaries
- implementation shape matters beyond a short AC list
- validator evidence needs dedicated refs

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

**Output in BACKLOG**: Note blockedBy and parallel groups in embedded task detail or linked task-detail docs:
```
### T-005: Implement AuthService
**blockedBy**: T-001 (schema), T-002 (DB setup)
**parallel**: T-006 (implement UserService), T-007 (implement TokenService)
```

**ROADMAP output**: Include strategic parallelization summary at epic level:
```
Parallel Group A: Epic A, Epic B, Epic C (all blocked by Epic Foundation)
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
**Outcomes**:
- [Outcome 1]
- [Outcome 2]

### Validation Phase
#### Epic: [Name]
**Outcomes**:
- [Validation outcome]
```

## BACKLOG Template

```markdown
# [Project] Backlog

**Version**: 0.1.0
**Updated**: [date]

---

## Tasks

| ID | Milestone | Phase | Epic | Task | Priority | Status | Canonical Refs |
|----|-----------|-------|------|------|----------|--------|----------------|
| T-001 | v0 | Initial | [Epic] | [Task] | P0 | pending | docs/development/tasks/v0.md#t-001 |

---

## Embedded Task Details (Optional)

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

Template source: installed templates directory under the active runtime root (`templates/` inside `~/.claude/`, `~/.agents/`, `~/.gemini/`, `~/.config/opencode/`, `~/.qwen/`, or the matching project-local runtime directory):
- `roadmap.md` - Complete ROADMAP structure
- `backlog.md` - Complete BACKLOG structure
- `task-detail.md` - Canonical task-detail structure for complex work

## Validation Checklist
- [ ] All architecture components have corresponding tasks
- [ ] Tasks are atomic (testable, committable)
- [ ] Dependencies are explicit and acyclic
- [ ] Critical path is identified (P0 tasks)
- [ ] Parallelization opportunities identified and noted
- [ ] Traceability: FR -> Component -> Epic -> Task
- [ ] Complex tasks either embed executable detail or point to canonical task-detail docs
