# Feature Requirements: Self-Validation

## Overview

An agent that reports success without checking is worse than one that reports a blocker, because the first ends the loop. This feature is the prompt that makes an agent check its own work against the contract it was given, before it hands off.

Self-validation is not the validation gate. `$validate` owns the gate and produces coverage evidence; this is the agent's own pre-handoff check that its output matches the criteria it was assigned and that it left nothing running.

## Terminology

- **Self-validation**: the agent's pre-handoff check of its own output, prompted at `SubagentStop`.
- **Checkpoint**: a scoped commit plus a status note. The only durable proof a slice progressed.

## Requirements

### REQ-006: Pre-handoff self-validation

**User Story:** As an orchestrator, I want each agent to check its own output before handing off, so that a slice does not reach the validation gate with obvious gaps.

**Acceptance Criteria:**

- **AC-006.1:** On completion the agent shall be prompted to verify its output against the acceptance criteria in scope.
- **AC-006.2:** The prompt shall require the agent to confirm the artifact follows its template sections where one applies.
- **AC-006.3:** The prompt shall require the agent to confirm a scoped commit was made, every service and store it booted was stopped or named as still live, and status was left to `$status-update`.
- **AC-006.4:** When the agent cannot verify an item, it shall state the gap explicitly rather than omitting it. Silence shall not read as a pass.
