# Component Blueprint: MCP Integration

## Capability Summary

MCP servers supply capabilities the package does not implement: document retrieval, structural code graphs, memory persistence, web research, browser automation. Every one is optional. The architectural commitment is that a core workflow degrades to a documented fallback rather than failing when a server is absent.

## Core Components

```component
name: RetrievalProvider
container: Host Runtime
responsibilities:
	- Serving indexed markdown retrieval and structural code-graph queries
	- Backing `$qmd` and `$codebase-memory` where present
	- Degrading to text search when absent or when its index is stale
```

```component
name: ResearchProvider
container: Host Runtime
responsibilities:
	- Serving library documentation and web research to `$research`
	- Providing the ground-truth source that keeps external claims verifiable
```

```component
name: MemoryProvider
container: Host Runtime
responsibilities:
	- Persisting project-scoped memory for `#KnowledgeIndex` adjuncts
	- Degrading to versioned memos under `docs/analysis/` when absent
```

Each is a capability class, not a vendor. Naming the class rather than the server is deliberate: a blueprint that hardcodes a vendor becomes wrong when the vendor is swapped, while the contract — "indexed retrieval, falling back to text search" — survives.

Classification is required, recommended, or optional. No recommended or optional provider is a precondition for a core workflow.

## System Contracts

### Key Contracts

- Core operation requires no MCP server configured.
- Retrieval is support, never source of truth — canonical artifacts live in repository paths.
- A stale or missing index is never a reason to skip retrieval; fire the indexing and answer another way.
- A provider's absence produces a documented fallback, never a failed skill.

### Integration Contracts

- **Host runtime**: owns server configuration and lifecycle; the package declares only which capability class a skill prefers.
- **Skills**: name the capability class and its fallback, not a vendor tool signature, wherever a fallback exists.

## Architecture Decision Records

- [ADR-FND-003](../ADR/ADR-FND-003.md) — Minimal MCP footprint
- [ADR-FND-008](../ADR/ADR-FND-008.md) — Multi-provider integration strategy
