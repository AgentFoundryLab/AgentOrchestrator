# Feature Requirements: Workflow Depth

## Overview

Not every request deserves the same ceremony. A typo fix and a new subsystem both need implementation, validation, a security pass, and a status record — but only one of them needs requirements, blueprints, and a plan first. Workflow depth is the mechanism that scales the planning stages to the work while leaving the delivery gates fixed.

The fixed part is the point. Depth selection can drop planning; it can never drop the scoped commit, the focused validation, the security gate, or the status record.

## Terminology

- **Depth**: which planning stages precede delivery — Full, Medium, Light, or Direct-fix.
- **Delivery chain**: `$implement` → `$validate` → `$security-review` → `$status-update`. Present at every depth.
- **Direct-fix**: delivery run against an existing `ISS`/`TD` with no new `WO` and no planning run.

## Requirements

### REQ-004: Complexity-scaled workflow depth with a fixed delivery chain

**User Story:** As a user, I want the workflow to scale to the work, so that a small change is not buried in planning ceremony and a large one is not started without it.

**Acceptance Criteria:**

- **AC-004.1:** Depth definitions shall live in `package/workflows/`, with `$orchestrate` owning selection; a depth shall remain usable when no workflow document is present.
- **AC-004.2:** Each planning stage shall produce a versioned artifact in the target repository.
- **AC-004.3:** `$orchestrate` shall score complexity, propose a depth, and confirm it with the user before starting.
- **AC-004.4:** Artifact templates shall install to the runtime root and shall not overwrite an existing file at the destination.
- **AC-004.5:** The delivery chain shall run at every depth. Selecting a shallower depth shall drop planning stages only.
- **AC-004.6:** A diagnosed, bounded defect shall be deliverable as Direct-fix against its own `ISS`/`TD`, with no `WO` minted.
