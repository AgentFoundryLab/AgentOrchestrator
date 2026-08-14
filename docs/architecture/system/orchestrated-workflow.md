# Orchestrated Workflow Sequence

```
/ORCHESTRATE         BA AGENT (with /spec injected)                  HOOKS
     |                   |                                             |
     | Assess: FULL      |                                             |
     | workflow needed   |                                             |
     |                   |                                             |
     | Task tool         |                                             |
     | (subagent: BA)    |                                             |
     | BA has skills:    |                                             |
     |   [spec]          |                                             |
     |------------------>|                                             |
     |                   |                                             |
     |                   | Agent spawns with /spec                     |
     |                   | content INJECTED into context               |
     |                   |                                             |
     |                   | Executes FRD/TRD authoring                  |
     |                   | (using injected instructions)               |
     |                   |----+                                        |
     |                   |    |                                        |
     |                   |<---+                                        |
     |                   |                                             |
     |                   | FRD/TRD artifacts created                   |
     |                   |                                             |
     |                   | Agent completes ---------------------------->|
     |                   |                                             |
     |                   |                              SubagentStop   |
     |                   |<--------------------------------------------|
     |                   |                                             |
     |                   | remind-validate.sh                          |
     |                   |---+                                         |
     |                   |   | Self-validation                         |
     |                   |<--+                                         |
     |                   |                                             |
     |                   | remind-agent-learn.sh                         |
     |                   |---+                                         |
     |                   |   | Report signal                           |
     |                   |<--+                                         |
     |                   |                                             |
     |   Result+FRD/TRD  |                                             |
     |<------------------|                                             |
     |                   |                                             |
     | Next: Task tool   |                                             |
     | (subagent: Arch)  |                                             |
     |------------------>|...                                          |
```

## Related

- [Workflow Engine](workflow-engine.md)
- [ADR-FND-001: Hook Behavior Pattern](../ADR/ADR-FND-001.md)
