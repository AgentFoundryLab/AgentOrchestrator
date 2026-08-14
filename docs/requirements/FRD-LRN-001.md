# Feature Requirements: Session Learning and Rule Optimization

## Overview

A workflow that repeats the same failure is missing a feedback loop, not a rule. This feature closes it: read what actually happened from session transcripts, name the failure mode, find the instruction that allowed it, propose a fix, and re-validate the mode against the updated rule.

Application is gated on approval and confined to instruction surfaces. Analysis is always safe; editing the rules that govern every future session is not.

## Terminology

- **Failure mode**: the shape of what went wrong, named from evidence — not a category picked from a list.
- **Instruction surface**: a policy file, agent profile, or skill. The only thing this loop may edit.
- **Deployed copy**: an installed artifact. Editing it is overwritten on next install; the fix belongs in `package/`.

## Requirements

### REQ-007: Tactical error capture

**Status:** `Decommissioned` — superseded by `REQ-008`.

The original requirement specified a dedicated tactical error-capture skill with its own memory namespace, separate from session reflection and from rule optimization. `$meta-learn` absorbed all three into one loop that reads real transcripts instead of hand-written records, so the separation no longer describes anything the system does.

Retained at its own id rather than deleted or renumbered. Its acceptance criteria `AC-007.1` through `AC-007.4` are `Decommissioned` with it.

### REQ-008: Session analysis with gated rule optimization

**User Story:** As an operator, I want failures analysed against the instructions that allowed them, so that the same failure mode does not recur every session.

**Acceptance Criteria:**

- **AC-008.1:** The system shall map the session graph from the runtime's own transcripts, identifying the root session and its sub-agents by parent linkage, and shall classify each failure mode from that evidence.
- **AC-008.2:** The system shall propose instruction changes naming the target file, the change verb, the precise wording, and the failure mode each prevents.
- **AC-008.3:** No instruction change shall be applied without explicit user approval, and affected global files shall be backed up first.
- **AC-008.4:** Edits shall be confined to instruction surfaces. When the target is an installed copy of a `package/` artifact, the fix shall be made to the source instead.
- **AC-008.5:** After applying, the system shall re-validate each original failure mode and state whether the updated rules prevent, reduce, detect, or still miss it. An unresolved mode shall be reported as unresolved.
