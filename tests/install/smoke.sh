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

# ---------------------------------------------------------------------------
# T-088: Conformance tests — expected capabilities present/absent per runtime
# ---------------------------------------------------------------------------
echo ""
echo "=== T-088: Conformance Tests (Capability Presence/Absence) ==="

# Claude: skills + hooks present; agents present
test_conformance_claude() {
    local tmp
    tmp=$(mktemp -d)
    HOME="$tmp" bash "${INSTALL}" --global --claude >/dev/null 2>&1
    local ok=0
    assert_dir_exists "${tmp}/.claude/skills" || ok=1
    assert_any_file_in "${tmp}/.claude/skills" || ok=1
    assert_dir_exists "${tmp}/.claude/hooks" || ok=1
    assert_any_file_in "${tmp}/.claude/hooks" || ok=1
    assert_dir_exists "${tmp}/.claude/agents" || ok=1
    rm -rf "$tmp"
    return $ok
}
run_test "conformance-claude-skills-hooks-present" test_conformance_claude

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

# Codex target still installs shared global policy files under ~/.claude
test_conformance_codex_shared_policy_present() {
    local tmp
    tmp=$(mktemp -d)
    HOME="$tmp" bash "${INSTALL}" --global --codex >/dev/null 2>&1
    local ok=0
    if [ ! -f "${tmp}/.claude/policy/PRINCIPLES.md" ]; then
        echo "  [assert] missing shared policy file: ${tmp}/.claude/policy/PRINCIPLES.md" >&2
        ok=1
    fi
    if [ ! -f "${tmp}/.claude/policy/RULES.md" ]; then
        echo "  [assert] missing shared policy file: ${tmp}/.claude/policy/RULES.md" >&2
        ok=1
    fi
    rm -rf "$tmp"
    return $ok
}
run_test "conformance-codex-shared-policy-present" test_conformance_codex_shared_policy_present

# Gemini: no skills dir, no hooks dir; .toml commands present (T-092)
test_conformance_gemini() {
    local tmp
    tmp=$(mktemp -d)
    HOME="$tmp" bash "${INSTALL}" --global --gemini >/dev/null 2>&1
    local ok=0
    assert_dir_absent "${tmp}/.gemini/skills" || ok=1
    assert_dir_absent "${tmp}/.gemini/hooks" || ok=1
    # T-092: TOML command files must be present
    assert_dir_exists "${tmp}/.gemini/commands" || ok=1
    assert_no_file_matching "${tmp}/.gemini/commands" "*.md" || ok=1
    local toml_count
    toml_count=$(find "${tmp}/.gemini/commands" -name "*.toml" 2>/dev/null | wc -l)
    if [ "$toml_count" -eq 0 ]; then
        echo "  [assert] expected .toml files in ${tmp}/.gemini/commands" >&2
        ok=1
    fi
    rm -rf "$tmp"
    return $ok
}
run_test "conformance-gemini-no-skills-no-hooks-toml-present" test_conformance_gemini

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
    before_count=$(find "${tmp}/.claude/skills" -maxdepth 1 -name "myorg.*" -type d 2>/dev/null | wc -l)
    [ "$before_count" -gt 0 ] || { echo "  [setup] no namespaced skills installed" >&2; rm -rf "$tmp"; return 1; }

    HOME="$tmp" bash "${INSTALL}" --global --claude --namespace myorg --restore >/dev/null 2>&1
    local after_count
    after_count=$(find "${tmp}/.claude/skills" -maxdepth 1 -name "myorg.*" -type d 2>/dev/null | wc -l)
    rm -rf "$tmp"
    [ "$after_count" -eq 0 ]
}
run_test "restore-namespace-myorg-skills-removed" test_restore_namespace

# Install --namespace myorg then --cleanup — namespaced skills removed
test_cleanup_namespace() {
    local tmp
    tmp=$(mktemp -d)
    HOME="$tmp" bash "${INSTALL}" --global --claude --namespace myorg >/dev/null 2>&1
    local before_count
    before_count=$(find "${tmp}/.claude/skills" -maxdepth 1 -name "myorg.*" -type d 2>/dev/null | wc -l)
    [ "$before_count" -gt 0 ] || { echo "  [setup] no namespaced skills installed" >&2; rm -rf "$tmp"; return 1; }

    HOME="$tmp" bash "${INSTALL}" --global --claude --namespace myorg --cleanup >/dev/null 2>&1
    local after_count
    after_count=$(find "${tmp}/.claude/skills" -maxdepth 1 -name "myorg.*" -type d 2>/dev/null | wc -l)
    rm -rf "$tmp"
    [ "$after_count" -eq 0 ]
}
run_test "cleanup-namespace-myorg-skills-removed" test_cleanup_namespace

# Codex: namespace flag is ignored; install remains flat and does not create namespaced dirs
test_codex_namespace_ignored_flat_install() {
    local tmp
    tmp=$(mktemp -d)
    HOME="$tmp" bash "${INSTALL}" --global --codex --namespace myorg >/dev/null 2>&1
    local ok=0
    assert_dir_exists "${tmp}/.agents/skills" || ok=1
    assert_dir_exists "${tmp}/.agents/agents" || ok=1
    local ns_skill_count flat_skill_count
    ns_skill_count=$(find "${tmp}/.agents/skills" -maxdepth 1 -name "myorg.*" -type d 2>/dev/null | wc -l)
    flat_skill_count=$(find "${tmp}/.agents/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
    [ "$ns_skill_count" -eq 0 ] || ok=1
    [ "$flat_skill_count" -gt 0 ] || ok=1
    if [ -d "${tmp}/.agents/agents/myorg" ]; then
        echo "  [assert] unexpected codex namespace dir exists: ${tmp}/.agents/agents/myorg" >&2
        ok=1
    fi
    rm -rf "$tmp"
    return $ok
}
run_test "codex-namespace-ignored-flat-install" test_codex_namespace_ignored_flat_install

# Codex: restore with namespace still targets flat install paths
test_codex_restore_namespace_targets_flat() {
    local tmp
    tmp=$(mktemp -d)
    HOME="$tmp" bash "${INSTALL}" --global --codex --namespace myorg >/dev/null 2>&1
    local before_count
    before_count=$(find "${tmp}/.agents/skills" -type f 2>/dev/null | wc -l)
    [ "$before_count" -gt 0 ] || { echo "  [setup] no codex skill files installed" >&2; rm -rf "$tmp"; return 1; }

    HOME="$tmp" bash "${INSTALL}" --global --codex --namespace myorg --restore >/dev/null 2>&1
    local after_count
    after_count=$(find "${tmp}/.agents/skills" -type f 2>/dev/null | wc -l)
    rm -rf "$tmp"
    [ "$after_count" -eq 0 ]
}
run_test "codex-restore-with-namespace-removes-flat-skills" test_codex_restore_namespace_targets_flat

# Codex: cleanup with namespace still targets flat install paths
test_codex_cleanup_namespace_targets_flat() {
    local tmp
    tmp=$(mktemp -d)
    HOME="$tmp" bash "${INSTALL}" --global --codex --namespace myorg >/dev/null 2>&1
    local before_count
    before_count=$(find "${tmp}/.agents/skills" -type f 2>/dev/null | wc -l)
    [ "$before_count" -gt 0 ] || { echo "  [setup] no codex skill files installed" >&2; rm -rf "$tmp"; return 1; }

    HOME="$tmp" bash "${INSTALL}" --global --codex --namespace myorg --cleanup >/dev/null 2>&1
    local after_count
    after_count=$(find "${tmp}/.agents/skills" -type f 2>/dev/null | wc -l)
    rm -rf "$tmp"
    [ "$after_count" -eq 0 ]
}
run_test "codex-cleanup-with-namespace-removes-flat-skills" test_codex_cleanup_namespace_targets_flat

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
    myorg_before=$(find "${tmp}/.claude/skills" -maxdepth 1 -name "myorg.*" -type d 2>/dev/null | wc -l)
    otherorg_before=$(find "${tmp}/.claude/skills" -maxdepth 1 -name "otherorg.*" -type d 2>/dev/null | wc -l)
    [ "$myorg_before" -gt 0 ] || { echo "  [setup] myorg skills missing" >&2; rm -rf "$tmp"; return 1; }
    [ "$otherorg_before" -gt 0 ] || { echo "  [setup] otherorg skills missing" >&2; rm -rf "$tmp"; return 1; }

    # Cleanup only myorg namespace
    HOME="$tmp" bash "${INSTALL}" --global --claude --namespace myorg --cleanup >/dev/null 2>&1

    local myorg_after otherorg_after
    myorg_after=$(find "${tmp}/.claude/skills" -maxdepth 1 -name "myorg.*" -type d 2>/dev/null | wc -l)
    otherorg_after=$(find "${tmp}/.claude/skills" -maxdepth 1 -name "otherorg.*" -type d 2>/dev/null | wc -l)
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
