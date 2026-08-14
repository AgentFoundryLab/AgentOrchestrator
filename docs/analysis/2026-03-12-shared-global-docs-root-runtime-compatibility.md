# Analysis: Shared Global Docs Root Runtime Compatibility

**Date**: 2026-03-12
**Scope**: Evaluate shared-global-doc-root options across Claude Code, Codex CLI, Gemini CLI, and other supported runtimes when agents/skills remain per-runtime.

## Conclusion

Using `~/.agents/` as the canonical shared global root for `policy/`, `templates/`, and `workflows/` is a valid installer convention, but it is **not** equally native across runtimes.

- **Codex**: workable, and the cleanest fit if `CODEX_HOME=~/.agents` is set explicitly.
- **Claude**: workable only if `~/.agents` is added to allowed directories; otherwise reads may fail outside the launch root.
- **Gemini**: highest risk. `~/.agents` is not a native global context root and may be inaccessible or ignored without explicit include-directory and trust/sandbox configuration.

## Runtime Assessment

### Claude Code

**Status**: Conditional support.

Observed from official docs:
- Claude Code supports additional accessible directories via CLI/config (`--add-dir`, `additionalDirectories`).
- Official user-level subagent location is `~/.claude/agents/`.

Implication:
- A Claude agent/skill referencing `~/.agents/...` is **not guaranteed** to work unless that directory is explicitly allowed in Claude settings or the session is launched with access to it.
- Shared docs in `~/.agents` therefore require a Claude-side bridge/config change.

Sources:
- https://code.claude.com/docs/en/settings
- https://code.claude.com/docs/en/sub-agents

### Codex CLI

**Status**: Mostly compatible.

Observed from official docs:
- Global `AGENTS.md` is loaded from `CODEX_HOME`, defaulting to `~/.codex`.
- `CODEX_HOME` can be changed.
- Sandboxing and approvals focus primarily on write access; `workspace-write` can extend writable roots.

Implication:
- Codex can support `~/.agents` cleanly if the install/runtime standard sets `CODEX_HOME=~/.agents`.
- Without that, `~/.agents` is an installer convention, not Codex’s documented default global root.

Sources:
- https://developers.openai.com/codex/guides/agents-md
- https://developers.openai.com/codex/config-reference
- https://developers.openai.com/codex/concepts/sandboxing
- https://developers.openai.com/codex/agent-approvals-security

### Gemini CLI

**Status**: High risk / strictest controls.

Observed from official docs:
- Gemini’s native global context file is `~/.gemini/GEMINI.md`.
- Context discovery is rooted in project/ancestor/subdirectory `GEMINI.md` files.
- Extra directories must be included explicitly (`--include-directories` / config).
- Sandbox docs state filesystem access may be limited to the project directory.
- Trusted Folder controls can disable project settings and local memory loading for untrusted workspaces.

Implication:
- `~/.agents` is **not** a native Gemini global docs root.
- A Gemini install that depends on direct reads from `~/.agents/...` is brittle unless the installer also provisions a Gemini-native shim and explicit directory inclusion policy.
- Of current supported runtimes, Gemini is the strongest argument against assuming shared-global-doc direct access will “just work.”

Sources:
- https://google-gemini.github.io/gemini-cli/docs/cli/gemini-md.html
- https://google-gemini.github.io/gemini-cli/docs/get-started/configuration.html
- https://google-gemini.github.io/gemini-cli/docs/cli/sandbox.html
- https://google-gemini.github.io/gemini-cli/docs/cli/trusted-folders.html

## Practical Risks

1. A runtime-local agent/skill may try to read `~/.agents/policy/PRINCIPLES.md` and fail because the harness does not allow reads outside the current workspace or its native config root.
2. A runtime may not treat `~/.agents` as a first-class instruction/context root even if raw file access is possible.
3. Gemini may silently diverge from expected behavior under sandbox or Trusted Folder rules.
4. Cross-runtime docs can drift if we assume all harnesses honor the same absolute-path references.

## Recommended Layout Strategy

Keep:
- Per-runtime agents and skills in native runtime roots.
- Shared global `policy/`, `templates/`, and `workflows` in `~/.agents/` as the installer’s canonical source.

Add runtime bridges:
- **Claude**: configure `additionalDirectories` to include `~/.agents`.
- **Codex**: set `CODEX_HOME=~/.agents` or install a minimal `~/.codex/AGENTS.md` shim that points to `~/.agents`.
- **Gemini**: install a minimal native `~/.gemini/GEMINI.md` shim and avoid depending on direct `~/.agents` reads for critical behavior unless include-directories/trust rules are also configured.

## Decision Guidance

If the goal is maximum portability with minimum runtime-specific config, a single shared global root at `~/.agents` is **not sufficient by itself**.

If the goal is a canonical installer-owned source of truth, `~/.agents` is reasonable **only with explicit per-runtime bridge mechanisms**.
