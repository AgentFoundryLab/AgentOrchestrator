# System Diagram Template

Use this template for a single focused architecture or flow diagram in Foundry.

## Diagram Summary

Summarize what the diagram explains, why it matters, and the audience who should use it.

## Scope

- Systems, containers, or flows represented in the diagram
- Explicit exclusions to keep the diagram focused

## Diagram

Choose the Mermaid type that matches the intent of the diagram:

- `C4Container` for system/container boundaries and external dependencies
- `C4Component` for component structure inside a container or capability
- `flowchart` for request flow, orchestration, and control flow
- `stateDiagram-v2` for lifecycle or state transitions
- `erDiagram` for data relationships

```mermaid
C4Container
    title Example Platform Diagram

    Person(user, "User")
    System_Boundary(product, "Product") {
        Container(web, "Client App", "React", "Renders the UI")
        Container(api, "API Server", "Node.js", "Handles business logic")
        ContainerDb(db, "Postgres", "PostgreSQL", "Stores product data")
    }

    Rel(user, web, "Uses")
    Rel(web, api, "Calls", "HTTPS/JSON")
    Rel(api, db, "Reads and writes", "SQL")
```

## Notes

- Clarify important paths, assumptions, and interpretation rules

## Source Blueprints

- @Foundation Blueprint or @Feature Blueprint that this diagram supports
