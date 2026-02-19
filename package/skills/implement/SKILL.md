---
name: implement
description: Implement a task from the backlog with code and tests
argument-hint: <task ID or description>
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
  - Task
  - AskUserQuestion
context: fork
agent: developer
---

# /implement - Task Implementation

Implement a specific task from the backlog with production code and tests.

## Purpose

Execute a task by:
- Understanding the requirement and acceptance criteria
- Writing production code following existing patterns
- Creating tests for new functionality
- Preparing a commit message

## Inputs

- `$ARGUMENTS`: Task ID (e.g., "T-001") or task description
- BACKLOG: `docs/development/BACKLOG.md` for task details
- Architecture: `docs/architecture/ARCHITECTURE.md` for patterns
- `${PROJECT_NAME}`: Current project context

## Outputs

- Production code in appropriate source files
- Tests alongside implementation
- Suggested commit message

## Workflow

### 1. Identify Task
Parse `$ARGUMENTS` to find the task:
- If task ID provided, look up in BACKLOG.md
- If description provided, match to existing task or confirm new work

### 2. Read Task Details
From BACKLOG.md, extract:
- Task description
- Acceptance criteria
- Epic context
- Dependencies (ensure they're complete)

### 3. Explore Codebase
Before writing code:
- Find related existing code
- Identify patterns to follow
- Check for similar implementations
- Understand the module structure

### 4. Plan Implementation
Outline the approach:
- Files to modify/create
- Functions/classes needed
- Test approach (derive test cases directly from AC)
- Edge cases to handle

**Skip TDD** (go directly to step 6) for: bug fixes in existing code, localized edits,
refactors with no behavior change, documentation-only changes.

### 5. Write Tests — Red
From the AC, write failing tests **before** writing implementation:
- One test per acceptance criterion
- Tests must fail (red) — confirms they actually test the right thing
- Use contracts/interfaces from `docs/architecture/technical/contracts.md` if available
- Follow existing test patterns and file layout

Run tests and confirm they fail as expected.

### 6. Implement — Green
Write the minimum code to make the failing tests pass:
- **Read Before Write**: Understand existing code
- **Minimal Changes**: Only what's needed to go green
- **Follow Patterns**: Match existing style
- **No Over-Engineering**: Simple solutions preferred
- **Security Aware**: Avoid common vulnerabilities

Run tests after each logical unit of code. Stop when all tests pass.

### 6b. Refactor (if needed)
With tests green, clean up without changing behavior:
- Remove duplication
- Improve naming/readability
- Re-run tests after each refactor step to stay green

### 7. Verify
Check against acceptance criteria:
- [ ] Each AC is met
- [ ] Tests pass
- [ ] No regressions
- [ ] Code follows patterns

### 8. Prepare Commit
Suggest commit message:
```
type(scope): description

- Detail of change 1
- Detail of change 2

Refs: T-XXX
```

Types: feat, fix, refactor, test, docs, chore

## Implementation Guidelines

### Code Quality
- Use descriptive variable/function names
- Keep functions focused (single responsibility)
- Add comments only where logic isn't self-evident
- Handle errors appropriately

### Testing
- Test behavior, not implementation
- One assertion per test when possible
- Clear test names describing expected behavior
- Mock external dependencies

### Security
- Validate inputs at boundaries
- Escape outputs appropriately
- No secrets in code
- Follow OWASP guidelines

## Validation Checklist
Before completing:
- [ ] All AC from task definition met (each criterion explicitly verified)
- [ ] Tests written and passing
- [ ] No TODO/mock/placeholder left in code
- [ ] Code follows existing patterns
- [ ] No hardcoded secrets or credentials
- [ ] Commit message references task ID (Refs: T-XXX)
- [ ] No unintended side effects on other components
- [ ] Task ready to mark complete

## Error Handling

If blocked:
1. Document the blocker clearly
2. Suggest alternatives if possible
3. Don't make assumptions without verification
4. Consider invoking /analyse for investigation

## Policy References

**Should-read** from `~/.claude/policy/RULES.md`:
- Implementation Completeness - No partial features, no TODOs
- Git Workflow - Feature branches, incremental commits
- Safety Rules - Framework respect, pattern adherence
