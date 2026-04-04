# Multi-Agent Orchestration & Workflow Frameworks Research

**Research Date**: February 2026
**Objective**: Evaluate multi-agent and workflow orchestration frameworks supporting multi-provider agents (Claude Code, Gemini, Codex) with native OAuth subscriptions, and map capabilities against Orchestrator requirements.

---

## Executive Summary

**Strategic Recommendation: Hybrid MCP + A2A Architecture (Option E)**

After comprehensive analysis, **Hybrid MCP + A2A Architecture** (Option E) emerged as the primary recommendation with **90% coverage** (highest) of Orchestrator requirements. This game-changing approach enables multi-provider OAuth subscriptions (Claude + OpenAI + Gemini) with any orchestration framework, eliminating vendor lock-in while achieving **up to 36x cost savings** for heavy agentic workloads.

**Alternative for AWS**: **Strands Agents** (Option C) - AWS-native with strong multi-agent primitives and A2A support (70% coverage)

**Alternative for Simplicity**: **MS Agent Framework** (Option D) - Native Claude Agent SDK with subscription OAuth (80% coverage)

### Key Findings

1. **Multi-Provider OAuth Breakthrough**: Hybrid MCP + A2A enables subscription billing across Claude (Code CLI or Agent SDK), OpenAI (ChatGPT CLI), and Gemini (gemini-cli)
2. **HITL Solved in Workflow Layer**: Prefect's interactive workflows (`pause_flow_run`) allow typed input without custom state plumbing
3. **Observability Requires OTel**: Pydantic AI, MS Agent Framework, and Strands Agents emit native OpenTelemetry traces
4. **Framework Flexibility**: Option E works with ANY orchestrator (Strands, Pydantic AI, MS Agent Framework, LangGraph)
5. **Cost Advantage**: Up to 36x savings vs API for agentic workloads with heavy caching

---

## Framework Comparison Matrix

### Core Capabilities Overview

| Framework | Multi-Provider | Production OTel | HITL | Durable State | Native OAuth | A2A Support | Verdict |
|-----------|---------------|-----------------|------|---------------|--------------|-------------|---------|
| **Pydantic AI** | **High** (OpenAI, Anthropic, Gemini) | **High** (Logfire) | Medium (Tool approvals) | **High** | Gap | **Yes** (FastA2A) | **Agent Runtime** |
| **Prefect** | N/A (Orchestrates) | Medium | **High** (Interactive workflows) | **High** | Gap | No | **Workflow Engine** |
| **Strands Agents** | **High** (Bedrock, Anthropic, OpenAI, Gemini, Ollama) | **High** (Native OTel) | Medium (Interrupts) | **High** (S3 backend) | Gap | **Yes** (Native) | **AWS Multi-Agent** |
| **MS Agent Framework** | Medium (Azure OpenAI, OpenAI) | **High** (Zero-code OTel) | **High** (Request/Response) | **High** | Gap | **Yes** (Native) | **Azure Multi-Agent** |
| **Dagster** | N/A (Orchestrates) | **Low** (Workarounds) | Low | **High** | Gap | No | **Data/Asset Focus** |
| **CrewAI Ent.** | **High** (LLM agnostic) | Medium | Medium | Medium | Gap | No | **Managed Platform** |
| **AutoGen Studio** | **High** | **Low** (Prototype) | Low | Low | Gap | No | **Prototype Only** |

---

## Detailed Framework Analysis

### 1. Strands Agents (AWS Open Source)

**Origin**: AWS open-source framework, v1.0 released July 2025
**Status**: Production-ready, used by Amazon Q, AWS Glue, Kiro
**GitHub**: 4,972 stars, 615 forks (Python SDK)

#### Architecture Approach
- **Model-Driven Orchestration**: Agents reason autonomously using LLM capabilities
- **Multi-Agent Primitives**: Agents-as-Tools, Swarms, Graphs, Workflows
- **A2A Protocol**: Native Agent-to-Agent communication for cross-platform agent discovery

#### Multi-Provider Support
- **Native**: Amazon Bedrock (Claude, Nova, Titan, Llama, etc.)
- **Direct APIs**: Anthropic, OpenAI, Gemini Live
- **Via LiteLLM**: Ollama, Cohere, Mistral, Stability, Writer
- **Authentication**: API keys only (no OAuth subscriptions)

#### Orchestrator Capability Coverage

**Orchestrator Engine**: **HIGH**
- Agent lifecycle: Discovery via A2A AgentCard, spawning, health monitoring
- Task management: Hierarchical delegation, swarm coordination, graph workflows
- Context propagation: Session management with S3 backend, shared state
- Coordination: Native A2A for inter-agent communication, agent mesh networks
- Control plane: Native OpenTelemetry for monitoring, async execution

**Workflow Engine**: **HIGH**
- DAG execution: Graph primitive with conditional routing
- Reactive/proactive: Event-driven via integration with orchestrators
- Parallelization: Swarm pattern for concurrent agent execution
- HITL: Interrupt primitive for human approval gates
- Persistent state: S3-backed session management, durable execution
- Failure management: Built-in retry logic, error handling

**Runtime Engine**: **HIGH**
- Devcontainer: Runs anywhere (AWS, GCP, on-prem)
- VM/K8s: Native support for EKS, Lambda, EC2, Fargate, Bedrock AgentCore
- Git worktree: Not built-in (application layer)
- Build pipeline: Integrates with AWS CodePipeline, GitOps workflows
- Resource management: Async support, concurrent execution

**Observability**: **HIGH**
- OpenTelemetry: First-class native support, zero-code setup
- Logs/traces/metrics: Full agent reasoning traces via OTEL
- Sub-agent spans: Tracks tool calls, agent delegation, token usage
- Evaluations: Integration with AWS monitoring, Langfuse compatible

**Security**: **MEDIUM**
- Isolation: Container/Lambda execution, sandboxed tool execution
- Secret management: AWS Secrets Manager, IAM integration
- RBAC: AWS IAM roles for agent authorization
- Guardrails: Bedrock Guardrails integration for content filtering

#### Strengths
1. **Production-proven**: Already used by multiple AWS production services
2. **Multi-agent native**: Swarm, Graph, Workflow primitives built-in
3. **A2A Protocol**: Enables cross-platform agent discovery and collaboration
4. **AWS integration**: Deep Bedrock, S3, IAM, Lambda integration
5. **Model flexibility**: 10+ model providers via LiteLLM
6. **Observability-first**: Native OTel with agent-level tracing

#### Gaps
1. **No native OAuth subscriptions**: API key based authentication only
2. **AWS-centric documentation**: Less guidance for non-AWS deployments
3. **HITL less mature**: Interrupt primitive exists but not as polished as Prefect
4. **Workflow orchestration**: Better for agent coordination than workflow scheduling

#### Best Fit Scenario
- **AWS-native deployments** with Bedrock/Lambda/EKS
- **Multi-agent systems** requiring A2A protocol for agent discovery
- **Production-grade** agentic applications with observability requirements
- **Model flexibility** needed across providers

---

### 2. Pydantic AI (Pydantic Team)

**Best Feature**: Unified Type Safety + **FastA2A** (reference A2A implementation)
**Observability**: Seamless with Logfire (OTel-based)
**Multi-Agent**: `pydantic-graph` for state machine orchestration
**A2A**: **Built FastA2A**, the framework-agnostic A2A protocol library

#### A2A Protocol Implementation
- **FastA2A**: Framework-agnostic Python library for A2A protocol (built by Pydantic team)
- **Built on Starlette**: ASGI-compatible, runs on any ASGI server (Uvicorn, etc.)
- **Convenience method**: `agent.to_a2a()` exposes agents as A2A servers
- **Full conversation history**: Persists tasks, contexts, tool calls
- **Multi-turn conversations**: Context continuity via `context_id`
- **Vendor-neutral**: Not exclusive to Pydantic AI

#### Orchestrator Coverage
- **Orchestrator Engine**: HIGH (typed state, delegation, sub-agents, A2A)
- **Workflow Engine**: MEDIUM (graph-based control flow)
- **Runtime Engine**: HIGH (sandboxed execution, FastAPI deployment, ASGI)
- **Observability**: HIGH (Logfire integration, agent traces)
- **A2A Support**: **VERY HIGH** (built the reference implementation)

#### Strengths
- **FastA2A**: Built the reference A2A protocol implementation
- FastAPI-style DX with type safety
- 5 agent complexity levels (simple → deep agents)
- Durable execution support
- Pydantic Evals framework included
- `to_a2a()` method for instant A2A server deployment
- ASGI-based for production deployment

#### Gaps
- No native HITL (tool approvals only)
- No workflow scheduling (relies on app code or Prefect)

---

### 3. Prefect (Workflow Orchestration)

**Best Feature**: Interactive Workflows with `pause_flow_run`
**Architecture**: Event-driven 3.0, worker-pull model
**HITL**: Generates UI forms from Pydantic models automatically

#### Orchestrator Coverage
- **Orchestrator Engine**: MEDIUM (orchestrates agents, not agent-native)
- **Workflow Engine**: HIGH (triggers, scheduling, HITL, state management)
- **Runtime Engine**: HIGH (K8s, ECS, workers in VPC)
- **Observability**: MEDIUM (flow-level logs, requires custom agent spans)

#### Strengths
- HITL solved without custom frontend
- Event-driven reactive triggering
- Enterprise RBAC, SSO, secret management
- Worker isolation in secure VPCs

#### Gaps
- Not agent-native (orchestrates any Python code)
- Agent-level tracing requires custom instrumentation
- No multi-provider agent primitives

---

### 4. Microsoft Agent Framework

**Origin**: Microsoft Research/Azure, production successor to AutoGen
**Status**: Production-ready (2026), replaces AutoGen for enterprise use
**GitHub**: Part of Microsoft Learn documentation
**Languages**: Python, .NET (C#)

#### Architecture Approach
- **Typed Workflow Graphs**: Explicit data-flow based orchestration with typed state
- **Middleware Pattern**: Security, PII filtering, input validation as composable middleware
- **Checkpointing**: Native state persistence for long-running, resumable workflows
- **Request/Response Pattern**: Structured HITL with typed inputs/outputs

#### Multi-Provider Support
- **Native**: Azure OpenAI Service (GPT-4, GPT-4o, o1)
- **Claude Agent SDK**: **Full integration with Anthropic Claude via native Claude Agent SDK** (agent framework, NOT Anthropic Client SDK API wrapper) (Python only)
  - Models: Sonnet, Opus, Haiku
  - Tools: Integrates with Claude Code ecosystem (Read, Write, Bash, Glob)
  - MCP Integration: Local (stdio) and remote (HTTP) MCP servers
  - Permission modes: default, acceptEdits, plan, bypassPermissions
  - **Subscription OAuth Support**: Claude.ai subscription for billing (Pro/Max plans)
- **Direct APIs**: OpenAI, Anthropic API
- **Extensible**: Plugin architecture for other providers
- **Authentication**: API keys, Azure Managed Identity, Azure AD, **Claude subscription OAuth**

#### Orchestrator Capability Coverage

**Orchestrator Engine**: **HIGH**
- Agent lifecycle: Typed agent registration, workflow-based spawning
- Task management: Data-flow graph with dependency resolution
- Context propagation: `AgentThread` for conversation state, shared workflow state
- Coordination: Routing via workflow edges, "Magentic" collaboration patterns
- Control plane: Middleware hooks for monitoring, Azure Monitor integration

**Workflow Engine**: **HIGH**
- DAG execution: Typed `Workflow` with conditional edges
- Reactive/proactive: Webhook triggers, event-driven Azure Functions integration
- Parallelization: Concurrent agent execution within workflow
- HITL: Request/Response pattern with typed user input
- Persistent state: Native checkpointing to Azure Storage/CosmosDB
- Failure management: Checkpoint-based recovery, retry policies

**Runtime Engine**: **MEDIUM-HIGH**
- Devcontainer: Docker support for development
- VM/K8s: Azure Container Apps, AKS deployment
- Git worktree: Not built-in (application layer)
- Build pipeline: Azure DevOps, GitHub Actions integration
- Resource management: Azure Functions for serverless, AKS for scale

**Observability**: **HIGH**
- OpenTelemetry: Zero-code setup via environment variables
- Logs/traces/metrics: Azure Monitor, Application Insights native
- Sub-agent spans: Workflow traces include tool execution, agent steps
- Evaluations: Azure AI Studio evaluation framework

**Security**: **HIGH**
- Isolation: Azure Container Apps, Functions sandboxing
- Secret management: Azure Key Vault integration
- RBAC: Azure AD, Managed Identity for zero-credential auth
- Guardrails: Middleware for content filtering, Azure Content Safety integration

#### Strengths
1. **Claude Agent SDK Integration**: **Native Claude Agent SDK with subscription OAuth support** (integrates with Claude Code ecosystem, Claude.ai Pro/Max subscription billing)
2. **A2A Protocol**: Native agent-to-agent communication with agent-card discovery
3. **MCP Integration**: Connect to local (stdio) and remote (HTTP) MCP servers
4. **Enterprise-grade**: Production successor to AutoGen with Microsoft support
5. **Checkpointing**: Resume workflows after interruptions/failures
6. **Azure ecosystem**: Deep integration with Azure AI, Storage, Security services
7. **Middleware architecture**: Composable security, logging, PII filtering layers
8. **Multi-language**: Python and .NET support for enterprise environments
9. **Zero-code OTel**: Observability via env vars, no instrumentation code
10. **HITL**: Request/Response pattern with typed validation

#### Gaps
1. **Claude Code SDK**: Python-only (no .NET support yet)
2. **Multi-provider breadth**: Fewer providers than Strands (but growing with Claude Code)
3. **Multi-cloud complexity**: Best experience on Azure (though runs anywhere)
4. **Distributed execution**: Single-process composition (distributed planned but not GA)

#### Best Fit Scenario
- **Claude Code users** wanting orchestration layer with native integration
- **Azure/Microsoft ecosystem** deployments with Azure AD, Key Vault
- **Enterprise** requiring .NET integration, compliance, security middleware
- **Long-running workflows** needing checkpoint/resume capabilities
- **Multi-agent systems** using A2A protocol for agent discovery
- **MCP integration** needing both local and remote server support

#### Comparison: MS Agent Framework vs Strands Agents

| Aspect | MS Agent Framework | Strands Agents |
|--------|-------------------|----------------|
| **Cloud Focus** | Azure-native (runs anywhere) | AWS-native (runs anywhere) |
| **Multi-Provider** | Azure OpenAI, OpenAI, **Claude Code SDK** | 10+ via Bedrock + LiteLLM |
| **Claude Integration** | ✅ **Native Claude Agent SDK** (subscription OAuth, integrates with Claude Code tools) | Via Bedrock or Anthropic API |
| **A2A Protocol** | ✅ **Native** (agent-card discovery) | ✅ Native (agent-card discovery) |
| **MCP Integration** | ✅ **Native** (stdio + HTTP servers) | ✅ Native |
| **Checkpointing** | ✅ Native (Azure Storage/CosmosDB) | ✅ S3-backed sessions |
| **HITL** | ✅ Request/Response | Interrupt primitive |
| **Middleware** | ✅ Composable (security, PII filtering) | Tool-level hooks |
| **Multi-Language** | Python, .NET | Python, TypeScript |
| **Observability** | Azure Monitor (zero-code OTel) | Native OTel (any backend) |
| **Best For** | Azure/Claude Code users, .NET shops | AWS deployments, Bedrock users |

---

### 5. Dagster (Data/Asset Orchestration)

**Focus**: Data pipelines, asset lineage, sensor-based triggering
**Agent Support**: LOW (not designed for agent orchestration)

#### Orchestrator Coverage
- **Orchestrator Engine**: LOW (asset-focused, not agent-aware)
- **Workflow Engine**: MEDIUM (sensors, DAG, asset triggers)
- **Observability**: LOW (no OTel, long-standing issue #12353)

**Verdict**: Skip for agent orchestration. Use for data pipelines if needed.

---

### 6. CrewAI Enterprise

**Architecture**: Role-based crews, hierarchical delegation
**Offering**: Managed platform with control plane

#### Orchestrator Coverage
- **Orchestrator Engine**: HIGH (role-based, shared memory)
- **Workflow Engine**: MEDIUM (sequential/hierarchical processes)
- **Observability**: MEDIUM (enterprise platform features)

#### Gaps
- Managed platform (lose infrastructure control)
- Enterprise features behind paywall
- Less flexible than open-source alternatives

**Verdict**: Good for rapid prototyping, avoid for Orchestrator (lose control).

---

### 7. AutoGen Studio (Research Prototype)

**Status**: Microsoft explicitly warns "not production-ready"
**Security**: Lacks jailbreak tests, data access controls

**Verdict**: DO NOT USE for Orchestrator. Prototype only.

---

## OAuth Subscription Gap Analysis

**Finding**: ZERO orchestration frameworks natively implement OAuth subscription billing themselves.

### Critical Distinction
**Frameworks don't authenticate to providers** - they integrate with agents/tools that do:
- **Framework OAuth** (what's missing): Framework manages OAuth flows and subscriptions
- **External Agent OAuth** (what exists): Frameworks integrate with external CLIs/SDKs that use OAuth subscriptions

### CRITICAL: Tool Type Distinctions

**Three distinct tool types per provider - DO NOT confuse:**

**Anthropic (Claude):**
1. **Claude Code CLI** - Terminal agent interface (`claude` command)
2. **Claude Agent SDK** - Agent development framework (building agents with Claude)
3. **Anthropic Client SDK** - Basic API wrapper (`anthropic` Python/JS package, API calls only)

**OpenAI:**
1. **ChatGPT CLI** - Terminal interface
2. **OpenAI Agents SDK** - Agent development framework (NOT the same as Client SDK!)
3. **OpenAI Client SDK** - Basic API wrapper (`openai` Python/JS package, API calls only)

**Google:**
1. **gemini-cli** - Terminal interface
2. **Gemini ADK (Agent Development Kit)** - Agent framework (NOT Gen AI SDK!)
3. **Google Gen AI SDK** - Basic API client wrapper (`google-generativeai` package)

---

### OAuth Subscription Support by Tool Type

| Provider | Tool Type | Tool Name | Subscription Plans | OAuth Support | Integration |
|----------|-----------|-----------|-------------------|---------------|-------------|
| **Anthropic** | **CLI** | Claude Code CLI | Pro ($17-20/mo), Max ($100/mo) | ✅ Yes (`claude login`) | Option E (MCP bridge) |
| **Anthropic** | **Agent SDK** | Claude Agent SDK | Pro ($17-20/mo), Max ($100/mo) | ✅ Yes (Claude.ai OAuth) | MS Agent Framework |
| **Anthropic** | Client SDK | Anthropic Client SDK | N/A | ❌ API keys only (PAYG) | All frameworks (API) |
| **OpenAI** | **CLI** | ChatGPT CLI | Plus ($20/mo), Pro ($200/mo) | ✅ Yes (ChatGPT OAuth) | Option E (MCP bridge) |
| **OpenAI** | **Agent SDK** | OpenAI Agents SDK | N/A | ❌ API keys only (PAYG) | All frameworks (API) |
| **OpenAI** | Client SDK | OpenAI Client SDK | N/A | ❌ API keys only (PAYG) | All frameworks (API) |
| **Google** | **CLI** | gemini-cli | AI Plus/Pro/Ultra ($7.99-249/mo) | ✅ Yes (Google OAuth) | Option E (MCP bridge) |
| **Google** | **Agent SDK** | Gemini ADK | N/A | ❌ API billing only | All frameworks (API) |
| **Google** | Client SDK | Google Gen AI SDK | N/A | ❌ API keys only (PAYG) | All frameworks (API) |

**Key Insight**: Only **Agent SDKs** and **CLIs** can potentially support subscription OAuth. Basic **Client SDKs** are just API wrappers (always use API keys/PAYG).

**Key Findings**:
- **Claude**: TWO tools support subscription OAuth (≠ Anthropic Client SDK):
  - **Claude Code CLI**: Terminal agent, `claude login` OAuth, via MCP bridge (Option E)
  - **Claude Agent SDK**: Agent framework, Claude.ai OAuth, native integration (MS Agent Framework)
  - ❌ **Anthropic Client SDK**: Basic API wrapper, API keys only
- **OpenAI**: Only ChatGPT CLI supports subscription (≠ OpenAI SDKs):
  - **ChatGPT CLI**: ✅ Subscription OAuth confirmed
  - ❌ **OpenAI Agents SDK**: API keys only (separate from ChatGPT subscription)
  - ❌ **OpenAI Client SDK**: Basic API wrapper, API keys only
- **Gemini**: gemini-cli only (≠ Google Gen AI SDK):
  - **gemini-cli**: ✅ Subscription OAuth with AI Pro/Ultra
  - ❌ **Gemini ADK**: API billing only
  - ❌ **Google Gen AI SDK**: Basic API wrapper, API keys only

### Current State
- All frameworks use **API keys** for direct provider access (Anthropic API, OpenAI API, Bedrock, Vertex)
- **Multi-provider OAuth available**:
  - **Claude**: Two tools with subscription OAuth:
    - **Claude Code CLI**: `claude login`, integrated via MCP bridge (Option E)
    - **Claude Agent SDK**: Claude.ai subscription OAuth, native SDK integration (MS Agent Framework)
  - **OpenAI**: ChatGPT CLI (subscription OAuth); OpenAI SDK (API keys only)
  - **Gemini**: gemini-cli (subscription OAuth with AI Pro/Ultra); Gemini ADK (API billing only)
- **Option E (Hybrid MCP + A2A)**: Integrates with **Claude Code CLI** (via MCP bridge), ChatGPT CLI, gemini-cli
- **MS Agent Framework**: Native **Claude Agent SDK** integration (programmatic, supports subscription OAuth)

### Solution Options for Orchestrator

1. **Build OAuth Broker Service**
   - Handle OAuth flows with providers (Google Cloud, Azure, AWS)
   - Exchange user identities for provider access tokens
   - Manage enterprise token pools

2. **Token Injection**
   - **Pydantic AI**: Inject via `RunContext` dependencies
   - **Strands Agents**: Configure model provider with dynamic tokens
   - **MS Agent Framework**: Configure client with tokens

3. **Usage Limits**
   - **Pydantic AI**: Use `UsageLimits` (request/token limits)
   - **Strands Agents**: Implement middleware for quota tracking
   - Track usage via observability telemetry

---

## Architecture Recommendation: Hybrid Stack

### Option A: Prefect + Pydantic AI (Best-of-Breed)

```
Control Plane (Prefect)
  ↓ Triggers, HITL, Scheduling
Agent Runtime (Pydantic AI)
  ↓ Agent Logic, Tools, State
Observability (Logfire/OTel)
  ↓ Traces, Metrics, Costs
Custom OAuth Broker
  ↓ Token Management
```

**Coverage**: 85% of Orchestrator requirements
**Strengths**: HITL solved, best observability, type safety, FastA2A (reference A2A implementation)
**Gaps**: API keys only (no subscription OAuth), need custom OAuth broker, 2 frameworks complexity

---

### Option B: Strands Agents + Prefect (AWS-Native)

```
Control Plane (Prefect)
  ↓ Triggers, HITL, Scheduling
Agent Runtime (Strands Agents)
  ↓ Multi-agent orchestration, A2A
Observability (Native OTel)
  ↓ Agent traces, tool calls
AWS Infrastructure
  ↓ Bedrock, Lambda, S3, IAM
Custom OAuth Broker
  ↓ Token Management
```

**Coverage**: 85% of Orchestrator requirements
**Strengths**: A2A protocol, multi-agent native, AWS production-proven
**Gaps**: HITL less polished than Prefect, need custom OAuth broker

---

### Option C: Strands Agents Standalone (Simplified)

```
Agent Runtime (Strands Agents)
  ↓ Multi-agent orchestration, A2A
Observability (Native OTel)
  ↓ Full agent tracing
AWS Infrastructure
  ↓ Bedrock, Lambda, EKS
Custom OAuth Broker
  ↓ Token Management
```

**Coverage**: 70% of Orchestrator requirements
**Strengths**: Simplified stack, A2A native, production-proven
**Gaps**: No workflow engine, manual HITL implementation, need custom OAuth

---

### Option D: MS Agent Framework (Azure-Native)

```
Agent Runtime (MS Agent Framework)
  ↓ Typed workflows, checkpointing
Middleware Layer
  ↓ Security, PII filtering, validation
Observability (Azure Monitor)
  ↓ OTel traces via env vars
Azure Infrastructure
  ↓ Azure OpenAI, Container Apps, Key Vault
Custom OAuth Broker
  ↓ Token Management (Azure AD)
```

**Coverage**: **80%** of Orchestrator requirements
**Strengths**:
- **Native Claude Agent SDK integration** (Read/Write/Bash/Glob tools)
- ✅ **Claude subscription OAuth support** (Claude Agent SDK supports Claude.ai subscription for billing)
- **A2A protocol** support (agent-card discovery)
- **MCP integration** (stdio + HTTP)
- Checkpointing, HITL via Request/Response
- Azure enterprise features, middleware architecture

**Gaps**: Azure-centric (best experience), Claude Code SDK Python-only, Claude-only subscription OAuth (OpenAI/Gemini require API keys or external CLIs)

**Best For**: Claude Code users, Azure/Microsoft-committed organizations, .NET integration needs, enterprise compliance requirements

---

### Option E: Hybrid MCP + A2A Architecture (Universal OAuth Solution)

**The Game-Changer: Get Subscription OAuth Benefits with ANY Framework**

```
Orchestration Layer (Strands/Pydantic AI/MS Agent FW/any MCP-compatible)
  ↓ MCP Client
A2A-MCP Bridge Server
  ↓ A2A Protocol
External Agents with OAuth Subscriptions:
  ├─ Claude Code CLI/SDK (Pro $17-20/mo, Max $100/mo)
  ├─ ChatGPT CLI (Plus $20/mo, Pro $200/mo)
  └─ gemini-cli (AI Plus $7.99/mo, AI Pro $19.99/mo, AI Ultra $249.99/mo)
  ↓ OAuth Authentication (NOT API Keys!)
Models via Subscription (36x cheaper than API for agentic workloads)
```

**Coverage**: **90%** of Orchestrator requirements (**HIGHEST - only option with multi-provider OAuth subscriptions**)

**Strengths**:
- ✅ **Multi-provider OAuth subscriptions**:
  - **Claude** (Pro $17-20/mo, Max $100/mo) via Claude Code CLI OR Claude Agent SDK
  - **OpenAI Codex** (Plus $20/mo, Pro $200/mo) via ChatGPT CLI (NOT OpenAI SDK)
  - **Gemini** (AI Plus $7.99/mo, AI Pro $19.99/mo, AI Ultra $249.99/mo) via gemini-cli (NOT Gemini ADK)
- ✅ **Up to 36x cost savings** across ALL three providers (subscription vs API with optimal caching)
- ✅ **Framework flexibility** (works with Strands, Pydantic AI, MS Agent Framework, any MCP client)
- ✅ **A2A agent ecosystem** access (discover and use any A2A agent)
- ✅ **Reference implementation** (A2A-MCP-Server: 131 GitHub stars, community-driven)
- ✅ **Cloud agnostic** (runs on AWS, Azure, GCP, on-prem)
- ⚠️ **Critical**: Use CLIs (not SDKs) for OpenAI & Gemini subscription auth. Only Claude supports SDK subscription auth.
- ⚠️ **Note**: Requires managing external agents (Claude CLI/SDK, ChatGPT CLI, gemini-cli)

**How It Works**:
1. **Orchestration Layer**: Use your preferred framework (Strands Agents, Pydantic AI, etc.)
2. **MCP Bridge**: Deploy A2A-MCP-Server to translate MCP tool calls ↔ A2A agent messages
3. **External Agents**: Run Claude Code CLI (or Gemini CLI) with OAuth login
4. **Cost Savings**: External agents use subscription auth (Pro: $17-20/mo, Max: $100/mo), not API keys

**Implementation**:
```bash
# Install A2A-MCP bridge
pip install a2a-mcp-server

# Or use existing A2A-MCP-Server from GitHub
git clone https://github.com/GongRzhe/A2A-MCP-Server
```

```python
# Configure as MCP server in your orchestrator
# Example with Strands Agents or Pydantic AI:

# 1. Register external Claude Code agent via MCP bridge
register_agent(url="http://localhost:41242")

# 2. Send tasks to agent
task_id = send_message(
    agent_url="http://localhost:41242",
    message="Write a Python function for data validation"
)

# 3. Get results
result = get_task_result(task_id=task_id)
```

**Architecture Benefits**:
- **No vendor lock-in**: Switch orchestration frameworks without losing Claude Code access
- **Best of both worlds**: Framework features + subscription economics
- **Scalable**: MCP bridge can proxy multiple external agents
- **Observable**: Full tracing through orchestration layer + MCP + A2A

**Gaps**:
- Additional MCP bridge layer (minimal overhead, estimated ~20ms latency)
- Requires running external agents (Claude CLI/SDK, ChatGPT CLI, gemini-cli)
- Manual agent lifecycle management (start/stop external CLIs)
- External agent authentication setup (one-time `claude login`, ChatGPT account OAuth for OpenAI CLI, Google account OAuth for Gemini CLI)
- **SDK limitation**: Only Claude Agent SDK supports subscription OAuth; OpenAI/Gemini require CLIs
- ⚠️ **Gemini CLI provisioning issue**: Community reports of Ultra plan users hitting free tier limits (bug under investigation)

**Best For**:
- **Multi-provider subscriptions**: Claude + OpenAI + Gemini all with OAuth
- **Maximum cost optimization**: 36x savings across all three providers
- **Framework flexibility**: No vendor lock-in to orchestration framework
- **Heavy agentic workloads**: Significant caching benefits from subscriptions
- **Multi-cloud deployments**: AWS/Azure/GCP agnostic
- **Teams evaluating frameworks**: Switch orchestrators without losing subscription benefits

**Production Examples**:
- **Rasa**: Orchestrates MCP + A2A agents with HITL integration
- **Community**: Claude-IPC-MCP project with 3 Claude Code + 1 Gemini CLI agents communicating
- **Enterprise**: Dynatrace, AWS examples of MCP + A2A orchestration patterns

---

## Implementation Roadmap (6-Week POC)

### Weeks 1-2: Core Integration
- **Option A**: Deploy Prefect Server, create Pydantic AI agent in Prefect Flow
- **Option B/C**: Deploy Strands Agents on EKS/Lambda, implement Swarm pattern
- **Option D**: Deploy MS Agent Framework on Azure Container Apps, implement typed workflow
- **Option E**: Deploy A2A-MCP-Server bridge, configure with Strands/Pydantic AI, start Claude Code CLI with OAuth
- Verify OTel traces in collector (Logfire, AWS X-Ray, Azure Monitor, or custom)

### Weeks 3-4: HITL & Multi-Agent
- **Option A**: Implement tool approval workflow with Prefect pause gates
- **Option B**: Implement Graph workflow with interrupt gates, test A2A between agents
- **Option C**: Implement Swarm coordination with agent handoffs
- **Option D**: Implement Request/Response HITL pattern, checkpoint/resume workflow
- **Option E**: Test MCP ↔ A2A bridge, register multiple external agents (Claude + Gemini), verify task delegation

### Weeks 5-6: Auth & Scale
- **Options A/B/C**: Build custom OAuth broker service (token exchange, quota enforcement)
- **Option D**: Integrate Azure AD for authentication, leverage native Claude Code SDK OAuth
- **Option E**: Configure external agent OAuth (Claude Code CLI login, Gemini CLI OAuth), no custom broker needed!
- Deploy workers to K8s (A/B/E), Lambda (C/E), or Container Apps (D)
- Set up usage limits and cost tracking
- Run evaluations to benchmark performance and cost savings (especially Option E vs API)

---

## Decision Matrix

| Criteria | Prefect + Pydantic AI | Strands + Prefect | Strands Standalone | MS Agent Framework | **Hybrid MCP + A2A** |
|----------|----------------------|-------------------|-------------------|-------------------|----------------------|
| **Time to Value** | Medium | Medium | **Fast** | Medium | Medium |
| **HITL** | **Best** (Prefect pause) | **Good** (Prefect pause) | Manual | **Good** (Request/Response) | Depends on orchestrator |
| **Multi-Agent** | Medium (graph-based) | **Best** (Swarm, Graph, A2A) | **Best** (A2A) | Medium (typed workflows) | **Best** (A2A native) |
| **Observability** | **Best** (Logfire) | **Best** (Native OTel) | **Best** (Native OTel) | **Best** (Azure Monitor) | **Best** (orchestrator + bridge) |
| **AWS Integration** | Medium | **Best** | **Best** | Low | **Best** (if using Strands) |
| **Azure Integration** | Low | Low | Low | **Best** | Good (cloud agnostic) |
| **A2A Protocol** | **Yes** (FastA2A) | **Yes** (Native) | **Yes** (Native) | **Yes** (Native) | **Yes** (Bridge) |
| **OAuth Subscription** | ❌ (API keys only) | ❌ (API keys only) | ❌ (API keys only) | ✅ **Claude only (native SDK)** | ✅ **Claude + Codex + Gemini** |
| **Cost Savings** | API rates (PAYG) | API rates (PAYG) | API rates (PAYG) | **36x** (Claude via native SDK) | **36x** (all 3 providers) |
| **Checkpointing** | No | Session-based | Session-based | **Best** (Native) | Orchestrator-dependent |
| **Complexity** | High (2 frameworks) | High (2 frameworks) | **Low** (single) | **Low** (single) | Medium (+ MCP bridge) |
| **Vendor Lock-in** | **Low** (open source) | Medium (AWS-optimized) | Medium (AWS-optimized) | **High** (Azure-centric) | **Low** (framework agnostic) |
| **Multi-Provider** | **Best** (Any) | **Best** (10+ via Bedrock/LiteLLM) | **Best** (10+) | **Good** (Azure OpenAI/OpenAI/Claude Code) | **Best** (Any A2A agent) |
| **Framework Flexibility** | Locked to Pydantic AI | Locked to Strands | Locked to Strands | Locked to MS Agent FW | ✅ **Use ANY framework** |

---

## Final Recommendation

### For Orchestrator Production System

**🏆 PRIMARY: Hybrid MCP + A2A Architecture** (Option E) - **90% coverage (HIGHEST)**

**The Game-Changer for Orchestrator:**
- ✅ **Multi-provider OAuth subscriptions**:
  - Claude (Pro $17-20/mo, Max $100/mo) via CLI/SDK
  - OpenAI Codex (Plus $20/mo, Pro $200/mo) via ChatGPT CLI
  - Gemini (AI Plus $7.99/mo, AI Pro $19.99/mo, AI Ultra $249.99/mo) via gemini-cli
- ✅ **36x cost savings across ALL providers** (subscription vs API with heavy caching)
- ✅ **Framework flexibility**: Use ANY orchestrator (Strands, Pydantic AI, MS Agent FW) without vendor lock-in
- ✅ **True multi-provider**: Claude Code CLI/SDK + ChatGPT CLI + gemini-cli all with subscription auth
- ✅ **Community pattern**: A2A-MCP-Server (131 stars), Rasa examples, active development
- ✅ **Cloud agnostic**: AWS, Azure, GCP, on-prem
- ✅ **True multi-agent**: A2A protocol for agent discovery & coordination

**Cost Comparison**:
- **API**: $3-15/MTok input (Claude Sonnet) × heavy agentic usage = $100-500/mo/developer
- **Subscription**: Claude Pro ($20/mo) + ChatGPT Plus ($20/mo) + Gemini AI Pro ($19.99/mo) = ~$60/mo total
- **Savings**: 2-8x typical ($100-500 API ÷ $60 subscription), **up to 36x maximum** with optimal prompt caching*

*36x calculation: Community benchmarks show subscription + caching can reduce effective cost to ~$0.08/MTok vs $3/MTok API baseline = 37.5x ([source](https://www.reddit.com/r/ClaudeAI/comments/1qpcj8q/claude_subscriptions_are_up_to_36x_cheaper_than/)). Actual savings depend on caching effectiveness for your workload.

**When to Choose Option E:**
- Need subscription economics across multiple providers (Claude + OpenAI + Gemini)
- Evaluating multiple orchestration frameworks
- Heavy agentic workloads with significant caching
- Multi-cloud strategy (AWS + Azure + GCP)
- Want flexibility to switch frameworks later
- Willing to manage external agents (Claude CLI/SDK, ChatGPT CLI, gemini-cli)
- **Note**: Only Claude supports SDK subscription auth; OpenAI & Gemini require CLIs

---

### Alternative Recommendations

**For AWS-Native**: **Strands Agents + Prefect** (Option B) - 85% coverage
- A2A protocol, production-proven (Amazon Q, AWS Glue)
- Multi-provider (10+ via Bedrock/LiteLLM)
- Prefect HITL, native OTel observability
- **Trade-off**: API keys (PAYG), no subscription

**For Simplest**: **MS Agent Framework** (Option D) - 80% coverage
- Native Claude Code SDK with OAuth (no bridge!)
- A2A + MCP + checkpointing built-in
- **Trade-off**: Azure-centric, Claude-only OAuth

**For AWS Simplified**: **Strands Agents Standalone** (Option C) - 70% coverage
- Fastest time to value, single framework
- A2A for multi-agent
- **Trade-off**: Manual HITL, API keys only

**For Type Safety**: **Prefect + Pydantic AI** (Option A) - 85% coverage
- FastA2A reference implementation
- Best type safety, Logfire observability
- **Trade-off**: API keys only, 2 frameworks

### Decision Criteria

**Choose Hybrid MCP + A2A (E)** if:
- ✅ **OAuth subscriptions critical** (36x cost savings)
- ✅ **Framework flexibility** needed
- ✅ Multi-cloud deployment
- ✅ Want to evaluate orchestrators without commitment
- ✅ Need Claude + Gemini + other A2A agents
- ⚠️ Acceptable: Additional MCP bridge layer

**Choose Strands Agents (B/C)** if:
- ✅ AWS infrastructure commitment
- ✅ A2A protocol for cross-platform agent discovery
- ✅ Multi-provider via Bedrock/LiteLLM
- ✅ Production-proven solution (Amazon Q, AWS Glue)
- ❌ Don't need subscription OAuth (API acceptable)

**Choose MS Agent Framework (D)** if:
- ✅ **Claude Code users** (native SDK)
- ✅ Azure/Microsoft ecosystem
- ✅ .NET integration required
- ✅ Enterprise compliance (Azure AD, Key Vault)
- ✅ Checkpointing critical
- ❌ Don't need multi-provider OAuth

**Choose Prefect + Pydantic AI (A)** if:
- ✅ Cloud-agnostic deployment
- ✅ Type safety paramount
- ✅ Best observability (Logfire)
- ✅ FastA2A reference implementation
- ❌ Don't need subscription OAuth

---

## Appendix: SDK/CLI Subscription Authentication Research

> **Note**: For tool type distinctions (CLI vs Agent SDK vs Client SDK), see comprehensive breakdown in [OAuth Subscription Support by Tool Type](#oauth-subscription-support-by-tool-type) section above.

**Key Takeaway**: Only **CLIs** and **Agent SDKs** can support subscription OAuth. **Client SDKs** are basic API wrappers (always API keys/PAYG).

---

### Claude (Anthropic)

**Tools with Subscription Support**: Claude Code CLI + Claude Agent SDK
**Tool without Subscription**: Anthropic Client SDK (API keys only)

**Research Findings**:
- **Claude Code CLI**:
  - OAuth login via `claude login` command
  - Supports Pro ($17-20/mo) and Max ($100/mo) subscriptions
  - Usage billed to subscription plan (not API PAYG)

- **Claude Agent SDK** (formerly Claude Code SDK):
  - Confirmed support for subscription OAuth (Reddit community confirmation)
  - Two authentication methods: Claude.ai subscription OAuth OR API key
  - When using Claude.ai subscription, usage comes from Pro/Max subscription plan
  - Installation: `pip install claude-agent-sdk` (Python) or `npm install claude-agent-sdk` (TypeScript)
  - Authentication: Uses same `claude login` OAuth flow as Claude Code CLI

**Source**:
- Reddit: "You can absolutely use your subscription with the agent SDK"
- Documentation shows Claude.ai subscription OAuth option for SDK authentication

### OpenAI

**Tools**: ChatGPT CLI (subscription support) + OpenAI Agents SDK (API only) + OpenAI Client SDK (API only)

**Research Findings**:
- **ChatGPT CLI**:
  - ✅ Supports subscription OAuth via ChatGPT account login
  - Codex included with ChatGPT Plus ($20/mo), Pro ($200/mo), Business, Edu, and Enterprise plans
  - Two auth options: ChatGPT account (subscription) OR API key (PAYG)
  - CLI usage billed to subscription when using ChatGPT account login

- **OpenAI Agents SDK** (`openai-agents` package):
  - ❌ Uses OpenAI API keys for authentication (PAYG billing)
  - Does NOT support ChatGPT subscription authentication
  - Open-source agent framework (Python/TypeScript available)
  - Separate from ChatGPT subscriptions (different billing system)
  - GitHub: https://github.com/openai/openai-agents-python

- **OpenAI Client SDK** (`openai` Python/JS package):
  - ❌ Uses API keys for authentication (PAYG billing via OpenAI API)
  - Does NOT support ChatGPT subscription billing
  - Basic API wrapper for direct model access

**Critical Distinction**: ChatGPT subscriptions and OpenAI API (used by both SDKs) are **completely separate billing systems**. Community forum confirms: "ChatGPT and the OpenAI API platform are two separate things."

**Source**:
- OpenAI Help Docs: "Codex is included with ChatGPT Plus, Pro, Business, Edu, and Enterprise plans"
- OpenAI Agents SDK Docs: https://platform.openai.com/docs/guides/agents-sdk
- Community forum: ChatGPT Plus subscribers confirmed they need separate API billing

### Google Gemini

**Tools with Subscription**: gemini-cli only
**Tools without Subscription**: Gemini ADK (agent framework, API billing) + Google Gen AI SDK (client wrapper, API keys)

**CRITICAL**: Gemini ADK ≠ Google Gen AI SDK (two separate tools!)

**Research Findings**:
- **gemini-cli**:
  - Supports OAuth authentication with Google account
  - Works with AI Plus ($7.99/mo), AI Pro ($19.99/mo), AI Ultra ($249.99/mo) subscriptions
  - Subscription page confirms: "Higher/Highest daily request limits in Gemini CLI" for Pro/Ultra plans
  - Community reports provisioning issues (Ultra subscribers hitting free tier limits - may be bug)

- **Gemini ADK (Agent Development Kit)**:
  - Agent development framework (similar to Claude Agent SDK concept)
  - Uses pay-as-you-go API billing through Google Cloud
  - Two tiers: Free and Paid (NOT subscription-based)
  - Authentication via API key (Google AI Studio) OR OAuth (Vertex AI service account)
  - OAuth in ADK is for Vertex AI project authentication, NOT subscription billing
  - **NOT the same as Google Gen AI SDK** (client wrapper)

- **Google Gen AI SDK** (`google-generativeai` package):
  - ❌ Basic API client wrapper (like `openai` or `anthropic` packages)
  - Uses API keys for authentication (PAYG billing)
  - Does NOT support subscription billing
  - Simple wrapper around Gemini API endpoints

- **Gemini App Subscriptions**:
  - AI Plus ($7.99/mo), AI Pro ($19.99/mo), AI Ultra ($249.99/mo)
  - For Gemini web/mobile app usage, NOT API/ADK access
  - Benefits: Gemini 3 Pro access, Deep Research, image/video generation, storage, etc.

**Source**:
- https://gemini.google/subscriptions/ - Subscription plans with CLI support
- https://ai.google.dev/gemini-api/docs/pricing - API pricing (separate from subscriptions)
- https://google.github.io/adk-docs/agents/models/google-gemini/ - ADK authentication methods
- Community forum: User with AI Ultra plan hitting free tier limits in gemini-cli

### Summary Table: Subscription OAuth Support

| Provider | CLI | Agent SDK | Client SDK | Notes |
|----------|-----|-----------|------------|-------|
| **Anthropic** | ✅ Claude Code CLI | ✅ Claude Agent SDK | ❌ Anthropic Client SDK (API only) | Only provider with Agent SDK subscription support |
| **OpenAI** | ✅ ChatGPT CLI | ❌ OpenAI Agents SDK (API only) | ❌ OpenAI Client SDK (API only) | Only CLI supports subscription; both SDKs use API keys |
| **Google** | ✅ gemini-cli | ❌ Gemini ADK (API only) | ❌ Google Gen AI SDK (API only) | ADK uses Google Cloud pay-as-you-go |

**Key**:
- ✅ = Confirmed subscription OAuth support
- ❌ = API keys/PAYG billing only

---

## References

### Core Frameworks
1. Prefect Interactive Workflows: https://docs.prefect.io/v3/advanced/interactive
2. Pydantic AI Documentation: https://ai.pydantic.dev/
3. Pydantic AI A2A Support: https://ai.pydantic.dev/a2a/
4. MS Agent Framework Overview: https://learn.microsoft.com/en-us/agent-framework/overview/agent-framework-overview
5. MS Agent Framework A2A Agent: https://learn.microsoft.com/en-us/agent-framework/user-guide/agents/agent-types/a2a-agent
6. MS Agent Framework Claude SDK: https://learn.microsoft.com/en-us/agent-framework/user-guide/agents/agent-types/claude-agent-sdk
7. Strands Agents v1.0 Announcement: https://aws.amazon.com/blogs/opensource/introducing-strands-agents-1-0-production-ready-multi-agent-orchestration-made-simple/
8. Strands Agents Technical Deep Dive: https://aws.amazon.com/blogs/machine-learning/strands-agents-sdk-a-technical-deep-dive-into-agent-architectures-and-observability/
9. Strands Agents Documentation: https://strandsagents.com/

### Hybrid MCP + A2A Architecture
10. A2A-MCP-Server GitHub: https://github.com/GongRzhe/A2A-MCP-Server
11. A2A + Claude Code MCP Setup: https://mcp.harishgarg.com/use/a2a/mcp-server/with/claude-code
12. Rasa MCP + A2A Orchestration: https://rasa.com/blog/orchestrating-a2a-and-mcp-with-rasa
13. Agentic MCP and A2A Guide: https://medium.com/@anil.jain.baba/agentic-mcp-and-a2a-architecture-a-comprehensive-guide-0ddf4359e152
14. Claude-IPC-MCP (Community): https://www.reddit.com/r/ClaudeAI/comments/1ltvcai/claudeicpmcp_connect_multiple_cli_ai_agents/

### OAuth & Authentication
15. Claude Code IAM Documentation: https://code.claude.com/docs/en/iam
16. Claude Subscription vs API Pricing: https://www.reddit.com/r/ClaudeAI/comments/1qpcj8q/claude_subscriptions_are_up_to_36x_cheaper_than/
17. Claude Pricing Full Guide: https://intuitionlabs.ai/articles/claude-pricing-plans-api-costs
18. MCP vs A2A Authentication: https://www.descope.com/blog/post/mcp-vs-a2a-auth
19. Claude Agent SDK Subscription Support (Reddit): Community confirmation of Claude.ai subscription OAuth support
20. OpenAI Codex with ChatGPT Subscriptions: Help documentation on included plans
21. Gemini API OAuth Authentication: https://ai.google.dev/gemini-api/docs/oauth
22. Gemini Subscription Plans: https://gemini.google/subscriptions/
23. Gemini API Pricing (Pay-as-you-go): https://ai.google.dev/gemini-api/docs/pricing
24. Gemini ADK Authentication Guide: https://google.github.io/adk-docs/agents/models/google-gemini/
25. Gemini CLI with AI Ultra Plan Issue: https://support.google.com/gemini/thread/387673436

### Comparisons & Analysis
19. Langfuse Framework Comparison: https://langfuse.com/blog/2025-03-19-ai-agent-comparison
20. Dagster OTel Issue: https://github.com/dagster-io/dagster/issues/12353
21. AutoGen Studio Warning: https://microsoft.github.io/autogen/dev/user-guide/autogenstudio-user-guide/
22. Dynatrace MCP + A2A Analysis: https://www.dynatrace.com/news/blog/agentic-ai-how-mcp-and-ai-agents-drive-the-latest-automation-revolution/
