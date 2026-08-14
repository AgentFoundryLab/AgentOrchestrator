# Agent with Skill Injection Pattern

```
+==========================================================================+
|                    AGENT + SKILL STRUCTURE                                |
+==========================================================================+

+-------------------------------------------------------------------------+
|  .claude/agents/jarvis/business-analyst.md                               |
+-------------------------------------------------------------------------+
|                                                                          |
|  FRONTMATTER (agent metadata)                                           |
|  +--------------------------------------------------------------------+ |
|  | name: business-analyst                                              | |
|  | description: Refinery requirements authoring                        | |
|  | skills:                                                              | |
|  |   - spec                    # <- Skill content INJECTED at spawn    | |
|  | hooks:                                                              | |
|  |   SubagentStop:                                                     | |
|  |     - type: command                                                 | |
|  |       command: "./.claude/hooks/scripts/remind-validate.sh"         | |
|  |     - type: command                                                 | |
|  |       command: "./.claude/hooks/scripts/remind-agent-learn.sh"        | |
|  +--------------------------------------------------------------------+ |
|                                                                          |
|  BODY (minimal - skill provides full instructions)                      |
|  +--------------------------------------------------------------------+ |
|  | You are a Business Analyst responsible for requirements            | |
|  | authoring: FRD and TRD.                                            | |
|  |                                                                      | |
|  | ## Boundaries                                                        | |
|  | - Will: Generate PRDs, define acceptance criteria, clarify reqs    | |
|  | - Won't: Write code, make architectural decisions                   | |
|  +--------------------------------------------------------------------+ |
|                                                                          |
+-------------------------------------------------------------------------+

                              +

+-------------------------------------------------------------------------+
|  .claude/skills/jarvis/spec/SKILL.md                                     |
+-------------------------------------------------------------------------+
|                                                                          |
|  FRONTMATTER (skill metadata)                                           |
|  +--------------------------------------------------------------------+ |
|  | name: spec                                                          | |
|  | description: Generate FRD/TRD from an idea or gap                   | |
|  | argument-hint: <idea or requirements>                               | |
|  | context: fork                # <- Triggers agent spawn              | |
|  | agent: business-analyst      # <- Target agent for injection        | |
|  +--------------------------------------------------------------------+ |
|                                                                          |
|  BODY (full instructions - INJECTED into agent context)                 |
|  +--------------------------------------------------------------------+ |
|  | # /spec Skill                                                        | |
|  |                                                                      | |
|  | Generate feature and technical requirements from the input.        | |
|  |                                                                      | |
|  | ## Input                                                             | |
|  | $ARGUMENTS - idea, requirements, or context                         | |
|  |                                                                      | |
|  | ## Process                                                           | |
|  | 1. Analyze the input for scope and complexity                       | |
|  | 2. Identify stakeholders and user personas                          | |
|  | 3. Extract functional requirements                                  | |
|  | 4. Define acceptance criteria for each requirement                  | |
|  | 5. Identify non-functional requirements                             | |
|  | 6. Generate user stories                                            | |
|  | 7. Flag open questions for user                                     | |
|  |                                                                      | |
|  | ## Output                                                            | |
|  | Write to: docs/requirements/FRD-<SCOPE>-NNN.md                      | |
|  +--------------------------------------------------------------------+ |
|                                                                          |
+-------------------------------------------------------------------------+

AGENT: Minimal wrapper (persona + hooks + skills: [spec])
SKILL: Full instructions (INJECTED into agent, not invoked at runtime)
```

## Related

- [ADR-FND-004: Skill-Agent Invocation Paths](../ADR/ADR-FND-004.md)
