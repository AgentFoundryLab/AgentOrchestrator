---
name: spec
description: Generate feature and technical requirements documents by eliciting and confirming explicit requirements, resolving implicit or conflicting constraints, and drafting shared-understanding-backed specs from an idea or feature request
argument-hint: idea, feature, requirement id, or requirement gap
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - WebSearch
  - AskUserQuestion
context: fork
agent: business-analyst
---

# /spec - Requirements

Create or update requirements documents under `docs/requirements/`.

## Purpose

Turn rough input into confirmed, testable requirements:
- **Feature Requirements Documents** — `FRD-<SCOPE>-NNN.md`, holding `REQ-NNN` with parent-scoped `AC-NNN.n`
- **Technical Requirements Documents** — `TRD-<SCOPE>-NNN.md`, holding `TR-NNN` with parent-scoped `TRC-NNN.n`
- Refreshed `REQUIREMENTS.md` index

## Document and id grammar

| | Document | Records inside |
|---|---|---|
| Feature | `docs/requirements/FRD-<SCOPE>-NNN.md` | `REQ-NNN`, `AC-NNN.n` |
| Technical | `docs/requirements/TRD-<SCOPE>-NNN.md` | `TR-NNN`, `TRC-NNN.n` |
| Index | `docs/requirements/REQUIREMENTS.md` | table of every `REQ`/`TR` |

- The `<SCOPE>` code is a short uppercase mnemonic for the delivery scope (`INS` installer, `ORC` orchestration, `POL` policy). **It lives in the filename only — never inside a record id.** Ids are flat and numeric.
- One document per scope per concern. A second document for the same scope takes the next `NNN`.
- `REQ` and `TR` counters are independent and global across all documents — `REQ-014` appears in exactly one FRD, whichever one owns it.
- `AC`/`TRC` are parent-scoped: `AC-014.1` belongs to `REQ-014` and nowhere else.
- Product framing — business problem, personas, success metrics — stays in `docs/objectives/VISION.md` and `BLUEPRINT.md`. Do not create a product-overview document; those two already own it.

## Inputs

- `$ARGUMENTS`: idea, feature request, requirement id, or gap to fix
- Existing requirements under `docs/requirements/`, and the index at `REQUIREMENTS.md`
- Product framing at `docs/objectives/VISION.md` and `BLUEPRINT.md`
- Templates from the active runtime root's `templates/` directory (`frd.md`, `trd.md`, `vision.md`)
- Uploaded artifacts and indexed codebase context when available

## Outputs

- Create/update `FRD-*` and `TRD-*` documents under `docs/requirements/`
- Refresh the `REQUIREMENTS.md` index rows for every record touched
- Update `VISION.md` / `BLUEPRINT.md` only when product scope itself shifted

## Id allocation

Requirement ids are immutable and never recycled. **Under `$orchestrate`, ids come from the brief** — the orchestrator is the sole allocator so parallel lanes cannot claim the same number. Working solo, read `REQUIREMENTS.md` for the highest existing `REQ`/`TR` and take the next. If a delegated slice needs an id the brief did not provide, return a blocker naming it rather than minting.

Every record carries its identity fields at creation: `category`, `scope`, `title`, and `priority` (`P0`–`P3`). `category` and `scope` must come from the project's recorded vocabulary — a new value is a deliberate extension, recorded before first use, never an inline invention.

## Delegation Guidance

- On a delegated requirements slice: follow the brief's scope, file/surface ownership, exclusions, validation expectations; do not expand scope or assume orchestration ownership.
- Return: changed files, ids authored, checks run, blockers, skipped scope, residual risk.

## Workflow

### 1. Choose the initialization mode
- Existing product or artifact-heavy input → reverse-engineer and refine
- New product or feature idea → start fresh
- Mixed state → preserve valid existing intent, rewrite only weak parts

### 2. Classify the work
Choose the smallest valid document set:
- Feature behavior → `REQ` + `AC` in the owning FRD for that scope
- Cross-cutting constraint, stack/vendor/platform/verification commitment → `TR` + `TRC` in the owning TRD
- Product-wide framing → `VISION.md` / `BLUEPRINT.md`, not a requirements document

The split is not cosmetic: feature requirements describe business capability and user-visible behavior; technical requirements carry mechanism. When removing implementation detail from a feature requirement, **move it to a TRD** rather than deleting it.

### 3. Read current context
- Reuse existing requirements before adding new ones — check `REQUIREMENTS.md` for a record that already covers the ask
- Pull context from uploaded artifacts and indexed codebase when it sharpens product intent
- Extract explicit requirements, implicit expectations, conflicts, missing terminology, constraint-like commitments
- Do not draft final artifacts while correctness-critical scope, intent, acceptance, or constraint ambiguity remains unresolved

### 4. Resolve requirements through Q&A
Before drafting final requirements:
- Elicit and confirm all explicit requirements from user input and existing artifacts
- Surface implicit, conflicting, underspecified, or constraint-like requirements needed for testable acceptance criteria
- Drive concise Q&A until shared understanding is reached: every correctness-critical requirement confirmed, intentionally excluded, or captured as a labeled assumption
- Ask grouped, high-signal questions with suggested defaults when defensible from context
- Confirm resolved understanding before writing when the change is broad, ambiguous, safety-sensitive, compliance-sensitive, or spans multiple documents
- If enough is known to draft safely, proceed with clearly labeled assumptions and report remaining open questions in the response
- Do not ask about implementation choices unless they are true product, policy, operational, integration, data, auth, performance, or compliance constraints

### 5. Draft with the correct template
- **FRD** sections exactly: `Overview`, `Terminology`, `Requirements`
- **TRD** sections exactly: `Overview`, `Scope`, `Constraints`, `Standards and References`, `Verification`
- Write the FRD `Overview` as 1-2 narrative paragraphs explaining the user problem and value, without implementation detail
- Define only feature-specific ambiguous terms in `Terminology`; omit the section when nothing needs defining

### 6. Keep requirements clean
- User-centered, atomic, independently testable, implementation-agnostic
- Every `AC` states explicit observable behavior: "When ..., the system shall ..."
- Every `TRC` carries something verifiable, and the `Verification` section says how and at which layer
- When the objective names a reference implementation or demands parity ("1:1", "match the reference UI/flow"), write explicit reference-parity criteria — flow completeness (every step of the named journey) and visual/style parity (bound to the named design system or reference screens), each validated against the reference itself. Behavioral criteria derived from the reference are not a substitute; if parity is deliberately out of scope, say so in the requirement rather than omitting it.
- No architecture or task decomposition
- Shape feature boundaries so the Architect can map them to blueprints cleanly

### 7. Apply the requirements-writing rules
- **Ids are immutable.** Never renumber or recycle — `REQ-003` stays `REQ-003` after `REQ-002` is dropped. A retired record keeps its id and takes `Decommissioned` or `Superseded`, with no date, actor, or reason in the requirement body.
- **Present tense, as if authored today.** No change history, dated parentheticals, rationale-of-change, or "was X, now Y" inside a requirement. A criterion is the target to test against; its history is the commit log and its state is a status field. The same holds for the prose around them — a document that chronicles its own edits carries the same fact three times and grows on every touch.
- **Citation runs one way.** Cite `REQ`/`AC`/`TR`/`TRC` and nothing else in a requirement body. An `FBP`, `ADR`, `WO`, `ISS`, `REG`, `TD`, or `FB` id, or a pointer to a rules file, is a flow violation: delete it, never re-point it at a newer record. The downstream artifact names the requirement it serves; the requirement stays silent.
- **Titles** are concise labels ≤ 80 chars, rephrased never truncated. `AC`/`TRC` titles in the index are single-line handles; the criterion prose lives in the document.
- Split, merge, or nest requirements only when it improves product clarity and downstream blueprint mapping.

### 8. Refresh the index
Update `docs/requirements/REQUIREMENTS.md` for every record touched. One row per `REQ`/`TR`:

```md
| REQ | Area | Title | Category | Scope | Priority | Status |
| --- | --- | --- | --- | --- | --- | --- |
| REQ-014 | orchestrator | Multi-runtime skill install | feature | installer | P1 | Implemented |
```

New records enter at `Not Implemented`. **Never set an implementation status here** — `$status-update` owns every status value. The index is the lookup surface; the document is the prose.

## Q&A Guardrails

- Prefer one focused round of questions over many small interruptions
- Ask at most 3-7 questions per round unless the user explicitly requests exhaustive discovery
- Ask only questions that can change requirement content, acceptance criteria, scope boundaries, terminology, success metrics, compliance, data/auth, integrations, or technical constraints
- Do not block on nice-to-have details; label assumptions and continue when downstream planning stays safe
- Escalate to another round only when ambiguity would make requirements incorrect, untestable, unsafe, contradictory, or materially incomplete

## Requirements Discovery Checklist

Before finalizing, verify whether the request needs clarification on:
- Users/personas and permissions
- User goals, outcomes, and success metrics
- In-scope and out-of-scope behavior
- Happy paths, edge cases, empty/error states, and failure handling
- Data inputs, outputs, retention, privacy, and audit needs
- Auth, roles, access control, and security constraints
- External integrations and dependency behavior
- Compliance, policy, legal, or operational constraints
- Performance, reliability, availability, and support expectations
- Terminology and domain-specific definitions
- Migration, rollout, compatibility, and deprecation concerns
- Conflicts with existing requirements or documented product behavior

## Template References

From the active runtime root's `templates/` directory:
- `frd.md`
- `trd.md`
- `vision.md`

## Validation Checklist

- [ ] Correct document type chosen — feature behavior in an FRD, mechanism in a TRD, product framing in objectives
- [ ] Document filename carries the scope code; no record id does
- [ ] New content fits the template sections exactly
- [ ] Every `AC` states observable behavior; every `TRC` is verifiable and its verification named
- [ ] Reference-parity objectives carry explicit flow-completeness and visual-parity criteria bound to the named reference, or parity is explicitly scoped out
- [ ] Explicit requirements from the request are captured or intentionally excluded
- [ ] Implicit requirements and constraints are confirmed or labeled as assumptions
- [ ] Conflicts with existing requirements are resolved or called out
- [ ] No id renumbered or recycled; no downstream id leaked into a requirement body
- [ ] Every record carries `category`, `scope`, `title`, `priority` from the recorded vocabulary
- [ ] `REQUIREMENTS.md` rows refreshed for every record touched, with no status invented
