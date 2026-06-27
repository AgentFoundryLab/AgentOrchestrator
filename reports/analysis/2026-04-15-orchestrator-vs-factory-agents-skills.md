# Orchestrator vs Factory Agents and Skills

Date: 2026-04-15

Current comparison is between `orchestrator/package/{agents,skills}` and the active Factory APM package in `factory/.apm/{agents,skills}`.

## Agents

| Orchestrator | Factory | Status | Orchestrator role | Factory role | Main delta |
|---|---|---|---|---|---|
| `business-analyst` | `business-analyst` | Retained, repurposed | PRD generation, domain docs, HITL via `/hitl` | Refinery authoring for Product Overview, Feature Requirements, Technical Requirements | Shift from single `PRD.md` model to Refinery document set in `artifacts/refinery/` |
| `architect` | `architect` | Retained, repurposed | `ARCHITECTURE.md`, ADR files, TDR separation | Foundry blueprint authoring: Foundation, Container, Component, Feature Blueprints, System Diagrams | Shift from standalone architecture docs/ADR files to blueprint-centric design with ADRs embedded in blueprints |
| `project-manager` | `planner` | Renamed, repurposed | ROADMAP/BACKLOG/task-detail planning | Work Orders and optional Implementation Plans in `artifacts/planner/` | Shift from milestone/backlog hierarchy to Planner work-order model |
| `developer` (`jarvis.developer`) | `developer` | Retained, narrowed | Implements backlog/task-detail against architecture docs | Implements Work Orders against linked blueprints and requirements | Execution source changed from BACKLOG/task-detail to Work Order + Implementation Plan + linked Foundry/Refinery artifacts |
| `validator` | `validator` | Retained, repurposed | Validate against backlog/task-detail/PRD | Validate against Work Order first, then linked blueprints and requirements | Validation contract now starts from Planner artifacts, not backlog summaries |
| `deployer` | none | Dropped | Deployment/release execution | none | Not migrated into Factory APM |
| `tech-writer` | none | Dropped | End-user/project documentation | none | Not migrated into Factory APM |

## Skills

| Orchestrator skill | Factory skill | Status | Orchestrator contract | Factory contract | Main delta |
|---|---|---|---|---|---|
| `spec` | `spec` | Retained, repurposed | Generate `docs/architecture/PRD.md` | Generate/update Refinery docs in `artifacts/refinery/` | PRD-only flow replaced by Refinery doc taxonomy |
| `design` | `design` | Retained, repurposed | Generate `ARCHITECTURE.md`, ADRs, technical docs | Generate/update Foundry blueprints and diagrams | Architecture output moved into Foundry templates |
| `plan` | `plan` | Retained, repurposed | ROADMAP, BACKLOG, task-detail docs | Work Orders and optional Implementation Plans | Planning output fully switched to Planner templates |
| `implement` | `implement` | Retained, repurposed | Implement backlog task/task-detail | Implement Planner Work Order | Primary execution contract changed |
| `validate` | `validate` | Retained, repurposed | Validate backlog task + PRD | Validate Work Order + upstream Foundry/Refinery | Validation source of truth changed |
| `hitl` | none | Dropped | Shared structured user-question protocol | Replaced inline with `AskUserQuestion` | No separate skill now |
| `onboard` | none | Dropped | Extra architect support/context bootstrap | none | Removed from active Factory package |
| `analyse` | none | Not migrated | Investigation/analysis helper | none | Not present |
| `deploy` | none | Not migrated | Deployment workflow | none | Not present |
| `distill` | none | Not migrated | Summarization/distillation | none | Not present |
| `document` | none | Not migrated | Documentation writing | none | Not present |
| `optimize` | none | Not migrated | Optimization workflow | none | Not present |
| `orchestrate` | none | Not migrated | Meta-orchestration | none | Not present |
| `reflect` | none | Not migrated | Reflection workflow | none | Not present |
| `reflexion` | none | Not migrated | Reflection/self-check workflow | none | Not present |
| `research` | none | Not migrated | Research workflow | none | Not present |
| `review` | none | Not migrated | Review workflow | none | Not present |

## Cross-Cutting Changes

| Area | Orchestrator | Factory |
|---|---|---|
| User questioning | `/hitl` skill + `QUESTIONS` block | direct `AskUserQuestion` usage in each agent |
| Hooks | Claude hook blocks on agents | removed |
| Artifact model | `docs/architecture`, `docs/objectives`, `docs/development`, `docs/knowledge` | `artifacts/refinery`, `artifacts/foundry`, `artifacts/planner`, `artifacts/validator` |
| Architecture decisions | standalone ADR files | ADR sections inside Foundry blueprints |
| Planning unit | roadmap/backlog/task | work order + optional implementation plan |
| Validation basis | backlog/task-detail plus PRD | work order first, then linked requirements/blueprints |

## Hard Truth

Factory currently preserves only the 5 core execution roles and 5 core skills. Everything else from orchestrator is either intentionally dropped or not yet migrated.
