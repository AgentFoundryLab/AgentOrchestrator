#!/usr/bin/env bash
# package/install/runtimes.sh
# Canonical runtime registry for AgentOrchestrator installer.
#
# REQUIREMENTS: bash 4.0+ (associative arrays). macOS ships bash 3.2 by default.
#   Install bash 4+: brew install bash
#
# USAGE: Source this file; do not execute it directly.
#   . "${PACKAGE_DIR}/install/runtimes.sh"
#
# No side effects on source — only variable/array declarations and one validation
# function. Safe to source multiple times (re-declaration is idempotent).
#
# ============================================================================
# FRONTMATTER TRANSFORM SPECIFICATION (T-066)
# ============================================================================
#
# Defines how SKILL.md content maps to each runtime's commands format when
# --commands compatibility mode is used. This is a documentation-only spec;
# the actual transform implementation lives in install.sh transform functions.
#
# Source format (SKILL.md frontmatter, YAML):
#   ---
#   name: <skill-name>
#   description: <one-line description>
#   context: <fork|inject|inline>
#   agent: <agent-name>          # optional
#   user-invocable: <true|false> # optional
#   ---
#   <body content in Markdown>
#
# Per-runtime transform rules:
#
# 1. CLAUDE (target: .claude/skills/<name>/SKILL.md)
#    - SKILL.md is the native format. No transform needed.
#    - Frontmatter keys: all preserved as-is.
#    - Skills installed directly from package/skills/<name>/SKILL.md.
#    - Compatibility path (.claude/commands/*.md) is legacy; not written by default.
#
# 2. CODEX (target: .agents/skills/<name>/SKILL.md)
#    - SKILL.md is the native format. No transform needed for skills mode.
#    - Compatibility commands path (~/.codex/prompts/<name>.md):
#        Strip YAML frontmatter block (---...---).
#        Keep body content verbatim.
#        Filename: <skill-name>.md
#        Unsupported frontmatter keys: all dropped (body only).
#    - Invocation: /prompts:<name> (deprecated upstream; skills preferred)
#
# 3. GEMINI (target: .gemini/commands/<name>.toml)
#    - No skills support. Commands only.
#    - Transform SKILL.md → TOML:
#        [command]
#        name = "<skill-name>"
#        description = "<description from frontmatter>"
#        # body content placed in `prompt` key, escaped as TOML multiline string
#        prompt = """
#        <body content>
#        """
#    - Frontmatter keys preserved: name, description.
#    - Frontmatter keys dropped with warning: context, agent, user-invocable.
#    - Subdirectory namespacing: commands/<ns>/<name>.toml for namespaced installs.
#    - Scripts: !{...} inline shell — no separate file installation.
#
# 4. OPENCODE (target: .opencode/skills/<name>/SKILL.md)
#    - SKILL.md is native format. No transform needed for skills mode.
#    - Commands path (.opencode/commands/<name>.md):
#        Same as skills but placed in commands/ directory.
#        Frontmatter: all keys preserved.
#    - Cross-read: OpenCode also reads .claude/skills and .agents/skills.
#        Installer does NOT duplicate artifacts to those paths for OpenCode-only installs.
#    - Plugin hooks: .opencode/plugins/ (JS/TS event subscriptions, not SKILL.md files).
#
# 5. QWEN (target: .qwen/skills/<name>/SKILL.md)
#    - SKILL.md is native format. No transform needed for skills mode.
#    - Commands path (.qwen/commands/<name>.md):
#        Markdown format preferred. TOML legacy not written by default.
#        Frontmatter: all keys preserved.
#    - Scripts: !{...} inline and optional scripts/ helpers in skill packages.
#
# Determinism guarantee: given the same SKILL.md input, the transform always
# produces the same output regardless of install order or runtime context.
#
# ============================================================================

# Guard against double-sourcing
if [[ "${_ORCHESTRATOR_RUNTIMES_LOADED:-}" == "1" ]]; then
    return 0
fi
_ORCHESTRATOR_RUNTIMES_LOADED=1

# Ordered list of all supported runtime slugs.
RUNTIMES=(claude codex gemini opencode qwen)

# ---------------------------------------------------------------------------
# Per-runtime associative arrays (keyed by runtime slug)
# ---------------------------------------------------------------------------

# Global (user-scope) config directory — absolute path, no trailing slash.
# Expand ~ at declare-time so arrays are ready for immediate use.
declare -A RUNTIME_CONF_DIR
RUNTIME_CONF_DIR[claude]="${HOME}/.claude"
RUNTIME_CONF_DIR[codex]="${HOME}/.agents"
RUNTIME_CONF_DIR[gemini]="${HOME}/.gemini"
RUNTIME_CONF_DIR[opencode]="${HOME}/.config/opencode"
RUNTIME_CONF_DIR[qwen]="${HOME}/.qwen"

# Project-local config directory — relative path from project root, no leading slash.
declare -A RUNTIME_PROJECT_DIR
RUNTIME_PROJECT_DIR[claude]=".claude"
RUNTIME_PROJECT_DIR[codex]=".agents"
RUNTIME_PROJECT_DIR[gemini]=".gemini"
RUNTIME_PROJECT_DIR[opencode]=".opencode"
RUNTIME_PROJECT_DIR[qwen]=".qwen"

# Policy-ref injection target filename — relative to RUNTIME_CONF_DIR (global)
# or project root (project). Empty string = no policy-ref injection for this runtime.
declare -A RUNTIME_DOC_FILE
RUNTIME_DOC_FILE[claude]="CLAUDE.md"
RUNTIME_DOC_FILE[codex]="AGENTS.md"
RUNTIME_DOC_FILE[gemini]="GEMINI.md"
RUNTIME_DOC_FILE[opencode]="opencode.json"
RUNTIME_DOC_FILE[qwen]="QWEN.md"

# Global doc injection directory override (when different from RUNTIME_CONF_DIR).
# Empty = use RUNTIME_CONF_DIR[rt] as the injection base directory.
declare -A RUNTIME_DOC_DIR_OVERRIDE
RUNTIME_DOC_DIR_OVERRIDE[claude]=""
RUNTIME_DOC_DIR_OVERRIDE[codex]="${HOME}/.codex"
RUNTIME_DOC_DIR_OVERRIDE[gemini]=""
RUNTIME_DOC_DIR_OVERRIDE[opencode]=""
RUNTIME_DOC_DIR_OVERRIDE[qwen]=""

# Relative path for skills installation (from RUNTIME_CONF_DIR or RUNTIME_PROJECT_DIR).
# Empty string = skills not supported by this runtime.
declare -A RUNTIME_SKILLS_PATH
RUNTIME_SKILLS_PATH[claude]="skills"
RUNTIME_SKILLS_PATH[codex]="skills"
RUNTIME_SKILLS_PATH[gemini]=""
RUNTIME_SKILLS_PATH[opencode]="skills"
RUNTIME_SKILLS_PATH[qwen]="skills"

# Relative path for agents installation.
declare -A RUNTIME_AGENTS_PATH
RUNTIME_AGENTS_PATH[claude]="agents"
RUNTIME_AGENTS_PATH[codex]="agents"
RUNTIME_AGENTS_PATH[gemini]=""
RUNTIME_AGENTS_PATH[opencode]="agents"
RUNTIME_AGENTS_PATH[qwen]="agents"

# Relative path for commands installation (from RUNTIME_CONF_DIR or RUNTIME_PROJECT_DIR).
declare -A RUNTIME_COMMANDS_PATH
RUNTIME_COMMANDS_PATH[claude]="commands"
RUNTIME_COMMANDS_PATH[codex]="prompts"
RUNTIME_COMMANDS_PATH[gemini]="commands"
RUNTIME_COMMANDS_PATH[opencode]="commands"
RUNTIME_COMMANDS_PATH[qwen]="commands"

# Codex compatibility commands install base (overrides RUNTIME_CONF_DIR for commands only).
# Empty = use RUNTIME_CONF_DIR[rt].
declare -A RUNTIME_COMMANDS_CONF_OVERRIDE
RUNTIME_COMMANDS_CONF_OVERRIDE[claude]=""
RUNTIME_COMMANDS_CONF_OVERRIDE[codex]="${HOME}/.codex"
RUNTIME_COMMANDS_CONF_OVERRIDE[gemini]=""
RUNTIME_COMMANDS_CONF_OVERRIDE[opencode]=""
RUNTIME_COMMANDS_CONF_OVERRIDE[qwen]=""

# Relative path for hooks/plugins installation. Empty = hooks not supported.
# NOTE: opencode hooks are JS/TS plugin event subscribers (.opencode/plugins/), not
# bash command hooks. Claude-format SH hooks are incompatible. GAP: no adapter exists.
# See docs/development/ISSUES.md G-001.
declare -A RUNTIME_HOOKS_PATH
RUNTIME_HOOKS_PATH[claude]="hooks"
RUNTIME_HOOKS_PATH[codex]=""
RUNTIME_HOOKS_PATH[gemini]=""
RUNTIME_HOOKS_PATH[opencode]=""
RUNTIME_HOOKS_PATH[qwen]=""

# Scripts model: "embedded" (scripts/ within skill packages, copied as part of skill dir)
#                "inline-only" (shell execution via !{...} in command bodies; no dir install)
declare -A RUNTIME_SCRIPTS_MODE
RUNTIME_SCRIPTS_MODE[claude]="embedded"
RUNTIME_SCRIPTS_MODE[codex]="embedded"
RUNTIME_SCRIPTS_MODE[gemini]="inline-only"
RUNTIME_SCRIPTS_MODE[opencode]="embedded"
RUNTIME_SCRIPTS_MODE[qwen]="embedded"

# Capability flags
declare -A RUNTIME_SUPPORTS_HOOKS
RUNTIME_SUPPORTS_HOOKS[claude]="true"
RUNTIME_SUPPORTS_HOOKS[codex]="false"
RUNTIME_SUPPORTS_HOOKS[gemini]="false"
RUNTIME_SUPPORTS_HOOKS[opencode]="false"  # GAP G-001: SH hooks incompatible with JS/TS plugin system (T-093)
RUNTIME_SUPPORTS_HOOKS[qwen]="false"

declare -A RUNTIME_SUPPORTS_SKILLS
RUNTIME_SUPPORTS_SKILLS[claude]="true"
RUNTIME_SUPPORTS_SKILLS[codex]="true"
RUNTIME_SUPPORTS_SKILLS[gemini]="false"
RUNTIME_SUPPORTS_SKILLS[opencode]="true"
RUNTIME_SUPPORTS_SKILLS[qwen]="true"

declare -A RUNTIME_SUPPORTS_COMMANDS
RUNTIME_SUPPORTS_COMMANDS[claude]="true"
RUNTIME_SUPPORTS_COMMANDS[codex]="true"
RUNTIME_SUPPORTS_COMMANDS[gemini]="true"
RUNTIME_SUPPORTS_COMMANDS[opencode]="true"
RUNTIME_SUPPORTS_COMMANDS[qwen]="true"

declare -A RUNTIME_SUPPORTS_SCRIPTS
RUNTIME_SUPPORTS_SCRIPTS[claude]="true"
RUNTIME_SUPPORTS_SCRIPTS[codex]="true"
RUNTIME_SUPPORTS_SCRIPTS[gemini]="true"
RUNTIME_SUPPORTS_SCRIPTS[opencode]="true"
RUNTIME_SUPPORTS_SCRIPTS[qwen]="true"

# Namespace mode for this runtime.
# "dot-prefix"   — namespace becomes a dot-prefix on artifact directory name
#                  e.g., skills/myorg.spec/ → /myorg.spec
# "subdirectory" — namespace becomes path segments
#                  e.g., commands/myorg/spec.toml → /myorg:spec
declare -A RUNTIME_NAMESPACE_MODE
RUNTIME_NAMESPACE_MODE[claude]="dot-prefix"
RUNTIME_NAMESPACE_MODE[codex]="dot-prefix"
RUNTIME_NAMESPACE_MODE[gemini]="subdirectory"
RUNTIME_NAMESPACE_MODE[opencode]="subdirectory"
RUNTIME_NAMESPACE_MODE[qwen]="dot-prefix"

# Commands artifact format.
declare -A RUNTIME_DOC_FORMAT
RUNTIME_DOC_FORMAT[claude]="markdown"
RUNTIME_DOC_FORMAT[codex]="markdown"    # PARTIAL G-003: Claude-specific frontmatter keys stripped (T-094); full key map pending T-095
RUNTIME_DOC_FORMAT[gemini]="toml"       # GAP G-002: TOML transform not implemented (T-092); PARTIAL G-003 (T-094/T-095)
RUNTIME_DOC_FORMAT[opencode]="markdown" # PARTIAL G-003: Claude-specific frontmatter keys stripped (T-094); full key map pending T-095
RUNTIME_DOC_FORMAT[qwen]="markdown"    # PARTIAL G-003: Claude-specific frontmatter keys stripped (T-094); full key map pending T-095

# ---------------------------------------------------------------------------
# register_runtime_defaults — validate all arrays are populated
# ---------------------------------------------------------------------------
# Iterates RUNTIMES and checks that every associative array above has an entry
# for each declared runtime. Exits non-zero and prints a diagnostic if any
# entry is missing. Call this after sourcing to verify registry completeness.
#
# Usage:
#   register_runtime_defaults || exit 1
register_runtime_defaults() {
    local errors=0

    # Arrays that must have a value (even if empty string) for every runtime.
    local required_arrays=(
        RUNTIME_CONF_DIR
        RUNTIME_PROJECT_DIR
        RUNTIME_DOC_FILE
        RUNTIME_DOC_DIR_OVERRIDE
        RUNTIME_SKILLS_PATH
        RUNTIME_AGENTS_PATH
        RUNTIME_COMMANDS_PATH
        RUNTIME_COMMANDS_CONF_OVERRIDE
        RUNTIME_HOOKS_PATH
        RUNTIME_SCRIPTS_MODE
        RUNTIME_SUPPORTS_HOOKS
        RUNTIME_SUPPORTS_SKILLS
        RUNTIME_SUPPORTS_COMMANDS
        RUNTIME_SUPPORTS_SCRIPTS
        RUNTIME_NAMESPACE_MODE
        RUNTIME_DOC_FORMAT
    )

    for rt in "${RUNTIMES[@]}"; do
        for arr in "${required_arrays[@]}"; do
            # Use nameref to check key presence
            local -n _arr_ref="${arr}"
            if [[ ! -v _arr_ref["${rt}"] ]]; then
                echo "[ERROR] runtimes.sh: ${arr}[${rt}] is not set" >&2
                ((++errors))
            fi
            unset -n _arr_ref
        done
    done

    # Validate boolean capability flags
    for rt in "${RUNTIMES[@]}"; do
        for flag in RUNTIME_SUPPORTS_HOOKS RUNTIME_SUPPORTS_SKILLS \
                    RUNTIME_SUPPORTS_COMMANDS RUNTIME_SUPPORTS_SCRIPTS; do
            local -n _flag_ref="${flag}"
            local val="${_flag_ref[${rt}]:-}"
            if [[ "$val" != "true" && "$val" != "false" ]]; then
                echo "[ERROR] runtimes.sh: ${flag}[${rt}] must be 'true' or 'false', got: '${val}'" >&2
                ((++errors))
            fi
            unset -n _flag_ref
        done
    done

    # Validate scripts mode values
    for rt in "${RUNTIMES[@]}"; do
        local mode="${RUNTIME_SCRIPTS_MODE[${rt}]:-}"
        if [[ "$mode" != "embedded" && "$mode" != "inline-only" ]]; then
            echo "[ERROR] runtimes.sh: RUNTIME_SCRIPTS_MODE[${rt}] must be 'embedded' or 'inline-only', got: '${mode}'" >&2
            ((++errors))
        fi
    done

    # Validate namespace mode values
    for rt in "${RUNTIMES[@]}"; do
        local ns_mode="${RUNTIME_NAMESPACE_MODE[${rt}]:-}"
        if [[ "$ns_mode" != "dot-prefix" && "$ns_mode" != "subdirectory" ]]; then
            echo "[ERROR] runtimes.sh: RUNTIME_NAMESPACE_MODE[${rt}] must be 'dot-prefix' or 'subdirectory', got: '${ns_mode}'" >&2
            ((++errors))
        fi
    done

    if [[ $errors -gt 0 ]]; then
        echo "[ERROR] runtimes.sh: registry validation failed with ${errors} error(s)" >&2
        return 1
    fi

    return 0
}
