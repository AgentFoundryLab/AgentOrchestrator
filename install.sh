#!/bin/bash
# AgentOrchestrator Installer
# Requires: bash 4.0+ (associative arrays). macOS ships bash 3.2; install via: brew install bash
# Usage:
#   ./install.sh --global              Install to selected runtime global dir(s)
#   ./install.sh --project <path>      Install project templates to <path>
#   ./install.sh [--claude|--gemini|--codex|--opencode|--qwen|--trio|--all]
#                                        Select install targets (default selector: --claude)
#   ./install.sh [--profile <profile>] Capability profile: skills|commands|hooks|scripts|all (default: auto)
#   ./install.sh [--hooks]             Enable hooks install for runtimes that support hooks (default: disabled)
#   ./install.sh [--namespace <name>]  Override agent/skill/command namespace (default: flat)
#   ./install.sh [--no-namespace]      Use flat agents/skills/commands paths (no namespace)
#   ./install.sh --overwrite           Overwrite existing files (backup to .backup/)
#   ./install.sh --restore             Remove installed artifacts, restore settings
#   ./install.sh --uninstall           Remove installed artifacts, unpatch files (no backup restore)
#   ./install.sh --check               Check registry paths against package layout (no writes)

set -e

VERSION="0.2.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="${SCRIPT_DIR}/package"
NAMESPACE=""

# Source canonical runtime registry (bash 4+ associative arrays)
# shellcheck source=package/install/runtimes.sh
. "${PACKAGE_DIR}/install/runtimes.sh"

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
REF_CLAUDE=false
REF_GEMINI=false
REF_CODEX=false
REF_OPENCODE=false
REF_QWEN=false
REF_TARGETS_EXPLICIT=false
# Target selector used when no runtime flags are passed.
# Allowed: --claude | --codex | --gemini | --opencode | --qwen | --trio | --all
DEFAULT_RUNTIME_SELECTOR="--claude"

# Profile: "auto" = runtime-specific default, or one of: skills, commands, hooks, scripts, all
PROFILE="auto"
HOOKS_ENABLED=false

# Print usage
usage() {
    cat << EOF
AgentOrchestrator Installer v${VERSION}
Requires: bash 4.0+ (macOS: brew install bash)

Usage:
    ./install.sh --global              Install to selected runtime global dir(s)
    ./install.sh --project <path>      Install project templates to <path>

Runtime target flags (composable):
    --claude                           Install to Claude Code paths (~/.claude/, .claude/)
    --codex                            Install to Codex CLI paths (~/.agents/, .agents/)
    --gemini                           Install to Gemini CLI paths (~/.gemini/, .gemini/)
    --opencode                         Install to OpenCode paths (~/.config/opencode/, .opencode/)
    --qwen                             Install to Qwen Code paths (~/.qwen/, .qwen/)
    --trio                             Shortcut: --claude --codex --gemini
    --all                              Shortcut: all runtimes (--claude --codex --gemini --opencode --qwen)

    Combine flags: --claude --codex installs to both runtimes in one run.
    If no runtime flag is provided, default selector '${DEFAULT_RUNTIME_SELECTOR}' is applied.

Profile flags (controls which capability artifacts are installed):
    --profile <profile>                Capability profile (default: auto per runtime)
                                       Values: skills, commands, hooks, scripts, all
                                       - skills: install skill packages (SKILL.md); requires runtime skills support
                                       - commands: install command artifacts; Claude/Codex/Qwen use .md,
                                                   Gemini uses .toml transform
                                       - hooks: install hooks/scripts; requires runtime hooks support
                                       - scripts: embedded within skill packages (no extra step)
                                       - all: install all capabilities supported by the runtime
                                       Default when runtime supports skills: skills
    --hooks                            Enable hook installation + Claude hook settings merge (default: disabled)

Namespace flags:
    --namespace <name>                 Override namespace for agents/skills/commands (default: flat)
                                       Grammar: dash-notation token [a-z][a-z0-9-]*
                                       Example: --namespace orchestrator
    --no-namespace                     Use flat agents/skills/commands paths (no namespace prefix)

Other flags:
    --overwrite                        Overwrite existing markdown files (backup to .backup/)
    --restore                          Remove installed artifacts, restore settings from backup
    --uninstall                        Remove installed artifacts, strip injected refs (no backup restore)
    --check                            Validate registry paths vs package layout; exits non-zero on drift
    --help                             Show this help

Flat install is the default when --namespace is omitted.

What gets installed per runtime (default skills profile):

  claude  (~/.claude/, .claude/):
    - agents/*.md          Agent definitions [default profile]
    - skills/<skill>/      Skills [default profile]
    - commands/            Commands in .md format [--profile commands only]
    - hooks/scripts/       Hook scripts [only when --hooks is passed]
    - settings.json        MCP + runtime settings (hook settings only when --hooks is passed)
    - policy/              PRINCIPLES.md, RULES.md
    - workflows/           SWE.md, meta-learning.md
    - templates/           One per record type: requirements, blueprints, ADR, plan, work order, feedback

  codex  (~/.agents/, .agents/):
    - agents/*.md          Agent definitions [default profile]
    - skills/<skill>/      Skills [default profile]
    - prompts/             Commands in .md (strip frontmatter) [--profile commands only]
    - policy/              PRINCIPLES.md, RULES.md
    - workflows/           SWE.md, meta-learning.md
    - templates/           One per record type: requirements, blueprints, ADR, plan, work order, feedback
    - [no hooks — not supported by Codex CLI]

  gemini  (~/.gemini/, .gemini/):
    - skills/<skill>/      Skills [default profile]
    - commands/*.toml      Commands in TOML format (from SKILL.md transform) [--profile commands]
    - policy/              PRINCIPLES.md, RULES.md
    - workflows/           SWE.md, meta-learning.md
    - templates/           One per record type: requirements, blueprints, ADR, plan, work order, feedback
    - [no hooks — excluded by installer policy]

  opencode  (~/.config/opencode/, .opencode/):
    - agents/*.md          Agent definitions [default profile]
    - skills/<name>/       Skills [default profile]
    - commands/*.md        Commands in .md format [--profile commands only]
    - policy/              PRINCIPLES.md, RULES.md
    - workflows/           SWE.md, meta-learning.md
    - templates/           One per record type: requirements, blueprints, ADR, plan, work order, feedback
    - [no hooks — excluded by installer policy]

  qwen  (~/.qwen/, .qwen/):
    - agents/*.md          Agent definitions [default profile]
    - skills/<skill>/      Skills [default profile]
    - commands/*.md        Commands in Markdown format [--profile commands only]
    - policy/              PRINCIPLES.md, RULES.md
    - workflows/           SWE.md, meta-learning.md
    - templates/           One per record type: requirements, blueprints, ADR, plan, work order, feedback
    - [no hooks — excluded by installer policy]

--project installs to <path>/ (runtime-agnostic scaffolding):
    - docs/                Provisioned folder tree with .gitignore placeholders
    - docs/policy/         STANDARDS.md, GUIDELINES.md templates
    - docs/knowledge/      README.md
    - docs/requirements/   FRD-*/TRD-* requirements
    - docs/architecture/   foundation/, feature/, system/, ADR/
    - docs/development/    plans/, workorders/, issues/, debt/, feedback/, status/
    - docs/analysis/       Analysis and review reports
    - docs/validation/     AC/TRC coverage documents
    - reports/             research/ and meta-optimization/ directories
    - .serena/             project.yml (requires uvx)
    - Injects @policy refs into runtime context docs

Profile defaults per runtime:
    Runtimes with skills support (claude, codex, gemini, opencode, qwen):
        Default profile: skills
        Skills are installed to <runtime>/skills/<skill>/ (flat by default).
        Optional --namespace translation is runtime/artifact-aware:
          - Skills/agents on flat runtimes: <namespace>-<name> fallback
          - Commands on Gemini/Qwen: <namespace>/<name> for /<namespace>:<name>
        Hooks are installed only when --hooks is passed and runtime support is enabled by installer policy (claude).
    Use --profile commands to install command-format artifacts for selected runtimes.

Examples:
    # Install to default runtime selector
    ./install.sh --global

    # Install to multiple runtimes in one run
    ./install.sh --global --codex --qwen

    # Install to the claude+codex+gemini trio
    ./install.sh --global --trio

    # Install to all five runtimes
    ./install.sh --global --all

    # Namespaced install (dash fallback naming)
    ./install.sh --global --claude --namespace orchestrator

    # Install with commands profile
    ./install.sh --global --gemini --profile commands

    # Check registry paths against package layout (no writes)
    ./install.sh --check

EOF
}

# ---------------------------------------------------------------------------
# validate_namespace — T-067: Validate namespace grammar
# ---------------------------------------------------------------------------
# Grammar: single dash-notation token matching [a-z][a-z0-9-]*.
# Empty string is valid (means no namespace / flat mode).
# Returns 0 for valid, 1 for invalid (with error message to stderr).
validate_namespace() {
    local ns="$1"

    # Empty namespace is valid (flat mode)
    [ -z "$ns" ] && return 0

    if [[ ! "$ns" =~ ^[a-z][a-z0-9-]*$ ]]; then
        log_error "Invalid namespace '${ns}': must match [a-z][a-z0-9-]* (single dash-notation token)"
        return 1
    fi

    return 0
}

# Resolve effective namespace for runtime + artifact.
# Namespace is applied only when artifact mode is not "flat".
# Artifact must be one of: skills, agents, commands.
effective_namespace_for_runtime_artifact() {
    local rt="$1"
    local artifact="$2"
    local ns="${3:-$NAMESPACE}"

    [ -z "$ns" ] && { echo ""; return 0; }

    local ns_mode="flat"
    case "$artifact" in
        skills)   ns_mode="${RUNTIME_NAMESPACE_SKILLS_MODE[${rt}]:-flat}" ;;
        agents)   ns_mode="${RUNTIME_NAMESPACE_AGENTS_MODE[${rt}]:-flat}" ;;
        commands) ns_mode="${RUNTIME_NAMESPACE_COMMANDS_MODE[${rt}]:-flat}" ;;
        *)
            log_warning "Unknown namespace artifact '${artifact}' for runtime '${rt}'; using flat mode"
            ns_mode="flat"
            ;;
    esac

    if [[ "$ns_mode" == "flat" ]]; then
        echo ""
        return 0
    fi
    echo "$ns"
}

namespace_mode_for_runtime_artifact() {
    local rt="$1"
    local artifact="$2"
    case "$artifact" in
        skills) echo "${RUNTIME_NAMESPACE_SKILLS_MODE[${rt}]:-flat}" ;;
        agents) echo "${RUNTIME_NAMESPACE_AGENTS_MODE[${rt}]:-flat}" ;;
        commands) echo "${RUNTIME_NAMESPACE_COMMANDS_MODE[${rt}]:-flat}" ;;
        *) echo "flat" ;;
    esac
}

apply_frontmatter_name_override() {
    local file="$1"
    local old_name="$2"
    local new_name="$3"
    [ -f "$file" ] || return 0
    sed -i "s/^name: ${old_name}$/name: ${new_name}/" "$file"
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
    local source_dir="${1%/}"  # strip trailing slash (glob expansion adds one)
    local target_dir="$2"
    local backup_dir="$3"
    local component_name
    component_name="$(basename "$source_dir")"

    if [ ! -d "$source_dir" ]; then
        log_warning "Source directory not found: $source_dir"
        return
    fi

    mkdir -p "$target_dir"

    while read -r file; do
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
    done < <(find "$source_dir" -type f)
}

# ---------------------------------------------------------------------------
# Namespaced skills/agents install/restore — ADR-014 D-2 artifact-aware modes
# ---------------------------------------------------------------------------

# Install skills with dash-prefix namespace: skills/<ns>-<skill>/ + patch name: field.
copy_namespaced_skills_dash_prefix() {
    local source_dir="$1"
    local target_parent="$2"
    local namespace="$3"
    local backup_dir="$4"
    local rt="${5:-claude}"

    if [ ! -d "$source_dir" ]; then
        log_warning "Source directory not found: $source_dir"
        return
    fi

    for skill_dir in "$source_dir"/*/; do
        [ -d "$skill_dir" ] || continue
        local skill_name
        skill_name="$(basename "$skill_dir")"
        local ns_skill="${namespace}-${skill_name}"
        local target_skill_dir="${target_parent}/${ns_skill}"

        local tmp_skill_dir
        tmp_skill_dir="$(mktemp -d)"
        cp -r "${skill_dir%/}/." "$tmp_skill_dir/"
        local tmp_skill_md="${tmp_skill_dir}/SKILL.md"
        if [ -f "$tmp_skill_md" ]; then
            apply_frontmatter_name_override "$tmp_skill_md" "$skill_name" "$ns_skill"
            normalize_skill_markdown_in_place "$tmp_skill_md" "$rt" "skills"
        fi

        copy_directory "$tmp_skill_dir" "$target_skill_dir" "$backup_dir"
        rm -rf "$tmp_skill_dir"
    done
}

# Install skills with subdirectory namespace: skills/<ns>/<skill>/
copy_namespaced_skills_subdirectory() {
    local source_dir="$1"
    local target_parent="$2"
    local namespace="$3"
    local backup_dir="$4"
    local rt="${5:-claude}"

    if [ ! -d "$source_dir" ]; then
        log_warning "Source directory not found: $source_dir"
        return
    fi

    for skill_dir in "$source_dir"/*/; do
        [ -d "$skill_dir" ] || continue
        local skill_name
        skill_name="$(basename "$skill_dir")"
        local target_skill_dir="${target_parent}/${namespace}/${skill_name}"

        copy_directory "$skill_dir" "$target_skill_dir" "$backup_dir"
        normalize_skill_markdown_in_place "${target_skill_dir}/SKILL.md" "$rt" "skills"
    done
}

# Install namespaced skills: dispatch by runtime skills namespace mode.
copy_namespaced_skills() {
    local source_dir="$1"
    local target_parent="$2"
    local namespace="$3"
    local backup_dir="$4"
    local rt="${5:-claude}"

    local ns_mode
    ns_mode="$(namespace_mode_for_runtime_artifact "$rt" "skills")"
    if [[ "$ns_mode" == "subdirectory" ]]; then
        copy_namespaced_skills_subdirectory "$source_dir" "$target_parent" "$namespace" "$backup_dir" "$rt"
    else
        copy_namespaced_skills_dash_prefix "$source_dir" "$target_parent" "$namespace" "$backup_dir" "$rt"
    fi
}

# Remove dash-prefixed namespaced skill directories
restore_namespaced_skills_dash_prefix() {
    local source_dir="$1"
    local target_parent="$2"
    local namespace="$3"

    [ -d "$source_dir" ] || return 0

    for skill_dir in "$source_dir"/*/; do
        [ -d "$skill_dir" ] || continue
        local skill_name
        skill_name="$(basename "$skill_dir")"
        local target_skill_dir="${target_parent}/${namespace}-${skill_name}"
        if [ -d "$target_skill_dir" ]; then
            rm -rf "$target_skill_dir"
            log_success "Removed: $target_skill_dir"
            ((++CREATED))
        fi
    done
}

# Remove subdirectory-namespaced skill tree.
restore_namespaced_skills_subdirectory() {
    local _source_dir="$1"
    local target_parent="$2"
    local namespace="$3"

    local target_ns_dir="${target_parent}/${namespace}"

    if [ -d "$target_ns_dir" ]; then
        rm -rf "$target_ns_dir"
        log_success "Removed: $target_ns_dir"
        ((++CREATED))
    fi
}

# Remove namespaced skill directories: dispatch to dot-prefix or subdirectory mode.
# Arguments: source_dir target_parent namespace [runtime]
restore_namespaced_skills() {
    local source_dir="$1"
    local target_parent="$2"
    local namespace="$3"
    local rt="${4:-claude}"

    local ns_mode
    ns_mode="$(namespace_mode_for_runtime_artifact "$rt" "skills")"
    if [[ "$ns_mode" == "subdirectory" ]]; then
        restore_namespaced_skills_subdirectory "$source_dir" "$target_parent" "$namespace"
    else
        restore_namespaced_skills_dash_prefix "$source_dir" "$target_parent" "$namespace"
    fi
}

# Install namespaced agents using dash fallback naming: agents/<ns>-<agent>.md.
copy_namespaced_agents_dash_prefix() {
    local source_dir="$1"
    local target_parent="$2"
    local namespace="$3"
    local backup_dir="$4"
    local rt="${5:-claude}"

    [ -d "$source_dir" ] || return 0
    mkdir -p "$target_parent"

    local tmp_agents_dir
    tmp_agents_dir="$(mktemp -d)"
    cp -r "${source_dir}/." "$tmp_agents_dir/"
    for agent_file in "$tmp_agents_dir"/*.md; do
        [ -f "$agent_file" ] || continue
        local agent_name
        agent_name="$(basename "${agent_file%.md}")"
        local ns_agent="${namespace}-${agent_name}"
        apply_frontmatter_name_override "$agent_file" "$agent_name" "$ns_agent"
        mv "$agent_file" "${tmp_agents_dir}/${ns_agent}.md"
        # Apply runtime-specific agent transformation
        normalize_agent_markdown_in_place "${tmp_agents_dir}/${ns_agent}.md" "$rt"
    done

    copy_directory "$tmp_agents_dir" "$target_parent" "$backup_dir"
    rm -rf "$tmp_agents_dir"
}

# Install namespaced agents using subdirectory mode: agents/<ns>/<agent>.md.
copy_namespaced_agents_subdirectory() {
    local source_dir="$1"
    local target_parent="$2"
    local namespace="$3"
    local backup_dir="$4"
    local rt="${5:-claude}"

    [ -d "$source_dir" ] || return 0
    local tmp_agents_dir
    tmp_agents_dir="$(mktemp -d)"
    cp -r "${source_dir}/." "$tmp_agents_dir/"
    
    for agent_file in "$tmp_agents_dir"/*.md; do
        [ -f "$agent_file" ] || continue
        normalize_agent_markdown_in_place "$agent_file" "$rt"
    done

    copy_directory "$tmp_agents_dir" "${target_parent}/${namespace}" "$backup_dir"
    rm -rf "$tmp_agents_dir"
}

copy_namespaced_agents() {
    local source_dir="$1"
    local target_parent="$2"
    local namespace="$3"
    local backup_dir="$4"
    local rt="$5"

    local ns_mode
    ns_mode="$(namespace_mode_for_runtime_artifact "$rt" "agents")"
    if [[ "$ns_mode" == "subdirectory" ]]; then
        copy_namespaced_agents_subdirectory "$source_dir" "$target_parent" "$namespace" "$backup_dir"
    else
        copy_namespaced_agents_dash_prefix "$source_dir" "$target_parent" "$namespace" "$backup_dir"
    fi
}

restore_namespaced_agents_dash_prefix() {
    local source_dir="$1"
    local target_parent="$2"
    local namespace="$3"

    [ -d "$source_dir" ] || return 0
    for agent_file in "$source_dir"/*.md; do
        [ -f "$agent_file" ] || continue
        local agent_name
        agent_name="$(basename "${agent_file%.md}")"
        local target_file="${target_parent}/${namespace}-${agent_name}.md"
        if [ -f "$target_file" ]; then
            rm -f "$target_file"
            log_success "Removed: $target_file"
            ((++CREATED))
        fi
    done
}

restore_namespaced_agents_subdirectory() {
    local source_dir="$1"
    local target_parent="$2"
    local namespace="$3"

    [ -d "$source_dir" ] || return 0
    local target_dir="${target_parent}/${namespace}"
    if [ -d "$target_dir" ]; then
        rm -rf "$target_dir"
        log_success "Removed: $target_dir"
        ((++CREATED))
    fi
}

restore_namespaced_agents() {
    local source_dir="$1"
    local target_parent="$2"
    local namespace="$3"
    local rt="$4"

    local ns_mode
    ns_mode="$(namespace_mode_for_runtime_artifact "$rt" "agents")"
    if [[ "$ns_mode" == "subdirectory" ]]; then
        restore_namespaced_agents_subdirectory "$source_dir" "$target_parent" "$namespace"
    else
        restore_namespaced_agents_dash_prefix "$source_dir" "$target_parent" "$namespace"
    fi
}

# Restore or remove installed file:
# - restore from backup if available
# - else remove only if target still matches installer source
# - else keep target (differs from source, no backup to restore)
restore_or_remove_installed_file() {
    local source_file="$1"
    local target_file="$2"
    local backup_file="$3"
    local component="${4:-}"
    local rt="${5:-claude}"

    if restore_file_from_backup "$backup_file" "$target_file"; then
        return
    fi

    if [ -f "$target_file" ]; then
        local matches=false

        if [ -f "$source_file" ] && diff -q "$source_file" "$target_file" > /dev/null 2>&1; then
            matches=true
        elif [[ "$component" == "skills" && "$rt" != "claude" && "$(basename "$source_file")" == "SKILL.md" ]]; then
            local tmp_source
            tmp_source="$(mktemp)"
            cp "$source_file" "$tmp_source"
            strip_claude_frontmatter "$tmp_source"
            if diff -q "$tmp_source" "$target_file" > /dev/null 2>&1; then
                matches=true
            fi
            rm -f "$tmp_source"
        fi

        if [ "$matches" = true ]; then
            rm -f "$target_file"
            log_success "Removed installed file: $target_file"
            ((++CREATED))
        else
            log_info "Kept (differs from source, no backup): $target_file"
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
    local rt="${5:-claude}"

    [ -d "$source_dir" ] || return 0
    [ -d "$target_dir" ] || return 0

    find "$source_dir" -type f | while read -r source_file; do
        local rel_path="${source_file#"$source_dir"/}"
        local target_file="${target_dir}/${rel_path}"
        local backup_file=""
        if [ -n "$backup_dir" ]; then
            backup_file="${backup_dir}/${backup_prefix}/${rel_path}"
        fi
        restore_or_remove_installed_file "$source_file" "$target_file" "$backup_file" "$backup_prefix" "$rt"
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
    local header="## Orchestrator Policy References"
    local desired_block
    desired_block=$(printf '%s\n%s\n%s\n%s' "$start_tag" "$header" "$refs_block" "$end_tag")

    for md_file in $doc_files; do
        local f="${target_dir}/${md_file}"
        [ -f "$f" ] || continue
        if grep -qF "$start_tag" "$f" 2>/dev/null; then
            if ! grep -qF "$end_tag" "$f" 2>/dev/null; then
                log_warning "Malformed refs block (missing end tag): $f"
                ((++WARNINGS))
                continue
            fi

            local existing_block
            existing_block=$(awk -v s="$start_tag" -v e="$end_tag" '
                $0 == s {inblock=1}
                inblock {print}
                $0 == e && inblock {exit}
            ' "$f")

            if [ "$existing_block" = "$desired_block" ]; then
                log_info "Refs present: $f"
                ((++UNCHANGED))
            else
                local backup_file="${backup_dir}/${backup_prefix}/${md_file}"
                mkdir -p "$(dirname "$backup_file")"
                cp "$f" "$backup_file"
                ((++BACKUPS))

                local tmp_file="${f}.tmp"
                awk -v s="$start_tag" -v e="$end_tag" -v r="$desired_block" '
                    BEGIN {inblock=0; replaced=0}
                    $0 == s && replaced == 0 {
                        print r
                        inblock=1
                        replaced=1
                        next
                    }
                    inblock == 1 {
                        if ($0 == e) {
                            inblock=0
                        }
                        next
                    }
                    {print}
                ' "$f" > "$tmp_file"
                mv "$tmp_file" "$f"
                log_success "Updated refs: $f"
                ((++PATCHED))
            fi
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

# ---------------------------------------------------------------------------
# check_drift (invoked by --check) — T-065
# ---------------------------------------------------------------------------
# Validates two things only:
#   1. SOURCE exists on disk  — package layout is intact (package/skills/, agents/, hooks/)
#   2. Registry declarations  — conf/project dir values are non-empty strings
#
# TARGET column is INFORMATIONAL only — it shows where artifacts would be installed.
# Missing target dirs (e.g. ~/.qwen/) are expected pre-install and are NOT checked here.
# To validate a post-install state, run a conformance test (tests/install/smoke.sh).
#
# STATUS values:
#   OK      — source exists and registry declaration is populated
#   MISSING — source directory absent from package layout (drift: fix package or registry)
#   DRIFT   — registry declaration is empty (fix runtimes.sh)
#   PARTIAL — installed but not fully compatible (e.g. frontmatter not yet transformed, D-5)
#   GAP     — not installed at all; implementation blocked by incompatibility (G-001, G-002)
#
# Respects --profile: skills (default) shows skills/agents/hooks rows;
#                     commands shows commands rows.
# Exits non-zero on MISSING or DRIFT. PARTIAL and GAP rows do not fail the check.
check_drift() {
    local drift_found=0
    # Resolve effective profile: auto -> skills (default for drift check)
    local effective_profile="${PROFILE}"
    [[ "$effective_profile" == "auto" ]] && effective_profile="skills"

    echo ""
    echo "Runtime Path Drift Check"
    echo "========================"
    printf "%-12s | %-5s | %-24s | %-45s | %-38s | %s\n" "RUNTIME" "TYPE" "PATH TYPE" "SOURCE" "TARGET" "STATUS"
    printf "%-12s-+-%-5s-+-%-24s-+-%-45s-+-%-38s-+-%s\n" \
        "------------" "-----" "------------------------" \
        "---------------------------------------------" \
        "--------------------------------------" "--------"

    _drift_row() {
        # Usage: _drift_row rt atype path_type source target [check_src] [status_override]
        # check_src:       directory to verify exists on disk (SOURCE check). Empty = skip.
        # status_override: "GAP"     — not implemented; no failure counted
        #                  "PARTIAL" — installs but schema/transform incomplete; no failure counted
        #                  empty     — derive from check_src result (OK or MISSING)
        local rt="$1" atype="$2" ptype="$3" src="$4" tgt="$5" check="${6:-}" override="${7:-}"
        local status="OK"
        if [[ -n "$override" ]]; then
            status="$override"
        elif [[ -n "$check" ]] && [ ! -d "$check" ]; then
            status="MISSING"
            drift_found=1
        fi
        printf "%-12s | %-5s | %-24s | %-45s | %-38s | %s\n" "$rt" "$atype" "$ptype" "$src" "$tgt" "$status"
    }

    for rt in "${RUNTIMES[@]}"; do
        local conf_dir="${RUNTIME_CONF_DIR[${rt}]:-}"
        local proj_dir="${RUNTIME_PROJECT_DIR[${rt}]:-}"
        local skills_src="${PACKAGE_DIR}/skills"
        local agents_src="${PACKAGE_DIR}/agents"
        local hooks_src="${PACKAGE_DIR}/hooks"
        # Artifact type for commands: TOML for gemini, MD for all others
        local cmd_type="MD"
        [[ "$rt" == "gemini" ]] && cmd_type="TOML"

        if [[ "$effective_profile" == "commands" ]]; then
            # Commands profile: show commands source → target for each runtime
            if [[ "${RUNTIME_SUPPORTS_COMMANDS[${rt}]:-false}" == "true" ]]; then
                local cmd_conf_dir="${RUNTIME_COMMANDS_CONF_OVERRIDE[${rt}]:-${conf_dir}}"
                local cmd_path="${RUNTIME_COMMANDS_PATH[${rt}]:-commands}"
                local cmd_override=""
                _drift_row "$rt" "$cmd_type" "commands" "$skills_src" "${cmd_conf_dir}/${cmd_path}/" "$skills_src" "$cmd_override"
                # T-095: runtime-aware frontmatter/schema transform applied
                [[ "$rt" != "claude" ]] && _drift_row "$rt" "MD" "frontmatter" "(runtime key map)" "${cmd_conf_dir}/${cmd_path}/"
            fi
        else
            # Skills profile (default): show skills / agents / hooks rows
            if [[ "${RUNTIME_SUPPORTS_SKILLS[${rt}]}" == "true" ]]; then
                local skills_target="${conf_dir}/${RUNTIME_SKILLS_PATH[${rt}]}/"
                _drift_row "$rt" "MD" "skills" "$skills_src" "$skills_target" "$skills_src"
                # T-095: runtime-aware frontmatter/schema transform applied
                [[ "$rt" != "claude" ]] && _drift_row "$rt" "MD" "frontmatter" "(runtime key map)" "$skills_target"
            fi

            # T-092: Gemini commands TOML transform — show status row in skills profile view
            if [[ "$rt" == "gemini" ]]; then
                local cmd_conf_dir="${RUNTIME_COMMANDS_CONF_OVERRIDE[gemini]:-${conf_dir}}"
                local cmd_path="${RUNTIME_COMMANDS_PATH[gemini]:-commands}"
                _drift_row "gemini" "TOML" "commands" "$skills_src" "${cmd_conf_dir}/${cmd_path}/" "$skills_src"
            fi

            if [[ -n "${RUNTIME_AGENTS_PATH[${rt}]}" ]]; then
                local agents_target="${conf_dir}/${RUNTIME_AGENTS_PATH[${rt}]}/"
                _drift_row "$rt" "MD" "agents" "$agents_src" "$agents_target" "$agents_src"
            fi

            if [[ "${RUNTIME_SUPPORTS_HOOKS[${rt}]}" == "true" ]]; then
                local hooks_target="${conf_dir}/${RUNTIME_HOOKS_PATH[${rt}]}/"
                _drift_row "$rt" "SH" "hooks" "$hooks_src" "$hooks_target" "$hooks_src"
            fi
            # GAP G-001: OpenCode hooks incompatible with JS/TS plugin system
            [[ "$rt" == "opencode" ]] && _drift_row "opencode" "SH" "hooks" "$hooks_src" "${conf_dir}/plugins/" "" "GAP"  # G-001: non-Claude hooks out of scope by decision
        fi

        # Registry declarations (always shown regardless of profile)
        if [[ -n "$conf_dir" ]]; then
            _drift_row "$rt" "DIR" "conf dir" "(registry)" "$conf_dir"
        else
            printf "%-12s | %-5s | %-24s | %-45s | %-38s | %s\n" "$rt" "DIR" "conf dir" "(registry)" "(empty)" "DRIFT"
            drift_found=1
        fi
        if [[ -n "$proj_dir" ]]; then
            _drift_row "$rt" "DIR" "project dir" "(registry)" "$proj_dir"
        else
            printf "%-12s | %-5s | %-24s | %-45s | %-38s | %s\n" "$rt" "DIR" "project dir" "(registry)" "(empty)" "DRIFT"
            drift_found=1
        fi
    done

    echo ""
    if [[ $drift_found -eq 0 ]]; then
        echo "[OK] No drift detected. Registry matches package layout."
    else
        echo "[ERROR] Drift detected. Update package/install/runtimes.sh or the package layout."
        return 1
    fi
}

# ---------------------------------------------------------------------------
# Runtime install helpers (registry-driven)
# ---------------------------------------------------------------------------

# strip_claude_frontmatter — T-094/T-095: Remove Claude-specific keys from SKILL.md frontmatter.
# Preserves universal keys: name, description, tools, scripts (and any unknown keys).
# Drops Claude-only keys in YAML frontmatter only: argument-hint, user-invocable, context, agent.
# No-op if file does not exist or has no frontmatter block.
strip_claude_frontmatter() {
    local f="$1"
    [ -f "$f" ] || return 0
    local tmp
    tmp="$(mktemp)"
    awk '
        BEGIN { in_fm = 0 }
        NR == 1 && $0 == "---" { in_fm = 1; print; next }
        in_fm && $0 == "---" { in_fm = 0; print; next }
        in_fm && $0 ~ /^(argument-hint|user-invocable|context|agent):/ { next }
        { print }
    ' "$f" > "$tmp"
    mv "$tmp" "$f"
}

# convert_args_placeholder — T-094: Replace $ARGUMENTS with {{args}} for runtimes that use it.
# Applies to commands mode targets for Qwen and Gemini (official docs confirmed).
convert_args_placeholder() {
    local f="$1"
    [ -f "$f" ] || return 0
    sed -i 's/\$ARGUMENTS/{{args}}/g' "$f"
}

# ============================================================================
# Tool name mapping: Claude tool names → target runtime formats
# Used by normalize_agent_markdown_in_place for agent frontmatter transformation.
# ============================================================================

declare -A TOOL_MAP_CLAUDE_TO_CODEX=(
    [Read]="read"
    [Write]="write"
    [Edit]="edit"
    [Glob]="glob"
    [Grep]="grep"
    [Bash]="bash"
    [ListDirectory]="list"
    [WebSearch]="web_search"
    [WebFetch]="web_fetch"
    [Task]="task"
    [AskUserQuestion]="ask_user"
    ["*"]="*"
)

declare -A TOOL_MAP_CLAUDE_TO_GEMINI=(
    [Read]="read_file"
    [Write]="write_file"
    [Edit]="replace"
    [Glob]="glob"
    [Grep]="grep_search"
    [Bash]="run_shell_command"
    [ListDirectory]="list_directory"
    [WebSearch]="google_web_search"
    [WebFetch]="web_fetch"
    [Task]="task"
    [AskUserQuestion]="ask_user"
    ["*"]="*"
)

declare -A TOOL_MAP_CLAUDE_TO_OPENCODE=(
    [Read]="read"
    [Write]="write"
    [Edit]="edit"
    [Glob]="glob"
    [Grep]="grep"
    [Bash]="bash"
    [ListDirectory]="list"
    [WebSearch]="websearch"
    [WebFetch]="webfetch"
    [Task]="task"
    [AskUserQuestion]="question"
    ["*"]="*"
)

declare -A TOOL_MAP_CLAUDE_TO_QWEN=(
    [Read]="read_file"
    [Write]="write_file"
    [Edit]="replace"
    [Glob]="glob"
    [Grep]="grep_search"
    [Bash]="run_shell_command"
    [ListDirectory]="list_directory"
    [WebSearch]="web_search"
    [WebFetch]="web_fetch"
    [Task]="task"
    [AskUserQuestion]="ask_user"
    ["*"]="*"
)

# Claude-only keys to strip from agent frontmatter for non-Claude runtimes.
declare -a CLAUDE_ONLY_AGENT_KEYS=(disallowedTools skills hooks)

# strip_claude_agent_frontmatter — Remove Claude-specific keys from AGENT.md frontmatter.
# Preserves: name, description, tools, model, temperature, max_turns, timeout_mins, kind.
# Drops: disallowedTools, skills, hooks (Claude-specific).
# Warns on unknown keys.
strip_claude_agent_frontmatter() {
    local f="$1"
    [ -f "$f" ] || return 0
    local tmp
    tmp="$(mktemp)"
    local rt="$2"
    
    # Known universal keys across all runtimes
    local known_keys="name|description|tools|model|temperature|max_turns|timeout_mins|kind|mode|permission|permissionMode"
    
    # AWK script handles multi-line arrays by tracking indentation
    awk -v strip="disallowedTools|skills|hooks" -v known="$known_keys" -v rt="$rt" '
        BEGIN { in_fm = 0; in_strip = 0; warned = 0 }
        NR == 1 && $0 == "---" { in_fm = 1; print; next }
        in_fm && $0 == "---" { in_fm = 0; in_strip = 0; print; next }
        
        # In frontmatter
        in_fm {
            # Check if we are in a multi-line array that should be stripped
            if (in_strip) {
                # Continue skipping until we hit a new top-level key (no leading space) or end of frontmatter
                if ($0 ~ /^[a-zA-Z]/ || $0 == "---") {
                    in_strip = 0
                    # Re-process this line
                    if ($0 == "---") {
                        in_fm = 0
                        print
                        next
                    }
                } else {
                    # Still in indented array content, skip it
                    next
                }
            }
            
            # Extract key name (before colon)
            key = $0
            sub(/:.*/, "", key)
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", key)
            
            # Strip Claude-only keys (entire block including multi-line arrays)
            if (key ~ "^(" strip ")$") {
                in_strip = 1
                next
            }
            
            # Check for unknown keys (only top-level keys, not indented values)
            if (!warned && key != "" && $0 ~ /^[a-zA-Z]/) {
                if (key !~ "^(" known ")$") {
                    print "[WARN] Unknown frontmatter key: " key " (runtime: " rt ", file: " FILENAME ")" > "/dev/stderr"
                    warned = 1
                }
            }
        }
        
        # Not in stripped section and not skipping
        { print }
    ' "$f" > "$tmp"
    mv "$tmp" "$f"
}

# map_tool_names — Map Claude tool names to target runtime format.
# Input: tools list line from frontmatter (e.g., "tools: [Read, Write, Edit]")
# Output: transformed tools list with mapped names
map_tool_name() {
    local tool="$1"
    local rt="$2"

    case "$rt" in
        codex) echo "${TOOL_MAP_CLAUDE_TO_CODEX[$tool]:-$tool}" ;;
        gemini) echo "${TOOL_MAP_CLAUDE_TO_GEMINI[$tool]:-$tool}" ;;
        opencode) echo "${TOOL_MAP_CLAUDE_TO_OPENCODE[$tool]:-$tool}" ;;
        qwen) echo "${TOOL_MAP_CLAUDE_TO_QWEN[$tool]:-$tool}" ;;
        *) echo "$tool" ;;
    esac
}

map_tool_names() {
    local tools_line="$1"
    local rt="$2"
    
    # Get the tools array content
    local tools_content
    tools_content=$(echo "$tools_line" | sed -n 's/.*\[\(.*\)\].*/\1/p')
    [ -z "$tools_content" ] && echo "$tools_line" && return 0
    
    # Split by comma, map each tool
    local mapped_tools=""
    local IFS=','
    for tool in $tools_content; do
        # Trim whitespace
        tool=$(echo "$tool" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        # Remove quotes
        tool=$(echo "$tool" | sed 's/^"//;s/"$//')
        
        local mapped=""
        mapped="$(map_tool_name "$tool" "$rt")"
        
        [ -n "$mapped_tools" ] && mapped_tools+=", "
        mapped_tools+="$mapped"
    done
    
    echo "tools: [$mapped_tools]"
}

map_agent_tools_in_place() {
    local f="$1"
    local rt="$2"
    [ -f "$f" ] || return 0

    local tmp
    tmp="$(mktemp)"

    local in_fm=false
    local in_tools=false
    local line mapped indent tool

    while IFS= read -r line || [ -n "$line" ]; do
        if [[ "$line" == "---" ]]; then
            if $in_fm; then
                in_fm=false
                in_tools=false
            else
                in_fm=true
            fi
            printf '%s\n' "$line" >> "$tmp"
            continue
        fi

        if $in_fm; then
            if [[ "$line" =~ ^tools:[[:space:]]*\[.*\][[:space:]]*$ ]]; then
                printf '%s\n' "$(map_tool_names "$line" "$rt")" >> "$tmp"
                continue
            fi

            if [[ "$line" =~ ^tools:[[:space:]]*$ ]]; then
                in_tools=true
                printf '%s\n' "$line" >> "$tmp"
                continue
            fi

            if $in_tools; then
                if [[ "$line" =~ ^([[:space:]]*)-[[:space:]]*(.+)$ ]]; then
                    indent="${BASH_REMATCH[1]}"
                    tool="${BASH_REMATCH[2]}"
                    tool="$(printf '%s' "$tool" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//; s/^"//; s/"$//')"
                    mapped="$(map_tool_name "$tool" "$rt")"
                    printf '%s- %s\n' "$indent" "$mapped" >> "$tmp"
                    continue
                fi

                if [[ "$line" =~ ^[[:space:]]+ ]]; then
                    printf '%s\n' "$line" >> "$tmp"
                    continue
                fi

                in_tools=false
            fi
        fi

        printf '%s\n' "$line" >> "$tmp"
    done < "$f"

    mv "$tmp" "$f"
}

# transform_agent_to_opencode_permission — Transform tools list to permission object for OpenCode.
# OpenCode uses permission object format instead of tools list.
transform_agent_to_opencode_permission() {
    local f="$1"
    [ -f "$f" ] || return 0
    local tmp
    tmp="$(mktemp)"
    
    # First pass: extract tools list and convert to permission format
    # Handles both inline arrays [A, B] and multi-line lists:
    #   tools:
    #     - Read
    #     - Write
    awk '
        BEGIN { in_fm = 0; in_tools = 0; tools_arr = ""; has_tools = 0; has_permission = 0 }
        NR == 1 && $0 == "---" { in_fm = 1; print; next }
        in_fm && $0 == "---" {
            # End of frontmatter
            if (has_tools && tools_arr != "" && !has_permission) {
                # Emit permission block
                print "permission:"
                
                # Parse tools - split by newlines for multi-line or comma for inline
                n = split(tools_arr, items, "\n")
                has_wildcard = 0
                
                for (i = 1; i <= n; i++) {
                    # Clean up item
                    gsub(/^[[:space:]-]*/, "", items[i])
                    gsub(/[[:space:]]*$/, "", items[i])
                    gsub(/"/, "", items[i])
                    if (items[i] == "*") has_wildcard = 1
                }
                
                if (has_wildcard) {
                    print "  \"*\": allow"
                } else {
                    for (i = 1; i <= n; i++) {
                        if (items[i] != "") {
                            # Map to OpenCode tool name (lowercase)
                            tool = tolower(items[i])
                            printf "  %s: allow\n", tool
                        }
                    }
                }
            }
            in_fm = 0
            print
            next
        }
        in_fm {
            # Strip name field for OpenCode (filename is used)
            if ($0 ~ /^name:/) { next }
            
            # Already have permission block - skip tools
            if ($0 ~ /^permission:/) { has_permission = 1 }
            if (has_permission) { print; next }
            
            # Collect tools from multi-line list
            if ($0 ~ /^tools:/) {
                in_tools = 1
                has_tools = 1
                # Check for inline array
                if ($0 ~ /\[/) {
                    # Inline array: tools: [Read, Write]
                    line = $0
                    gsub(/^tools:[[:space:]]*\[/, "", line)
                    gsub(/\].*/, "", line)
                    gsub(/,[[:space:]]*/, "\n", line)
                    tools_arr = line
                    in_tools = 0
                }
                next
            }
            
            if (in_tools) {
                # Multi-line list item: "  - Read" or indented continuation
                if ($0 ~ /^[[:space:]]*-[[:space:]]/) {
                    line = $0
                    gsub(/^[[:space:]]*-[[:space:]]*/, "", line)
                    tools_arr = tools_arr (tools_arr ? "\n" : "") line
                    next
                } else if ($0 ~ /^[[:space:]]+/) {
                    # Still indented, may be continuation
                    next
                } else {
                    # Not indented, tools list ended
                    in_tools = 0
                }
            }
            
            # Strip Claude-specific keys
            if ($0 ~ /^(disallowedTools|skills|hooks):/) { 
                # Skip entire block until next key
                while ((getline line > 0) && line ~ /^[[:space:]-]/) {}
                # Re-process the non-indented line
                if (line !~ /^---/) { print line }
                next
            }
            
            # Add mode if not present
            if ($0 ~ /^mode:/) { has_mode = 1 }
        }
        { print }
    ' "$f" > "$tmp"
    mv "$tmp" "$f"
    
    # Add mode: subagent if not already present (default for agents)
    if ! grep -q "^mode:" "$f"; then
        awk '
            BEGIN { in_fm = 0; added_mode = 0 }
            NR == 1 && $0 == "---" { in_fm = 1; print; next }
            in_fm && $0 == "---" { 
                if (!added_mode) {
                    print "mode: subagent"
                    added_mode = 1
                }
                print; next 
            }
            /^description:/ && !added_mode {
                print
                print "mode: subagent"
                added_mode = 1
                next
            }
            { print }
        ' "$f" > "$tmp"
        mv "$tmp" "$f"
    fi
}

# normalize_agent_markdown_in_place — Apply per-runtime agent frontmatter transformation.
# Runtime-specific rules:
#   - claude: No transformation (native format)
#   - codex: Strip Claude-only keys, lowercase tool names
#   - gemini: Strip Claude-only keys, map tool names, add kind: local
#   - opencode: Strip name, transform tools → permission, add mode
#   - qwen: Strip Claude-only keys, map tool names
normalize_agent_markdown_in_place() {
    local f="$1"
    local rt="$2"

    [ -f "$f" ] || return 0

    # Claude: no transformation needed
    [[ "$rt" == "claude" ]] && return 0

    # Strip Claude-only agent keys
    strip_claude_agent_frontmatter "$f" "$rt"

    # Runtime-specific transformations
    case "$rt" in
        codex)
            map_agent_tools_in_place "$f" "$rt"
            ;;
        gemini)
            # Map tool names and add kind: local if absent
            awk '
                BEGIN { in_fm = 0; has_kind = 0 }
                /^---$/ { in_fm = !in_fm; print; next }
                in_fm && /^kind:/ { has_kind = 1; print; next }
                in_fm && /^---$/ && !has_kind { print "kind: local"; print; next }
                { print }
                END { if (!has_kind && in_fm) print "kind: local" }
            ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
            ;;
        opencode)
            transform_agent_to_opencode_permission "$f"
            ;;
        qwen)
            map_agent_tools_in_place "$f" "$rt"
            ;;
    esac
}

# normalize_skill_markdown_in_place — T-095: Apply per-runtime frontmatter/body normalization.
# Runtime-agnostic rule: strip Claude-only keys for non-Claude runtimes.
# Commands-mode runtime rule: Qwen/Gemini use {{args}} placeholder.
normalize_skill_markdown_in_place() {
    local f="$1"
    local rt="$2"
    local mode="$3"

    [ -f "$f" ] || return 0

    [[ "$rt" != "claude" ]] && strip_claude_frontmatter "$f"
    if [[ "$mode" == "commands" ]] && [[ "$rt" == "qwen" || "$rt" == "gemini" ]]; then
        convert_args_placeholder "$f"
    fi
}

# Strip YAML frontmatter (---...---) from a file, printing remaining content to stdout.
strip_frontmatter() {
    local src="$1"
    awk '
        NR == 1 && $0 == "---" { in_frontmatter = 1; next }
        in_frontmatter && $0 == "---" { in_frontmatter = 0; next }
        in_frontmatter { next }
        { print }
    ' "$src"
}

# ---------------------------------------------------------------------------
# Commands profile — per-runtime SKILL.md schema/transform notes
# ---------------------------------------------------------------------------
# When --profile commands is used,
# each SKILL.md is transformed for the target runtime's commands directory.
#
# Runtime | Target path                          | Transform applied
# --------|--------------------------------------|-------------------------------
# claude  | .claude/commands/<skill>.md          | Frontmatter preserved
# codex   | ~/.codex/prompts/<skill>.md          | Frontmatter stripped (body only)
# gemini  | .gemini/commands/<skill>.toml        | TOML transform (description + prompt)
# opencode| .opencode/commands/<skill>.md        | Claude keys stripped for non-Claude schema
# qwen    | .qwen/commands/<skill>.md            | Claude keys stripped + {{args}} conversion
# ---------------------------------------------------------------------------

# skill_to_gemini_toml — T-092: Transform a SKILL.md file into a Gemini TOML command file.
# Writes the result to stdout.
# Transform rules:
#   - description: extracted from frontmatter `description:` field
#   - body: everything after the closing --- of frontmatter, with $ARGUMENTS -> {{args}}
#   - unknown frontmatter keys are excluded from TOML output
# Output format (Gemini TOML command schema):
#   description = "<description>"
#   prompt = '''
#   <body content>
#   '''
# Determinism: same input always produces same output.
skill_to_gemini_toml() {
    local src="$1"
    [ -f "$src" ] || return 1

    local fm_description
    fm_description=$(awk '
        /^---$/ { block++; next }
        block == 1 && /^description:/ {
            sub(/^description:[[:space:]]*/, ""); print; exit
        }
        block >= 2 { exit }
    ' "$src")

    # Extract body from file after frontmatter; normalize placeholder for Gemini.
    local body
    body="$(strip_frontmatter "$src" | sed 's/\$ARGUMENTS/{{args}}/g')"

    # Trim leading blank lines from body
    body=$(printf '%s' "$body" | sed '/./,$!d')

    # Escape description for TOML basic string.
    local safe_description
    safe_description=$(printf '%s' "$fm_description" | sed 's/\\/\\\\/g; s/"/\\"/g')

    # Prefer TOML literal multiline strings to avoid escape churn from markdown content.
    if printf '%s' "$body" | grep -q "'''"; then
        local safe_body
        safe_body=$(printf '%s' "$body" | sed 's/\\/\\\\/g; s/"/\\"/g')
        printf 'description = "%s"\nprompt = """\n%s\n"""\n' "$safe_description" "$safe_body"
    else
        printf "description = \"%s\"\nprompt = '''\n%s\n'''\n" "$safe_description" "$body"
    fi
}

# render_transformed_skill — T-095: apply per-runtime transform rules.
# Writes transformed content to stdout.
render_transformed_skill() {
    local src="$1"
    local rt="$2"
    local mode="$3"
    local source_name="$4"
    local target_name="$5"

    [ -f "$src" ] || return 1

    local tmp_md
    tmp_md="$(mktemp)"
    cp "$src" "$tmp_md"
    normalize_skill_markdown_in_place "$tmp_md" "$rt" "$mode"

    # Keep name/frontmatter aligned with namespaced fallback command names.
    if [[ "$mode" == "commands" && "$rt" != "codex" && "$rt" != "gemini" && "$source_name" != "$target_name" ]]; then
        apply_frontmatter_name_override "$tmp_md" "$source_name" "$target_name"
    fi

    case "$mode:$rt" in
        commands:codex)
            strip_frontmatter "$tmp_md"
            ;;
        commands:gemini)
            skill_to_gemini_toml "$tmp_md"
            ;;
        *)
            cat "$tmp_md"
            ;;
    esac

    rm -f "$tmp_md"
}

copy_generated_file() {
    local generated_file="$1"
    local target_file="$2"
    local backup_dir="$3"
    local backup_rel_path="$4"

    if [ -f "$target_file" ]; then
        if diff -q "$generated_file" "$target_file" > /dev/null 2>&1; then
            log_info "Unchanged: $target_file"
            ((++UNCHANGED))
        elif [ "$OVERWRITE" = true ]; then
            local backup_file="${backup_dir}/${backup_rel_path}"
            mkdir -p "$(dirname "$backup_file")"
            cp "$target_file" "$backup_file"
            cp "$generated_file" "$target_file"
            log_success "Overwritten: $target_file"
            ((++BACKUPS))
            ((++CREATED))
        else
            log_warning "$target_file exists and differs; use --overwrite to replace"
        fi
    else
        mkdir -p "$(dirname "$target_file")"
        cp "$generated_file" "$target_file"
        log_success "Created: $target_file"
        ((++CREATED))
    fi
}

resolve_commands_target_relpath() {
    local rt="$1"
    local namespace="$2"
    local skill_name="$3"
    local ext="$4"

    local command_name="$skill_name"
    local ns_mode
    ns_mode="$(namespace_mode_for_runtime_artifact "$rt" "commands")"
    if [ -n "$namespace" ]; then
        if [[ "$ns_mode" == "subdirectory" ]]; then
            printf '%s/%s.%s\n' "$namespace" "$skill_name" "$ext"
            return 0
        fi
        command_name="${namespace}-${skill_name}"
    fi
    printf '%s.%s\n' "$command_name" "$ext"
}

# Install skills as commands profile artifacts, applying per-runtime transforms.
install_runtime_commands_compat() {
    local rt="$1"
    local base_dir="$2"   # RUNTIME_CONF_DIR[rt] or rt_target
    local backup_dir="$3"
    local namespace="${4:-}"
    local commands_base_override="${5-__USE_RUNTIME_DEFAULT__}"

    local commands_base=""
    if [ "$commands_base_override" = "__USE_RUNTIME_DEFAULT__" ]; then
        commands_base="${RUNTIME_COMMANDS_CONF_OVERRIDE[${rt}]:-}"
    else
        commands_base="$commands_base_override"
    fi
    local commands_dir
    if [ -n "$commands_base" ]; then
        commands_dir="${commands_base}/${RUNTIME_COMMANDS_PATH[${rt}]}"
    else
        commands_dir="${base_dir}/${RUNTIME_COMMANDS_PATH[${rt}]}"
    fi

    if [ ! -d "${PACKAGE_DIR}/skills" ]; then
        log_warning "${rt}: no skills source directory; skipping commands profile install"
        return
    fi

    mkdir -p "$commands_dir"

    for skill_dir in "${PACKAGE_DIR}/skills"/*/; do
        [ -d "$skill_dir" ] || continue
        local skill_name
        skill_name="$(basename "$skill_dir")"
        local skill_md="${skill_dir}/SKILL.md"
        [ -f "$skill_md" ] || continue

        local ext="md"
        [[ "$rt" == "gemini" ]] && ext="toml"

        local target_rel
        target_rel="$(resolve_commands_target_relpath "$rt" "$namespace" "$skill_name" "$ext")"
        local target_name="${target_rel##*/}"
        target_name="${target_name%.*}"
        local target_file="${commands_dir}/${target_rel}"

        local tmp_file
        tmp_file="$(mktemp)"
        render_transformed_skill "$skill_md" "$rt" "commands" "$skill_name" "$target_name" > "$tmp_file"
        copy_generated_file "$tmp_file" "$target_file" "$backup_dir" "commands-compat-${rt}/${target_rel}"
        rm -f "$tmp_file"
    done
}

restore_or_remove_generated_file() {
    local generated_file="$1"
    local target_file="$2"
    local backup_file="$3"

    if restore_file_from_backup "$backup_file" "$target_file"; then
        return 0
    fi

    if [ -f "$target_file" ] && diff -q "$generated_file" "$target_file" > /dev/null 2>&1; then
        rm -f "$target_file"
        log_success "Removed installed file: $target_file"
        ((++CREATED))
    fi
    return 0
}

restore_runtime_commands_compat() {
    local rt="$1"
    local base_dir="$2"
    local backup_dir="$3"
    local namespace="${4:-}"
    local commands_base_override="${5-__USE_RUNTIME_DEFAULT__}"

    local commands_base=""
    if [ "$commands_base_override" = "__USE_RUNTIME_DEFAULT__" ]; then
        commands_base="${RUNTIME_COMMANDS_CONF_OVERRIDE[${rt}]:-}"
    else
        commands_base="$commands_base_override"
    fi
    local commands_dir
    if [ -n "$commands_base" ]; then
        commands_dir="${commands_base}/${RUNTIME_COMMANDS_PATH[${rt}]}"
    else
        commands_dir="${base_dir}/${RUNTIME_COMMANDS_PATH[${rt}]}"
    fi

    [ -d "${PACKAGE_DIR}/skills" ] || return 0
    [ -d "$commands_dir" ] || return 0

    for skill_dir in "${PACKAGE_DIR}/skills"/*/; do
        [ -d "$skill_dir" ] || continue
        local skill_name
        skill_name="$(basename "$skill_dir")"
        local skill_md="${skill_dir}/SKILL.md"
        [ -f "$skill_md" ] || continue

        local ext="md"
        [[ "$rt" == "gemini" ]] && ext="toml"

        local target_rel
        target_rel="$(resolve_commands_target_relpath "$rt" "$namespace" "$skill_name" "$ext")"
        local target_name="${target_rel##*/}"
        target_name="${target_name%.*}"
        local target_file="${commands_dir}/${target_rel}"

        local tmp_file
        tmp_file="$(mktemp)"
        render_transformed_skill "$skill_md" "$rt" "commands" "$skill_name" "$target_name" > "$tmp_file"
        local backup_file=""
        [ -n "$backup_dir" ] && backup_file="${backup_dir}/commands-compat-${rt}/${target_rel}"
        restore_or_remove_generated_file "$tmp_file" "$target_file" "$backup_file"
        rm -f "$tmp_file"
    done

    find "$commands_dir" -depth -type d -empty -delete 2>/dev/null || true
}

# check_runtime_collisions — T-081: Detect shared paths between selected runtimes.
check_runtime_collisions() {
    # OpenCode reads .claude/skills and .agents/skills natively
    if [ "$REF_OPENCODE" = true ]; then
        [ "$REF_CLAUDE" = true ] && log_info "Note: OpenCode natively reads .claude/skills — Claude and OpenCode will share that path"
        [ "$REF_CODEX" = true ]  && log_info "Note: OpenCode natively reads .agents/skills — Codex and OpenCode will share that path"
    fi

    # Check for shared project root doc files
    local shared_docs=()
    local doc_files=()
    local active_rts
    read -ra active_rts <<< "$(get_active_runtimes)"
    for rt in "${active_rts[@]}"; do
        local doc="${RUNTIME_DOC_FILE[${rt}]}"
        for existing in "${doc_files[@]}"; do
            [ "$doc" = "$existing" ] && shared_docs+=("$doc")
        done
        doc_files+=("$doc")
    done
    for shared in "${shared_docs[@]}"; do
        log_info "Note: ${shared} is shared between multiple runtimes; policy refs from all runtimes will be injected"
    done
}

# prune_gemini_native_alias_conflicts
# Gemini also loads Codex alias paths (~/.agents/skills or .agents/skills). When both
# contain the same skill name at the same scope, Gemini emits "Skill conflict detected".
# To suppress this runtime warning, remove duplicate native Gemini skill folders and keep
# the alias copy only.
prune_gemini_native_alias_conflicts() {
    local gemini_skills_dir="$1"
    local alias_skills_dir="$2"
    local removed=0

    [ -d "$gemini_skills_dir" ] || return 0
    [ -d "$alias_skills_dir" ] || return 0

    for skill_dir in "$gemini_skills_dir"/*; do
        [ -d "$skill_dir" ] || continue
        local skill_name="${skill_dir##*/}"
        local alias_skill_md="${alias_skills_dir}/${skill_name}/SKILL.md"
        local gemini_skill_md="${skill_dir}/SKILL.md"
        if [ -f "$alias_skill_md" ] && [ -f "$gemini_skill_md" ]; then
            rm -rf "$skill_dir"
            log_info "gemini: pruned duplicate skill '${skill_name}' (alias preferred: ${alias_skill_md})"
            ((++removed))
        fi
    done

    if [ "$removed" -gt 0 ]; then
        find "$gemini_skills_dir" -depth -type d -empty -delete 2>/dev/null || true
        log_info "gemini: removed ${removed} duplicate native skills to suppress alias conflict warnings"
    fi
}

# Install global artifacts for a single runtime (registry-driven)
install_runtime_global() {
    local rt="$1"
    local backup_dir="$2"
    local target="${RUNTIME_CONF_DIR[${rt}]}"

    log_info "Installing runtime '${rt}' to ${target} (profile: ${PROFILE})"

    # T-079: warn and skip when requested profile is unsupported by this runtime
    if [[ "$PROFILE" == "hooks" ]] && [[ "${RUNTIME_SUPPORTS_HOOKS[${rt}]}" != "true" ]]; then
        log_warning "${rt}: hooks not supported; --profile hooks ignored for this runtime"
        return
    fi
    if [[ "$PROFILE" == "skills" ]] && [[ "${RUNTIME_SUPPORTS_SKILLS[${rt}]}" != "true" ]]; then
        log_warning "${rt}: skills not supported; --profile skills ignored for this runtime (use --profile commands)"
        return
    fi

    # Resolve effective profile for this runtime
    local eff_profile="$PROFILE"
    if [[ "$eff_profile" == "auto" ]]; then
        if [[ "${RUNTIME_SUPPORTS_SKILLS[${rt}]}" == "true" ]]; then
            eff_profile="skills"
        else
            eff_profile="commands"
        fi
    fi
    if [[ "$HOOKS_ENABLED" != "true" ]] && [[ "${RUNTIME_SUPPORTS_HOOKS[${rt}]}" == "true" ]] && [[ "$eff_profile" == "skills" || "$eff_profile" == "hooks" || "$eff_profile" == "all" ]]; then
        log_info "${rt}: hooks disabled by default; pass --hooks to install hooks"
    fi
    local skills_namespace agents_namespace commands_namespace
    skills_namespace="$(effective_namespace_for_runtime_artifact "$rt" "skills")"
    agents_namespace="$(effective_namespace_for_runtime_artifact "$rt" "agents")"
    commands_namespace="$(effective_namespace_for_runtime_artifact "$rt" "commands")"

    # Skills: install when profile is skills or all
    if [[ "$eff_profile" == "skills" || "$eff_profile" == "all" ]]; then
        if [[ "${RUNTIME_SUPPORTS_SKILLS[${rt}]}" == "true" ]] && [ -d "${PACKAGE_DIR}/skills" ]; then
            local skills_target="${target}/${RUNTIME_SKILLS_PATH[${rt}]}"
            if [ -n "$skills_namespace" ]; then
                copy_namespaced_skills "${PACKAGE_DIR}/skills" "$skills_target" "$skills_namespace" "$backup_dir" "$rt"
            else
                # Non-Claude runtimes persist transformed SKILL.md; copy transformed source to avoid repeated false diffs.
                if [[ "$rt" != "claude" ]]; then
                    local tmp_skills_dir
                    tmp_skills_dir="$(mktemp -d)"
                    cp -r "${PACKAGE_DIR}/skills/." "$tmp_skills_dir/"
                    for skill_md in "$tmp_skills_dir"/*/SKILL.md; do
                        normalize_skill_markdown_in_place "$skill_md" "$rt" "skills"
                    done
                    copy_directory "$tmp_skills_dir" "$skills_target" "$backup_dir"
                    rm -rf "$tmp_skills_dir"
                else
                    copy_directory "${PACKAGE_DIR}/skills" "$skills_target" "$backup_dir"
                fi
            fi

            if [[ "$rt" == "gemini" ]]; then
                local codex_alias_skills="${RUNTIME_CONF_DIR[codex]}/${RUNTIME_SKILLS_PATH[codex]}"
                prune_gemini_native_alias_conflicts "$skills_target" "$codex_alias_skills"
            fi
        fi
    fi

    # Commands compat: install when profile is commands or all
    if [[ "$eff_profile" == "commands" || "$eff_profile" == "all" ]]; then
        install_runtime_commands_compat "$rt" "$target" "$backup_dir" "$commands_namespace"
    fi

    # Agents: only if runtime has agents path (not gated by profile)
    if [[ -n "${RUNTIME_AGENTS_PATH[${rt}]}" ]] && [ -d "${PACKAGE_DIR}/agents" ]; then
        local agents_target="${target}/${RUNTIME_AGENTS_PATH[${rt}]}"
        if [ -n "$agents_namespace" ]; then
            copy_namespaced_agents "${PACKAGE_DIR}/agents" "$agents_target" "$agents_namespace" "$backup_dir" "$rt"
        else
            # Non-Claude runtimes need transformed AGENT.md; copy transformed source to avoid repeated false diffs.
            if [[ "$rt" != "claude" ]]; then
                local tmp_agents_dir
                tmp_agents_dir="$(mktemp -d)"
                cp -r "${PACKAGE_DIR}/agents/." "$tmp_agents_dir/"
                for agent_md in "$tmp_agents_dir"/*.md; do
                    [ -f "$agent_md" ] || continue
                    normalize_agent_markdown_in_place "$agent_md" "$rt"
                done
                copy_directory "$tmp_agents_dir" "$agents_target" "$backup_dir"
                rm -rf "$tmp_agents_dir"
            else
                copy_directory "${PACKAGE_DIR}/agents" "$agents_target" "$backup_dir"
            fi
        fi
    fi

    # Extra agents: runtime-specific agents from package/agents-also-run/<runtime>/
    if [[ -n "${RUNTIME_AGENTS_PATH[${rt}]}" ]] && [[ -n "${RUNTIME_EXTRA_AGENTS[${rt}]:-}" ]]; then
        local extra_agents_dir="${PACKAGE_DIR}/agents-also-run/${rt}"
        if [ -d "$extra_agents_dir" ]; then
            local agents_target="${target}/${RUNTIME_AGENTS_PATH[${rt}]}"
            for extra_agent in ${RUNTIME_EXTRA_AGENTS[${rt}]}; do
                local extra_agent_file="${extra_agents_dir}/${extra_agent}.md"
                if [ -f "$extra_agent_file" ]; then
                    mkdir -p "$agents_target"
                    # Transform extra agent for target runtime
                    if [[ "$rt" != "claude" ]]; then
                        local tmp_extra_agent
                        tmp_extra_agent="$(mktemp)"
                        cp "$extra_agent_file" "$tmp_extra_agent"
                        normalize_agent_markdown_in_place "$tmp_extra_agent" "$rt"
                        cp "$tmp_extra_agent" "${agents_target}/${extra_agent}.md"
                        rm -f "$tmp_extra_agent"
                    else
                        cp "$extra_agent_file" "${agents_target}/${extra_agent}.md"
                    fi
                    log_success "Installed extra agent: ${extra_agent}.md for ${rt}"
                fi
            done
        fi
    fi

    # Hooks: install only when explicitly enabled via --hooks.
    if [[ "$HOOKS_ENABLED" == "true" ]] && [[ "$eff_profile" == "hooks" || "$eff_profile" == "all" || "$eff_profile" == "skills" ]]; then
        if [[ "${RUNTIME_SUPPORTS_HOOKS[${rt}]}" == "true" ]] && [ -d "${PACKAGE_DIR}/hooks" ]; then
            local hooks_target="${target}/${RUNTIME_HOOKS_PATH[${rt}]}"
            copy_directory "${PACKAGE_DIR}/hooks" "$hooks_target" "$backup_dir"
        fi
    fi
}

# Install project artifacts for a single runtime (registry-driven)
install_runtime_project() {
    local rt="$1"
    local target="$2"
    local backup_dir="$3"
    local rt_dir="${RUNTIME_PROJECT_DIR[${rt}]}"
    local rt_target="${target}/${rt_dir}"

    log_info "Installing runtime '${rt}' project artifacts to ${rt_target} (profile: ${PROFILE})"

    # T-079: warn and skip when requested profile is unsupported by this runtime
    if [[ "$PROFILE" == "hooks" ]] && [[ "${RUNTIME_SUPPORTS_HOOKS[${rt}]}" != "true" ]]; then
        log_warning "${rt}: hooks not supported; --profile hooks ignored for this runtime"
        return
    fi
    if [[ "$PROFILE" == "skills" ]] && [[ "${RUNTIME_SUPPORTS_SKILLS[${rt}]}" != "true" ]]; then
        log_warning "${rt}: skills not supported; --profile skills ignored for this runtime (use --profile commands)"
        return
    fi

    # Resolve effective profile for this runtime
    local eff_profile="$PROFILE"
    if [[ "$eff_profile" == "auto" ]]; then
        if [[ "${RUNTIME_SUPPORTS_SKILLS[${rt}]}" == "true" ]]; then
            eff_profile="skills"
        else
            eff_profile="commands"
        fi
    fi
    if [[ "$HOOKS_ENABLED" != "true" ]] && [[ "${RUNTIME_SUPPORTS_HOOKS[${rt}]}" == "true" ]] && [[ "$eff_profile" == "skills" || "$eff_profile" == "hooks" || "$eff_profile" == "all" ]]; then
        log_info "${rt}: hooks disabled by default; pass --hooks to install hooks"
    fi
    local skills_namespace agents_namespace commands_namespace
    skills_namespace="$(effective_namespace_for_runtime_artifact "$rt" "skills")"
    agents_namespace="$(effective_namespace_for_runtime_artifact "$rt" "agents")"
    commands_namespace="$(effective_namespace_for_runtime_artifact "$rt" "commands")"

    # Skills: install when profile is skills or all
    if [[ "$eff_profile" == "skills" || "$eff_profile" == "all" ]]; then
        if [[ "${RUNTIME_SUPPORTS_SKILLS[${rt}]}" == "true" ]] && [ -d "${PACKAGE_DIR}/skills" ]; then
            local skills_target="${rt_target}/${RUNTIME_SKILLS_PATH[${rt}]}"
            if [ -n "$skills_namespace" ]; then
                copy_namespaced_skills "${PACKAGE_DIR}/skills" "$skills_target" "$skills_namespace" "$backup_dir" "$rt"
            else
                # Non-Claude runtimes persist transformed SKILL.md; copy transformed source to avoid repeated false diffs.
                if [[ "$rt" != "claude" ]]; then
                    local tmp_skills_dir
                    tmp_skills_dir="$(mktemp -d)"
                    cp -r "${PACKAGE_DIR}/skills/." "$tmp_skills_dir/"
                    for skill_md in "$tmp_skills_dir"/*/SKILL.md; do
                        normalize_skill_markdown_in_place "$skill_md" "$rt" "skills"
                    done
                    copy_directory "$tmp_skills_dir" "$skills_target" "$backup_dir"
                    rm -rf "$tmp_skills_dir"
                else
                    copy_directory "${PACKAGE_DIR}/skills" "$skills_target" "$backup_dir"
                fi
            fi

            if [[ "$rt" == "gemini" ]]; then
                local codex_alias_skills="${target}/${RUNTIME_PROJECT_DIR[codex]}/${RUNTIME_SKILLS_PATH[codex]}"
                prune_gemini_native_alias_conflicts "$skills_target" "$codex_alias_skills"
            fi
        fi
    fi

    # Commands compat: install when profile is commands or all
    if [[ "$eff_profile" == "commands" || "$eff_profile" == "all" ]]; then
        install_runtime_commands_compat "$rt" "$rt_target" "$backup_dir" "$commands_namespace" ""
    fi

    # Agents: only if runtime has agents path (not gated by profile)
    if [[ -n "${RUNTIME_AGENTS_PATH[${rt}]}" ]] && [ -d "${PACKAGE_DIR}/agents" ]; then
        local agents_target="${rt_target}/${RUNTIME_AGENTS_PATH[${rt}]}"
        if [ -n "$agents_namespace" ]; then
            copy_namespaced_agents "${PACKAGE_DIR}/agents" "$agents_target" "$agents_namespace" "$backup_dir" "$rt"
        else
            # Non-Claude runtimes need transformed AGENT.md; copy transformed source to avoid repeated false diffs.
            if [[ "$rt" != "claude" ]]; then
                local tmp_agents_dir
                tmp_agents_dir="$(mktemp -d)"
                cp -r "${PACKAGE_DIR}/agents/." "$tmp_agents_dir/"
                for agent_md in "$tmp_agents_dir"/*.md; do
                    [ -f "$agent_md" ] || continue
                    normalize_agent_markdown_in_place "$agent_md" "$rt"
                done
                copy_directory "$tmp_agents_dir" "$agents_target" "$backup_dir"
                rm -rf "$tmp_agents_dir"
            else
                copy_directory "${PACKAGE_DIR}/agents" "$agents_target" "$backup_dir"
            fi
        fi
    fi

    # Extra agents: runtime-specific agents from package/agents-also-run/<runtime>/
    if [[ -n "${RUNTIME_AGENTS_PATH[${rt}]}" ]] && [[ -n "${RUNTIME_EXTRA_AGENTS[${rt}]:-}" ]]; then
        local extra_agents_dir="${PACKAGE_DIR}/agents-also-run/${rt}"
        if [ -d "$extra_agents_dir" ]; then
            local agents_target="${rt_target}/${RUNTIME_AGENTS_PATH[${rt}]}"
            for extra_agent in ${RUNTIME_EXTRA_AGENTS[${rt}]}; do
                local extra_agent_file="${extra_agents_dir}/${extra_agent}.md"
                if [ -f "$extra_agent_file" ]; then
                    mkdir -p "$agents_target"
                    # Transform extra agent for target runtime
                    if [[ "$rt" != "claude" ]]; then
                        local tmp_extra_agent
                        tmp_extra_agent="$(mktemp)"
                        cp "$extra_agent_file" "$tmp_extra_agent"
                        normalize_agent_markdown_in_place "$tmp_extra_agent" "$rt"
                        cp "$tmp_extra_agent" "${agents_target}/${extra_agent}.md"
                        rm -f "$tmp_extra_agent"
                    else
                        cp "$extra_agent_file" "${agents_target}/${extra_agent}.md"
                    fi
                    log_success "Installed extra agent: ${extra_agent}.md for ${rt}"
                fi
            done
        fi
    fi

    # Hooks: install only when explicitly enabled via --hooks.
    if [[ "$HOOKS_ENABLED" == "true" ]] && [[ "$eff_profile" == "hooks" || "$eff_profile" == "all" || "$eff_profile" == "skills" ]]; then
        if [[ "${RUNTIME_SUPPORTS_HOOKS[${rt}]}" == "true" ]] && [ -d "${PACKAGE_DIR}/hooks" ]; then
            local hooks_target="${rt_target}/${RUNTIME_HOOKS_PATH[${rt}]}"
            copy_directory "${PACKAGE_DIR}/hooks" "$hooks_target" "$backup_dir"
        fi
    fi
}

# Restore global artifacts for a single runtime (registry-driven)
restore_runtime_global() {
    local rt="$1"
    local backup_dir="$2"
    local target="${RUNTIME_CONF_DIR[${rt}]}"
    local skills_namespace agents_namespace commands_namespace
    skills_namespace="$(effective_namespace_for_runtime_artifact "$rt" "skills")"
    agents_namespace="$(effective_namespace_for_runtime_artifact "$rt" "agents")"
    commands_namespace="$(effective_namespace_for_runtime_artifact "$rt" "commands")"

    # Skills
    if [[ "${RUNTIME_SUPPORTS_SKILLS[${rt}]}" == "true" ]] && [ -d "${PACKAGE_DIR}/skills" ]; then
        local skills_target="${target}/${RUNTIME_SKILLS_PATH[${rt}]}"
        if [ -n "$skills_namespace" ]; then
            restore_namespaced_skills "${PACKAGE_DIR}/skills" "$skills_target" "$skills_namespace" "$rt"
        else
            restore_or_remove_installed_tree "${PACKAGE_DIR}/skills" "$skills_target" "$backup_dir" "skills" "$rt"
        fi
    fi

    # Commands compatibility artifacts
    if [[ "${RUNTIME_SUPPORTS_COMMANDS[${rt}]}" == "true" ]]; then
        restore_runtime_commands_compat "$rt" "$target" "$backup_dir" "$commands_namespace"
    fi

    # Agents
    if [[ -n "${RUNTIME_AGENTS_PATH[${rt}]}" ]] && [ -d "${PACKAGE_DIR}/agents" ]; then
        local agents_target="${target}/${RUNTIME_AGENTS_PATH[${rt}]}"
        if [ -n "$agents_namespace" ]; then
            restore_namespaced_agents "${PACKAGE_DIR}/agents" "$agents_target" "$agents_namespace" "$rt"
        else
            restore_or_remove_installed_tree "${PACKAGE_DIR}/agents" "$agents_target" "$backup_dir" "agents" "$rt"
        fi
    fi

    # Hooks
    if [[ "${RUNTIME_SUPPORTS_HOOKS[${rt}]}" == "true" ]]; then
        local hooks_dir="${target}/${RUNTIME_HOOKS_PATH[${rt}]}"
        if [ -d "$hooks_dir" ]; then
            rm -rf "$hooks_dir"
            log_success "Removed: $hooks_dir"
            ((++CREATED))
        fi
    fi
}

# Restore project artifacts for a single runtime (registry-driven)
restore_runtime_project() {
    local rt="$1"
    local target="$2"
    local backup_dir="$3"
    local rt_target="${target}/${RUNTIME_PROJECT_DIR[${rt}]}"
    local skills_namespace agents_namespace commands_namespace
    skills_namespace="$(effective_namespace_for_runtime_artifact "$rt" "skills")"
    agents_namespace="$(effective_namespace_for_runtime_artifact "$rt" "agents")"
    commands_namespace="$(effective_namespace_for_runtime_artifact "$rt" "commands")"

    # Skills
    if [[ "${RUNTIME_SUPPORTS_SKILLS[${rt}]}" == "true" ]] && [ -d "${PACKAGE_DIR}/skills" ]; then
        local skills_target="${rt_target}/${RUNTIME_SKILLS_PATH[${rt}]}"
        if [ -n "$skills_namespace" ]; then
            restore_namespaced_skills "${PACKAGE_DIR}/skills" "$skills_target" "$skills_namespace" "$rt"
        else
            restore_or_remove_installed_tree "${PACKAGE_DIR}/skills" "$skills_target" "$backup_dir" "skills" "$rt"
        fi
    fi

    # Commands compatibility artifacts
    if [[ "${RUNTIME_SUPPORTS_COMMANDS[${rt}]}" == "true" ]]; then
        restore_runtime_commands_compat "$rt" "$rt_target" "$backup_dir" "$commands_namespace" ""
    fi

    # Agents
    if [[ -n "${RUNTIME_AGENTS_PATH[${rt}]}" ]] && [ -d "${PACKAGE_DIR}/agents" ]; then
        local agents_target="${rt_target}/${RUNTIME_AGENTS_PATH[${rt}]}"
        if [ -n "$agents_namespace" ]; then
            restore_namespaced_agents "${PACKAGE_DIR}/agents" "$agents_target" "$agents_namespace" "$rt"
        else
            restore_or_remove_installed_tree "${PACKAGE_DIR}/agents" "$agents_target" "$backup_dir" "agents" "$rt"
        fi
    fi

    # Hooks
    if [[ "${RUNTIME_SUPPORTS_HOOKS[${rt}]}" == "true" ]]; then
        local hooks_dir="${rt_target}/${RUNTIME_HOOKS_PATH[${rt}]}"
        if [ -d "$hooks_dir" ]; then
            rm -rf "$hooks_dir"
            log_success "Removed: $hooks_dir"
            ((++CREATED))
        fi
    fi
}

# Reset runtime-selection REF_* flags to false.
reset_runtime_targets() {
    REF_CLAUDE=false
    REF_CODEX=false
    REF_GEMINI=false
    REF_OPENCODE=false
    REF_QWEN=false
}

# Enable runtime-selection REF_* flags from a runtime selector token.
# Selectors:
#   --claude --codex --gemini --opencode --qwen
#   --trio  -> --claude --codex --gemini
#   --all   -> all runtimes
apply_runtime_selector() {
    local selector="$1"
    case "$selector" in
        --claude|claude)
            REF_CLAUDE=true
            ;;
        --codex|codex)
            REF_CODEX=true
            ;;
        --gemini|gemini)
            REF_GEMINI=true
            ;;
        --opencode|opencode)
            REF_OPENCODE=true
            ;;
        --qwen|qwen)
            REF_QWEN=true
            ;;
        --trio|trio)
            REF_CLAUDE=true
            REF_CODEX=true
            REF_GEMINI=true
            ;;
        --all|all)
            REF_CLAUDE=true
            REF_CODEX=true
            REF_GEMINI=true
            REF_OPENCODE=true
            REF_QWEN=true
            ;;
        *)
            log_error "Invalid runtime selector '${selector}'. Valid: --claude --codex --gemini --opencode --qwen --trio --all"
            exit 1
            ;;
    esac
}

# Build list of active runtimes based on REF_* flags
get_active_runtimes() {
    local active=()
    [ "$REF_CLAUDE" = true ]    && active+=(claude)
    [ "$REF_CODEX" = true ]     && active+=(codex)
    [ "$REF_GEMINI" = true ]    && active+=(gemini)
    [ "$REF_OPENCODE" = true ]  && active+=(opencode)
    [ "$REF_QWEN" = true ]      && active+=(qwen)
    echo "${active[@]}"
}

# Resolve backup anchor target from active runtime set.
# Keeps per-target operations isolated (e.g., --codex must not touch ~/.claude).
get_backup_anchor_target() {
    local active_runtimes
    read -ra active_runtimes <<< "$(get_active_runtimes)"
    local anchor_rt="${active_runtimes[0]:-claude}"
    echo "${RUNTIME_CONF_DIR[${anchor_rt}]}"
}

# Build per-runtime global policy refs that point to that runtime's own policy dir.
global_refs_for_runtime() {
    local rt="$1"
    local policy_dir="${RUNTIME_CONF_DIR[${rt}]}/policy"
    local policy_ref_dir="${policy_dir/#${HOME}/\~}"
    printf 'Read @%s/PRINCIPLES.md\nRead @%s/RULES.md' "$policy_ref_dir" "$policy_ref_dir"
}

# Install global components to runtime conf dirs
install_global() {
    local claude_target="${RUNTIME_CONF_DIR[claude]}"
    log_info "Installing global components"
    if [ -n "$NAMESPACE" ]; then
        log_info "Using namespace '${NAMESPACE}' where supported by runtime"
    else
        log_info "Using flat paths (no namespace prefix)"
    fi

    local backup_dir
    local backup_anchor_target
    backup_anchor_target="$(get_backup_anchor_target)"
    backup_dir=$(create_backup_dir "$backup_anchor_target")

    local active_runtimes
    read -ra active_runtimes <<< "$(get_active_runtimes)"

    # Install shared global assets into each selected runtime target dir.
    if [ -d "${PACKAGE_DIR}" ]; then
        for rt in "${active_runtimes[@]}"; do
            local rt_target="${RUNTIME_CONF_DIR[${rt}]}"
            local rt_backup_dir="${backup_dir}/shared-${rt}"
            copy_directory "${PACKAGE_DIR}/policy" "${rt_target}/policy" "$rt_backup_dir"
            copy_directory "${PACKAGE_DIR}/workflows" "${rt_target}/workflows" "$rt_backup_dir"
            copy_directory "${PACKAGE_DIR}/templates" "${rt_target}/templates" "$rt_backup_dir"
        done
    fi

    # Claude-specific settings are only merged when claude runtime is active.
    if [ "$REF_CLAUDE" = true ]; then
        local claude_settings_source="${PACKAGE_DIR}/settings.no-hooks.json"
        if [ "$HOOKS_ENABLED" = true ]; then
            claude_settings_source="${PACKAGE_DIR}/settings.json"
        fi
        if [ -f "$claude_settings_source" ]; then
            merge_json "$claude_settings_source" "${claude_target}/settings.json" "$backup_dir"
        fi
    fi

    # Claude-specific user-scope MCP config is only merged when claude runtime is active.
    if [ "$REF_CLAUDE" = true ] && [ -f "${PACKAGE_DIR}/mcp.json" ]; then
        merge_json "${PACKAGE_DIR}/mcp.json" "${HOME}/.claude.json" "$backup_dir" ".claude.json"
    fi

    # T-081: check for cross-runtime path collisions
    check_runtime_collisions

    # Install per-runtime artifacts using registry
    for rt in "${active_runtimes[@]}"; do
        install_runtime_global "$rt" "$backup_dir"
    done

    # Inject @-references for global policies into selected runtime docs.
    if [ "$REF_CLAUDE" = true ]; then
        local claude_global_refs
        claude_global_refs="$(global_refs_for_runtime "claude")"
        inject_policy_refs "${RUNTIME_CONF_DIR[claude]}" "orchestrator:global-refs" \
            "$claude_global_refs" "$backup_dir" "claude" "${RUNTIME_DOC_FILE[claude]}"
    fi
    if [ "$REF_GEMINI" = true ]; then
        local gemini_global_refs
        gemini_global_refs="$(global_refs_for_runtime "gemini")"
        inject_policy_refs "${RUNTIME_CONF_DIR[gemini]}" "orchestrator:global-refs" \
            "$gemini_global_refs" "$backup_dir" "gemini" "${RUNTIME_DOC_FILE[gemini]}"
    fi
    if [ "$REF_CODEX" = true ]; then
        local codex_doc_dir="${RUNTIME_DOC_DIR_OVERRIDE[codex]:-${RUNTIME_CONF_DIR[codex]}}"
        local codex_global_refs
        codex_global_refs="$(global_refs_for_runtime "codex")"
        inject_policy_refs "$codex_doc_dir" "orchestrator:global-refs" \
            "$codex_global_refs" "$backup_dir" "codex" "${RUNTIME_DOC_FILE[codex]}"
    fi
    if [ "$REF_OPENCODE" = true ]; then
        log_info "opencode: policy-ref injection into opencode.json not yet implemented (JSON format differs)"
    fi
    if [ "$REF_QWEN" = true ]; then
        local qwen_global_refs
        qwen_global_refs="$(global_refs_for_runtime "qwen")"
        inject_policy_refs "${RUNTIME_CONF_DIR[qwen]}" "orchestrator:global-refs" \
            "$qwen_global_refs" "$backup_dir" "qwen" "${RUNTIME_DOC_FILE[qwen]}"
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
    if [ -n "$NAMESPACE" ]; then
        log_info "Using namespace '${NAMESPACE}' where supported by runtime"
    else
        log_info "Using flat paths (no namespace prefix)"
    fi

    local backup_dir
    backup_dir=$(create_backup_dir "$target")

    # 1. Provision docs folder tree with .gitignore placeholders
    # The record schema's document tree. ADR is uppercase because the record id is
    # ADR-<TIER>-NNN and every canon reference spells the directory that way; a lowercase
    # adr/ is invisible on a case-insensitive filesystem and a second, empty directory on
    # every other one.
    local dirs=(docs/policy docs/objectives docs/requirements
                docs/architecture docs/architecture/foundation docs/architecture/feature
                docs/architecture/system docs/architecture/ADR
                docs/development docs/development/plans docs/development/workorders
                docs/development/issues docs/development/debt docs/development/feedback
                docs/development/status
                docs/knowledge docs/knowledge/decisions
                docs/knowledge/domain docs/knowledge/patterns docs/knowledge/runbooks
                docs/analysis docs/validation
                reports/research reports/meta-optimization)
    for d in "${dirs[@]}"; do
        mkdir -p "${target}/${d}"
        if [ -z "$(ls -A "${target}/${d}" 2>/dev/null)" ]; then
            printf '# Placeholder to keep this directory in git.\n' > "${target}/${d}/.gitignore"
        elif [ -f "${target}/${d}/.gitkeep" ] && [ ! -f "${target}/${d}/.gitignore" ] && [ "$(find "${target}/${d}" -mindepth 1 -maxdepth 1 | wc -l)" -eq 1 ]; then
            rm -f "${target}/${d}/.gitkeep"
            printf '# Placeholder to keep this directory in git.\n' > "${target}/${d}/.gitignore"
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

    local active_runtimes
    read -ra active_runtimes <<< "$(get_active_runtimes)"

    # 4. Deploy shared runtime assets (templates, policy, workflows) into each
    #    selected runtime's project root so installed skills/agents resolve the
    #    same relative locations across Claude, Codex, Gemini, OpenCode, and Qwen.
    for rt in "${active_runtimes[@]}"; do
        local rt_target="${target}/${RUNTIME_PROJECT_DIR[${rt}]}"
        local rt_backup_dir="${backup_dir}/shared-project-${rt}"
        copy_directory "${PACKAGE_DIR}/templates" "${rt_target}/templates" "$rt_backup_dir"
        copy_directory "${PACKAGE_DIR}/policy" "${rt_target}/policy" "$rt_backup_dir"
        if [ -d "${PACKAGE_DIR}/workflows" ]; then
            copy_directory "${PACKAGE_DIR}/workflows" "${rt_target}/workflows" "$rt_backup_dir"
        fi
    done

    # T-081: check for cross-runtime path collisions
    check_runtime_collisions

    # 5. Install per-runtime project artifacts using registry
    for rt in "${active_runtimes[@]}"; do
        install_runtime_project "$rt" "$target" "$backup_dir"
    done

    # 6. Inject @-references for project policies into selected local runtime docs
    local project_doc_files=""
    [ "$REF_CLAUDE" = true ]    && project_doc_files="${project_doc_files} ${RUNTIME_DOC_FILE[claude]}"
    [ "$REF_CODEX" = true ]     && project_doc_files="${project_doc_files} ${RUNTIME_DOC_FILE[codex]}"
    [ "$REF_GEMINI" = true ]    && project_doc_files="${project_doc_files} ${RUNTIME_DOC_FILE[gemini]}"
    [ "$REF_QWEN" = true ]      && project_doc_files="${project_doc_files} ${RUNTIME_DOC_FILE[qwen]}"
    # opencode.json injection skipped (JSON format differs from markdown ref pattern)
    if [ -n "$project_doc_files" ]; then
        inject_policy_refs "$target" "orchestrator:project-refs" \
            "$(printf 'Read @docs/policy/STANDARDS.md\nRead @docs/policy/GUIDELINES.md')" \
            "$backup_dir" "project-root" "$project_doc_files"
    fi

    # 7. Initialize Serena project if uvx is available
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

    # Run Serena using normal argv quoting so the runtime sees the raw project name.
    if (cd "$target" && uvx --from git+https://github.com/oraios/serena serena project create --name "$project_name" 2>/dev/null); then
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
    echo "  1. Run your agent of choice"
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

# Remove top-level keys contributed by the installer's settings.json from target.
# If the result is an empty object, deletes the file.
unpatch_settings_json() {
    local target_file="$1"

    [ -f "$target_file" ] || return 0

    if ! command -v jq &>/dev/null; then
        log_warning "jq not found. Cannot unpatch $target_file"
        return
    fi

    local source="${PACKAGE_DIR}/settings.json"
    [ -f "$source" ] || return 0

    local result
    result=$(jq --argjson src "$(cat "$source")" \
        'to_entries | map(select(.key as $k | ($src | has($k)) | not)) | from_entries' \
        "$target_file")

    if [ "$result" = "{}" ] || [ -z "$result" ]; then
        rm -f "$target_file"
        log_success "Removed: $target_file (was fully installer-managed)"
        ((++CREATED))
    else
        printf '%s\n' "$result" > "$target_file"
        log_success "Unpatched: $target_file (removed installer-contributed keys)"
        ((++PATCHED))
    fi
}

# Restore settings.json from backup; fall back to unpatching installer keys.
restore_settings() {
    local target="$1"
    local backup_dir="$2"
    local settings_file="${target}/settings.json"

    # Look for settings.json in backup
    local backup_settings=""
    if [ -n "$backup_dir" ]; then
        backup_settings="${backup_dir}/settings.json"
    fi
    if [ -n "$backup_settings" ] && [ -f "$backup_settings" ]; then
        cp "$backup_settings" "$settings_file"
        log_success "Restored: $settings_file from backup"
        ((++CREATED))
    else
        log_info "No settings.json backup found; unpatching installer-contributed keys"
        unpatch_settings_json "$settings_file"
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
    local tmp_file="${target_file}.tmp"

    [ -f "$target_file" ] || return 0

    # Preferred bounded block removal (no tail loss).
    if grep -qF "$start_tag" "$target_file" 2>/dev/null && grep -qF "$end_tag" "$target_file" 2>/dev/null; then
        awk -v start="$start_tag" -v end="$end_tag" '
            $0 == start {skip=1; next}
            $0 == end   {skip=0; next}
            !skip       {lines[++n]=$0}
            END {
                while (n > 0 && lines[n] ~ /^[[:space:]]*$/) n--
                for (i = 1; i <= n; i++) print lines[i]
            }
        ' "$target_file" > "$tmp_file"
        mv "$tmp_file" "$target_file"
        log_success "Stripped refs from: $target_file"
        ((++PATCHED))
        return 0
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
    local claude_target="${RUNTIME_CONF_DIR[claude]}"
    log_info "Restoring global installation"
    if [ -n "$NAMESPACE" ]; then
        log_info "Restoring namespace '${NAMESPACE}' where supported by runtime"
    else
        log_info "Restoring flat paths"
    fi

    local backup_dir
    local backup_anchor_target
    backup_anchor_target="$(get_backup_anchor_target)"
    backup_dir=$(find_latest_backup "$backup_anchor_target")

    # Restore per-runtime artifacts using registry
    local active_runtimes
    read -ra active_runtimes <<< "$(get_active_runtimes)"
    for rt in "${active_runtimes[@]}"; do
        restore_runtime_global "$rt" "$backup_dir"
    done

    # Restore/remove shared trees under each selected runtime target dir.
    for rt in "${active_runtimes[@]}"; do
        local rt_target="${RUNTIME_CONF_DIR[${rt}]}"
        local rt_backup_dir=""
        [ -n "$backup_dir" ] && rt_backup_dir="${backup_dir}/shared-${rt}"
        restore_or_remove_installed_tree \
            "${PACKAGE_DIR}/policy" \
            "${rt_target}/policy" \
            "$rt_backup_dir" \
            "policy"
        restore_or_remove_installed_tree \
            "${PACKAGE_DIR}/workflows" \
            "${rt_target}/workflows" \
            "$rt_backup_dir" \
            "workflows"
        restore_or_remove_installed_tree \
            "${PACKAGE_DIR}/templates" \
            "${rt_target}/templates" \
            "$rt_backup_dir" \
            "templates"
    done

    if [ "$REF_CLAUDE" = true ]; then
        # Restore settings.json from backup
        restore_settings "$claude_target" "$backup_dir"

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
                        effective_backup_dir=$(create_backup_dir "$claude_target")
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
    fi

    # Restore global injected refs in selected runtime docs.
    if [ "$REF_CLAUDE" = true ]; then
        restore_policy_refs "${RUNTIME_CONF_DIR[claude]}" "$backup_dir" \
            "orchestrator:global-refs" "claude" "${RUNTIME_DOC_FILE[claude]}"
    fi
    if [ "$REF_GEMINI" = true ]; then
        restore_policy_refs "${RUNTIME_CONF_DIR[gemini]}" "$backup_dir" \
            "orchestrator:global-refs" "gemini" "${RUNTIME_DOC_FILE[gemini]}"
    fi
    if [ "$REF_CODEX" = true ]; then
        local codex_doc_dir="${RUNTIME_DOC_DIR_OVERRIDE[codex]:-${RUNTIME_CONF_DIR[codex]}}"
        restore_policy_refs "$codex_doc_dir" "$backup_dir" \
            "orchestrator:global-refs" "codex" "${RUNTIME_DOC_FILE[codex]}"
    fi
    if [ "$REF_QWEN" = true ]; then
        restore_policy_refs "${RUNTIME_CONF_DIR[qwen]}" "$backup_dir" \
            "orchestrator:global-refs" "qwen" "${RUNTIME_DOC_FILE[qwen]}"
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
    if [ -n "$NAMESPACE" ]; then
        log_info "Restoring namespace '${NAMESPACE}' where supported by runtime"
    else
        log_info "Restoring flat paths"
    fi

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

    local active_runtimes
    read -ra active_runtimes <<< "$(get_active_runtimes)"

    # Restore/remove managed shared runtime trees (surgical file-level).
    for rt in "${active_runtimes[@]}"; do
        local rt_target="${target}/${RUNTIME_PROJECT_DIR[${rt}]}"
        local rt_backup_dir=""
        [ -n "$backup_dir" ] && rt_backup_dir="${backup_dir}/shared-project-${rt}"
        restore_or_remove_installed_tree \
            "${PACKAGE_DIR}/templates" \
            "${rt_target}/templates" \
            "$rt_backup_dir" \
            "templates"
        restore_or_remove_installed_tree \
            "${PACKAGE_DIR}/policy" \
            "${rt_target}/policy" \
            "$rt_backup_dir" \
            "policy"
        restore_or_remove_installed_tree \
            "${PACKAGE_DIR}/workflows" \
            "${rt_target}/workflows" \
            "$rt_backup_dir" \
            "workflows"
    done

    # Restore per-runtime project artifacts using registry
    for rt in "${active_runtimes[@]}"; do
        restore_runtime_project "$rt" "$target" "$backup_dir"
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
    [ "$REF_CLAUDE" = true ]    && project_doc_files="${project_doc_files} ${RUNTIME_DOC_FILE[claude]}"
    [ "$REF_CODEX" = true ]     && project_doc_files="${project_doc_files} ${RUNTIME_DOC_FILE[codex]}"
    [ "$REF_GEMINI" = true ]    && project_doc_files="${project_doc_files} ${RUNTIME_DOC_FILE[gemini]}"
    [ "$REF_QWEN" = true ]      && project_doc_files="${project_doc_files} ${RUNTIME_DOC_FILE[qwen]}"
    if [ -n "$project_doc_files" ]; then
        restore_policy_refs "$target" "$backup_dir" "orchestrator:project-refs" "project-root" "$project_doc_files"
    fi

    log_success "Project restore complete"
}

# Cleanup global installation (remove installed artifacts, strip injected refs - no backup restore)
cleanup_global() {
    local claude_target="${RUNTIME_CONF_DIR[claude]}"
    log_info "Cleaning up global installation"
    if [ -n "$NAMESPACE" ]; then
        log_info "Cleaning namespace '${NAMESPACE}' where supported by runtime"
    else
        log_info "Cleaning flat paths"
    fi

    # Remove per-runtime artifacts using registry (no backup restore).
    local active_runtimes
    read -ra active_runtimes <<< "$(get_active_runtimes)"
    for rt in "${active_runtimes[@]}"; do
        restore_runtime_global "$rt" ""
    done

    # Remove shared trees under each selected runtime target dir.
    for rt in "${active_runtimes[@]}"; do
        local rt_target="${RUNTIME_CONF_DIR[${rt}]}"
        restore_or_remove_installed_tree \
            "${PACKAGE_DIR}/policy" "${rt_target}/policy" "" "policy"
        restore_or_remove_installed_tree \
            "${PACKAGE_DIR}/workflows" "${rt_target}/workflows" "" "workflows"
        restore_or_remove_installed_tree \
            "${PACKAGE_DIR}/templates" "${rt_target}/templates" "" "templates"
    done

    if [ "$REF_CLAUDE" = true ]; then
        # Unpatch settings.json by removing installer-contributed keys (no backup restore).
        unpatch_settings_json "${claude_target}/settings.json"

        # Remove mcpServers from ~/.claude.json without creating a backup.
        if command -v jq &> /dev/null && [ -f "${HOME}/.claude.json" ]; then
            if jq 'has("mcpServers")' "${HOME}/.claude.json" | grep -q true; then
                jq 'del(.mcpServers)' "${HOME}/.claude.json" > "${HOME}/.claude.json.tmp"
                mv "${HOME}/.claude.json.tmp" "${HOME}/.claude.json"
                log_success "Removed mcpServers from ~/.claude.json"
                ((++PATCHED))
            fi
        fi
    fi

    # Strip injected refs via sentinel (no backup restore).
    if [ "$REF_CLAUDE" = true ]; then
        strip_ref_block_if_present \
            "${RUNTIME_CONF_DIR[claude]}/${RUNTIME_DOC_FILE[claude]}" "orchestrator:global-refs"
    fi
    if [ "$REF_GEMINI" = true ]; then
        strip_ref_block_if_present \
            "${RUNTIME_CONF_DIR[gemini]}/${RUNTIME_DOC_FILE[gemini]}" "orchestrator:global-refs"
    fi
    if [ "$REF_CODEX" = true ]; then
        local codex_doc_dir="${RUNTIME_DOC_DIR_OVERRIDE[codex]:-${RUNTIME_CONF_DIR[codex]}}"
        strip_ref_block_if_present \
            "${codex_doc_dir}/${RUNTIME_DOC_FILE[codex]}" "orchestrator:global-refs"
    fi
    if [ "$REF_QWEN" = true ]; then
        strip_ref_block_if_present \
            "${RUNTIME_CONF_DIR[qwen]}/${RUNTIME_DOC_FILE[qwen]}" "orchestrator:global-refs"
    fi

    log_success "Global cleanup complete"
}

# Cleanup project installation (remove installed artifacts, strip injected refs - no backup restore)
cleanup_project() {
    local target="$1"

    if [ -z "$target" ]; then
        log_error "Project path required for --uninstall with --project"
        usage
        exit 1
    fi

    log_info "Cleaning up project installation from $target"
    if [ -n "$NAMESPACE" ]; then
        log_info "Cleaning namespace '${NAMESPACE}' where supported by runtime"
    else
        log_info "Cleaning flat paths"
    fi

    # Remove docs files installed from templates (no backup restore).
    restore_or_remove_installed_file \
        "${PACKAGE_DIR}/templates/knowledge.md" \
        "${target}/docs/knowledge/README.md" ""
    restore_or_remove_installed_file \
        "${PACKAGE_DIR}/templates/standards.md" \
        "${target}/docs/policy/STANDARDS.md" ""
    restore_or_remove_installed_file \
        "${PACKAGE_DIR}/templates/guidelines.md" \
        "${target}/docs/policy/GUIDELINES.md" ""

    local active_runtimes
    read -ra active_runtimes <<< "$(get_active_runtimes)"

    # Remove managed shared runtime trees (no backup restore).
    for rt in "${active_runtimes[@]}"; do
        local rt_target="${target}/${RUNTIME_PROJECT_DIR[${rt}]}"
        restore_or_remove_installed_tree \
            "${PACKAGE_DIR}/templates" "${rt_target}/templates" "" "templates"
        restore_or_remove_installed_tree \
            "${PACKAGE_DIR}/policy" "${rt_target}/policy" "" "policy"
        restore_or_remove_installed_tree \
            "${PACKAGE_DIR}/workflows" "${rt_target}/workflows" "" "workflows"
    done

    # Remove per-runtime project artifacts using registry (no backup restore).
    for rt in "${active_runtimes[@]}"; do
        restore_runtime_project "$rt" "$target" ""
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

    # Strip injected refs via sentinel (no backup restore).
    local project_doc_files=""
    [ "$REF_CLAUDE" = true ]    && project_doc_files="${project_doc_files} ${RUNTIME_DOC_FILE[claude]}"
    [ "$REF_CODEX" = true ]     && project_doc_files="${project_doc_files} ${RUNTIME_DOC_FILE[codex]}"
    [ "$REF_GEMINI" = true ]    && project_doc_files="${project_doc_files} ${RUNTIME_DOC_FILE[gemini]}"
    [ "$REF_QWEN" = true ]      && project_doc_files="${project_doc_files} ${RUNTIME_DOC_FILE[qwen]}"
    for md_file in $project_doc_files; do
        strip_ref_block_if_present "${target}/${md_file}" "orchestrator:project-refs"
    done

    log_success "Project cleanup complete"
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
    local do_cleanup=false
    local do_check_drift=false
    local project_path=""

    while [ $# -gt 0 ]; do
        case "$1" in
            --claude|--gemini|--codex|--opencode|--qwen|--trio|--all)
                if [ "$REF_TARGETS_EXPLICIT" = false ]; then
                    reset_runtime_targets
                    REF_TARGETS_EXPLICIT=true
                fi
                apply_runtime_selector "$1"
                shift
                ;;
            --namespace)
                shift
                if [ $# -eq 0 ] || [[ "$1" =~ ^-- ]]; then
                    log_error "--namespace requires a value (use --no-namespace for flat paths)"
                    usage
                    exit 1
                fi
                NAMESPACE="$1"
                if ! validate_namespace "$NAMESPACE"; then
                    exit 1
                fi
                shift
                ;;
            --no-namespace)
                NAMESPACE=""
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
            --uninstall)
                do_cleanup=true
                shift
                ;;
            --profile)
                shift
                if [ $# -eq 0 ] || [[ "$1" =~ ^-- ]]; then
                    log_error "--profile requires a value"
                    usage
                    exit 1
                fi
                PROFILE="$1"
                case "$PROFILE" in
                    skills|commands|hooks|scripts|all|auto) ;;
                    *) log_error "Invalid --profile: ${PROFILE}. Valid: skills commands hooks scripts all auto"; exit 1 ;;
                esac
                shift
                ;;
            --hooks)
                HOOKS_ENABLED=true
                shift
                ;;
            --check)
                do_check_drift=true
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

    # Apply default runtime selector if no explicit runtime flags were passed.
    if [ "$REF_TARGETS_EXPLICIT" = false ]; then
        reset_runtime_targets
        apply_runtime_selector "$DEFAULT_RUNTIME_SELECTOR"
    fi

    # --check: validate registry then exit (no writes)
    if [ "$do_check_drift" = true ]; then
        register_runtime_defaults || exit 1
        check_drift
        exit $?
    fi

    echo ""
    echo "AgentOrchestrator Installer v${VERSION}"
    echo "=================================="
    echo ""

    # Validate registry before any install operations
    register_runtime_defaults || exit 1

    if [ "$do_restore" = true ] && [ "$do_cleanup" = true ]; then
        log_error "--restore and --uninstall are mutually exclusive"
        usage
        exit 1
    fi

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
    elif [ "$do_cleanup" = true ]; then
        if [ "$do_global" = true ]; then
            cleanup_global
            echo ""
        fi
        if [ "$do_project" = true ]; then
            cleanup_project "$project_path"
            echo ""
        fi
        # If neither specified, default to global cleanup
        if [ "$do_global" = false ] && [ "$do_project" = false ]; then
            cleanup_global
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
