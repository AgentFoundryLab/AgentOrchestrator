# Feature Requirements: Orchestrated Delivery Journeys

## Overview

The component features describe what exists; these requirements describe what a user can actually accomplish end to end. Each is a journey that crosses several components, so each is stated as its own requirement rather than folded into a component's acceptance criteria — a journey that works only because three components happen to compose correctly is not covered by any of their individual criteria.

These journeys are also the acceptance surface for delegation. A journey that completes only when one agent does everything is not orchestrated, however correct its output.

## Terminology

- **Journey**: a user-visible path from input to committed artifact, crossing more than one stage.
- **Delegated slice**: one stage of a journey executed by a sub-agent in its own worktree.

## Requirements

### REQ-009: Idea to requirements

**User Story:** As a user, I want to hand over a rough idea and get confirmed, testable requirements, so that implementation starts from something verifiable.

**Acceptance Criteria:**

- **AC-009.1:** When given an idea, the system shall elicit missing product context before drafting, and shall not draft while correctness-critical ambiguity remains unresolved.
- **AC-009.2:** The system shall produce `FRD`/`TRD` documents with `REQ`/`AC` and `TR`/`TRC` records, and refresh the requirements index.
- **AC-009.3:** Remaining open questions shall be reported without blocking downstream planning when planning is still safe.

### REQ-010: Requirements to blueprints

**User Story:** As a user, I want requirements translated into implementable architecture, so that a developer has a technical path rather than a restatement of the requirement.

**Acceptance Criteria:**

- **AC-010.1:** When given requirements, the system shall produce `FBP` blueprints establishing foundations before feature structure.
- **AC-010.2:** Every requirement in scope shall have a traceable technical path through a blueprint.
- **AC-010.3:** Decisions with alternatives and lasting consequences shall be recorded as standalone tier-scoped ADRs, cross-referenced from the governing blueprint and never inlined.
- **AC-010.4:** A domain or data-model change shall not proceed to planning without an explicit adversarial-validation pass.

### REQ-011: Blueprints to Work Orders

**User Story:** As a user, I want architecture decomposed into executable Work Orders, so that delivery can be sequenced and parallelized.

**Acceptance Criteria:**

- **AC-011.1:** When given blueprints and requirements, the system shall produce `WO` records cross-referencing requirements by id with a brief description, never copying requirement text.
- **AC-011.2:** Each `WO` shall carry `Phase`, `Milestone`, `Category`, `Scope`, `Title`, `Complexity`, and `Priority` at creation.
- **AC-011.3:** `dependsOn` shall reflect the real dependency graph, and a shared surface touched by several Work Orders shall be stated as a sequencing barrier.
- **AC-011.4:** Multi-file, high-risk, or dependency-sensitive work shall receive an implementation plan with a delegation map, linked from its `WO`.

### REQ-012: End-to-end orchestrated delivery

**User Story:** As a user, I want a goal delivered through delegated agents, so that independent work runs in parallel without agents overwriting each other.

**Acceptance Criteria:**

- **AC-012.1:** `$orchestrate` shall score complexity, propose a depth, confirm it, and maintain a ledger of mode, lanes, commits, validation state, and blockers.
- **AC-012.2:** Every non-trivial slice shall be delegated into its own isolated worktree; concurrent agents shall never share a worktree.
- **AC-012.3:** A lane that boots the application or its stores shall shift every service port and namespace every ephemeral store, so parallel lanes never contend.
- **AC-012.4:** The orchestrator shall be the sole allocator of record ids; a delegated agent shall receive its ids in the brief and shall return a blocker rather than minting one.
- **AC-012.5:** The model tier shall be passed explicitly at every dispatch, derived from the item's own classification.
- **AC-012.6:** A slice shall be treated as complete only at an explicit checkpoint; silence or a truncated report shall be treated as incomplete and recovered, not assumed done.
- **AC-012.7:** Every runtime stack shall be stopped before its agent reports; every worktree and branch shall survive until its merge lands, then be removed.

### REQ-013: Session learning

**User Story:** As an operator, I want a failed session analysed against the instructions that allowed the failure, so that the workflow improves instead of repeating.

**Acceptance Criteria:**

- **AC-013.1:** When a session ends, the system shall prompt for session-level learning without blocking completion.
- **AC-013.2:** Analysis shall be grounded in the session's own transcripts, and any heuristic session selection shall be reported as such.
- **AC-013.3:** Findings shall be written to a versioned memo naming real record ids, never hand-invented ones.

### REQ-014: Codebase investigation

**User Story:** As a user, I want a bug or unfamiliar area investigated with evidence, so that a fix starts from a root cause rather than a guess.

**Acceptance Criteria:**

- **AC-014.1:** Investigation shall prefer structural code retrieval and indexed document retrieval over broad text search, and shall fall back to text search only for raw text, config, or a stale index.
- **AC-014.2:** Findings shall cite source paths and symbols, and shall state confidence.
- **AC-014.3:** A contradiction between requirements, blueprints, implementation, validation, or status shall be surfaced and routed to the owning stage, never silently reconciled.
- **AC-014.4:** An investigation whose findings must outlive the session shall produce a report under `docs/analysis/`.
