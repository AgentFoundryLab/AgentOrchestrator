# Technical Requirements: {{CONCERN_NAME}}

> Document id: `TRD-{{SCOPE_CODE}}-{{NNN}}` — filename `TRD-{{SCOPE_CODE}}-{{NNN}}.md` under `docs/requirements/`.
> Record ids inside are flat and numeric: `TR-NNN` with parent-scoped `TRC-NNN.n`. The scope code lives in
> the filename only, never inside an id.

## Overview

Summarize the cross-cutting concern, why it matters, and which parts of the product it constrains.

## Scope

- In-scope systems, features, or containers
- Explicit boundaries of this requirement set

## Constraints

### TR-{{NNN}}: {{CONSTRAINT_NAME}}

**Intent:** Describe the rule or constraint and why it exists.

**Requirements:**

- **TRC-{{NNN}}.1:** The system shall {{CROSS_CUTTING_BEHAVIOR_OR_CONSTRAINT}}.
- **TRC-{{NNN}}.2:** The system shall {{CROSS_CUTTING_BEHAVIOR_OR_CONSTRAINT}}.

### TR-{{NNN}}: {{CONSTRAINT_NAME}}

**Intent:** Describe the rule or constraint and why it exists.

**Requirements:**

- **TRC-{{NNN}}.1:** The system shall {{CROSS_CUTTING_BEHAVIOR_OR_CONSTRAINT}}.

## Standards and References

- Relevant internal standards, external regulations, or integration contracts

## Verification

- How compliance with each constraint will be validated, and at which layer

<!--
Authoring rules (see the $spec skill for the full set):
- Sections are exactly: Overview, Scope, Constraints, Standards and References, Verification.
- Technical requirements carry stack, vendor, platform, and verification commitments.
  User-visible behavior belongs in an FRD, not here.
- Every TRC carries something verifiable. A constraint nobody can check is a wish.
- Present tense, immutable ids, one-way citation — same rules as the FRD.
-->
