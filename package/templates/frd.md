# Feature Requirements: {{FEATURE_NAME}}

> Document id: `FRD-{{SCOPE_CODE}}-{{NNN}}` — filename `FRD-{{SCOPE_CODE}}-{{NNN}}.md` under `docs/requirements/`.
> Record ids inside are flat and numeric: `REQ-NNN` with parent-scoped `AC-NNN.n`. The scope code lives in
> the filename only, never inside an id.

## Overview

Write 1-2 narrative paragraphs explaining what the feature does and why users need it. Focus on the problem being solved and the value delivered, not the implementation.

## Terminology

Define only feature-specific ambiguous terms. Omit the section when nothing needs defining.

- {{TERM}}: Brief, precise definition.
- {{TERM}}: Brief, precise definition.

## Requirements

### REQ-{{NNN}}: {{REQUIREMENT_NAME}}

**User Story:** As a {{ROLE}}, I want to {{ACTION}}, so that I can {{OUTCOME}}.

**Acceptance Criteria:**

- **AC-{{NNN}}.1:** When {{CONDITION}}, the system shall {{BEHAVIOR}}.
- **AC-{{NNN}}.2:** When {{CONDITION}}, the system shall {{BEHAVIOR}}.

### REQ-{{NNN}}: {{REQUIREMENT_NAME}}

**User Story:** As a {{ROLE}}, I want to {{ACTION}}, so that I can {{OUTCOME}}.

**Acceptance Criteria:**

- **AC-{{NNN}}.1:** When {{CONDITION}}, the system shall {{BEHAVIOR}}.

<!--
Authoring rules (see the $spec skill for the full set):
- Sections are exactly: Overview, Terminology, Requirements.
- Every criterion states explicit observable behavior: "When ..., the system shall ...".
- Present tense, as if authored today. No dated parentheticals, no rationale-of-change,
  no "was X, now Y". A criterion is the target to test against.
- A retired requirement keeps its id and carries one word: Decommissioned or Superseded.
- Cite REQ/AC/TR/TRC and nothing else. An FBP, ADR, WO, ISS, REG, TD, or FB id in a
  requirement body is a flow violation — delete it, never re-point it.
- Ids are immutable: never renumber or recycle. REQ-003 stays REQ-003 after REQ-002 is dropped.
-->
