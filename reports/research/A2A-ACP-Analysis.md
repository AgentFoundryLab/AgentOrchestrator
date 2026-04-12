# A2A & ACP Analysis for Orchestrator

## Protocol Disambiguation

**IMPORTANT**: Only ONE "ACP" protocol is relevant for this analysis:

- **ACP** (Agent Client Protocol): Orchestrator ↔ Agent communication, from **Zed Industries**
- **A2A** (Agent2Agent Protocol): Agent ↔ Agent communication, governed by **Linux Foundation**
- **MCP** (Model Context Protocol): Agent ↔ Tools/Resources, from **Anthropic**

**Historical Note**: IBM's Agent Communication Protocol (also called "ACP") was merged into A2A in August 2025 and is now defunct. When we refer to "ACP" in this document, we mean **Zed's Agent Client Protocol only**.

---

## Protocol Stack

| Protocol | Purpose | Pattern | When to Use |
|----------|---------|---------|-------------|
| **ACP** | Orchestrator ↔ Agent | Hub-spoke (1 client : 1 agent) | Multi-provider agent control (all levels L1/L2/L3) |
| **A2A** | Agent ↔ Agent | Peer-to-peer | L2: Optional direct; L3: Always |
| **MCP** | Agent ↔ Tools/Resources | Client-server | Tool access, config sharing |

---

## Agent Protocol Support Matrix

| Agent | ACP Support | A2A Support | MCP Support | Notes |
|-------|-------------|-------------|-------------|-------|
| **Gemini CLI** | ✅ Native (`--experimental-acp`) | ✅ **Native** | ✅ Native | Google reference impl (ACP + A2A) |
| **Claude Code** | ✅ Via `claude-code-acp` adapter | ⚠️ Via A2A-MCP bridge | ✅ Native | [Limitations](#claude-via-acp-limitations) |
| **Codex** | ✅ Via `codex-acp` adapter | ⚠️ Via A2A-MCP bridge | ✅ Native | Same MCP bridge as Claude |

### Claude via ACP Limitations

When using Claude Code through the ACP adapter (`claude-code-acp`), the following features are **not available**:

- ❌ No hooks (custom observability lost)
- ❌ No edit past messages
- ❌ No resume from history
- ❌ No checkpoints
- ⚠️ Subset of built-in slash commands only

**Source**: [Zed Blog - Claude Code via ACP](https://zed.dev/blog/claude-code-via-acp)

**Recommendation**: For production Orchestrator where observability is critical, consider using Claude Code via its native CLI alongside other agents via ACP.

---

## Multi-Agent Coordination Levels

| Level | Pattern | Coordination | Use A2A? | Recommendation |
|-------|---------|--------------|----------|----------------|
| **L1: Workflow** | Sequential/DAG | Orchestrator only | ❌ No | Use LangGraph/Pydantic AI via ACP |
| **L2: Graph** | Conditional routing | Orchestrator + optional peer messaging | ⚠️ **Optional** | A2A for efficiency if high inter-agent traffic |
| **L3: Swarm** | Autonomous peers | **Agent-driven** | ✅ **Always** | A2A native (Gemini) or via MCP bridge (Claude/Codex) |

**Key Insight**:
- **L1**: ACP only - orchestrator controls all coordination
- **L2**: ACP primary, A2A optional for direct peer messaging (bypassing orchestrator)
- **L3**: A2A primary - agents autonomously collaborate, orchestrator provides minimal control

---

### Orchestration vs Choreography Boundary

| Aspect | Orchestration (L1) | Hybrid (L2) | Choreography (L3) |
|--------|-------------------|-------------|-------------------|
| **Decision Control** | Orchestrator decides everything | Orchestrator controls flow | Agents decide collaboration |
| **Communication** | Hub-spoke via ACP only | ACP + optional peer A2A | Peer A2A primary |
| **Agent Autonomy** | None - execute & report | Limited - can message peers | Full - self-organize |
| **Orchestrator Role** | Central coordinator | Flow controller | Spawn + escalation |
| **Pattern** | Centralized | Hybrid | Decentralized |

**The Boundary**:
- **Orchestration → Hybrid**: When agents gain ability to communicate directly via A2A (L1 → L2)
- **Hybrid → Choreography**: When decision-making shifts from orchestrator to agents (L2 → L3)

**Examples**:
- **L1 Orchestration**: Orch assigns Task A to Agent 1 → waits → assigns Task B to Agent 2 (via ACP only)
- **L2 Hybrid**: Orch routes to Agent 1 via ACP → Agent 1 directly messages Agent 2 via A2A about dependency
- **L3 Choreography**: Orch spawns agents via ACP → agents negotiate via A2A who does what

---

## Orchestrator Architecture Options

### Option 1: ACP-Only (Multi-Provider, Simple)

```
Orchestrator (ACP Client)
    ├─[ACP]─→ Gemini CLI (via --experimental-acp)
    ├─[ACP]─→ Claude Code (via claude-code-acp adapter)
    └─[ACP]─→ Codex (via codex-acp adapter)
```

**Characteristics**:
- ✅ Multi-provider flexibility with single protocol
- ❌ **Lose Claude hooks** (no custom observability)
- ❌ No agent-to-agent communication (L1/L2 only)
- ✅ Simpler architecture (ACP only)

**Use for**: L1 Workflow, simple L2 Graph (orchestrator-mediated only)

---

### Option 2: Hybrid Native + ACP (Recommended for Production)

```
Orchestrator
    ├─[Native CLI]─→ Claude Code (full features + hooks + observability)
    ├─[ACP]───────→ Gemini CLI (via --experimental-acp)
    └─[ACP]───────→ Codex (via codex-acp)
```

**Characteristics**:
- ✅ **Preserve Claude observability** (hooks, checkpoints, full features)
- ✅ Multi-provider support (native Claude + ACP for others)
- ⚠️ Two integration patterns (native + ACP)
- ✅ Maximum flexibility

**Use for**: Production Orchestrator L1/L2 where Claude observability is critical

**To add L3 capability**: Include A2A-MCP bridge for Claude to enable peer communication

---

### Option 3: L3 Swarm with A2A (Advanced Multi-Agent)

```
Orchestrator (Minimal orchestration via ACP)
    │
    ├─[ACP]─→ Gemini CLI (A2A native) ─────┐
    ├─[ACP]─→ Claude (via bridge) ─────────┼─[A2A Protocol]─→ Autonomous peer collaboration
    └─[ACP]─→ Codex (via bridge) ──────────┘
                     ↑
              A2A-MCP Bridge
           (universal MCP server)
```

**Characteristics**:
- **Gemini**: Native A2A support (no bridge needed)
- **Claude/Codex**: Via universal A2A-MCP bridge (same MCP server for both)
- ✅ Full peer-to-peer agent collaboration
- ✅ Agents self-organize and negotiate
- ⚠️ Higher complexity (ACP + A2A + bridge)
- ⚠️ Orchestrator has limited visibility into peer conversations

**Use for**: Advanced L3 swarms, autonomous multi-agent collaboration

**Note**: Can combine with Option 2 (native Claude) for observability while enabling A2A collaboration

---

## ACP Specifications (Zed Industries)

### Core Capabilities

**Protocol**: JSON-RPC 2.0
**Transports**: stdio, WebSocket
**Pattern**: Request-response + streaming notifications

**Required Methods** (all agents MUST support):
- `POST /agent/initialize` - Capability negotiation, protocol version
- `POST /session/new` - Create new session with working directory + MCP servers
- `POST /session/prompt` - Send user prompt to agent
- `POST /session/cancel` - Cancel ongoing operation
- `POST /session/update` - Update session state

**Optional Capabilities** (agents MAY support):
- `loadSession` - Resume existing session from history
- File operations - `fs/read_text_file`, `fs/write_text_file` (if client advertises support)
- Terminal access - `terminal/*` methods
- Various content types - images, audio, embedded context

### MCP Configuration Sharing

Per [ACP spec](https://agentclientprotocol.com/), orchestrator provides MCP servers during session creation:

```json
POST /session/new
{
  "cwd": "/project",
  "mcpServers": [
    {
      "type": "stdio",
      "name": "context7",
      "command": "/usr/local/bin/mcp-server-context7",
      "args": ["--api-key", "${CONTEXT7_KEY}"]
    },
    {
      "type": "http",
      "name": "parallel-search",
      "url": "https://api.parallel.com/mcp",
      "headers": [{"name": "Authorization", "value": "Bearer ${TOKEN}"}]
    }
  ]
}
```

**Strategy**: Orchestrator manages global + role-specific MCP configs. Agents receive configs on session creation via ACP.

### What ACP Does NOT Handle

- ❌ Agent-to-agent communication (use A2A)
- ❌ Multi-agent orchestration (use orchestrator frameworks like LangGraph)
- ❌ Distributed agent coordination (use A2A for L3 swarms)
- ❌ Agent discovery across networks (use A2A Agent Cards)

**ACP is designed for**: Single orchestrator controlling a single agent via hub-spoke communication.

---

## A2A Protocol Specifications (Linux Foundation)

### Core Capabilities

**Protocol**: JSON-RPC 2.0
**Transports**: HTTP/HTTPS, Server-Sent Events (SSE), gRPC (v0.3+)
**Pattern**: Peer-to-peer + pub/sub + task-based workflow

**Core Abstractions**:
- **Agent Card**: JSON metadata describing capabilities, skills, auth schemes, endpoints
- **Task**: Unit of work with states (submitted, working, input-required, completed, failed)
- **Message**: Atomic communication unit (associated with context/task)
- **Artifact**: Output/result from task execution
- **Context**: Shared conversation state between agents

**Key Features**:
- Async-first design for long-running tasks
- Streaming via SSE for real-time updates
- Webhook push notifications for disconnected clients
- OAuth2 / API Key authentication
- Capability-based authorization
- Opaque execution (agents don't expose internals)

---

## A2A-MCP Bridge (Universal)

**Purpose**: Enables MCP-native agents (Claude, Codex, any MCP client) to participate in A2A peer communication.

**Setup** (same for all MCP agents):
```bash
# Universal MCP server - works with ALL MCP clients
npx -y @regismesquita/mcp_a2a
```

**When needed**:
- **L2 Graph**: If using A2A for direct peer messaging with Claude/Codex
- **L3 Swarm**: **Always required** for Claude/Codex (Gemini has native A2A)

**Architecture**:
```
┌──────────────────────────────────┐
│   A2A-MCP Bridge (MCP Server)    │
│   • MCP interface (universal)    │
│   • A2A protocol translator      │
└────────┬─────────────────────────┘
         │ MCP (universal)
    ┌────┼─────┬──────────┐
    ↓    ↓     ↓          ↓
  Claude Codex Future   Any MCP
  (MCP)  (MCP)  Agent    Client

         │ A2A Protocol
         ↓
    Gemini CLI (A2A native)
```

**Source**: [A2A-MCP-Server on GitHub](https://github.com/GongRzhe/A2A-MCP-Server)

**Note**: A2A peer communication requires:
- Gemini ↔ Gemini: Native A2A (no bridge)
- Gemini ↔ Claude/Codex: A2A-MCP bridge on Claude/Codex side only
- Claude ↔ Codex: A2A-MCP bridge on **both** sides

---

## Integration Patterns

### Pattern 1: L2 Graph Direct Communication (Optional)

```
Orch [ACP] → Agent A
                ↓ [A2A direct] → Agent B (bypass Orch)
                                      ↓
Orch ←─────────────────────────[ACP]─┘
```

- Orchestrator assigns to Agent A via ACP
- Agent A uses A2A to directly message Agent B (efficiency, no round-trip through Orch)
- Agent B reports back to Orch via ACP
- **Alternative** (simpler): A → [ACP] → Orch → [ACP] → B (LangGraph mediated)

**Trade-off**: Direct A2A reduces latency but adds complexity. Use only if high inter-agent message volume.

---

### Pattern 2: L3 Hierarchical Execution (Swarm)

```
Orch [ACP] → Agent A → [A2A] → Agent B → [A2A] → Agent C
                                                      ↓
Orch ←───────────────────────────────────────[ACP]───┘
```

- Orchestrator spawns Agent A via ACP
- Agents autonomously delegate via A2A
- Final agent reports results back to Orch via ACP
- **Orchestrator role**: Minimal (spawn + receive final results)

---

### Pattern 3: L3 Parallel Coordination (Swarm)

```
Orch spawns 3 agents via ACP
    ↓
Agents coordinate via A2A:
  - Share context
  - Negotiate task allocation
  - Sync state
    ↓
All report to Orch via ACP (final results only)
```

**Requires**: A2A-MCP bridge for Claude/Codex agents (Gemini native A2A)

---

### Pattern 4: Failure Recovery

- **L1**: Agent escalates directly to Orch via ACP
- **L2**: Agent may retry via A2A peer, then escalate to Orch via ACP if fails
- **L3**: Agents attempt peer recovery via A2A first, escalate to Orch via ACP only if critical

---

### Pattern 5: Context Propagation

| Context Type | L1 | L2 | L3 | Protocol |
|--------------|----|----|----|----|
| **Global** (project-wide) | ✅ | ✅ | ✅ | ACP (Orch → All agents) |
| **Local** (task-specific) | ❌ | ⚠️ Optional | ✅ Always | A2A (Agent → Agent) |

---

## Overlap & Avoidance

| Function | ACP Role | A2A Role | Duplication Avoidance |
|----------|----------|----------|----------------------|
| **Inter-agent messaging** | Orch relays (hub-spoke) | Direct peer (L2 opt, L3 always) | L1: ACP only; L2: Optional A2A; L3: Prefer A2A |
| **Status updates** | Agent → Orch (coarse) | Agent → Agent (fine, L2/L3) | Different granularity |
| **Context sharing** | Global (project-wide) | Local (task-specific, L2/L3) | Different scope |
| **Error reporting** | Critical failures | Recoverable errors (L2/L3) | Different severity |

**Rules**:
- **L1**: ACP only
- **L2**: ACP primary, optional A2A peer messaging (if efficiency > complexity)
- **L3**: A2A primary, ACP for control plane (spawn, escalation)

---

## Orchestrator Component Mapping

| Component | ACP Coverage | A2A Coverage | Integration |
|-----------|--------------|--------------|-------------|
| **Agent Lifecycle** | ✅ Discovery, spawn, terminate | ⚠️ Health monitoring (L2/L3 peers) | ACP controls, A2A monitors |
| **Task Management** | ✅ Assignment, status tracking | ⚠️ Delegation (L2 opt, L3 always) | ACP assigns, A2A coordinates |
| **Context Propagation** | ✅ Global context (all) | ⚠️ Local (L2 opt, L3 always) | Hierarchical split |
| **Coordination (L1)** | ✅ Full orchestrator control | ❌ Not used | ACP only |
| **Coordination (L2)** | ✅ Primary control | ⚠️ Optional peer messaging | ACP primary, A2A optional |
| **Coordination (L3)** | ⚠️ Minimal/escalation | ✅ Peer collaboration | A2A primary, ACP fallback |
| **Control Plane** | ✅ Policy enforcement (all) | ⚠️ Local adaptation (L2/L3) | ACP enforces, A2A optimizes |
| **Workflow Execution** | ✅ Initiation, routing (all) | ⚠️ Peer messaging (L2 opt, L3 always) | ACP controls, A2A coordinates |

---

## Shared Components

### Agent Registry

```python
# ACP populates (all levels: L1/L2/L3)
def register_agent(agent_id, capabilities):
    registry[agent_id] = capabilities

# A2A consumes (L2 optional, L3 always)
def route_message(task):
    return registry.find_agent(task.required_capability)
```

### Context Manager

```python
global_context: ProjectContext  # Via ACP (all levels)
local_context: Dict[AgentId, TaskContext]  # Via A2A (L2 opt, L3 always)

def push_global(ctx):  # Orch → Agents (ACP) - all levels
    pass

def share_local(from_agent, to_agent, ctx):  # Agent → Agent (A2A) - L2 opt, L3 always
    pass
```

### Observability

```python
# Both protocols feed unified OTEL
acp_events → OTEL  # Orch ↔ Agent interactions (all levels)
a2a_events → OTEL  # Agent ↔ Agent interactions (L2 opt, L3 always)
```

---

## Protocol Characteristics

| Aspect | ACP (Zed) | A2A (Linux Foundation) |
|--------|-----------|------------------------|
| **Transport** | JSON-RPC over stdio/WebSocket | JSON-RPC over HTTP/HTTPS, SSE, gRPC |
| **Pattern** | Request/response + streaming | Request/response + pub/sub + task workflow |
| **Relationship** | 1 client : 1 agent (hub-spoke) | Agent : Agent (peer-to-peer) |
| **State** | Per-session state | Shared conversation context |
| **Errors** | To orchestrator for decision | Peer recovery or escalate |
| **Discovery** | Capability negotiation (init) | Agent Cards + registry lookup |
| **Use Case** | L1/L2/L3 orchestrator control | L2: Optional peer; L3: Always peer |

---

## Implementation Recommendations

### For Workflow (L1)

- **Don't use A2A** - unnecessary complexity
- Use **ACP only** for multi-provider orchestration
- Use LangGraph/Pydantic AI/Dagster frameworks
- **Recommended**: Option 1 (ACP-only) or Option 2 (if Claude observability needed)

---

### For Graph (L2)

- **A2A optional** - use for direct peer messaging if high traffic
- Consider A2A if: High inter-agent message volume, latency-sensitive
- Skip A2A if: Simple graphs, complexity > benefit
- Use LangGraph/Pydantic AI (simpler, ACP-only often sufficient)
- **Recommended**: Option 2 (Hybrid) for observability

---

### For Swarm (L3)

- **A2A always required** - autonomous peer collaboration
- **Gemini**: Native A2A (no bridge)
- **Claude/Codex**: Universal A2A-MCP bridge required
- Orchestrator provides minimal coordination (spawn + escalation)
- **Recommended**: Option 3 with A2A-MCP bridge

---

### Trade-offs Summary

| Approach | Multi-Provider | Observability | Complexity | Best For |
|----------|---------------|---------------|------------|----------|
| **ACP-Only (Option 1)** | ✅ Yes | ❌ Lose Claude hooks | Low | L1/L2 workflows, non-Claude primary |
| **Hybrid (Option 2)** | ✅ Yes | ✅ Full (native Claude) | Medium | **Production L1/L2/L3** with Claude observability |
| **L3 Swarm (Option 3)** | ✅ Yes | ⚠️ Via A2A events | High | Advanced L3 autonomous swarms |

---

## Sources

### Official Protocol Documentation

- [Agent Client Protocol (ACP) - Zed Industries](https://agentclientprotocol.com/)
- [A2A Protocol Specification - Linux Foundation](https://a2a-protocol.org/latest/)
- [ACP GitHub - Zed Industries](https://github.com/zed-industries/agent-client-protocol)
- [A2A GitHub - Linux Foundation](https://github.com/a2aproject/A2A)

### Agent Implementations

- [Gemini CLI ACP Support](https://zed.dev/blog/bring-your-own-agent-to-zed) (`--experimental-acp`)
- [Gemini CLI A2A Native Support](https://github.com/google-gemini/gemini-cli/discussions/7822)
- [Claude Code ACP Adapter](https://github.com/zed-industries/claude-code-acp)
- [Claude via ACP Limitations](https://zed.dev/blog/claude-code-via-acp)
- [Codex ACP Support](https://zed.dev/blog/codex-is-live-in-zed)

### Bridges & Integration

- [A2A-MCP Bridge (Universal)](https://github.com/GongRzhe/A2A-MCP-Server)
- [MCP + A2A with Claude (Anthropic Webinar)](https://www.anthropic.com/webinars/deploying-multi-agent-systems-using-mcp-and-a2a-with-claude-on-vertex-ai)

### Historical: IBM-ACP Merger

- [IBM-ACP Joins A2A - Linux Foundation](https://lfaidata.foundation/communityblog/2025/08/29/acp-joins-forces-with-a2a-under-the-linux-foundations-lf-ai-data/)
- [IBM ACP Documentation (Historical)](https://www.ibm.com/think/topics/agent-communication-protocol) - Note: IBM-ACP is defunct, merged with A2A

### A2A Governance & Announcements

- [Google A2A Announcement](https://cloud.google.com/blog/products/ai-machine-learning/agent2agent-protocol-is-getting-an-upgrade)
- [Linux Foundation A2A Project Launch](https://www.linuxfoundation.org/press/linux-foundation-launches-the-agent2agent-protocol-project-to-enable-secure-intelligent-communication-between-ai-agents)
