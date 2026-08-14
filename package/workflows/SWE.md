# Software Engineering Workflow

**Version**: 0.2.0
**Purpose**: Guide development from idea to deployment

---

## Workflow Overview

Delivery — `implement → validate → security-review → status-update` — runs in every depth. The depth
selects only which planning stages precede it.

| Depth | Planning stages | Use When |
|-------|-----------------|----------|
| **Full** | onboard → spec → architect → planner → **review** | New product, complex system |
| **Medium** | spec → planner → **review** | New feature, moderate complexity |
| **Light** | planner | Simple change, clear task |
| **Direct fix** | none — runs against an existing `ISS`/`TD` | Diagnosed, bounded defect |

`/orchestrate` owns depth selection, delegation, and lane lifecycle. `/deploy` and `/document` follow
delivery when the work ships or needs docs.

---

## Workflow Definitions

### Full Workflow

```
┌─────────┐   ┌───────────┐   ┌──────────┐   ┌─────────┐   ┌───────────┐
│  /spec  │──▶│/architect │──▶│ /planner │──▶│ /review │──▶│/implement │
└─────────┘   └───────────┘   └──────────┘   └─────────┘   └───────────┘
     │             │               │              │              │
     ▼             ▼               ▼              ▼              ▼
   FRD/TRD     FBP-* +        PLAN-* +        review-        Code +
               ADR-* +        WO-* +          YYYY-MM-DD     Tests
               diagrams       plans               │              │
                                          [blocking gate]        ▼
                    ┌──────────┐   ┌──────────────────┐   ┌────────────────┐
                    │/validate │──▶│ /security-review │──▶│ /status-update │
                    └──────────┘   └──────────────────┘   └────────────────┘
                         │                  │                     │
                         ▼                  ▼                     ▼
                   reports/           PASS | FAIL |         Status in
                   docs/validation/     FINDINGS         record indexes
                                                                  │
                                          ┌─────────┐   ┌──────────┐
                                          │ /deploy │──▶│/document │
                                          └─────────┘   └──────────┘
                                               │              │
                                               ▼              ▼
                                           Deployed       README +
                                           Artifacts      Runbooks
```

**Phases**:

1. **Specification** (`/spec` → Business Analyst)
   - Input: Idea or feature description
   - Output: `docs/requirements/FRD-<SCOPE>-NNN.md`, `TRD-<SCOPE>-NNN.md`
   - Activities: Requirements elicitation, acceptance criteria definition

2. **Architecture** (`/architect` → Architect)
   - Input: `FRD`/`TRD` requirements
   - Output: `docs/architecture/{foundation,feature}/FBP-<TIER>-NNN.md`, `ADR/ADR-<TIER>-NNN.md`, `system/`
   - Activities: System design, component definition, trade-off analysis, ADR authoring
   - Note: Domain/data model changes require an explicit adversarial-validation pass before planning.

3. **Planning** (`/planner` → Planner)
   - Input: Architecture
   - Output: `docs/development/ROADMAP.md`, `plans/PLAN-NNN-*.md`, `workorders/WO-NNN.md`, optional `WO-NNN-implementation-plan.md`
   - Activities: Work Order decomposition, prioritization, dependency mapping, implementation-plan authoring for complex work

4. **Review** (`/review` → Tech Writer)
   - Input: Roadmap, Plans, Work Orders, requirements, blueprints, ADRs
   - Output: `reports/analysis/review-YYYY-MM-DD.md`, blocking issues in `docs/development/ISSUES.md`
   - Activities: Cross-artifact consistency, `REQ` coverage, Work Order traceability
   - Note: **Blocking gate** — halt if blocking issues found. Skip for medium/light workflows.

5. **Implementation** (`/implement` → Developer)
   - Input: Work Order plus its implementation plan when present
   - Output: Code, tests
   - Activities: Coding, testing, code review prep

6. **Validation** (`/validate` → Validator)
   - Input: Implementation plus the Work Order's implementation plan when present
   - Output: `docs/validation/` coverage keyed on `AC`/`TRC`, plus `ISS`/`REG`/`TD` records
   - Activities: Testing, acceptance-criteria verification, quality checks, regression evidence matrix
   - Note: Fails closed. A missing, stale, or partial evidence row is `NOT VALIDATED`.

7. **Security Gate** (`/security-review` → Security)
   - Input: Implementation commit and the validator handoff
   - Output: Verdict (PASS | FAIL | FINDINGS), issue rows for Critical/High findings
   - Activities: OWASP Top 10 + LLM Top 10 assessment, threat modeling, CI gate alignment
   - Note: Any Critical or High finding is FAIL and routes back to `/implement`.

8. **Status Update** (`/status-update` → Validator)
   - Input: Validation evidence and the security verdict
   - Output: Assessed status in each record's index, plus `status/STATUS.md`
   - Activities: Implementation assessment, authored-doc drift reconciliation, status commit
   - Note: Sole owner of status values. No other stage sets them.

9. **Deployment** (`/deploy` → Deployer)
   - Input: Validated code
   - Output: Deployed artifacts
   - Activities: Build, deploy, release verification

10. **Documentation** (`/document` → Tech Writer)
   - Input: Deployed feature
   - Output: `docs/`, `README.md`
   - Activities: User docs, API docs, runbooks

---

### Medium Workflow

```
┌─────────┐   ┌──────────┐   ┌─────────┐   ┌──────────────────────┐
│  /spec  │──▶│ /planner │──▶│ /review │──▶│      delivery        │
└─────────┘   └──────────┘   └─────────┘   └──────────────────────┘
     │             │              │                    │
     ▼             ▼              ▼                    ▼
   FRD/TRD    WO-* +          review-          Code + Tests +
              tasks/*.md    YYYY-MM-DD        evidence + status
```

**Phases**:

1. **Specification** (`/spec` → Business Analyst)
   - Streamlined requirements with focus on acceptance criteria
   - Skip detailed user personas if obvious

2. **Planning** (`/planner` → Planner)
   - Direct to Work Orders (skip a formal Plan)
   - Focus on task breakdown

3. **Review** (`/review` → Tech Writer)
   - Cross-artifact consistency gate before implementation starts

4. **Delivery** (`/implement` → `/validate` → `/security-review` → `/status-update`)
   - Full delivery chain, same gates as the Full workflow

---

### Light Workflow

```
┌──────────┐   ┌──────────────────────┐
│ /planner │──▶│      delivery        │
└──────────┘   └──────────────────────┘
     │                    │
     ▼                    ▼
  Task def         Code + Tests +
                  evidence + status
```

**Phases**:

1. **Planning** (`/planner` → Planner)
   - Quick task definition with acceptance criteria
   - May be a single task, no epic structure needed

2. **Delivery** (`/implement` → `/validate` → `/security-review` → `/status-update`)
   - The chain never shortens below this; only the planning stages drop out

---

### Direct Fix

For a defect whose remediation is already diagnosed and bounded, run delivery against the existing
`ISS`/`TD` with no new Work Order minted and no planning run:

```
┌──────────────────────┐
│      delivery        │  against ISS / TD    
└──────────────────────┘
```

Mint a task and run a fuller depth instead when the fix needs decomposition, or touches a requirement,
architecture, domain/data model, or security boundary — route those through `/reconcile`.

---

## Complexity Assessment

Use this scoring to select workflow depth:

| Factor | Score | Examples |
|--------|-------|----------|
| New system/product | +3 | "Build a CLI tool", "Create a new service" |
| Multiple components | +2 | "Frontend + backend", "Multiple microservices" |
| External integration | +2 | "Connect to Stripe", "OAuth integration" |
| New API design | +1 | "New REST endpoints", "GraphQL schema" |
| UI changes | +1 | "New dashboard", "Form redesign" |
| Database changes | +1 | "New tables", "Schema migration" |
| Simple bug fix | -2 | "Fix null check", "Handle edge case" |
| Documentation only | -3 | "Update README", "Add comments" |
| Configuration change | -2 | "Update env vars", "Change settings" |

**Scoring Thresholds**:
- **Score >= 4**: Full workflow
- **Score 1-3**: Medium workflow
- **Score <= 0**: Light workflow

---

## Decision Points

The orchestrator should consult the user at these points:

### Mandatory Checkpoints
1. **Workflow Selection**: Before starting, confirm depth is appropriate
2. **Scope Changes**: If spec reveals larger scope than expected
3. **Architecture Trade-offs**: When decisions have significant long-term impact
4. **Blockers**: When unable to proceed without guidance

### Optional Checkpoints
1. **Phase Transitions**: "Requirements complete. Ready to proceed to blueprints?"
2. **Implementation Choices**: "Two approaches possible: A or B. Preference?"
3. **Validation Failures**: "Tests failing. Should I fix or investigate further?"

---

## Artifact Flow

Each phase produces artifacts consumed by subsequent phases:

```
/spec
  └─▶ FRD / TRD
        └─▶ /architect
              └─▶ FBP blueprints, ADRs, diagrams
                    └─▶ /planner
                          └─▶ ROADMAP.md, PLAN-*, WO-*
                                └─▶ /review
                                      └─▶ review-YYYY-MM-DD.md
                                            └─▶ /implement
                                                  └─▶ Code, Tests
                                                        └─▶ /validate
                                                              └─▶ docs/validation/
                                                                    └─▶ /security-review
                                                                          └─▶ Verdict
                                                                                └─▶ /status-update
                                                                                      └─▶ Status
                                                                                            └─▶ /deploy
                                                                                                  └─▶ /document
```

Feedback runs the other way through `/reconcile`, which classifies a downstream finding and routes it
to the stage that owns the fix. Downstream artifacts never rewrite upstream ones directly.

**Traceability**: Each artifact should reference its source:
- Requirements → User request
- Blueprints → requirements
- Work Orders → blueprint components
- Code → record ids
- Commits → record ids

---

## Error Handling

If a phase fails or is blocked:

1. **Document the blocker** in the artifact
2. **Assess severity**:
   - Critical: Cannot proceed (stop workflow)
   - High: Needs resolution before next phase
   - Medium: Can proceed with caveat
   - Low: Note for later
3. **Invoke `$meta-learn`** if the failure reveals an instruction or process gap — inline, in the session that owns the workflow. Never delegate it to a lane agent; a lane reports the signal instead.
4. **Consult user** for critical/high blockers
5. **Continue or halt** based on guidance

---

## Parallel Execution

Where dependencies allow, phases can run in parallel:

```
/spec ────────────────────────┐
                              ├──▶ /architect
/scout (existing code) ───────┘
```

```
/implement (task 1) ──────────┐
                              ├──▶ /validate
/implement (task 2) ──────────┘
```

Use the Wave → Checkpoint → Wave pattern for parallel tasks. Each parallel implementation lane runs in
its own isolated worktree with shifted ports and namespaced stores — see `/orchestrate` for lane
provisioning and teardown.

---

## Workflow Selection Examples

| Request | Score | Workflow |
|---------|-------|----------|
| "Build a project management app" | +3 (new) +2 (components) = 5 | Full |
| "Add user authentication" | +2 (integration) +1 (API) = 3 | Medium |
| "Implement dark mode toggle" | +1 (UI) = 1 | Medium |
| "Fix typo in error message" | -2 (simple fix) = -2 | Light |
| "Add retry logic to API calls" | 0 | Light |
| "Fix the null deref in ISS-014" | n/a — diagnosed defect | Direct fix |
| "Build analytics dashboard" | +3 (new) +1 (UI) +1 (API) = 5 | Full |
