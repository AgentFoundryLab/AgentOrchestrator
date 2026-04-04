# Multi-Agent Orchestration: Unified Observability in BYOL Systems

This document details the critical challenges and architectural solutions for achieving unified, end-to-end observability in a Bring-Your-Own-License (BYOL) multi-agent orchestration setup.

## The Core Problem: Disconnected Traces

When an Orchestrator invokes an external agent running in a separate process, the OpenTelemetry (OTEL) traces become fragmented. The orchestrator's trace ends when it sends the request, and the agent starts a new, disconnected trace. This "black box" view makes it impossible to analyze the full lifecycle of a request, hindering debugging, performance tuning, and advanced meta-optimization.

## The Solution: OpenTelemetry Trace Context Propagation

The established solution is **Trace Context Propagation**, based on the W3C Trace Context standard. This involves passing a `traceparent` string from the caller (Orchestrator) to the callee (Agent), allowing the agent's OTEL SDK to continue the existing trace instead of starting a new one.

In a BYOL system, this mechanism must be explicitly implemented. Below are two architectural patterns for achieving this.

---

## Option 1: Hybrid A2A-MCP Architecture (Decoupled)

This architecture is ideal for systems where the orchestrator and agents are highly decoupled, communicating as peers via the **A2A (Agent2Agent Protocol)**. A protocol bridge is used to translate A2A messages into **MCP (Model Context Protocol)** commands that CLI agents understand.

### Architecture Diagram

```
[Orchestrator (A2A)] --- (A2A Msg + Trace) --> [A2A-MCP Bridge] --- (MCP Cmd + Trace) --> [Custom Adapter (MCP)] --- (Env Var + Trace) --> [Instrumented Agent]
```

### Trace Propagation Flow:

1.  **Orchestrator (A2A Client):**
    *   Starts a root OTEL span for a workflow.
    *   **Injects** the `traceparent` context into the metadata of the **A2A message** sent to the bridge.

2.  **A2A-MCP Bridge:**
    *   Acts as a simple protocol translator.
    *   Receives the A2A message.
    *   Constructs an MCP command for the agent.
    *   **Faithfully passes the `traceparent`** from the A2A metadata into the MCP command's metadata.

3.  **Custom Observability-Aware Adapter (MCP Server):**
    *   This is your custom-developed component.
    *   Receives the MCP command from the bridge.
    *   **Extracts** the `traceparent` from the metadata.
    *   Uses its OTEL SDK to start a new span that is a child of the received `traceparent`.
    *   **Spawns the CLI agent process**, injecting the `traceparent` into the agent's **environment variables** (e.g., `OTEL_TRACEPARENT`).

4.  **Instrumented CLI Agent:**
    *   Must have an OTEL SDK.
    *   On startup, the SDK automatically reads the `OTEL_TRACEPARENT` environment variable and configures its tracer to continue the trace.
    *   All internal operations (tool calls, LLM requests) now generate spans that are correctly nested within the end-to-end trace.

---

## Option 2: Direct ACP Architecture (Simpler Coupling)

This architecture is suitable when the orchestrator can act as a direct **ACP (Agent Client Protocol) Client**, managing the lifecycle and sessions of its agents.

**IMPORTANT**: This refers to the **Zed Industries ACP standard** for orchestrator-to-agent communication, NOT to be confused with the defunct IBM Agent Communication Protocol (which was for agent-to-agent communication and merged with A2A in August 2025).

This eliminates the need for a protocol translation bridge, simplifying the overall architecture.

### Architecture Diagram

```
[Orchestrator (ACP Client)] --- (Spawn Process with Env Var + Trace) --> [Instrumented Agent (ACP Server)]
```

### Trace Propagation Flow:

1.  **Orchestrator (ACP Client):**
    *   Starts a root OTEL span for a workflow.
    *   Prepares to launch a new agent for a task or session.
    *   **Injects** the current `traceparent` context directly into the **environment variables** of the agent process it is about to spawn.
    *   Alternatively, the context could be passed in the initial `POST /session/new` ACP request metadata using the `_meta` field, if the agent is designed to handle it. The environment variable approach is generally more robust and works universally.

2.  **Instrumented CLI Agent (ACP Server):**
    *   The agent process starts, launched by the orchestrator.
    *   Its integrated OTEL SDK **reads the `OTEL_TRACEPARENT` environment variable** on startup.
    *   It immediately configures its tracer to continue the trace initiated by the orchestrator.
    *   All subsequent internal operations are now part of the unified trace.

---

## Comparison of Architectures

The decision between these two patterns depends on the desired level of coupling and architectural complexity.

| Aspect | Hybrid A2A-MCP Architecture | Direct ACP Architecture |
| :--- | :--- | :--- |
| **Coupling** | **Low (Decoupled)** | **High (Tightly Coupled)** |
| **Complexity** | **High** (Orchestrator + Bridge + Adapter + Agent) | **Low** (Orchestrator + Agent) |
| **Flexibility** | **High**. Orchestrator speaks one protocol (A2A) to a generic bridge. Agents can be swapped easily behind the adapter. | **Low**. Orchestrator must contain agent-specific logic for lifecycle management and ACP communication. |
| **Protocol** | Orchestrator: A2A. Bridge -> Agent: MCP. | Orchestrator -> Agent: ACP (Zed). |
| **Custom Dev** | Requires an "Observability-Aware Adapter" that is also an MCP server. | Requires the Orchestrator to have ACP client logic and agent lifecycle management capabilities. |
| **Best For** | Heterogeneous systems, peer-to-peer agent collaboration (L3 swarms), and architectures where the orchestrator should not be concerned with agent specifics. | Simpler, client-server workflows (L1/L2) where the orchestrator's primary role is to directly control a set of known agents. |

---

## Additional Observability Considerations

### Agent-to-Agent (A2A) Trace Propagation

When using **L3 swarm architectures** where agents communicate directly via the A2A protocol (peer-to-peer), trace context must also be propagated through A2A messages:

**A2A Message Metadata:**
```json
{
  "message": {
    "role": "agent",
    "parts": [{"text": "Can you handle the database query?"}]
  },
  "_meta": {
    "traceparent": "00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01"
  }
}
```

**Key Points:**
- A2A supports custom metadata via `_meta` field on messages
- Sending agent injects `traceparent` in `_meta`
- Receiving agent extracts and continues trace
- Requires both agents to have OTEL instrumentation

**Note**: This is particularly important for L3 choreography patterns where agents autonomously coordinate via A2A without orchestrator mediation.

---

### ACP Trace Propagation via _meta Field

The Zed ACP protocol supports custom metadata via the `_meta` field in all protocol messages. This can be leveraged for trace propagation:

**Option A: Environment Variable (Recommended)**
```python
# Orchestrator spawns agent with traceparent in env
env = {
    "OTEL_TRACEPARENT": current_traceparent,
    "OTEL_EXPORTER_OTLP_ENDPOINT": "http://collector:4318"
}
subprocess.Popen(["gemini", "--experimental-acp"], env=env)
```

**Option B: ACP _meta Field (Advanced)**
```json
POST /session/new
{
  "cwd": "/project",
  "mcpServers": [...],
  "_meta": {
    "observability": {
      "traceparent": "00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01",
      "tracestate": "congo=t61rcWkgMzE"
    }
  }
}
```

**Agent implementation must**:
- Check for `_meta.observability.traceparent` in session creation
- Initialize OTEL tracer with parent context
- Propagate to all internal spans

---

### Unified OTEL Collector Configuration

For both architectures, configure agents to export to a centralized OTEL collector:

```yaml
# otel-collector-config.yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

processors:
  batch:
    timeout: 10s
    send_batch_size: 1024

  # Enrich spans with protocol metadata
  attributes:
    actions:
      - key: protocol.type
        action: upsert
        from_attribute: net.protocol.name  # "acp" or "a2a"
      - key: agent.id
        action: upsert
        from_attribute: service.name

exporters:
  # Export to your observability backend
  otlp/jaeger:
    endpoint: jaeger:4317

  otlp/datadog:
    endpoint: datadog-agent:4317

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [attributes, batch]
      exporters: [otlp/jaeger, otlp/datadog]
```

---

### Protocol-Specific Instrumentation

**ACP Events to Instrument:**
- `POST /agent/initialize` - Capability negotiation
- `POST /session/new` - Session creation
- `POST /session/prompt` - User prompt processing
- `POST /session/cancel` - Cancellation requests
- Agent-to-orchestrator notifications (streaming)

**A2A Events to Instrument:**
- Agent Card discovery
- Task creation and state transitions
- Message exchanges (agent-to-agent)
- Artifact generation
- Context propagation

**MCP Events to Instrument:**
- Tool discovery
- Tool execution
- Resource access
- Prompt/completion pairs

---

## Implementation Checklist

### For ACP-Based Orchestration:

- [ ] Orchestrator injects `OTEL_TRACEPARENT` env var when spawning agents
- [ ] OR orchestrator includes traceparent in `POST /session/new` `_meta` field
- [ ] Agents configured with OTEL SDK (auto-instrumentation or manual)
- [ ] Agents read env var or `_meta` on startup and continue trace
- [ ] All ACP method calls (initialize, prompt, etc.) emit spans
- [ ] Spans tagged with `protocol.type=acp`, `agent.id`, `session.id`

### For A2A-Based Peer Communication:

- [ ] Agents inject `traceparent` in A2A message `_meta` field
- [ ] Receiving agents extract and continue trace from `_meta`
- [ ] A2A task state transitions emit spans
- [ ] Message exchanges between agents are traced
- [ ] Spans tagged with `protocol.type=a2a`, `sending_agent.id`, `receiving_agent.id`

### For Hybrid Architectures:

- [ ] Orchestrator uses ACP for agent lifecycle (with trace propagation)
- [ ] Agents use A2A for peer communication (with trace propagation)
- [ ] Both ACP and A2A events flow to unified OTEL collector
- [ ] Trace IDs remain consistent across protocol boundaries
- [ ] Observability backend can correlate ACP + A2A spans

---

## Example: End-to-End Trace Visualization

**Scenario**: L3 Swarm - Orchestrator spawns 3 agents via ACP, agents coordinate via A2A

```
Trace ID: 4bf92f3577b34da6a3ce929d0e0e4736

[Orchestrator] workflow.execute (root span)
  │
  ├─[ACP] POST /session/new → Agent A (span: acp.session.create)
  │   └─[Agent A] internal.reasoning (span: agent.reasoning)
  │       └─[A2A] Agent A → Agent B: request_database_query (span: a2a.message.send)
  │           └─[Agent B] database.query (span: agent.tool.execution)
  │               └─[A2A] Agent B → Agent A: query_result (span: a2a.message.response)
  │
  ├─[ACP] POST /session/new → Agent C (span: acp.session.create)
  │   └─[Agent C] file.analysis (span: agent.tool.execution)
  │
  └─[ACP] aggregate_results (span: orchestrator.aggregation)
```

**Benefits**:
- Single trace ID across all agents and protocols
- Full visibility into ACP orchestrator-agent interactions
- Full visibility into A2A peer-to-peer agent collaboration
- Ability to identify bottlenecks, failures, and optimization opportunities

---

## Conclusion

Achieving deep, unified observability in a BYOL multi-agent system is not an out-of-the-box feature but a deliberate engineering choice. It requires implementing a trace context propagation mechanism across protocol boundaries.

*   The **Hybrid A2A-MCP architecture** offers maximum flexibility and decoupling at the cost of higher complexity and more moving parts. Best for L3 swarm architectures.
*   The **Direct ACP architecture** offers simplicity and fewer components at the cost of tighter coupling between the orchestrator and the agents. Best for L1/L2 orchestration patterns.

**Protocol Clarity**:
- **ACP (Zed Industries)**: Orchestrator ↔ Agent communication (hub-spoke)
- **A2A (Linux Foundation)**: Agent ↔ Agent communication (peer-to-peer)
- **MCP (Anthropic)**: Agent ↔ Tools/Resources (client-server)

**Historical Note**: IBM's Agent Communication Protocol (also called "ACP") was merged into A2A in August 2025 and is now defunct. This document refers exclusively to **Zed's Agent Client Protocol** when using the term "ACP".

Both architectural approaches are viable. The correct choice depends on the specific requirements of the Orchestrator system, weighing the trade-offs between flexibility, simplicity, and the coordination level (L1/L2/L3) you're targeting.
