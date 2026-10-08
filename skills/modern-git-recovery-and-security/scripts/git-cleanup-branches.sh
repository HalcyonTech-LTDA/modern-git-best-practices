#!/usr/bin/env bash
# git-cleanup-branches.sh: Safely prunes remote-deleted tracking branches and
# deletes local branches already merged into the main/trunk target branch.
#
# Worktree-aware, offline-resilient, and protects critical branches.
#
# Usage:
#   ./git-cleanup-branches.sh [OPTIONS]
#
# Options:
#   -n, --dry-run        Simulate cleanup without deleting branches
#   -f, --force          Force-delete unmerged/squashed branches (-D instead of -d)
#   -t, --target <name>  Specify target branch (default: auto-detected main/trunk/master)
#   -h, --help           Show usage help

set -euo pipefail

DRY_RUN=false
FORCE=false
TARGET_BRANCH=""

show_help() {
    cat << 'EOF'
Usage: ./git-cleanup-branches.sh [OPTIONS]

Safely cleans up stale local branches that have already been merged into the target branch,
skipping active branches across all worktrees and protected branches.

Options:
  -n, --dry-run        Simulate cleanup without deleting branches
  -f, --force          Force-delete branches (uses 'git branch -D' instead of '-d')
  -t, --target <name>  Specify target branch to check merge status against
  -h, --help           Show this help message
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -t|--target)
            if [[ -n "${2:-}" ]]; then
                TARGET_BRANCH="$2"
                shift 2
            else
                echo "❌ Error: --target requires a branch name argument." >&2
                exit 1
            fi
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "❌ Unknown argument: $1" >&2
            show_help
            exit 1
            ;;
    esac
done

if [[ "${DRY_RUN}" == true ]]; then
    echo "🔍 Running in DRY-RUN mode. No branches will be deleted."
fi

# 1. Auto-detect default trunk branch if not explicitly specified
if [[ -z "${TARGET_BRANCH}" ]]; then
    # Priority A: Check remote origin/HEAD symbolic reference
    REMOTE_HEAD=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || true)
    if [[ -n "${REMOTE_HEAD}" ]] && (git show-ref --quiet "refs/heads/${REMOTE_HEAD}" || git show-ref --quiet "refs/remotes/origin/${REMOTE_HEAD}"); then
        TARGET_BRANCH="${REMOTE_HEAD}"
    fi

    # Priority B: Check standard primary trunk branch candidates
    if [[ -z "${TARGET_BRANCH}" ]]; then
        for candidate in main trunk master; do
            if git show-ref --quiet "refs/heads/${candidate}" || git show-ref --quiet "refs/remotes/origin/${candidate}"; then
                TARGET_BRANCH="${candidate}"
                break
            fi
        done
    fi

    # Priority C: Fallback to Git global/local defaultBranch or 'main'
    if [[ -z "${TARGET_BRANCH}" ]]; then
        TARGET_BRANCH=$(git config init.defaultBranch 2>/dev/null || echo "main")
    fi
fi

# Verify target branch exists locally or on remote
if ! git show-ref --quiet "refs/heads/${TARGET_BRANCH}" && ! git show-ref --quiet "refs/remotes/origin/${TARGET_BRANCH}"; then
    echo "❌ Error: Target branch '${TARGET_BRANCH}' does not exist in this repository." >&2
    exit 1
fi

# 2. Prune remote tracking references (gracefully handle offline / no-remote state)
if git remote 2>/dev/null | grep -q .; then
    echo "📡 Pruning remote tracking branches..."
    if ! git fetch --prune 2>/dev/null; then
        echo "⚠️  Notice: Remote fetch failed (offline or unreachable); continuing with local branches..."
    fi
else
    echo "ℹ️  No remote repository configured; skipping remote prune."
fi

# 3. Collect active branches across ALL linked worktrees
ACTIVE_WORKTREE_BRANCHES=$(git worktree list --porcelain 2>/dev/null | grep "^branch refs/heads/" | sed 's@^branch refs/heads/@@' || true)
CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "")

echo "🧹 Inspecting branches merged into '${TARGET_BRANCH}'..."

# 4. Collect local branches merged into TARGET_BRANCH
# Format %(refname:short) produces clean branch names without * or + markers
PROTECTED_PATTERN="^(${TARGET_BRANCH}|main|master|trunk|develop|development|staging|production|release/.*)$"
MERGED_CANDIDATES=$(git branch --format='%(refname:short)' --merged "${TARGET_BRANCH}" 2>/dev/null | grep -vE "${PROTECTED_PATTERN}" || true)

if [[ -z "${MERGED_CANDIDATES}" ]]; then
    echo "✅ No stale merged branches found. Working tree is clean!"
    exit 0
fi

echo "Identified candidate merged branches:"
echo "${MERGED_CANDIDATES}"
echo "--------------------------------------------------------------------------------"

DELETE_FLAG="-d"
if [[ "${FORCE}" == true ]]; then
    DELETE_FLAG="-D"
fi

DELETED_COUNT=0
SKIPPED_COUNT=0

while IFS= read -r branch; do
    if [[ -z "${branch}" ]]; then
        continue
    fi

    # Check if branch is currently checked out in the current working tree
    if [[ "${branch}" == "${CURRENT_BRANCH}" ]]; then
        echo "⚠️  Skipping '${branch}' (currently checked out in active working tree)."
        ((SKIPPED_COUNT++)) || true
        continue
    fi

    # Check if branch is checked out in any linked worktree
    if echo "${ACTIVE_WORKTREE_BRANCHES}" | grep -qx "${branch}"; then
        echo "⚠️  Skipping '${branch}' (currently checked out in a linked worktree)."
        ((SKIPPED_COUNT++)) || true
        continue
    fi

    if [[ "${DRY_RUN}" == true ]]; then
        echo "[DRY-RUN] Would delete branch: ${branch} (flag: ${DELETE_FLAG})"
        ((DELETED_COUNT++)) || true
    else
        echo "🗑️  Deleting branch: ${branch}..."
        if git branch "${DELETE_FLAG}" "${branch}"; then
            ((DELETED_COUNT++)) || true
        else
            echo "❌ Failed to delete branch '${branch}'. Use --force (-f) if it was squashed on the remote."
        fi
    fi
done <<< "${MERGED_CANDIDATES}"

echo "--------------------------------------------------------------------------------"
if [[ "${DRY_RUN}" == true ]]; then
    echo "✅ Dry run complete: ${DELETED_COUNT} branch(es) would be deleted, ${SKIPPED_COUNT} skipped."
else
    echo "✅ Cleanup complete: ${DELETED_COUNT} branch(es) deleted, ${SKIPPED_COUNT} skipped."
fi
