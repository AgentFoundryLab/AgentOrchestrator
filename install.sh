#!/bin/bash
# AgentOrchestrator Installer
# Usage:
#   ./install.sh --global              Install to ~/.claude/
#   ./install.sh --project <path>      Install project templates to <path>
#   ./install.sh [--claude|--gemini|--codex]  Limit policy-ref targets (default: all)
#   ./install.sh --overwrite           Overwrite existing files (backup to .backup/)
#   ./install.sh --restore             Remove installed artifacts, restore settings

set -e

VERSION="0.1.0 "
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="${SCRIPT_DIR}/package"
NAMESPACE="jarvis"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
CREATED=0
PATCHED=0
UNCHANGED=0
WARNINGS=0
BACKUPS=0

# Options
OVERWRITE=false
REF_CLAUDE=true
REF_GEMINI=true
REF_CODEX=true
REF_TARGETS_EXPLICIT=false

# Print usage
usage() {
    cat << EOF
AgentOrchestrator Installer v${VERSION}

Usage:
    ./install.sh --global              Install to ~/.claude/
    ./install.sh --project <path>      Install project templates to <path>
    ./install.sh --claude              Target CLAUDE.md refs only
    ./install.sh --gemini              Target GEMINI.md refs only
    ./install.sh --codex               Target AGENTS.md refs only
    ./install.sh --overwrite           Overwrite existing markdown files (backup to .backup/)
    ./install.sh --restore             Remove installed artifacts, restore settings from backup
    ./install.sh --help                Show this help

Policy-ref target flags are optional.
If none are provided, installer targets all three: --claude + --gemini + --codex.

What gets installed:

--global installs to ~/.claude/:
    - agents/jarvis/    Agent definitions (7 files)
    - skills/jarvis/    Skill definitions (15 directories)
    - hooks/scripts/    Hook scripts (5 files)
    - settings.json     Hook and MCP configuration
    - policy/           PRINCIPLES.md, RULES.md
    - workflows/        SWE.md, meta-learning.md
    - templates/        PRD, architecture, ADR, roadmap, backlog, issues

--project installs to <path>/:
    - docs/             Provisioned folder tree with .gitkeep
    - docs/policy/      STANDARDS.md, GUIDELINES.md templates (from package/templates/)
    - docs/knowledge/   README.md (from package/templates/)
    - reports/          analysis/, research/ directories
    - .claude/agents/jarvis/ Agent definitions (project-local namespace)
    - .claude/skills/jarvis/ Skill definitions (project-local namespace)
    - .claude/templates/ Templates (project-local copy, agents prefer over global)
    - .claude/policy/   PRINCIPLES.md, RULES.md (project-local copies)
    - .claude/workflows/ SWE.md, meta-learning.md (project-local copies)
    - .serena/          project.yml (auto-detected languages, requires uvx)
    - Injects @policy refs into existing CLAUDE.md/AGENTS.md/GEMINI.md

EOF
}

# Log functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    ((++WARNINGS))
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Create backup directory
create_backup_dir() {
    local target="$1"
    local backup_dir
    backup_dir="${target}/.backup/$(date +%Y-%m-%d_%H-%M-%S)"
    mkdir -p "$backup_dir"
    echo "$backup_dir"
}

# Deep merge JSON files using jq
merge_json() {
    local source="$1"
    local target="$2"
    local backup_dir="$3"
    local rel_path="$4"

    if [ -f "$target" ]; then
        # Backup existing (preserve subfolder structure)
        local backup_file="${backup_dir}/${rel_path:-$(basename "$target")}"
        mkdir -p "$(dirname "$backup_file")"
        cp "$target" "$backup_file"
        ((++BACKUPS))

        # Deep merge: existing values take precedence, but add new keys
        if command -v jq &> /dev/null; then
            jq -s '.[0] * .[1]' "$target" "$source" > "${target}.tmp"
            mv "${target}.tmp" "$target"
            log_success "Patched: $target (backup: $backup_file)"
            ((++PATCHED))
        else
            log_warning "jq not found. Skipping JSON merge for $target"
            log_warning "Install jq for proper JSON merging: apt install jq / brew install jq"
        fi
    else
        mkdir -p "$(dirname "$target")"
        cp "$source" "$target"
        log_success "Created: $target"
        ((++CREATED))
    fi
}

# Copy markdown file (warn if different, overwrite with --overwrite)
copy_markdown() {
    local source="$1"
    local target="$2"
    local backup_dir="$3"
    local rel_path="$4"

    if [ -f "$target" ]; then
        if diff -q "$source" "$target" > /dev/null 2>&1; then
            log_info "Unchanged: $target"
            ((++UNCHANGED))
        elif [ "$OVERWRITE" = true ]; then
            # Backup existing to backup_dir (preserve subfolder structure)
            local backup_file="${backup_dir}/${rel_path:-$(basename "$target")}"
            mkdir -p "$(dirname "$backup_file")"
            cp "$target" "$backup_file"
            cp "$source" "$target"
            log_success "Overwritten: $target (backup: $backup_file)"
            ((++BACKUPS))
            ((++CREATED))
        else
            log_warning "$target exists and differs from AgentOrchestrator version"
            log_warning "  Use --overwrite to replace (backup to .backup/)"
        fi
    else
        mkdir -p "$(dirname "$target")"
        cp "$source" "$target"
        log_success "Created: $target"
        ((++CREATED))
    fi
}

# Copy shell script (backup + overwrite if different)
copy_script() {
    local source="$1"
    local target="$2"
    local backup_dir="$3"
    local rel_path="$4"

    if [ -f "$target" ]; then
        if diff -q "$source" "$target" > /dev/null 2>&1; then
            log_info "Unchanged: $target"
            ((++UNCHANGED))
            return
        fi
        # Backup existing (preserve subfolder structure)
        local backup_file="${backup_dir}/${rel_path:-$(basename "$target")}"
        mkdir -p "$(dirname "$backup_file")"
        cp "$target" "$backup_file"
        ((++BACKUPS))
        log_info "Backed up: $target → $backup_file"
    fi

    mkdir -p "$(dirname "$target")"
    cp "$source" "$target"
    chmod +x "$target"
    log_success "Installed: $target"
    ((++CREATED))
}

# Copy directory recursively with appropriate handling
copy_directory() {
    local source_dir="$1"
    local target_dir="$2"
    local backup_dir="$3"
    local component_name
    component_name="$(basename "$target_dir")"

    if [ ! -d "$source_dir" ]; then
        log_warning "Source directory not found: $source_dir"
        return
    fi

    mkdir -p "$target_dir"

    find "$source_dir" -type f | while read -r file; do
        local rel_path="${file#"$source_dir"/}"
        local target_file="${target_dir}/${rel_path}"
        local backup_rel_path="${component_name}/${rel_path}"
        local ext="${file##*.}"

        case "$ext" in
            json)
                merge_json "$file" "$target_file" "$backup_dir" "$backup_rel_path"
                ;;
            md)
                copy_markdown "$file" "$target_file" "$backup_dir" "$backup_rel_path"
                ;;
            sh)
                copy_script "$file" "$target_file" "$backup_dir" "$backup_rel_path"
                ;;
            *)
                # Default: copy if not exists
                if [ ! -f "$target_file" ]; then
                    mkdir -p "$(dirname "$target_file")"
                    cp "$file" "$target_file"
                    log_success "Created: $target_file"
                    ((++CREATED))
                else
                    log_info "Unchanged: $target_file"
                    ((++UNCHANGED))
                fi
                ;;
        esac
    done
}

# Restore or remove installed file:
# - restore from backup if available
# - else remove only if target still matches installer source
# - else keep target (user modified)
restore_or_remove_installed_file() {
    local source_file="$1"
    local target_file="$2"
    local backup_file="$3"

    if restore_file_from_backup "$backup_file" "$target_file"; then
        return
    fi

    if [ -f "$target_file" ]; then
        if [ -f "$source_file" ] && diff -q "$source_file" "$target_file" > /dev/null 2>&1; then
            rm -f "$target_file"
            log_success "Removed installed file: $target_file"
            ((++CREATED))
        else
            log_warning "Keeping modified file (no backup): $target_file"
        fi
    fi

    return 0
}

# Restore/remove an installed tree based on source and backup.
restore_or_remove_installed_tree() {
    local source_dir="$1"
    local target_dir="$2"
    local backup_dir="$3"
    local backup_prefix="$4"

    [ -d "$source_dir" ] || return 0
    [ -d "$target_dir" ] || return 0

    find "$source_dir" -type f | while read -r source_file; do
        local rel_path="${source_file#"$source_dir"/}"
        local target_file="${target_dir}/${rel_path}"
        local backup_file=""
        if [ -n "$backup_dir" ]; then
            backup_file="${backup_dir}/${backup_prefix}/${rel_path}"
        fi
        restore_or_remove_installed_file "$source_file" "$target_file" "$backup_file"
    done

    # Prune empty directories under the managed tree.
    find "$target_dir" -depth -type d -empty -delete 2>/dev/null || true

    return 0
}

# Inject @-references into existing CLAUDE.md/AGENTS.md/GEMINI.md (idempotent)
inject_policy_refs() {
    local target_dir="$1"
    local sentinel="$2"
    local refs_block="$3"
    local backup_dir="$4"
    local backup_prefix="$5"
    local doc_files="$6"
    local start_tag="<!-- ${sentinel}:start -->"
    local end_tag="<!-- ${sentinel}:end -->"
    local legacy_tag="<!-- ${sentinel} -->"
    local header="## Orchestrator Policy References"

    for md_file in $doc_files; do
        local f="${target_dir}/${md_file}"
        [ -f "$f" ] || continue
        if grep -qF "$start_tag" "$f" 2>/dev/null || grep -qF "$legacy_tag" "$f" 2>/dev/null; then
            log_info "Refs present: $f"
            ((++UNCHANGED))
        else
            local backup_file="${backup_dir}/${backup_prefix}/${md_file}"
            mkdir -p "$(dirname "$backup_file")"
            cp "$f" "$backup_file"
            ((++BACKUPS))
            printf '\n%s\n%s\n%s\n%s\n' "$start_tag" "$header" "$refs_block" "$end_tag" >> "$f"
            log_success "Appended refs: $f"
            ((++PATCHED))
        fi
    done
}

# Install global components to ~/.claude/
install_global() {
    local target="${HOME}/.claude"
    log_info "Installing global components to $target"

    local backup_dir
    backup_dir=$(create_backup_dir "$target")

    # Install package/ contents (source-of-truth in repository)
    if [ -d "${PACKAGE_DIR}" ]; then
        copy_directory "${PACKAGE_DIR}/agents" "${target}/agents/${NAMESPACE}" "$backup_dir"
        copy_directory "${PACKAGE_DIR}/skills" "${target}/skills/${NAMESPACE}" "$backup_dir"
        copy_directory "${PACKAGE_DIR}/hooks" "${target}/hooks" "$backup_dir"
        copy_directory "${PACKAGE_DIR}/policy" "${target}/policy" "$backup_dir"
        copy_directory "${PACKAGE_DIR}/workflows" "${target}/workflows" "$backup_dir"
        copy_directory "${PACKAGE_DIR}/templates" "${target}/templates" "$backup_dir"

        # Handle global settings.json
        if [ -f "${PACKAGE_DIR}/settings.json" ]; then
            merge_json "${PACKAGE_DIR}/settings.json" "${target}/settings.json" "$backup_dir"
        fi
    fi

    # Install global MCP servers to ~/.claude.json (user-scope)
    if [ -f "${PACKAGE_DIR}/mcp.json" ]; then
        merge_json "${PACKAGE_DIR}/mcp.json" "${HOME}/.claude.json" "$backup_dir" ".claude.json"
    fi

    # Inject @-references for global policies into selected runtime docs.
    if [ "$REF_CLAUDE" = true ]; then
        inject_policy_refs "${HOME}/.claude" "orchestrator:global-refs" \
            "$(printf 'Read @policy/PRINCIPLES.md\nRead @policy/RULES.md')" "$backup_dir" "claude" "CLAUDE.md"
    fi
    if [ "$REF_GEMINI" = true ]; then
        inject_policy_refs "${HOME}/.gemini" "orchestrator:global-refs" \
            "$(printf 'Read @policy/PRINCIPLES.md\nRead @policy/RULES.md')" "$backup_dir" "gemini" "GEMINI.md"
    fi
    if [ "$REF_CODEX" = true ]; then
        inject_policy_refs "${HOME}/.codex" "orchestrator:global-refs" \
            "$(printf 'Read @policy/PRINCIPLES.md\nRead @policy/RULES.md')" "$backup_dir" "codex" "AGENTS.md"
    fi

    log_success "Global installation complete"
}

# Install project scaffolding to specified path
install_project() {
    local target="$1"

    if [ -z "$target" ]; then
        log_error "Project path required for --project"
        usage
        exit 1
    fi

    log_info "Installing project scaffolding to $target"

    local backup_dir
    backup_dir=$(create_backup_dir "$target")

    # 1. Provision docs folder tree with .gitkeep
    local dirs=(docs/policy docs/objectives docs/architecture docs/architecture/adr
                docs/development docs/knowledge reports/analysis reports/research)
    for d in "${dirs[@]}"; do
        mkdir -p "${target}/${d}"
        if [ -z "$(ls -A "${target}/${d}" 2>/dev/null)" ]; then
            touch "${target}/${d}/.gitkeep"
        fi
    done

    # 2. Deploy knowledge README from template
    copy_markdown "${PACKAGE_DIR}/templates/knowledge.md" \
                  "${target}/docs/knowledge/README.md" "$backup_dir" "docs/knowledge/README.md"

    # 3. Deploy policy templates (scaffolds for /onboard to hydrate)
    copy_markdown "${PACKAGE_DIR}/templates/standards.md" \
                  "${target}/docs/policy/STANDARDS.md" "$backup_dir" "docs/policy/STANDARDS.md"
    copy_markdown "${PACKAGE_DIR}/templates/guidelines.md" \
                  "${target}/docs/policy/GUIDELINES.md" "$backup_dir" "docs/policy/GUIDELINES.md"

    # 4. Inject @-references for project policies into selected local runtime docs
    local project_doc_files=""
    [ "$REF_CLAUDE" = true ] && project_doc_files="${project_doc_files} CLAUDE.md"
    [ "$REF_CODEX" = true ] && project_doc_files="${project_doc_files} AGENTS.md"
    [ "$REF_GEMINI" = true ] && project_doc_files="${project_doc_files} GEMINI.md"
    inject_policy_refs "$target" "orchestrator:project-refs" \
        "$(printf 'Read @docs/policy/STANDARDS.md\nRead @docs/policy/GUIDELINES.md')" "$backup_dir" "project-root" "$project_doc_files"

    # 5. Deploy templates to project-local .claude/templates/
    copy_directory "${PACKAGE_DIR}/templates" "${target}/.claude/templates" "$backup_dir"

    # 6. Deploy policy to project-local .claude/policy/ (read-only copies, /onboard hydrates docs/policy/)
    copy_directory "${PACKAGE_DIR}/policy" "${target}/.claude/policy" "$backup_dir"

    # 7. Deploy workflows to project-local .claude/workflows/
    if [ -d "${PACKAGE_DIR}/workflows" ]; then
        copy_directory "${PACKAGE_DIR}/workflows" "${target}/.claude/workflows" "$backup_dir"
    fi

    # 8. Deploy project-local agent/skill namespaces (dogfood-safe)
    if [ -d "${PACKAGE_DIR}/agents" ]; then
        copy_directory "${PACKAGE_DIR}/agents" "${target}/.claude/agents/${NAMESPACE}" "$backup_dir"
    fi
    if [ -d "${PACKAGE_DIR}/skills" ]; then
        copy_directory "${PACKAGE_DIR}/skills" "${target}/.claude/skills/${NAMESPACE}" "$backup_dir"
    fi

    # 9. Initialize Serena project if uvx is available
    init_serena_project "$target"

    log_success "Project installation complete"
    log_info "Run /onboard to generate project-tailored STANDARDS.md + GUIDELINES.md"
}

# Initialize Serena MCP project configuration
init_serena_project() {
    local target="$1"
    local project_name
    project_name="$(basename "$target")"

    # Skip if .serena/project.yml already exists
    if [ -f "${target}/.serena/project.yml" ]; then
        log_info "Serena project already configured: ${target}/.serena/project.yml"
        ((++UNCHANGED))
        return
    fi

    # Check if uvx is available
    if ! command -v uvx &> /dev/null; then
        log_warning "uvx not found. Skipping Serena project initialization."
        log_warning "  Install uv (https://docs.astral.sh/uv/) and run:"
        log_warning "  cd $target && uvx --from git+https://github.com/oraios/serena serena project create"
        return
    fi

    log_info "Initializing Serena project configuration..."

    # Create .serena directory
    mkdir -p "${target}/.serena"

    # Run serena project create (auto-detects languages) - properly quote project name to prevent command injection
    if (cd "$target" && uvx --from git+https://github.com/oraios/serena serena project create --name "${project_name@Q}" 2>/dev/null); then
        log_success "Created: ${target}/.serena/project.yml"
        touch "${target}/.serena/.orchestrator-created-project-yml"
        ((++CREATED))
    else
        log_warning "Serena project creation failed. You can manually run:"
        log_warning "  cd $target && uvx --from git+https://github.com/oraios/serena serena project create"
    fi
}

# Print installation summary
print_summary() {
    echo ""
    echo "=================================="
    echo "AgentOrchestrator Installation Summary"
    echo "=================================="
    echo -e "Created:    ${GREEN}${CREATED}${NC} files"
    echo -e "Patched:    ${BLUE}${PATCHED}${NC} files"
    echo -e "Unchanged:  ${UNCHANGED} files"
    echo -e "Warnings:   ${YELLOW}${WARNINGS}${NC} files"
    echo -e "Backups:    ${BACKUPS} files"
    echo ""

    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}Review warnings above for files that may need manual attention.${NC}"
        echo ""
    fi

    echo "Next steps:"
    echo "  1. Verify installation with 'ls ~/.claude/'"
    echo "  2. Test with '/orchestrate test project'"
    echo "  3. See README.md for usage guide"
}

# Find latest backup directory
find_latest_backup() {
    local target="$1"
    local backup_base="${target}/.backup"

    if [ ! -d "$backup_base" ]; then
        echo ""
        return
    fi

    # Find most recent backup directory - validate path to prevent traversal
    local canonical_base canonical_target
    canonical_base="$(readlink -f "$backup_base")"
    canonical_target="$(readlink -f "$target")"
    if [[ "$canonical_base" == "$canonical_target"/.backup ]]; then
        ls -1d "${backup_base}"/*/ 2>/dev/null | sort -r | head -1
    fi
}

# Restore settings.json from backup
restore_settings() {
    local target="$1"
    local backup_dir="$2"
    local settings_file="${target}/settings.json"

    if [ -z "$backup_dir" ]; then
        log_warning "No backup found to restore settings from"
        return
    fi

    # Look for settings.json in backup
    local backup_settings="${backup_dir}/settings.json"
    if [ -f "$backup_settings" ]; then
        cp "$backup_settings" "$settings_file"
        log_success "Restored: $settings_file from backup"
        ((++CREATED))
    else
        log_info "No settings.json backup found in $backup_dir"
    fi
}

# Restore file from backup if present
restore_file_from_backup() {
    local backup_file="$1"
    local target_file="$2"

    if [ -n "$backup_file" ] && [ -f "$backup_file" ]; then
        mkdir -p "$(dirname "$target_file")"
        cp "$backup_file" "$target_file"
        log_success "Restored: $target_file from backup"
        ((++PATCHED))
        return 0
    fi

    return 1
}

# Strip injected ref block by sentinel if backup is unavailable
strip_ref_block_if_present() {
    local target_file="$1"
    local sentinel="$2"
    local start_tag="<!-- ${sentinel}:start -->"
    local end_tag="<!-- ${sentinel}:end -->"
    local legacy_tag="<!-- ${sentinel} -->"
    local tmp_file="${target_file}.tmp"

    [ -f "$target_file" ] || return 0

    # Preferred bounded block removal (no tail loss).
    if grep -qF "$start_tag" "$target_file" 2>/dev/null && grep -qF "$end_tag" "$target_file" 2>/dev/null; then
        awk -v start="$start_tag" -v end="$end_tag" '
            $0 == start {skip=1; next}
            $0 == end {skip=0; next}
            !skip {print}
        ' "$target_file" > "$tmp_file"
        mv "$tmp_file" "$target_file"
        log_success "Stripped refs from: $target_file"
        ((++PATCHED))
        return 0
    fi

    # Legacy unbounded marker fallback: remove only known injected lines.
    if grep -qF "$legacy_tag" "$target_file" 2>/dev/null; then
        awk -v legacy="$legacy_tag" '
            {
                if (!skip && index($0, legacy) > 0) { skip=1; next }
                if (skip) {
                    if ($0 ~ /^## Orchestrator Policy References/) next
                    if ($0 ~ /^Read @/) next
                    if ($0 ~ /^[[:space:]]*$/) next
                    skip=0
                }
                print
            }
        ' "$target_file" > "$tmp_file"
        mv "$tmp_file" "$target_file"
        log_success "Stripped legacy refs from: $target_file"
        ((++PATCHED))
    fi

    return 0
}

# Restore CLAUDE/AGENTS/GEMINI refs from backup, fallback to sentinel stripping
restore_policy_refs() {
    local target_dir="$1"
    local backup_dir="$2"
    local sentinel="$3"
    local backup_prefix="$4"
    local doc_files="$5"

    for md_file in $doc_files; do
        local target_file="${target_dir}/${md_file}"
        local backup_file=""
        if [ -n "$backup_dir" ]; then
            backup_file="${backup_dir}/${backup_prefix}/${md_file}"
        fi

        if ! restore_file_from_backup "$backup_file" "$target_file"; then
            strip_ref_block_if_present "$target_file" "$sentinel"
        fi
    done
}

# Restore global installation (remove installed artifacts + restore settings)
restore_global() {
    local target="${HOME}/.claude"
    log_info "Restoring global installation from $target"

    local backup_dir
    backup_dir=$(find_latest_backup "$target")

    # Remove namespaced agent/skill directories to avoid conflicts with other installed packs
    local dirs_to_remove=("agents/${NAMESPACE}" "skills/${NAMESPACE}" "hooks" "policy" "workflows" "templates")
    for dir in "${dirs_to_remove[@]}"; do
        if [ -d "${target:?}/${dir}" ]; then
            rm -rf "${target:?}/${dir}"
            log_success "Removed: ${target}/${dir}"
            ((++CREATED))
        fi
    done

    # Restore settings.json from backup
    restore_settings "$target" "$backup_dir"

    # Restore ~/.claude.json from backup if present, fallback to mcpServers deletion
    local claude_json_backup=""
    if [ -n "$backup_dir" ]; then
        claude_json_backup="${backup_dir}/.claude.json"
    fi
    if ! restore_file_from_backup "$claude_json_backup" "${HOME}/.claude.json"; then
        if command -v jq &> /dev/null && [ -f "${HOME}/.claude.json" ]; then
            if jq 'has("mcpServers")' "${HOME}/.claude.json" | grep -q true; then
                local effective_backup_dir="$backup_dir"
                if [ -z "$effective_backup_dir" ]; then
                    effective_backup_dir=$(create_backup_dir "$target")
                    log_warning "No prior backup found. Created backup directory: $effective_backup_dir"
                fi

                local fallback_backup="${effective_backup_dir}/.claude.json"
                mkdir -p "$(dirname "$fallback_backup")"
                cp "${HOME}/.claude.json" "$fallback_backup"
                jq 'del(.mcpServers)' "${HOME}/.claude.json" > "${HOME}/.claude.json.tmp"
                mv "${HOME}/.claude.json.tmp" "${HOME}/.claude.json"
                log_success "Removed mcpServers from ~/.claude.json (backup: $fallback_backup)"
                ((++BACKUPS))
            fi
        fi
    fi

    # Restore global injected refs in selected runtime docs.
    if [ "$REF_CLAUDE" = true ]; then
        restore_policy_refs "${HOME}/.claude" "$backup_dir" "orchestrator:global-refs" "claude" "CLAUDE.md"
    fi
    if [ "$REF_GEMINI" = true ]; then
        restore_policy_refs "${HOME}/.gemini" "$backup_dir" "orchestrator:global-refs" "gemini" "GEMINI.md"
    fi
    if [ "$REF_CODEX" = true ]; then
        restore_policy_refs "${HOME}/.codex" "$backup_dir" "orchestrator:global-refs" "codex" "AGENTS.md"
    fi

    log_success "Global restore complete"
}

# Restore project installation (remove installed artifacts + strip refs)
restore_project() {
    local target="$1"

    if [ -z "$target" ]; then
        log_error "Project path required for --restore with --project"
        usage
        exit 1
    fi

    log_info "Restoring project installation from $target"

    local backup_dir
    backup_dir=$(find_latest_backup "$target")

    # Restore/remove project docs files installed from templates (surgical only).
    local docs_backup_knowledge=""
    local docs_backup_standards=""
    local docs_backup_guidelines=""
    if [ -n "$backup_dir" ]; then
        docs_backup_knowledge="${backup_dir}/docs/knowledge/README.md"
        docs_backup_standards="${backup_dir}/docs/policy/STANDARDS.md"
        docs_backup_guidelines="${backup_dir}/docs/policy/GUIDELINES.md"
    fi
    restore_or_remove_installed_file \
        "${PACKAGE_DIR}/templates/knowledge.md" \
        "${target}/docs/knowledge/README.md" \
        "$docs_backup_knowledge"
    restore_or_remove_installed_file \
        "${PACKAGE_DIR}/templates/standards.md" \
        "${target}/docs/policy/STANDARDS.md" \
        "$docs_backup_standards"
    restore_or_remove_installed_file \
        "${PACKAGE_DIR}/templates/guidelines.md" \
        "${target}/docs/policy/GUIDELINES.md" \
        "$docs_backup_guidelines"

    # Restore/remove managed .claude trees (surgical file-level).
    restore_or_remove_installed_tree \
        "${PACKAGE_DIR}/templates" \
        "${target}/.claude/templates" \
        "$backup_dir" \
        "templates"
    restore_or_remove_installed_tree \
        "${PACKAGE_DIR}/policy" \
        "${target}/.claude/policy" \
        "$backup_dir" \
        "policy"
    restore_or_remove_installed_tree \
        "${PACKAGE_DIR}/workflows" \
        "${target}/.claude/workflows" \
        "$backup_dir" \
        "workflows"

    # Remove namespaced agents/skills only (isolated namespace).
    local dirs_to_remove=(".claude/agents/${NAMESPACE}" ".claude/skills/${NAMESPACE}")
    for dir in "${dirs_to_remove[@]}"; do
        if [ -d "${target:?}/${dir}" ]; then
            rm -rf "${target:?}/${dir}"
            log_success "Removed: ${target}/${dir}"
            ((++CREATED))
        fi
    done

    # Remove Serena project file only if this installer created it.
    local serena_marker="${target}/.serena/.orchestrator-created-project-yml"
    local serena_project="${target}/.serena/project.yml"
    if [ -f "$serena_marker" ]; then
        if [ -f "$serena_project" ]; then
            rm -f "$serena_project"
            log_success "Removed installer-created file: ${serena_project}"
            ((++CREATED))
        fi
        rm -f "$serena_marker"
        rmdir "${target}/.serena" 2>/dev/null || true
    fi

    # Restore project injected refs in selected local runtime docs
    local project_doc_files=""
    [ "$REF_CLAUDE" = true ] && project_doc_files="${project_doc_files} CLAUDE.md"
    [ "$REF_CODEX" = true ] && project_doc_files="${project_doc_files} AGENTS.md"
    [ "$REF_GEMINI" = true ] && project_doc_files="${project_doc_files} GEMINI.md"
    restore_policy_refs "$target" "$backup_dir" "orchestrator:project-refs" "project-root" "$project_doc_files"

    log_success "Project restore complete"
}

# Main
main() {
    if [ $# -eq 0 ]; then
        usage
        exit 1
    fi

    local do_global=false
    local do_project=false
    local do_restore=false
    local project_path=""

    while [ $# -gt 0 ]; do
        case "$1" in
            --claude|--gemini|--codex)
                if [ "$REF_TARGETS_EXPLICIT" = false ]; then
                    REF_CLAUDE=false
                    REF_GEMINI=false
                    REF_CODEX=false
                    REF_TARGETS_EXPLICIT=true
                fi
                case "$1" in
                    --claude) REF_CLAUDE=true ;;
                    --gemini) REF_GEMINI=true ;;
                    --codex) REF_CODEX=true ;;
                esac
                shift
                ;;
            --global)
                do_global=true
                shift
                ;;
            --project)
                do_project=true
                shift
                if [ $# -gt 0 ] && [[ ! "$1" =~ ^-- ]]; then
                    project_path="$1"
                    shift
                fi
                ;;
            --overwrite)
                OVERWRITE=true
                shift
                ;;
            --restore)
                do_restore=true
                shift
                ;;
            --help|-h)
                usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done

    echo ""
    echo "AgentOrchestrator Installer v${VERSION}"
    echo "=================================="
    echo ""

    if [ "$do_restore" = true ]; then
        if [ "$do_global" = true ]; then
            restore_global
            echo ""
        fi
        if [ "$do_project" = true ]; then
            restore_project "$project_path"
            echo ""
        fi
        # If neither specified, default to global restore
        if [ "$do_global" = false ] && [ "$do_project" = false ]; then
            restore_global
            echo ""
        fi
    else
        if [ "$do_global" = true ]; then
            install_global
            echo ""
        fi

        if [ "$do_project" = true ]; then
            install_project "$project_path"
            echo ""
        fi
    fi

    print_summary
}

main "$@"
