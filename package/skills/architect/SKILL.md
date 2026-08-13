---
name: architect
description: Create Foundry blueprints and architecture decision records from requirements
argument-hint: requirement id, blueprint id, or architecture focus area
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Bash
  - WebSearch
  - AskUserQuestion
context: fork
agent: architect
---

# /architect - Blueprints and Decisions

Create or update blueprints from requirements.

## Purpose

Transform requirements into:
- **Foundation, Container, and Component Blueprints** — the shared technical substrate
- **Feature Blueprints** — how a feature composes that substrate
- **System Diagrams** — focused visual clarification
- **Architecture Decision Records** — standalone, cross-referenced from the governing blueprint

## Document and id grammar

| Kind | Path | Tier |
|---|---|---|
| Foundation | `docs/architecture/foundation/FBP-FND-NNN.md` | `FND` |
| Container | `docs/architecture/foundation/FBP-FND-NNN.md` | `FND` |
| Component | `docs/architecture/foundation/FBP-FND-NNN.md` | `FND` |
| Feature | `docs/architecture/feature/FBP-FEAT-NNN.md` | `FEAT` |
| System diagram | `docs/architecture/system/<NAME>.md` | `SYS` |
| ADR | `docs/architecture/ADR/ADR-<TIER>-NNN.md` | matches governed blueprint |
| ADR index | `docs/architecture/ADR/README.md` | — |

- `FBP` and `ADR` are **tier-scoped**: `TYPE-<TIER>-NNN`, tier ∈ `SYS` | `FND` | `FEAT`, **one counter per tier**. `foundation`/`container`/`component` → `FND`; `feature` → `FEAT`; `system` → `SYS`.
- `--tier` is the blueprint *family*; the finer `kind` (foundation / container / component / feature / system) stays a field of the record, not part of the id.
- An ADR's tier matches the blueprint it governs. `ADR-FND-004` governs a foundation-family blueprint.
- Non-architectural operational or policy decisions are **TDRs** under `docs/knowledge/decisions/<slug>.md`, not ADRs. Keep the separation strict: an ADR changes system structure or a durable technical contract; a TDR records a choice with local blast radius.

## Inputs

- `$ARGUMENTS`: requirement id (`REQ-014`, `TR-003`), blueprint id, or focus area
- Requirements under `docs/requirements/` and the `REQUIREMENTS.md` index
- Existing blueprints under `docs/architecture/`, and the ADR index
- Domain knowledge under `docs/knowledge/domain/`; prior decisions under `docs/knowledge/decisions/`
- Templates from the active runtime root's `templates/` directory
- Indexed codebase context when available

## Outputs

- Create/update `FBP-*` blueprints under `docs/architecture/{foundation,feature}/`
- Create system diagrams under `docs/architecture/system/`
- Create `ADR-<TIER>-NNN.md` under `docs/architecture/ADR/` and add each to `README.md`
- Create TDRs under `docs/knowledge/decisions/` for non-architectural choices

## Id allocation

`FBP` and `ADR` ids are immutable and never recycled. **Under `$orchestrate`, ids come from the brief** — the orchestrator is the sole allocator, so parallel lanes cannot claim the same number. Working solo, read the ADR index and the blueprint directories for the highest existing id **in that tier** and take the next. If a delegated slice needs an id the brief did not provide, return a blocker naming it rather than minting.

Every blueprint carries `category`, `scope`, `title`, `tier`, and `kind` at creation. Every ADR carries `category`, `scope`, `title`, `tier`, and its one-line decision.

## Delegation Guidance

- On a delegated architecture slice: follow the brief's scope, file/surface ownership, exclusions, validation expectations; do not expand scope or assume orchestration ownership.
- Return: changed files, ids authored, decisions made, blockers, skipped scope, residual risk.

## Workflow

### 1. Read upstream requirements
- Feature requirements (`REQ`/`AC` in an FRD) shape feature blueprints
- Technical requirements (`TR`/`TRC` in a TRD) shape foundations and constraints
- Do not use downstream Work Orders as a design source; route downstream-driven design reconsideration through `$reconcile`

### 2. Establish or update foundations first
- Capture project-wide stack, standards, boundaries, and shared capabilities in Foundation blueprints before detailing any feature
- Anchor reusable technical substrate with Container and Component blueprints
- Domain/data model changes require explicit adversarial validation before downstream planning: challenge cardinality, ownership, lifecycle/status states, source-of-truth, migration/data implications, backwards compatibility, and user-stated invariants
- No hacky workaround, contradicting fallback, alias mapping, lifecycle invention, or on-the-spot schema change may bypass that gate
- Reverse-engineer shared patterns from the codebase when existing implementation already constrains design
- For HTTP/API/network integrations, confirm real endpoint paths, headers, and response shape before specifying contracts

### 3. Choose the blueprint kind
- Cross-cutting architecture → **Foundation Blueprint**
- Deployable/runtime unit → **Container Blueprint**
- Reusable capability → **Component Blueprint**
- Feature composition → **Feature Blueprint**
- Visual clarification → **System Diagram**

### 4. Author in the blueprint format
Use the chosen template's baseline sections **exactly**:

| Kind | Sections |
|---|---|
| Foundation | `Foundation Summary`, `Scope`, `Standards and Decisions`, `Shared Contracts`, `Architecture Decision Records` |
| Container | `Container Summary`, `Infrastructure`, `Entry Points and Boundaries`, `System Contracts`, `Architecture Decision Records` |
| Component | `Capability Summary`, `Core Components`, optional `Data Models`, `System Contracts`, `Architecture Decision Records` |
| Feature | `Feature Summary`, `Component Blueprint Composition`, `Feature-Specific Components`, optional `Data Models`, `System Contracts`, `Architecture Decision Records` |
| System Diagram | `Diagram Summary`, `Scope`, `Diagram`, `Notes`, `Source Blueprints` |

**Structured blocks anchor; prose explains.**

- `component` blocks are the nodes; the relationship paragraphs around them are the edges. A blueprint with blocks and no relationship prose describes parts but no system.
- `model` blocks are for **canonical** models only — one that multiple components read or mutate. A model used by exactly one component is a field of that component, not a block.
- Mention syntax: `#Component` for components, `` `element` `` for elements, `@Document` for documents and platform entities.
- A component defined in any blueprint may be referenced from any other with `#Name`. **Do not redefine a shared component inside a Feature Blueprint** — describe how the feature composes and configures it. Give feature-specific components their own full block.
- `System Contracts` carries the invariants: `Key Contracts` for correctness rules and reliability semantics, `Integration Contracts` / `Integration Boundaries` for APIs, events, payloads, and ownership.
- Reference code by symbol and file path, resolved fresh at read time — never a stored line range that goes stale on the next edit.

### 5. Record decisions as ADRs
- Allocate the next unused id **in the governed blueprint's tier**; never renumber or recycle. A superseded ADR keeps its id, takes `Status: Superseded`, and points at its replacement.
- Author the standalone file from `adr.md`: `# ADR-<TIER>-NNN: Title`, a `Blueprint:` back-link, `Status`, then `Context` / `Decision` / `Consequences`.
- Cross-reference it from the governing blueprint's `Architecture Decision Records` section as `- [ADR-<TIER>-NNN](../ADR/ADR-<TIER>-NNN.md) — Title`. **Never inline the record in the blueprint.**
- Add the row to `docs/architecture/ADR/README.md`.

### 6. Keep alignment tight
- Every requirement in scope needs a traceable technical path through some blueprint
- Feature Blueprints name the requirements document they serve in `Feature Summary`
- Prefer composition-first design and shared capabilities over parallel feature-specific machinery
- Avoid legacy fallback paths unless requirements explicitly demand them
- Add diagrams only when they materially improve clarity
- When code exists, reconcile blueprint drift instead of pretending the implementation doesn't exist

### 7. Choose focused diagram types
- `C4Container` for container boundaries and external dependencies
- `C4Component` for runtime structure inside or across containers
- `flowchart` for feature orchestration and request flow
- `stateDiagram-v2` for state and lifecycle behavior
- `erDiagram` for data relationships

## Template References

From the active runtime root's `templates/` directory:
- `fbp-foundation.md`
- `fbp-container.md`
- `fbp-component.md`
- `fbp-feature.md`
- `fbp-system-diagram.md`
- `adr.md`

## Validation Checklist

- [ ] Correct blueprint kind chosen, authored at the right path, with the right tier in its id
- [ ] Template baseline sections used exactly
- [ ] Every in-scope requirement has a technical path through a blueprint
- [ ] `component` blocks have relationship prose around them; `model` blocks are canonical only
- [ ] Shared components are referenced with `#Name`, not redefined in a Feature Blueprint
- [ ] Contracts, boundaries, and invariants are explicit in `System Contracts`
- [ ] Domain/data model changes include adversarial validation of cardinality, lifecycle, ownership, source-of-truth, migration implications, and rejected fallbacks/aliases/workarounds
- [ ] ADRs are standalone files, cross-referenced from the governing blueprint, listed in the ADR index, never inlined
- [ ] ADR tier matches the blueprint it governs; ADR vs TDR separation is clean
- [ ] No `FBP`/`ADR` id renumbered or recycled
- [ ] Diagrams are focused and use an appropriate Mermaid type
