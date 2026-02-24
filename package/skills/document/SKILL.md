---
name: document
description: Create or update documentation for features, APIs, or components
argument-hint: <component or feature to document>
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Grep
  - Glob
  - Bash
  - AskUserQuestion
context: fork
agent: tech-writer
---

# /document - Documentation Generation

Create or update documentation based on recent commits or specific components.

## Purpose

Maintain quality documentation by:
- Classifying changes by Area (what) and Criticality (severity)
- Determining documentation propagation paths
- Updating docs in correct order (entry point → downstream)
- Skipping levels with no impact

## Modes

| Mode | Trigger | Scope | Cost |
|------|---------|-------|------|
| **Incremental** (default) | `/document` | Commits since last docs update | ~2min, ~15k tokens |
| **Full Review** | `/document --full` | All docs consistency check | ~5min, ~70k tokens |

**Default behavior**: Analyze commits on current branch since the last documentation commit.

## Inputs

- `$ARGUMENTS`: Component, feature, or API to document (optional - if empty, analyze recent commits)
  - Use `--full` to trigger full consistency review across all documentation
- Source code for reference
- Existing docs in `docs/`

## Outputs

Documentation updates organized by impact area with propagation paths.

---

## Impact Classification (Orthogonal Dimensions)

### Areas (What Changed)

| Area | Boundary | Entry Point |
|------|----------|-------------|
| **System** | Core functionality broken (hooks, MCP, install, agents) | ISSUES |
| **Product** | Vision, goals, target users, success metrics | VISION |
| **Solution** | Capabilities, feature matrix, technical scope | BLUEPRINT |
| **Specification** | Features, requirements, user stories, acceptance criteria | PRD |
| **Architecture** | Components, patterns, dependencies, decisions | ARCHITECTURE |
| **Development** | Task organization, priorities, status | ROADMAP/BACKLOG |
| **Documentation** | All docs: arch docs, policies, knowledge, runbooks | Varies |

### Criticality (Severity - Independent of Area)

| Level | Definition | Response |
|-------|------------|----------|
| **CRITICAL** | Blocking, broken functionality, data loss risk | Immediate |
| **HIGH** | Significant impact, major feature affected | Current session |
| **MEDIUM** | Moderate impact, standard priority | Current sprint |
| **LOW** | Minor, cosmetic, can defer | Backlog |

### Propagation Paths by Area

```
SYSTEM        → ISSUES → BACKLOG
PRODUCT       → VISION → BLUEPRINT → PRD → ARCHITECTURE → ADR → ROADMAP → BACKLOG
SOLUTION      → BLUEPRINT → PRD → ARCHITECTURE → ADR → ROADMAP → BACKLOG
SPECIFICATION → PRD → ARCHITECTURE → ADR → ROADMAP → BACKLOG
ARCHITECTURE  → ARCHITECTURE → ADR → ROADMAP → BACKLOG
DEVELOPMENT   → ROADMAP → BACKLOG (or BACKLOG only)
DOCUMENTATION → Direct to target doc
```

---

## Workflow

### 0. Determine Mode and Scope

Check `$ARGUMENTS` for `--full` flag:
- **If `--full` present**: Full consistency review mode (step 0a)
- **Otherwise**: Incremental mode - commits since last docs update (step 0b)

#### 0a. Full Review Mode (--full only)

**Cost**: ~5min, ~70k tokens

Read all docs listed in the **Outputs** column of the Area Classification table, then proceed to step 1 with full scope.

#### 0b. Incremental Mode (default)

**Cost**: ~2min, ~15k tokens

Only read docs that are directly affected by recent changes. Skip full consistency check.

### 1. Gather Changes

#### 1a. Find Last Documentation Commit

```bash
# Find the most recent commit that updated docs
LAST_DOCS_COMMIT=$(git log --oneline \
  --grep="^docs:" \
  --grep="^docs(" \
  -- README.md CLAUDE.md 'docs/**' '.claude/hooks/README.md' \
  -1 --format="%H" 2>/dev/null | head -1)

# If no docs commit found, use merge-base with main
if [ -z "$LAST_DOCS_COMMIT" ]; then
  LAST_DOCS_COMMIT=$(git merge-base HEAD main 2>/dev/null || echo "HEAD~10")
fi

echo "Analyzing commits since: $LAST_DOCS_COMMIT"
```

#### 1b. Get Commits Since Last Docs Update

```bash
# Get commits since last docs update
git log ${LAST_DOCS_COMMIT}..HEAD --oneline

# Get changed files in those commits
git diff ${LAST_DOCS_COMMIT}..HEAD --name-only
```

#### 1c. Include Uncommitted Changes (Optional)

If there are uncommitted changes, ask user:

```
AskUserQuestion:
  question: "Include uncommitted changes in documentation scope?"
  header: "Scope"
  options:
    - label: "Commits only (Recommended)"
      description: "Only analyze committed changes since last docs update"
    - label: "Include uncommitted"
      description: "Also include staged and unstaged changes"
```

If including uncommitted:
```bash
git status --porcelain
git diff --name-only          # Unstaged
git diff --cached --name-only # Staged
```

### 2. Classify Changes (Area × Criticality)

For each changed file/feature, determine BOTH dimensions:

#### Area Classification

| Area | Triggers | Outputs |
|------|---------|---------|
| **System** | hooks/MCP/install broken; agents/skills fail | `ISSUES.md`, `BACKLOG.md` |
| **Product** | `VISION.md`, goals, OKRs, target users | `VISION.md` |
| **Solution** | `BLUEPRINT.md`, capabilities, feature matrix | `BLUEPRINT.md` |
| **Specification** | `PRD.md`, `package/skills/` (source) or `.claude/skills/jarvis/` (installed), user stories | `PRD.md` |
| **Architecture** | `ARCHITECTURE.md`, `adr/`, `DESIGN-PRINCIPLES.md`, hooks/agents structure | `ARCHITECTURE.md`, `DESIGN-PRINCIPLES.md`, `adr/NNN-*.md` |
| **Development** | `ROADMAP.md`, `docs/development/` | `ROADMAP.md`, `BACKLOG.md` |
| **Documentation** | `README.md`, `CLAUDE.md`, `docs/policy/`, `docs/knowledge/`, `docs/architecture/technical/` | `README.md`, `CLAUDE.md`, `docs/policy/{STANDARDS,GUIDELINES}.md`, `docs/architecture/{PRD,ARCHITECTURE,DESIGN-PRINCIPLES}.md`, `docs/architecture/{api/,technical/{data-model,contracts}.md}`, `docs/knowledge/{domain,patterns,decisions,runbooks}/`, `docs/development/{BACKLOG,ISSUES}.md` |

#### Criticality Assessment

| Condition | Criticality |
|-----------|-------------|
| Functionality broken, blocking work | **CRITICAL** |
| Major feature change, significant impact | **HIGH** |
| Standard change, moderate impact | **MEDIUM** |
| Typo, cosmetic, minor improvement | **LOW** |

### 3. Group and Prioritize

Group by Area, sort by Criticality within each area:

```
┌─────────────────────────────────────────────────────────────────────┐
│ IMPACT ANALYSIS - Session Changes                                    │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│ SYSTEM                                                               │
│ └── [CRITICAL] Hooks broken after settings change                    │
│     Path: ISSUES → BACKLOG                                           │
│                                                                      │
│ PRODUCT                                                              │
│ └── [HIGH] New target user segment                                   │
│     Path: VISION → BLUEPRINT → PRD → ARCHITECTURE → BACKLOG          │
│                                                                      │
│ SOLUTION                                                             │
│ └── [HIGH] New /document skill capability                            │
│     Path: BLUEPRINT → PRD → ARCHITECTURE → BACKLOG                   │
│     Skip: ADR (no decision needed), ROADMAP (no milestone change)    │
│                                                                      │
│ SPECIFICATION                                                        │
│ └── [MEDIUM] Skill behavior change                                   │
│     Path: PRD → ARCHITECTURE → BACKLOG                               │
│                                                                      │
│ ARCHITECTURE                                                         │
│ └── [MEDIUM] New hook-utils.sh shared library                        │
│     Path: ARCHITECTURE → BACKLOG                                     │
│     Skip: ADR (minor structural), ROADMAP (no milestone)             │
│                                                                      │
│ DEVELOPMENT                                                          │
│ └── [LOW] Task status updates                                        │
│     Path: BACKLOG                                                    │
│                                                                      │
│ DOCUMENTATION                                                        │
│ └── [MEDIUM] BLUEPRINT refs moved to objectives/                     │
│     Path: Direct updates to affected docs                            │
│ └── [LOW] README typo                                                │
│     Path: README.md                                                  │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### 4. Detect Inconsistencies and Conflicts

**Full mode (`--full`)**: Proactively scan all docs for cross-document inconsistencies.

**Incremental mode (default)**: Only check for conflicts when updating specific docs. Read only the docs being modified and their direct references.

Detect conflicts between:
- **Doc ↔ Doc**: Docs contradict each other
- **Code ↔ Doc**: Implementation differs from documented behavior
- **New ↔ Old**: Recent changes contradict earlier decisions (ADRs, PRD)

#### Inconsistency Types

| Type | Example | Severity |
|------|---------|----------|
| **Decision Conflict** | New code contradicts ADR decision | HIGH |
| **Specification Drift** | Implementation differs from PRD | HIGH |
| **Cross-Doc Mismatch** | ARCHITECTURE says X, README says Y | MEDIUM |
| **Stale Reference** | Doc references removed component | MEDIUM |
| **Version Mismatch** | Changelog vs actual version | LOW |

#### When Inconsistencies Found

**NEVER silently overwrite.** Return a QUESTIONS block to the Orchestrator:

```
## QUESTIONS FOR USER

Q1: Inconsistency detected: [describe conflict]. How should we resolve? *(blocking)*
- Option A: Update old to match new — the new change is correct
- Option B: Keep old, flag new — the prior decision stands, new change needs review
- Option C: Document both (tentative) — record conflict in ISSUES for later resolution
- Option D: Pause for full review — stop and escalate to appropriate agent
```

#### If Decision Conflicts with ADR

```
## QUESTIONS FOR USER

Q1: Change contradicts ADR-XXX: [summary]. This is a significant decision reversal. *(blocking)*
- Option A: Supersede ADR — create new ADR explaining why decision changed
- Option B: Revert approach — the ADR decision stands, flag change for revision
- Option C: Document conflict — record in ISSUES as unresolved architectural debt
```

### 5. Handle Tentative or Rejected Decisions

If user selects "tentative", "pause", or rejects a proposed update:

#### Log to ISSUES.md

```markdown
## [DATE] Documentation Inconsistency - PENDING REVIEW

**Type**: [Decision Conflict | Specification Drift | Cross-Doc Mismatch]
**Severity**: [HIGH | MEDIUM | LOW]
**Session**: ${CLAUDE_SESSION_ID}

### Conflict Description
[Describe what contradicts what]

### Affected Documents
- doc1.md (line X): states "..."
- doc2.md (line Y): states "..."

### User Decision
- [ ] Tentative - needs review
- [ ] Rejected - requires architectural decision

### Recommended Resolution
**Agent**: [Architect | Business Analyst | Developer]
**Action**: [Suggest specific review action]
```

#### Suggest Appropriate Agent

| Conflict Type | Suggested Agent | Reason |
|---------------|-----------------|--------|
| ADR contradiction | `/design` (Architect) | Architectural decision needed |
| PRD specification drift | `/spec` (Business Analyst) | Requirements clarification needed |
| Implementation mismatch | `/implement` (Developer) | Code review needed |
| Cross-doc inconsistency | `/review` (Tech Writer) | Cross-artifact consistency review |

### 6. Present to User for Confirmation

After resolving all conflicts, return update plan to the Orchestrator:

```
## QUESTIONS FOR USER

Q1: Proceed with documentation updates? [N resolved, M logged to ISSUES] *(blocking)*
- Option A: Proceed — update docs following propagation paths
- Option B: Modify selection — specify which items to include/exclude
- Option C: Critical only — address only CRITICAL items now
```

### 7. Execute Updates

For each Area (process CRITICAL items first across all areas):

1. **Update entry point document**
2. **Propagate downstream** (skip levels with no impact)
3. **Verify cross-references**

Always follow the propagation paths (information flows upstream → downstream). Criticality determines what to tackle first, not the order within a path.

Sort items by criticality (CRITICAL → HIGH → MEDIUM → LOW) before starting. For each item, walk its propagation path in order — skip levels with no impact.

### 8. Validate

Check documentation quality:
- [ ] CRITICAL items addressed first
- [ ] Entry points updated before downstream
- [ ] Cross-references valid (for touched docs)
- [ ] No orphaned changes (all classified)
- [ ] Skipped levels justified
- [ ] **All detected inconsistencies resolved or logged to ISSUES**
- [ ] **No silent overwrites (user confirmed all conflicts)**
- [ ] **Tentative decisions documented with suggested agent**

**Full mode additional checks:**
- [ ] All cross-document references consistent
- [ ] No stale references to removed components
- [ ] Version numbers aligned across docs

---

## Output Format

### Impact Analysis Report

```markdown
# Documentation Impact Analysis

**Session**: ${CLAUDE_SESSION_ID}
**Date**: $(date +%Y-%m-%d)
**Changes Analyzed**: N files

## Changes by Area × Criticality

### SYSTEM
| Change | Criticality | Path | Skip |
|--------|-------------|------|------|
| (none) | | | |

### PRODUCT
| Change | Criticality | Path | Skip |
|--------|-------------|------|------|
| (none) | | | |

### SOLUTION
| Change | Criticality | Path | Skip |
|--------|-------------|------|------|
| /document skill capability | HIGH | BLUEPRINT→PRD→ARCH→BACKLOG | ADR, ROADMAP |

### SPECIFICATION
| Change | Criticality | Path | Skip |
|--------|-------------|------|------|
| Skill behavior change | MEDIUM | PRD→ARCH→BACKLOG | ADR, ROADMAP |

### ARCHITECTURE
| Change | Criticality | Path | Skip |
|--------|-------------|------|------|
| hook-utils.sh library | MEDIUM | ARCH→BACKLOG | ADR, ROADMAP |

### DEVELOPMENT
| Change | Criticality | Path | Skip |
|--------|-------------|------|------|
| Task completions | LOW | BACKLOG | |

### DOCUMENTATION
| Change | Criticality | Path | Skip |
|--------|-------------|------|------|
| BLUEPRINT refs | MEDIUM | Direct | |
| README typo | LOW | Direct | |

## Recommended Update Order
1. [HIGH] BLUEPRINT.md - new capability
2. [HIGH] PRD.md - /document skill description
3. [MEDIUM] PRD.md - skill behavior change
4. [MEDIUM] ARCHITECTURE.md - hook utils section
5. [MEDIUM] Various docs - BLUEPRINT refs
6. [LOW] BACKLOG.md - task tracking
7. [LOW] README.md - typo fix
```

## Policy References

**Should-read** from `~/.claude/policy/RULES.md`:
- Professional Honesty - No marketing language, accurate claims
- File Organization - Purpose-based organization
