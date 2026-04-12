---
name: validate
description: Verify implementation against acceptance criteria and run tests
argument-hint: task ID or artifact path
user-invocable: true
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
context: fork
agent: validator
---

# /validate - Implementation Validation

Verify that implementation meets acceptance criteria and passes tests.

## Purpose

Ensure quality by:
- Running test suites
- Checking acceptance criteria
- Validating artifact schemas
- Reporting findings

## Inputs

- `$ARGUMENTS`: Task ID or artifact path to validate
- BACKLOG for task lookup and refs: `docs/development/BACKLOG.md`
- Canonical task-detail docs when present: `docs/development/tasks/*.md`
- PRD for requirements: `docs/architecture/PRD.md`

## Outputs

Validation report stored in Serena memory (transient).

## Workflow

### 1. Identify Target
Parse `$ARGUMENTS`:
- Task ID → Load task lookup data from BACKLOG, then resolve canonical task-detail refs if present
- File path → Validate specific artifact
- No args → Validate most recent implementation

### 2. Load Acceptance Criteria
From the canonical task-detail source first, then PRD if needed:
- List all criteria to check
- Note any dependencies
- Capture any evidence refs needed to prove completion

### 3. Run Tests
Execute appropriate test commands:
```bash
# Common patterns
npm test
pytest
make test
go test ./...
```

Capture results: passed, failed, skipped.

### 4. Verify Acceptance Criteria
For each criterion:
- Can it be verified automatically?
- If yes, run verification
- If no, check manually via code inspection

If stronger task-detail refs exist, validation against backlog summary text alone is insufficient.

### 5. Check Quality
Run quality checks if available:
```bash
# Linting
npm run lint
ruff check .

# Type checking
tsc --noEmit
mypy .

# Format check
prettier --check .
ruff format --check .
```

### 6. Validate Artifacts
If artifacts were produced:
- Check schema compliance
- Verify required fields
- Validate references

### 7. Report Findings
Create validation report:

```yaml
---
date: YYYY-MM-DD
task: [Task ID]
target: [What was validated]
status: pass | fail | partial
---

## Summary
[Overall status and key findings]

## Test Results
| Suite | Passed | Failed | Skipped |
|-------|--------|--------|---------|
| [Name] | X | Y | Z |

## Acceptance Criteria
| ID | Criterion | Status | Evidence |
|----|-----------|--------|----------|
| AC1 | [Description] | Pass/Fail | [How verified] |

## Quality Checks
- [ ] Linting: [status]
- [ ] Type check: [status]
- [ ] Format: [status]

## Issues Found
1. [Issue description]
   - Severity: Low/Medium/High
   - Location: [file:line]

## Recommendation
[Pass/Fix issues/Block deployment]
```

## Validation Levels

### Quick Validation
- Run tests
- Check critical AC only
- Fast feedback

### Full Validation
- All tests
- All AC
- Quality checks
- Artifact validation

### Pre-Deploy Validation
- Full validation
- Security checks
- Performance baseline
- Integration tests

## Validation Checklist
Before completing:
- [ ] Tests pass (no regressions)
- [ ] Each AC explicitly verified with evidence (not assumed)
- [ ] Canonical task-detail refs were used when available
- [ ] Code follows established patterns
- [ ] Documentation accurate (matches implementation)
- [ ] Security considerations addressed
- [ ] Validation report produced and written to `reports/analysis/`
- [ ] Test results captured (pass/fail counts)
- [ ] If any failures: ISSUES.md updated with findings
- [ ] Recommendation stated (Pass / Fix issues / Block deployment)

## Policy References

**Should-read** from the active runtime root's `policy/RULES.md`:
- Failure Investigation - Root cause analysis, never skip tests or validation
