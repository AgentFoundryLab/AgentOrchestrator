---
name: document
description: Create or update documentation for features, APIs, or components
argument-hint: component or feature to document
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

## Artifact Layers

`policy/RULES.md` owns the upstream → downstream flow, and `$reconcile` owns the routing taxonomy. This
skill does not restate either — a second copy drifts the moment the schema changes. What `/document`
needs is only *which artifact owns which detail level*:

| Layer | Artifacts | Owns |
|---|---|---|
| Strategic | `docs/objectives/{VISION,BLUEPRINT}.md` | product intent, capability scope, success direction |
| Requirements | `docs/requirements/{FRD,TRD}-*.md` | `REQ`/`AC` behavior, `TR`/`TRC` constraints |
| Architecture | `docs/architecture/**` (`FBP-*`, `ADR-*`) | component design and decision rationale |
| Knowledge | `docs/knowledge/**` (TDRs, runbooks, patterns, domain) | operational patterns, runtime semantics, investigations |
| Execution | `docs/development/**` (`ROADMAP`, `PLAN-*`, `WO-*`, `ISS`/`REG`/`TD`/`FB`, `status/`) | sequencing, deliverables, blockers, status |
| Validation | `docs/validation/**` | `AC`/`TRC` coverage and evidence |
| Entry | `README.md`, `CLAUDE.md`, `AGENTS.md` | quick entrypoint, constraints summary, pointers |

**Placement principle:** write content to the artifact that owns that decision level; cross-reference
instead of duplicating detail across layers.

When a change must propagate across layers, follow the flow in `RULES.md` and route anything ambiguous
through `$reconcile`. Do not maintain a propagation table here.

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
| **System** | hooks/MCP/install broken; agents/skills fail | an `ISS` + `REG`, then a `WO` |
| **Product** | `VISION.md`, goals, OKRs, target users | `VISION.md` |
| **Solution** | `BLUEPRINT.md`, capabilities, feature matrix | `BLUEPRINT.md` |
| **Requirements** | requirement or acceptance-criteria definitions | `docs/requirements/{FRD,TRD}-*.md` + `REQUIREMENTS.md` |
| **Architecture** | blueprints, ADRs, `DESIGN-PRINCIPLES.md`, hooks/agents structure | `docs/architecture/{foundation,feature,system}/FBP-*`, `ADR/ADR-*`, `DESIGN-PRINCIPLES.md` |
| **Development** | `ROADMAP.md`, Plans, Work Orders | `ROADMAP.md`, `plans/PLAN-*`, `workorders/WO-*`, `WORKORDERS.md` |
| **Documentation** | `README.md`, `CLAUDE.md`, `AGENTS.md`, `docs/policy/`, `docs/knowledge/` | `README.md`, `CLAUDE.md`, `AGENTS.md`, `docs/policy/{STANDARDS,GUIDELINES}.md`, `docs/knowledge/{domain,patterns,decisions,runbooks}/` |

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
│     Path: ISS + REG → WO                                             │
│                                                                      │
│ PRODUCT                                                              │
│ └── [HIGH] New target user segment                                   │
│     Path: VISION → BLUEPRINT → FRD → FBP → WO                        │
│                                                                      │
│ SOLUTION                                                             │
│ └── [HIGH] New /document skill capability                            │
│     Path: BLUEPRINT → FRD → FBP → WO                                 │
│     Skip: ADR (no decision needed), ROADMAP (no milestone change)    │
│                                                                      │
│ REQUIREMENTS                                                         │
│ └── [MEDIUM] Skill behavior change                                   │
│     Path: FRD → FBP → WO                                             │
│                                                                      │
│ ARCHITECTURE                                                         │
│ └── [MEDIUM] New hook-utils.sh shared library                        │
│     Path: FBP → WO                                                   │
│     Skip: ADR (minor structural), ROADMAP (no milestone)             │
│                                                                      │
│ DEVELOPMENT                                                          │
│ └── [LOW] Task status updates                                        │
│     Path: WO                                                         │
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
- **New ↔ Old**: Recent changes contradict earlier decisions (ADRs, requirements)

#### Inconsistency Types

| Type | Example | Severity |
|------|---------|----------|
| **Decision Conflict** | New code contradicts ADR decision | HIGH |
| **Requirement Drift** | Implementation differs from its `REQ`/`AC` | HIGH |
| **Cross-Doc Mismatch** | ARCHITECTURE says X, README says Y | MEDIUM |
| **Stale Reference** | Doc references removed component | MEDIUM |
| **Version Mismatch** | Changelog vs actual version | LOW |

#### When Inconsistencies Found

**NEVER silently overwrite.** Ask the user directly with `AskUserQuestion`:

- question: `Inconsistency detected: [describe conflict]. How should we resolve?`
- **Update old to match new** — the new change is correct
- **Keep old, flag new** — the prior decision stands; the new change needs review
- **Document both (tentative)** — record the conflict in `ISSUES.md` for later resolution
- **Pause for full review** — stop and route through `$reconcile` to the owning stage

#### If Decision Conflicts with ADR

Ask with `AskUserQuestion`:

- question: `Change contradicts ADR-XXX: [summary]. This is a significant decision reversal.`
- **Supersede the ADR** — route to `$architect` to author a new ADR explaining why the decision changed
- **Revert the approach** — the ADR decision stands; flag the change for revision
- **Document the conflict** — record in `ISSUES.md` as unresolved architectural debt

A decision reversal is an `$architect` change, not a docs edit. `/document` records the conflict; it never authors or supersedes an ADR itself.

### 5. Handle Tentative or Rejected Decisions

If user selects "tentative", "pause", or rejects a proposed update:

#### Log as an ISS record

```markdown
## [DATE] Documentation Inconsistency - PENDING REVIEW

**Type**: [Decision Conflict | Requirement Drift | Cross-Doc Mismatch]
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

| Conflict Type | Suggested Route | Reason |
|---------------|-----------------|--------|
| ADR contradiction | `/architect` (Architect) | Architectural decision needed |
| Requirement drift | `/spec` (Business Analyst) | Requirements clarification needed |
| Implementation mismatch | `/implement` (Developer) | Code review needed |
| Cross-doc inconsistency | `/review` (Tech Writer) | Cross-artifact consistency review |
| Status claims not proven by code/tests | `/status-update` (Validator) | Implementation assessment, not a docs edit |
| Unclear which stage owns the fix | `/reconcile` | Classifies the finding and names the owning stage |

`/reconcile` owns the upstream→downstream flow model and the routing taxonomy. This table is the docs-facing shortcut; when a conflict does not map cleanly to one row, route through `$reconcile` rather than guessing.

### 6. Present to User for Confirmation

After resolving all conflicts, confirm the update plan with `AskUserQuestion`:

- question: `Proceed with documentation updates? [N resolved, M logged to ISSUES]`
- **Proceed** — update docs following the propagation paths
- **Modify selection** — specify which items to include or exclude
- **Critical only** — address only CRITICAL items now

### 7. Execute Updates

For each Area (process CRITICAL items first across all areas):

1. **Update entry point document**
2. **Propagate downstream** (skip levels with no impact)
3. **Verify cross-references**
4. **Enforce artifact boundaries** (place detail in the owning artifact type; keep entry docs summary-level with pointers)

Always follow the propagation paths (information flows upstream → downstream). Criticality determines what to tackle first, not the order within a path.

Sort items by criticality (CRITICAL → HIGH → MEDIUM → LOW) before starting. For each item, walk its propagation path in order — skip levels with no impact.

### 8. Validate

Check documentation quality:
- [ ] CRITICAL items addressed first
- [ ] Entry points updated before downstream
- [ ] Cross-references valid (for touched docs)
- [ ] No orphaned changes (all classified)
- [ ] Skipped levels justified
- [ ] Artifact boundaries respected (detail level matches artifact type)
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
| /document skill capability | HIGH | BLUEPRINT→FRD→FBP→WO | ADR, PLAN |

### REQUIREMENTS
| Change | Criticality | Path | Skip |
|--------|-------------|------|------|
| Skill behavior change | MEDIUM | FRD→FBP→WO | ADR, PLAN |

### ARCHITECTURE
| Change | Criticality | Path | Skip |
|--------|-------------|------|------|
| hook-utils.sh library | MEDIUM | FBP→WO | ADR, PLAN |

### DEVELOPMENT
| Change | Criticality | Path | Skip |
|--------|-------------|------|------|
| Work Order completions | LOW | WO | |

### DOCUMENTATION
| Change | Criticality | Path | Skip |
|--------|-------------|------|------|
| BLUEPRINT refs | MEDIUM | Direct | |
| README typo | LOW | Direct | |

## Recommended Update Order
1. [HIGH] BLUEPRINT.md - new capability
2. [HIGH] FRD-DOC-001 - /document skill description
3. [MEDIUM] FRD-DOC-001 - skill behavior change
4. [MEDIUM] FBP-FND-002 - hook utils section
5. [MEDIUM] Various docs - BLUEPRINT refs
6. [LOW] WORKORDERS.md - status tracking
7. [LOW] README.md - typo fix
```

## Policy References

**Should-read** from the active runtime root's `policy/RULES.md`:
- Professional Honesty - No marketing language, accurate claims
- File Organization - Purpose-based organization
