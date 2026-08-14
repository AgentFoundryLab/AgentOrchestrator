# Component Blueprint: Session Context and Memory

## Capability Summary

Agents start with nothing unless something injects it. This capability covers what the runtime injects at session start, where session evidence accumulates, and what survives as durable knowledge. The distinction it enforces is between *evidence* — transcripts and logs, read-only and never committed — and *knowledge*, authored and versioned.

## Core Components

```component
name: ContextInjector
container: Installed Runtime Root
responsibilities:
	- Injecting `PROJECT_NAME` derived from the working directory as a path slug
	- Injecting the session identifier for skills to reference
	- Making project knowledge discoverable at session start
```

```component
name: SessionEvidence
container: Host Runtime
responsibilities:
	- Accumulating transcripts under the runtime's own session directory
	- Nesting sub-agent transcripts so parent linkage is recoverable
	- Remaining read-only to every skill that reads it
```

```component
name: KnowledgeBase
container: Consuming Repository
responsibilities:
	- Holding authored domain notes, patterns, runbooks, and TDR decisions
	- Staying small and versioned, unlike `#SessionEvidence`
```

`#ContextInjector` runs at the lifecycle boundary `#HookScript` owns. `#SessionEvidence` is written by the host runtime, not by this package — the package only reads it, which is why every consumer treats it as immutable. `#KnowledgeBase` is the only one of the three that enters git.

Conflating evidence with knowledge is the failure this split prevents: it produces a repository full of transcripts and a knowledge base full of noise.

## Data Models

```model
name: SessionRecord
store: Host runtime session directory
description: Read-only evidence a learning pass reconstructs a session graph from.
fields:
	- session_id: string (required)
	- cwd: path (required)
	- parent_session_id: string (nullable — present for a sub-agent transcript)
	- attribution_agent: string (nullable — the sub-agent's role)
constraints:
	- never written by this package
	- never copied into a repository
	- parent linkage recoverable without a field lookup where the runtime nests by directory
```

## System Contracts

### Key Contracts

- Session evidence is read-only and never committed.
- A learning pass reports heuristic session selection as heuristic.
- Project knowledge is authored, never generated from transcripts wholesale.
- Memory providers are optional; absence degrades to documented fallbacks.

### Integration Contracts

- **Host runtime**: owns the session directory layout and the identifiers injected.
- **MCP memory provider**: optional project-scoped store — see `FBP-FND-008`.

## Architecture Decision Records

- [ADR-FND-002](../ADR/ADR-FND-002.md) — Four-tier memory
- [ADR-FND-010](../ADR/ADR-FND-010.md) — Observability architecture
