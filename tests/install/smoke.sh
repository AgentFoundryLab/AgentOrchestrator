#!/usr/bin/env bash
# tests/install/smoke.sh
# Install smoke, conformance, restore/cleanup regression, and idempotency tests.
# Covers T-087, T-088, T-089, T-090.
#
# Usage: bash tests/install/smoke.sh
# Requirements: bash 4.0+, no external dependencies.
# All installs run against a temp HOME — real ~/.claude/ and peers are untouched.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
INSTALL="${PROJECT_ROOT}/install.sh"

# ---------------------------------------------------------------------------
# Test harness
# ---------------------------------------------------------------------------
FAILURES=0
PASS=0

run_test() {
    local name="$1"; shift
    if "$@" 2>&1; then
        echo "PASS: $name"
        PASS=$((PASS + 1))
    else
        echo "FAIL: $name"
        FAILURES=$((FAILURES + 1))
    fi
}

assert_dir_exists() {
    local path="$1"
    if [ -d "$path" ]; then
        return 0
    else
        echo "  [assert] directory missing: $path" >&2
        return 1
    fi
}

assert_dir_absent() {
    local path="$1"
    if [ ! -d "$path" ]; then
        return 0
    else
        echo "  [assert] directory should not exist: $path" >&2
        return 1
    fi
}

assert_file_exists() {
    local path="$1"
    if [ -f "$path" ]; then
        return 0
    else
        echo "  [assert] file missing: $path" >&2
        return 1
    fi
}

assert_any_file_in() {
    local dir="$1"
    if [ -d "$dir" ] && [ -n "$(ls -A "$dir" 2>/dev/null)" ]; then
        return 0
    else
        echo "  [assert] expected files in: $dir" >&2
        return 1
    fi
}

assert_no_file_matching() {
    local dir="$1"
    local pattern="$2"
    local found
    found=$(find "$dir" -name "$pattern" 2>/dev/null | head -1)
    if [ -z "$found" ]; then
        return 0
    else
        echo "  [assert] unexpected file found: $found" >&2
        return 1
    fi
}

assert_file_contains() {
    local file="$1"
    local needle="$2"
    if grep -qF -- "$needle" "$file" 2>/dev/null; then
        return 0
    else
        echo "  [assert] expected '${needle}' in: $file" >&2
        return 1
    fi
}

assert_file_not_contains() {
    local file="$1"
    local needle="$2"
    if grep -qF -- "$needle" "$file" 2>/dev/null; then
        echo "  [assert] unexpected '${needle}' in: $file" >&2
        return 1
    else
        return 0
    fi
}

assert_file_lacks_claude_keys() {
    local file="$1"
    if grep -Eq '^(argument-hint|user-invocable|context|agent):' "$file"; then
        echo "  [assert] unexpected Claude-only frontmatter key in: $file" >&2
        return 1
    fi
    return 0
}

# ---------------------------------------------------------------------------
# T-087: Smoke tests — each runtime, global install, exit code 0
# ---------------------------------------------------------------------------
echo ""
echo "=== T-087: Smoke Tests (Global Install per Runtime) ==="

for rt in claude codex gemini opencode qwen; do
    TMP=$(mktemp -d)
    trap 'rm -rf "$TMP"' EXIT

    test_smoke_global() {
        local runtime="$1"
        local tmp="$2"
        HOME="$tmp" bash "${INSTALL}" --global "--${runtime}" >/dev/null 2>&1
    }

    run_test "smoke-install-global-${rt}" test_smoke_global "${rt}" "${TMP}"

    # Clean up trap and temp dir after each runtime test
    trap - EXIT
    rm -rf "${TMP}"
done

# No runtime flags defaults to claude-only install target
test_smoke_global_default_target_claude_only() {
    local tmp
    tmp=$(mktemp -d)
    HOME="$tmp" bash "${INSTALL}" --global >/dev/null 2>&1
    local ok=0
    assert_dir_exists "${tmp}/.claude/skills" || ok=1
    if [ -d "${tmp}/.agents" ]; then
        echo "  [assert] unexpected default codex install at ${tmp}/.agents" >&2
        ok=1
    fi
    if [ -d "${tmp}/.gemini" ]; then
        echo "  [assert] unexpected default gemini install at ${tmp}/.gemini" >&2
        ok=1
    fi
    rm -rf "$tmp"
    return $ok
}
run_test "smoke-install-global-default-claude-only" test_smoke_global_default_target_claude_only

test_smoke_global_trio_shortcut() {
    local tmp
    tmp=$(mktemp -d)
    HOME="$tmp" bash "${INSTALL}" --global --trio >/dev/null 2>&1
    local ok=0
    assert_dir_exists "${tmp}/.claude/skills" || ok=1
    assert_dir_exists "${tmp}/.agents/skills" || ok=1
    assert_dir_exists "${tmp}/.gemini/policy" || ok=1
    assert_dir_absent "${tmp}/.qwen/skills" || ok=1
    assert_dir_absent "${tmp}/.config/opencode/skills" || ok=1
    rm -rf "$tmp"
    return $ok
}
run_test "smoke-install-global-trio-shortcut" test_smoke_global_trio_shortcut

test_smoke_global_all_shortcut() {
    local tmp
    tmp=$(mktemp -d)
    HOME="$tmp" bash "${INSTALL}" --global --all >/dev/null 2>&1
    local ok=0
    assert_dir_exists "${tmp}/.claude/skills" || ok=1
    assert_dir_exists "${tmp}/.agents/skills" || ok=1
    assert_dir_exists "${tmp}/.gemini/policy" || ok=1
    assert_dir_exists "${tmp}/.qwen/skills" || ok=1
    assert_dir_exists "${tmp}/.config/opencode/skills" || ok=1
    rm -rf "$tmp"
    return $ok
}
run_test "smoke-install-global-all-shortcut" test_smoke_global_all_shortcut

# ---------------------------------------------------------------------------
# T-088: Conformance tests — expected capabilities present/absent per runtime
# ---------------------------------------------------------------------------
echo ""
echo "=== T-088: Conformance Tests (Capability Presence/Absence) ==="

# Claude default: skills present; hooks disabled unless --hooks; agents present
test_conformance_claude_default() {
    local tmp
    tmp=$(mktemp -d)
    HOME="$tmp" bash "${INSTALL}" --global --claude >/dev/null 2>&1
    local ok=0
    assert_dir_exists "${tmp}/.claude/skills" || ok=1
    assert_any_file_in "${tmp}/.claude/skills" || ok=1
    assert_dir_absent "${tmp}/.claude/hooks" || ok=1
    assert_dir_exists "${tmp}/.claude/agents" || ok=1
    assert_file_exists "${tmp}/.claude/templates/task-detail.md" || ok=1
    rm -rf "$tmp"
    return $ok
}
run_test "conformance-claude-default-hooks-absent" test_conformance_claude_default

# Claude with --hooks: hooks present
test_conformance_claude_with_hooks() {
    local tmp
    tmp=$(mktemp -d)
    HOME="$tmp" bash "${INSTALL}" --global --claude --hooks >/dev/null 2>&1
    local ok=0
    assert_dir_exists "${tmp}/.claude/skills" || ok=1
    assert_any_file_in "${tmp}/.claude/skills" || ok=1
    assert_dir_exists "${tmp}/.claude/hooks" || ok=1
    assert_any_file_in "${tmp}/.claude/hooks" || ok=1
    assert_dir_exists "${tmp}/.claude/agents" || ok=1
    rm -rf "$tmp"
    return $ok
}
run_test "conformance-claude-hooks-present-with-flag" test_conformance_claude_with_hooks

# Codex: skills present; hooks absent
test_conformance_codex() {
    local tmp
    tmp=$(mktemp -d)
    HOME="$tmp" bash "${INSTALL}" --global --codex >/dev/null 2>&1
    local ok=0
    assert_dir_exists "${tmp}/.agents/skills" || ok=1
    assert_any_file_in "${tmp}/.agents/skills" || ok=1
    assert_dir_exists "${tmp}/.agents/agents" || ok=1
    assert_dir_absent "${tmp}/.agents/hooks" || ok=1
    rm -rf "$tmp"
    return $ok
}
run_test "conformance-codex-skills-present-hooks-absent" test_conformance_codex

# Codex-only installs must not write Gemini skill artifacts
test_conformance_codex_no_gemini_skill_artifacts() {
    local tmp
    tmp=$(mktemp -d)
    HOME="$tmp" bash "${INSTALL}" --global --codex >/dev/null 2>&1
    local ok=0
    assert_dir_absent "${tmp}/.gemini/skills" || ok=1
    assert_dir_absent "${tmp}/.gemini/agents" || ok=1
    rm -rf "$tmp"
    return $ok
}
run_test "conformance-codex-no-gemini-skill-artifacts" test_conformance_codex_no_gemini_skill_artifacts

# Codex-only installs must not write Claude shared assets
test_conformance_codex_no_claude_artifacts() {
    local tmp
    tmp=$(mktemp -d)
    HOME="$tmp" bash "${INSTALL}" --global --codex >/dev/null 2>&1
    local ok=0
    if [ -d "${tmp}/.claude" ]; then
        echo "  [assert] unexpected claude artifacts for codex-only install: ${tmp}/.claude" >&2
        ok=1
    fi
    rm -rf "$tmp"
    return $ok
}
run_test "conformance-codex-no-claude-artifacts" test_conformance_codex_no_claude_artifacts

# Codex-only installs: global shared assets stay under .agents and refs are codex-scoped.
test_conformance_codex_global_assets_and_scoped_refs() {
    local tmp
    tmp=$(mktemp -d)
    mkdir -p "${tmp}/.codex"
    printf '# AGENTS\n' > "${tmp}/.codex/AGENTS.md"
    HOME="$tmp" bash "${INSTALL}" --global --codex >/dev/null 2>&1
    local ok=0
    assert_file_exists "${tmp}/.agents/policy/PRINCIPLES.md" || ok=1
    assert_file_exists "${tmp}/.agents/workflows/SWE.md" || ok=1
    assert_file_exists "${tmp}/.agents/templates/prd.md" || ok=1
    assert_file_contains "${tmp}/.codex/AGENTS.md" "Read @~/.agents/policy/PRINCIPLES.md" || ok=1
    assert_file_not_contains "${tmp}/.codex/AGENTS.md" "Read @~/.claude/policy/PRINCIPLES.md" || ok=1
    rm -rf "$tmp"
    return $ok
}
run_test "conformance-codex-global-assets-and-scoped-refs" test_conformance_codex_global_assets_and_scoped_refs

# Existing Claude-scoped sentinel block in Codex docs is migrated to Codex-scoped refs.
test_conformance_codex_ref_block_migrated_from_claude_scope() {
    local tmp
    tmp=$(mktemp -d)
    mkdir -p "${tmp}/.codex"
    cat > "${tmp}/.codex/AGENTS.md" <<'EOF'
# AGENTS

<!-- orchestrator:global-refs:start -->
## Orchestrator Policy References
Read @~/.claude/policy/PRINCIPLES.md
Read @~/.claude/policy/RULES.md
<!-- orchestrator:global-refs:end -->
EOF
    HOME="$tmp" bash "${INSTALL}" --global --codex >/dev/null 2>&1
    local ok=0
    assert_file_contains "${tmp}/.codex/AGENTS.md" "Read @~/.agents/policy/PRINCIPLES.md" || ok=1
    assert_file_not_contains "${tmp}/.codex/AGENTS.md" "Read @~/.claude/policy/PRINCIPLES.md" || ok=1
    local sentinel_count
    sentinel_count=$(grep -c "orchestrator:global-refs:start" "${tmp}/.codex/AGENTS.md" 2>/dev/null || true)
    [ "$sentinel_count" -eq 1 ] || ok=1
    rm -rf "$tmp"
    return $ok
}
run_test "conformance-codex-ref-block-migrated-from-claude-scope" test_conformance_codex_ref_block_migrated_from_claude_scope

# Gemini: skills present by default; hooks absent by policy
test_conformance_gemini() {
    local tmp
    tmp=$(mktemp -d)
    HOME="$tmp" bash "${INSTALL}" --global --gemini >/dev/null 2>&1
    local ok=0
    assert_dir_exists "${tmp}/.gemini/skills" || ok=1
    assert_any_file_in "${tmp}/.gemini/skills" || ok=1
    assert_dir_absent "${tmp}/.gemini/hooks" || ok=1
    if [ -d "${tmp}/.gemini/commands" ]; then
        echo "  [assert] unexpected default commands profile artifacts at ${tmp}/.gemini/commands" >&2
        ok=1
    fi
    rm -rf "$tmp"
    return $ok
}
run_test "conformance-gemini-skills-present-hooks-absent" test_conformance_gemini

# Gemini-only installs: global shared assets stay under .gemini and refs are gemini-scoped.
test_conformance_gemini_global_assets_and_scoped_refs() {
    local tmp
    tmp=$(mktemp -d)
    mkdir -p "${tmp}/.gemini"
    printf '# GEMINI\n' > "${tmp}/.gemini/GEMINI.md"
    HOME="$tmp" bash "${INSTALL}" --global --gemini >/dev/null 2>&1
    local ok=0
    assert_file_exists "${tmp}/.gemini/policy/PRINCIPLES.md" || ok=1
    assert_file_exists "${tmp}/.gemini/workflows/SWE.md" || ok=1
    assert_file_exists "${tmp}/.gemini/templates/prd.md" || ok=1
    assert_file_contains "${tmp}/.gemini/GEMINI.md" "Read @~/.gemini/policy/PRINCIPLES.md" || ok=1
    assert_file_not_contains "${tmp}/.gemini/GEMINI.md" "Read @~/.claude/policy/PRINCIPLES.md" || ok=1
    rm -rf "$tmp"
    return $ok
}
run_test "conformance-gemini-global-assets-and-scoped-refs" test_conformance_gemini_global_assets_and_scoped_refs

# Existing Claude-scoped sentinel block in Gemini docs is migrated to Gemini-scoped refs.
test_conformance_gemini_ref_block_migrated_from_claude_scope() {
    local tmp
    tmp=$(mktemp -d)
    mkdir -p "${tmp}/.gemini"
    cat > "${tmp}/.gemini/GEMINI.md" <<'EOF'
# GEMINI

<!-- orchestrator:global-refs:start -->
## Orchestrator Policy References
Read @~/.claude/policy/PRINCIPLES.md
Read @~/.claude/policy/RULES.md
<!-- orchestrator:global-refs:end -->
EOF
    HOME="$tmp" bash "${INSTALL}" --global --gemini >/dev/null 2>&1
    local ok=0
    assert_file_contains "${tmp}/.gemini/GEMINI.md" "Read @~/.gemini/policy/PRINCIPLES.md" || ok=1
    assert_file_not_contains "${tmp}/.gemini/GEMINI.md" "Read @~/.claude/policy/PRINCIPLES.md" || ok=1
    local sentinel_count
    sentinel_count=$(grep -c "orchestrator:global-refs:start" "${tmp}/.gemini/GEMINI.md" 2>/dev/null || true)
    [ "$sentinel_count" -eq 1 ] || ok=1
    rm -rf "$tmp"
    return $ok
}
run_test "conformance-gemini-ref-block-migrated-from-claude-scope" test_conformance_gemini_ref_block_migrated_from_claude_scope

# Gemini uninstall must not touch existing Claude assets when --claude is not selected
test_conformance_gemini_uninstall_does_not_touch_claude() {
    local tmp
    tmp=$(mktemp -d)
    HOME="$tmp" bash "${INSTALL}" --global --claude >/dev/null 2>&1
    local ok=0
    local before after
    before=$(find "${tmp}/.claude" -type f 2>/dev/null | sort | sha256sum | awk '{print $1}')
    HOME="$tmp" bash "${INSTALL}" --global --gemini --uninstall >/dev/null 2>&1
    after=$(find "${tmp}/.claude" -type f 2>/dev/null | sort | sha256sum | awk '{print $1}')
    [ "$before" = "$after" ] || ok=1
    rm -rf "$tmp"
    return $ok
}
run_test "conformance-gemini-uninstall-does-not-touch-claude" test_conformance_gemini_uninstall_does_not_touch_claude

# Codex uninstall must not touch existing Claude assets when --claude is not selected
test_conformance_codex_uninstall_does_not_touch_claude() {
    local tmp
    tmp=$(mktemp -d)
    HOME="$tmp" bash "${INSTALL}" --global --claude >/dev/null 2>&1
    local ok=0
    local before after
    before=$(find "${tmp}/.claude" -type f 2>/dev/null | sort | sha256sum | awk '{print $1}')
    HOME="$tmp" bash "${INSTALL}" --global --codex --uninstall >/dev/null 2>&1
    after=$(find "${tmp}/.claude" -type f 2>/dev/null | sort | sha256sum | awk '{print $1}')
    [ "$before" = "$after" ] || ok=1
    rm -rf "$tmp"
    return $ok
}
run_test "conformance-codex-uninstall-does-not-touch-claude" test_conformance_codex_uninstall_does_not_touch_claude

# Gemini install after Codex should prune duplicate native skills to avoid conflict warnings.
test_conformance_gemini_prunes_alias_duplicates_when_codex_exists() {
    local tmp
    tmp=$(mktemp -d)
    HOME="$tmp" bash "${INSTALL}" --global --codex >/dev/null 2>&1
    HOME="$tmp" bash "${INSTALL}" --global --gemini >/dev/null 2>&1
    local ok=0
    assert_dir_exists "${tmp}/.agents/skills/analyse" || ok=1
    assert_dir_absent "${tmp}/.gemini/skills/analyse" || ok=1
    rm -rf "$tmp"
    return $ok
}
run_test "conformance-gemini-prunes-alias-duplicates-when-codex-exists" test_conformance_gemini_prunes_alias_duplicates_when_codex_exists

# Gemini-only installs must not write Codex skill artifacts (cross-runtime duplication guard)
test_conformance_gemini_no_codex_skill_artifacts() {
    local tmp
    tmp=$(mktemp -d)
    HOME="$tmp" bash "${INSTALL}" --global --gemini >/dev/null 2>&1
    local ok=0
    assert_dir_absent "${tmp}/.agents/skills" || ok=1
    assert_dir_absent "${tmp}/.agents/agents" || ok=1
    rm -rf "$tmp"
    return $ok
}
run_test "conformance-gemini-no-codex-skill-artifacts" test_conformance_gemini_no_codex_skill_artifacts

# Gemini commands profile should preserve markdown content and use TOML literal multiline prompt strings
test_conformance_gemini_commands_body_preserved_literal_prompt() {
    local tmp
    tmp=$(mktemp -d)
    HOME="$tmp" bash "${INSTALL}" --global --gemini --profile commands >/dev/null 2>&1
    local ok=0
    local research_toml
    research_toml="${tmp}/.gemini/commands/research.toml"
    if [ ! -f "$research_toml" ]; then
        echo "  [assert] expected research command TOML at ${research_toml}" >&2
        ok=1
    else
        grep -q "prompt = '''" "$research_toml" || { echo "  [assert] expected TOML literal multiline prompt in ${research_toml}" >&2; ok=1; }
        grep -q "^---$" "$research_toml" || { echo "  [assert] expected markdown horizontal rule preserved in ${research_toml}" >&2; ok=1; }
        grep -q "## References" "$research_toml" || { echo "  [assert] expected non-truncated body content in ${research_toml}" >&2; ok=1; }
    fi
    rm -rf "$tmp"
    return $ok
}
run_test "conformance-gemini-commands-body-preserved-literal-prompt" test_conformance_gemini_commands_body_preserved_literal_prompt

# Gemini commands profile: TOML output present and syntactically valid
test_conformance_gemini_commands_toml_valid() {
    local tmp
    tmp=$(mktemp -d)
    HOME="$tmp" bash "${INSTALL}" --global --gemini --profile commands >/dev/null 2>&1
    local ok=0
    assert_dir_exists "${tmp}/.gemini/commands" || ok=1
    assert_no_file_matching "${tmp}/.gemini/commands" "*.md" || ok=1
    local toml_count
    toml_count=$(find "${tmp}/.gemini/commands" -name "*.toml" -type f 2>/dev/null | wc -l)
    if [ "$toml_count" -eq 0 ]; then
        echo "  [assert] expected .toml files in ${tmp}/.gemini/commands" >&2
        ok=1
    fi
    if command -v python3 >/dev/null 2>&1; then
        if ! python3 - "${tmp}/.gemini/commands" <<'PY'; then
import pathlib
import sys
import tomllib

base = pathlib.Path(sys.argv[1])
files = list(base.rglob("*.toml"))
if not files:
    raise SystemExit(1)

for f in files:
    data = tomllib.loads(f.read_text(encoding="utf-8"))
    if "name" in data:
        raise SystemExit(f"unexpected name key in {f}")
    if "prompt" not in data:
        raise SystemExit(f"missing prompt key in {f}")
    if "$ARGUMENTS" in data["prompt"]:
        raise SystemExit(f"unconverted $ARGUMENTS placeholder in {f}")
PY
            echo "  [assert] TOML parse/shape validation failed for Gemini commands profile" >&2
            ok=1
        fi
    else
        echo "  [warn] python3 missing; skipping TOML parse validation" >&2
    fi
    rm -rf "$tmp"
    return $ok
}
run_test "conformance-gemini-commands-profile-toml-valid" test_conformance_gemini_commands_toml_valid

# OpenCode: skills present; agents present; plugins absent (G-001: SH hooks incompatible with JS/TS plugin system)
test_conformance_opencode() {
    local tmp
    tmp=$(mktemp -d)
    HOME="$tmp" bash "${INSTALL}" --global --opencode >/dev/null 2>&1
    local ok=0
    assert_dir_exists "${tmp}/.config/opencode/skills" || ok=1
    assert_any_file_in "${tmp}/.config/opencode/skills" || ok=1
    assert_dir_exists "${tmp}/.config/opencode/agents" || ok=1
    # plugins dir must NOT be created (GAP G-001: hooks not supported for opencode)
    if [ -d "${tmp}/.config/opencode/plugins" ]; then
        echo "  UNEXPECTED: .config/opencode/plugins exists (hooks should not be installed for opencode)"
        ok=1
    fi
    rm -rf "$tmp"
    return $ok
}
run_test "conformance-opencode-skills-plugins-absent" test_conformance_opencode

# Qwen: skills present; hooks absent
test_conformance_qwen() {
    local tmp
    tmp=$(mktemp -d)
    HOME="$tmp" bash "${INSTALL}" --global --qwen >/dev/null 2>&1
    local ok=0
    assert_dir_exists "${tmp}/.qwen/skills" || ok=1
    assert_any_file_in "${tmp}/.qwen/skills" || ok=1
    assert_dir_exists "${tmp}/.qwen/agents" || ok=1
    assert_dir_absent "${tmp}/.qwen/hooks" || ok=1
    rm -rf "$tmp"
    return $ok
}
run_test "conformance-qwen-skills-present-hooks-absent" test_conformance_qwen

# Codex: no hooks at any sub-path
test_conformance_codex_no_hooks() {
    local tmp
    tmp=$(mktemp -d)
    HOME="$tmp" bash "${INSTALL}" --global --codex >/dev/null 2>&1
    local ok=0
    assert_no_file_matching "${tmp}/.agents" "hooks" || ok=1
    rm -rf "$tmp"
    return $ok
}
run_test "conformance-codex-hooks-subpath-absent" test_conformance_codex_no_hooks

# Gemini: no hooks at any sub-path
test_conformance_gemini_no_hooks() {
    local tmp
    tmp=$(mktemp -d)
    HOME="$tmp" bash "${INSTALL}" --global --gemini >/dev/null 2>&1
    local ok=0
    assert_no_file_matching "${tmp}/.gemini" "hooks" || ok=1
    rm -rf "$tmp"
    return $ok
}
run_test "conformance-gemini-hooks-absent" test_conformance_gemini_no_hooks

# Qwen: no hooks at any sub-path
test_conformance_qwen_no_hooks() {
    local tmp
    tmp=$(mktemp -d)
    HOME="$tmp" bash "${INSTALL}" --global --qwen >/dev/null 2>&1
    local ok=0
    assert_no_file_matching "${tmp}/.qwen" "hooks" || ok=1
    rm -rf "$tmp"
    return $ok
}
run_test "conformance-qwen-hooks-absent" test_conformance_qwen_no_hooks

# Non-Claude skills installs strip Claude-only frontmatter keys
test_non_claude_skills_frontmatter_normalized() {
    local tmp
    tmp=$(mktemp -d)
    HOME="$tmp" bash "${INSTALL}" --global --codex --gemini --opencode --qwen >/dev/null 2>&1
    local ok=0
    local codex_skill opencode_skill qwen_skill gemini_skill
    codex_skill=$(find "${tmp}/.agents/skills" -name "SKILL.md" -type f 2>/dev/null | head -1)
    opencode_skill=$(find "${tmp}/.config/opencode/skills" -name "SKILL.md" -type f 2>/dev/null | head -1)
    qwen_skill=$(find "${tmp}/.qwen/skills" -name "SKILL.md" -type f 2>/dev/null | head -1)
    gemini_skill=$(find "${tmp}/.gemini/skills" -name "SKILL.md" -type f 2>/dev/null | head -1)
    [ -n "$codex_skill" ] || ok=1
    [ -n "$opencode_skill" ] || ok=1
    [ -n "$qwen_skill" ] || ok=1
    [ -n "$codex_skill" ] && assert_file_lacks_claude_keys "$codex_skill" || ok=1
    [ -n "$opencode_skill" ] && assert_file_lacks_claude_keys "$opencode_skill" || ok=1
    [ -n "$qwen_skill" ] && assert_file_lacks_claude_keys "$qwen_skill" || ok=1
    [ -n "$gemini_skill" ] && assert_file_lacks_claude_keys "$gemini_skill" || true
    rm -rf "$tmp"
    return $ok
}
run_test "conformance-non-claude-skills-frontmatter-normalized" test_non_claude_skills_frontmatter_normalized

# Gemini + Codex combined install keeps one active skill source to suppress alias conflicts.
test_conformance_gemini_codex_combined_conflict_suppressed() {
    local tmp
    tmp=$(mktemp -d)
    HOME="$tmp" bash "${INSTALL}" --global --gemini --codex >/dev/null 2>&1
    local ok=0
    assert_dir_exists "${tmp}/.agents/skills" || ok=1
    assert_any_file_in "${tmp}/.agents/skills" || ok=1
    assert_dir_exists "${tmp}/.gemini/policy" || ok=1
    assert_dir_absent "${tmp}/.gemini/skills/analyse" || ok=1
    rm -rf "$tmp"
    return $ok
}
run_test "conformance-gemini-codex-combined-conflict-suppressed" test_conformance_gemini_codex_combined_conflict_suppressed

# Qwen commands profile strips Claude-only keys and converts args placeholder
test_qwen_commands_frontmatter_and_args_transform() {
    local tmp
    tmp=$(mktemp -d)
    HOME="$tmp" bash "${INSTALL}" --global --qwen --profile commands >/dev/null 2>&1
    local ok=0
    local cmd_md
    cmd_md=$(find "${tmp}/.qwen/commands" -name "*.md" -type f 2>/dev/null | head -1)
    if [ -z "$cmd_md" ]; then
        echo "  [assert] expected qwen command markdown file" >&2
        ok=1
    else
        assert_file_lacks_claude_keys "$cmd_md" || ok=1
        grep -q "{{args}}" "$cmd_md" || { echo "  [assert] missing {{args}} in $cmd_md" >&2; ok=1; }
        if grep -q '\$ARGUMENTS' "$cmd_md"; then
            echo "  [assert] found unconverted \$ARGUMENTS in $cmd_md" >&2
            ok=1
        fi
    fi
    rm -rf "$tmp"
    return $ok
}
run_test "conformance-qwen-commands-frontmatter-and-args-transform" test_qwen_commands_frontmatter_and_args_transform

# Codex commands profile should keep project-scoped installs inside target project
test_codex_project_commands_stay_project_scoped() {
    local tmp project
    tmp=$(mktemp -d)
    project="${tmp}/project"
    mkdir -p "$project"
    HOME="$tmp" bash "${INSTALL}" --project "$project" --codex --profile commands >/dev/null 2>&1
    local ok=0
    assert_dir_exists "${project}/.agents/prompts" || ok=1
    assert_any_file_in "${project}/.agents/prompts" || ok=1
    assert_dir_absent "${tmp}/.codex/prompts" || ok=1
    rm -rf "$tmp"
    return $ok
}
run_test "conformance-codex-project-commands-stay-project-scoped" test_codex_project_commands_stay_project_scoped

# Codex agent transform should map multiline YAML tool lists to runtime names
test_codex_agent_multiline_tools_mapped() {
    local tmp
    tmp=$(mktemp -d)
    HOME="$tmp" bash "${INSTALL}" --global --codex >/dev/null 2>&1
    local ok=0
    local architect_md="${tmp}/.agents/agents/architect.md"
    assert_file_exists "$architect_md" || ok=1
    if [ -f "$architect_md" ]; then
        if awk '
            BEGIN { in_fm = 0; bad = 0 }
            /^---$/ { in_fm = !in_fm; next }
            in_fm && /^[[:space:]]*-[[:space:]]*(Read|Write|Edit|Bash|Glob|Grep|WebSearch)$/ { bad = 1 }
            END { exit bad ? 0 : 1 }
        ' "$architect_md"; then
            echo "  [assert] found unnormalized Codex multiline tool names in: $architect_md" >&2
            ok=1
        fi
        assert_file_contains "$architect_md" '  - read' || ok=1
        assert_file_contains "$architect_md" '  - web_search' || ok=1
    fi
    rm -rf "$tmp"
    return $ok
}
run_test "conformance-codex-agent-multiline-tools-mapped" test_codex_agent_multiline_tools_mapped

# Qwen agent transform should map multiline YAML tool lists to runtime names
test_qwen_agent_multiline_tools_mapped() {
    local tmp
    tmp=$(mktemp -d)
    HOME="$tmp" bash "${INSTALL}" --global --qwen >/dev/null 2>&1
    local ok=0
    local architect_md="${tmp}/.qwen/agents/architect.md"
    assert_file_exists "$architect_md" || ok=1
    if [ -f "$architect_md" ]; then
        if awk '
            BEGIN { in_fm = 0; bad = 0 }
            /^---$/ { in_fm = !in_fm; next }
            in_fm && /^[[:space:]]*-[[:space:]]*(Read|Write|Edit|Bash|Glob|Grep|WebSearch)$/ { bad = 1 }
            END { exit bad ? 0 : 1 }
        ' "$architect_md"; then
            echo "  [assert] found unnormalized Qwen multiline tool names in: $architect_md" >&2
            ok=1
        fi
        assert_file_contains "$architect_md" '  - read_file' || ok=1
        assert_file_contains "$architect_md" '  - run_shell_command' || ok=1
        assert_file_contains "$architect_md" '  - web_search' || ok=1
    fi
    rm -rf "$tmp"
    return $ok
}
run_test "conformance-qwen-agent-multiline-tools-mapped" test_qwen_agent_multiline_tools_mapped

# OpenCode agent transform should emit wildcard permission block correctly
test_opencode_agent_wildcard_permission_mapping() {
    local tmp
    tmp=$(mktemp -d)
    HOME="$tmp" bash "${INSTALL}" --global --opencode >/dev/null 2>&1
    local ok=0
    local developer_md="${tmp}/.config/opencode/agents/developer.md"
    assert_file_exists "$developer_md" || ok=1
    if [ -f "$developer_md" ]; then
        assert_file_contains "$developer_md" 'permission:' || ok=1
        assert_file_contains "$developer_md" '  "*": allow' || ok=1
        if awk '
            BEGIN { in_fm = 0; bad = 0 }
            /^---$/ { in_fm = !in_fm; next }
            in_fm && $0 == "0" { bad = 1 }
            END { exit bad ? 0 : 1 }
        ' "$developer_md"; then
            echo "  [assert] unexpected standalone 0 in OpenCode agent frontmatter: $developer_md" >&2
            ok=1
        fi
    fi
    rm -rf "$tmp"
    return $ok
}
run_test "conformance-opencode-agent-wildcard-permission-mapping" test_opencode_agent_wildcard_permission_mapping

# Serena project init should pass the raw project name as a normal argv value
test_serena_project_name_not_shell_quoted() {
    local tmp project bindir args_file
    tmp=$(mktemp -d)
    project="${tmp}/my project"
    bindir="${tmp}/bin"
    args_file="${tmp}/uvx.args"
    mkdir -p "$project" "$bindir"
    cat > "${bindir}/uvx" <<EOF
#!/usr/bin/env bash
printf '%s\n' "\$@" > "${args_file}"
mkdir -p .serena
printf 'name: ok\n' > .serena/project.yml
EOF
    chmod +x "${bindir}/uvx"

    local ok=0
    HOME="$tmp" PATH="${bindir}:$PATH" bash "${INSTALL}" --project "$project" --claude >/dev/null 2>&1
    assert_file_exists "${project}/.serena/project.yml" || ok=1
    assert_file_exists "$args_file" || ok=1
    if [ -f "$args_file" ]; then
        assert_file_contains "$args_file" '--name' || ok=1
        assert_file_contains "$args_file" 'my project' || ok=1
        assert_file_not_contains "$args_file" "'my project'" || ok=1
    fi
    rm -rf "$tmp"
    return $ok
}
run_test "conformance-serena-project-name-not-shell-quoted" test_serena_project_name_not_shell_quoted

# ---------------------------------------------------------------------------
# T-089: Restore/cleanup regression tests for namespaced installs
# ---------------------------------------------------------------------------
echo ""
echo "=== T-089: Restore/Cleanup Regression (Namespaced Installs) ==="

# Install --namespace myorg then --restore — namespaced skills removed
test_restore_namespace() {
    local tmp
    tmp=$(mktemp -d)
    HOME="$tmp" bash "${INSTALL}" --global --claude --namespace myorg >/dev/null 2>&1
    local before_count
    before_count=$(find "${tmp}/.claude/skills" -maxdepth 1 -name "myorg-*" -type d 2>/dev/null | wc -l)
    [ "$before_count" -gt 0 ] || { echo "  [setup] no namespaced skills installed" >&2; rm -rf "$tmp"; return 1; }

    HOME="$tmp" bash "${INSTALL}" --global --claude --namespace myorg --restore >/dev/null 2>&1
    local after_count
    after_count=$(find "${tmp}/.claude/skills" -maxdepth 1 -name "myorg-*" -type d 2>/dev/null | wc -l)
    rm -rf "$tmp"
    [ "$after_count" -eq 0 ]
}
run_test "restore-namespace-myorg-skills-removed" test_restore_namespace

# Install --namespace myorg then --uninstall — namespaced skills removed
test_cleanup_namespace() {
    local tmp
    tmp=$(mktemp -d)
    HOME="$tmp" bash "${INSTALL}" --global --claude --namespace myorg >/dev/null 2>&1
    local before_count
    before_count=$(find "${tmp}/.claude/skills" -maxdepth 1 -name "myorg-*" -type d 2>/dev/null | wc -l)
    [ "$before_count" -gt 0 ] || { echo "  [setup] no namespaced skills installed" >&2; rm -rf "$tmp"; return 1; }

    HOME="$tmp" bash "${INSTALL}" --global --claude --namespace myorg --uninstall >/dev/null 2>&1
    local after_count
    after_count=$(find "${tmp}/.claude/skills" -maxdepth 1 -name "myorg-*" -type d 2>/dev/null | wc -l)
    rm -rf "$tmp"
    [ "$after_count" -eq 0 ]
}
run_test "cleanup-namespace-myorg-skills-removed" test_cleanup_namespace

# Codex: namespace uses dash fallback naming for skills/agents
test_codex_namespace_dash_install() {
    local tmp
    tmp=$(mktemp -d)
    HOME="$tmp" bash "${INSTALL}" --global --codex --namespace myorg >/dev/null 2>&1
    local ok=0
    assert_dir_exists "${tmp}/.agents/skills" || ok=1
    assert_dir_exists "${tmp}/.agents/agents" || ok=1
    local ns_skill_count flat_skill_count ns_agent_count
    ns_skill_count=$(find "${tmp}/.agents/skills" -maxdepth 1 -name "myorg-*" -type d 2>/dev/null | wc -l)
    flat_skill_count=$(find "${tmp}/.agents/skills" -mindepth 1 -maxdepth 1 -type d ! -name "myorg-*" 2>/dev/null | wc -l)
    ns_agent_count=$(find "${tmp}/.agents/agents" -maxdepth 1 -name "myorg-*.md" -type f 2>/dev/null | wc -l)
    [ "$ns_skill_count" -gt 0 ] || ok=1
    [ "$flat_skill_count" -eq 0 ] || ok=1
    [ "$ns_agent_count" -gt 0 ] || ok=1
    if [ -d "${tmp}/.agents/agents/myorg" ]; then
        echo "  [assert] unexpected codex namespace dir exists: ${tmp}/.agents/agents/myorg" >&2
        ok=1
    fi
    rm -rf "$tmp"
    return $ok
}
run_test "codex-namespace-dash-install" test_codex_namespace_dash_install

# Codex: restore with namespace removes namespaced artifacts
test_codex_restore_namespace_targets_dash() {
    local tmp
    tmp=$(mktemp -d)
    HOME="$tmp" bash "${INSTALL}" --global --codex --namespace myorg >/dev/null 2>&1
    local before_count
    before_count=$(find "${tmp}/.agents/skills" -maxdepth 1 -name "myorg-*" -type d 2>/dev/null | wc -l)
    [ "$before_count" -gt 0 ] || { echo "  [setup] no codex skill files installed" >&2; rm -rf "$tmp"; return 1; }

    HOME="$tmp" bash "${INSTALL}" --global --codex --namespace myorg --restore >/dev/null 2>&1
    local after_count agents_after
    after_count=$(find "${tmp}/.agents/skills" -maxdepth 1 -name "myorg-*" -type d 2>/dev/null | wc -l)
    agents_after=$(find "${tmp}/.agents/agents" -maxdepth 1 -name "myorg-*.md" -type f 2>/dev/null | wc -l)
    rm -rf "$tmp"
    [ "$after_count" -eq 0 ] && [ "$agents_after" -eq 0 ]
}
run_test "codex-restore-with-namespace-removes-dash-artifacts" test_codex_restore_namespace_targets_dash

# Codex: cleanup with namespace removes namespaced artifacts
test_codex_cleanup_namespace_targets_dash() {
    local tmp
    tmp=$(mktemp -d)
    HOME="$tmp" bash "${INSTALL}" --global --codex --namespace myorg >/dev/null 2>&1
    local before_count
    before_count=$(find "${tmp}/.agents/skills" -maxdepth 1 -name "myorg-*" -type d 2>/dev/null | wc -l)
    [ "$before_count" -gt 0 ] || { echo "  [setup] no codex skill files installed" >&2; rm -rf "$tmp"; return 1; }

    HOME="$tmp" bash "${INSTALL}" --global --codex --namespace myorg --uninstall >/dev/null 2>&1
    local after_count agents_after
    after_count=$(find "${tmp}/.agents/skills" -maxdepth 1 -name "myorg-*" -type d 2>/dev/null | wc -l)
    agents_after=$(find "${tmp}/.agents/agents" -maxdepth 1 -name "myorg-*.md" -type f 2>/dev/null | wc -l)
    rm -rf "$tmp"
    [ "$after_count" -eq 0 ] && [ "$agents_after" -eq 0 ]
}
run_test "codex-cleanup-with-namespace-removes-dash-artifacts" test_codex_cleanup_namespace_targets_dash

# Gemini: namespace does not rewrite skills identifiers in skills profile
test_gemini_namespace_skills_flat() {
    local tmp
    tmp=$(mktemp -d)
    HOME="$tmp" bash "${INSTALL}" --global --gemini --namespace myorg >/dev/null 2>&1
    local ok=0
    local ns_skill_count flat_skill_count
    ns_skill_count=$(find "${tmp}/.gemini/skills" -maxdepth 1 -name "myorg-*" -type d 2>/dev/null | wc -l)
    flat_skill_count=$(find "${tmp}/.gemini/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
    [ "$flat_skill_count" -gt 0 ] || ok=1
    [ "$ns_skill_count" -eq 0 ] || ok=1
    rm -rf "$tmp"
    return $ok
}
run_test "gemini-namespace-skills-profile-stays-flat" test_gemini_namespace_skills_flat

# Gemini: commands profile uses native namespace directories
test_gemini_namespace_commands_subdirectory() {
    local tmp
    tmp=$(mktemp -d)
    HOME="$tmp" bash "${INSTALL}" --global --gemini --profile commands --namespace myorg >/dev/null 2>&1
    local ok=0
    assert_dir_exists "${tmp}/.gemini/commands/myorg" || ok=1
    local ns_toml_count
    ns_toml_count=$(find "${tmp}/.gemini/commands/myorg" -maxdepth 1 -name "*.toml" -type f 2>/dev/null | wc -l)
    [ "$ns_toml_count" -gt 0 ] || ok=1
    rm -rf "$tmp"
    return $ok
}
run_test "gemini-namespace-commands-profile-subdirectory" test_gemini_namespace_commands_subdirectory

# Flat install then restore — flat skills removed
test_restore_flat() {
    local tmp
    tmp=$(mktemp -d)
    HOME="$tmp" bash "${INSTALL}" --global --claude --no-namespace >/dev/null 2>&1
    assert_dir_exists "${tmp}/.claude/skills" || { rm -rf "$tmp"; return 1; }

    HOME="$tmp" bash "${INSTALL}" --global --claude --no-namespace --restore >/dev/null 2>&1
    local after_count
    after_count=$(find "${tmp}/.claude/skills" -type f 2>/dev/null | wc -l)
    rm -rf "$tmp"
    [ "$after_count" -eq 0 ]
}
run_test "restore-flat-skills-removed" test_restore_flat

# Two namespaces: install both, cleanup one, verify other intact
test_two_namespace_isolation() {
    local tmp
    tmp=$(mktemp -d)
    HOME="$tmp" bash "${INSTALL}" --global --claude --namespace myorg >/dev/null 2>&1
    HOME="$tmp" bash "${INSTALL}" --global --claude --namespace otherorg >/dev/null 2>&1

    local myorg_before otherorg_before
    myorg_before=$(find "${tmp}/.claude/skills" -maxdepth 1 -name "myorg-*" -type d 2>/dev/null | wc -l)
    otherorg_before=$(find "${tmp}/.claude/skills" -maxdepth 1 -name "otherorg-*" -type d 2>/dev/null | wc -l)
    [ "$myorg_before" -gt 0 ] || { echo "  [setup] myorg skills missing" >&2; rm -rf "$tmp"; return 1; }
    [ "$otherorg_before" -gt 0 ] || { echo "  [setup] otherorg skills missing" >&2; rm -rf "$tmp"; return 1; }

    # Cleanup only myorg namespace
    HOME="$tmp" bash "${INSTALL}" --global --claude --namespace myorg --uninstall >/dev/null 2>&1

    local myorg_after otherorg_after
    myorg_after=$(find "${tmp}/.claude/skills" -maxdepth 1 -name "myorg-*" -type d 2>/dev/null | wc -l)
    otherorg_after=$(find "${tmp}/.claude/skills" -maxdepth 1 -name "otherorg-*" -type d 2>/dev/null | wc -l)
    rm -rf "$tmp"
    [ "$myorg_after" -eq 0 ] && [ "$otherorg_after" -gt 0 ]
}
run_test "two-namespaces-cleanup-one-leaves-other-intact" test_two_namespace_isolation

# ---------------------------------------------------------------------------
# T-090: Idempotency tests for repeated installs
# ---------------------------------------------------------------------------
echo ""
echo "=== T-090: Idempotency Tests ==="

# Run install twice, second run exits 0 and creates 0 new files
test_idempotent_double_install() {
    local tmp
    tmp=$(mktemp -d)
    HOME="$tmp" bash "${INSTALL}" --global --claude >/dev/null 2>&1
    local output
    output=$(HOME="$tmp" bash "${INSTALL}" --global --claude 2>&1)
    rm -rf "$tmp"
    echo "$output" | grep -q "Created:.*0"
}
run_test "idempotent-double-install-claude" test_idempotent_double_install

# Double install codex
test_idempotent_double_install_codex() {
    local tmp
    tmp=$(mktemp -d)
    HOME="$tmp" bash "${INSTALL}" --global --codex >/dev/null 2>&1
    local output
    output=$(HOME="$tmp" bash "${INSTALL}" --global --codex 2>&1)
    rm -rf "$tmp"
    echo "$output" | grep -q "Created:.*0"
}
run_test "idempotent-double-install-codex" test_idempotent_double_install_codex

# Install claude+codex, then install claude alone — codex artifacts not removed
test_idempotent_subset_install() {
    local tmp
    tmp=$(mktemp -d)
    HOME="$tmp" bash "${INSTALL}" --global --claude --codex >/dev/null 2>&1
    local codex_count_before
    codex_count_before=$(find "${tmp}/.agents/skills" -type d 2>/dev/null | wc -l)

    HOME="$tmp" bash "${INSTALL}" --global --claude >/dev/null 2>&1
    local codex_count_after
    codex_count_after=$(find "${tmp}/.agents/skills" -type d 2>/dev/null | wc -l)
    rm -rf "$tmp"
    [ "$codex_count_after" -eq "$codex_count_before" ]
}
run_test "idempotent-subset-install-preserves-codex-artifacts" test_idempotent_subset_install

# Policy-ref injection is idempotent (no duplicates on second run)
test_idempotent_policy_refs() {
    local tmp
    tmp=$(mktemp -d)
    # Create a CLAUDE.md for ref injection to target
    mkdir -p "${tmp}/.claude"
    printf '# Test\n' > "${tmp}/.claude/CLAUDE.md"

    HOME="$tmp" bash "${INSTALL}" --global --claude >/dev/null 2>&1
    HOME="$tmp" bash "${INSTALL}" --global --claude >/dev/null 2>&1

    # Count sentinel occurrences: should be exactly 1
    local sentinel_count
    sentinel_count=$(grep -c "orchestrator:global-refs:start" "${tmp}/.claude/CLAUDE.md" 2>/dev/null || true)
    rm -rf "$tmp"
    [ "$sentinel_count" -eq 1 ]
}
run_test "idempotent-policy-ref-injection-no-duplicates" test_idempotent_policy_refs

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
echo "==================================="
echo "Results: $((PASS + FAILURES)) tests, ${PASS} passed, ${FAILURES} failed"
echo "==================================="

[ "$FAILURES" -eq 0 ] && echo "ALL TESTS PASSED" || { echo "FAILURES: $FAILURES"; exit 1; }
