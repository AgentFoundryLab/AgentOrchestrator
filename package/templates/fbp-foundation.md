# Foundation Blueprint Template

Use this template for project-wide technical context that applies across multiple features.

## Foundation Summary

Summarize the cross-cutting architectural concern, why it exists, and which parts of the system it governs.

## Scope

- Containers, capabilities, or features governed by this foundation
- Explicit boundaries and exclusions

## Standards and Decisions

- Technology choices
- Security, observability, and deployment standards
- Naming or structural conventions

## Shared Contracts

### Key Contracts

- Cross-cutting invariants and correctness rules

### Integration Boundaries

- Ownership boundaries and cross-system expectations

## Architecture Decision Records

> ADRs are standalone files at `docs/architecture/ADR/ADR-FND-NNN.md`, never inline.
> Ids are immutable and allocated by the orchestrator (or the primary session when working solo) —
> read `docs/architecture/ADR/README.md` for the highest existing `ADR-FND` and take the next.
> Author the file with a `Blueprint:` back-link plus `Context`/`Decision`/`Consequences`, add it to the
> ADR index, and cross-reference it here:

- [ADR-FND-NNN](../ADR/ADR-FND-NNN.md) — Decision title
