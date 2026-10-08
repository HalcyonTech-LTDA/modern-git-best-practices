#!/usr/bin/env sh
# Lightweight, zero-dependency Git hook to enforce Conventional Commits v1.0.0.
# Compatible with POSIX sh (dash, ash, bash, zsh).
#
# Setup options:
# 1. Team-shared hooks (recommended):
#    git config core.hooksPath .githooks
#    Place this file in .githooks/commit-msg and run: chmod +x .githooks/commit-msg
# 2. Local-only hook:
#    Place this file in .git/hooks/commit-msg and run: chmod +x .git/hooks/commit-msg

set -e

COMMIT_MSG_FILE="$1"

if [ -z "$COMMIT_MSG_FILE" ] || [ ! -f "$COMMIT_MSG_FILE" ]; then
    echo "❌ commit-msg hook error: Commit message file '$COMMIT_MSG_FILE' not found." >&2
    exit 1
fi

# Extract the first non-comment, non-empty line (ignoring Git comment lines starting with #)
FIRST_LINE=$(grep -v '^[[:space:]]*#' "$COMMIT_MSG_FILE" | grep -v '^[[:space:]]*$' | head -n 1 || true)

# If message is completely empty, allow Git to handle the empty commit abort
if [ -z "$FIRST_LINE" ]; then
    exit 0
fi

# Allow automated Git commit prefixes:
# - Merges (Merge branch ..., Merge remote-tracking branch ..., Merge pull request ..., Merge tag ...)
# - Reverts (Revert "...", revert: ...)
# - Interactive rebase / autosquash helpers (fixup! ..., squash! ..., amend! ...)
if echo "$FIRST_LINE" | grep -Eq '^(Merge (branch|remote-tracking branch|pull request|tag)|Revert ".*"|fixup!|squash!|amend!)'; then
    exit 0
fi

# Conventional Commits regex:
# Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
# Scope: optional, enclosed in (), allows letters, numbers, hyphens, underscores, dots, and slashes
# Breaking change bang: optional !
# Separator: : followed by a space
# Subject: must start with lowercase letter or number
CONVENTIONAL_REGEX='^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([a-zA-Z0-9_\/.-]+\))?!?: [a-z0-9]'

# 1. Validate basic Conventional Commits structure
if ! echo "$FIRST_LINE" | grep -Eq "$CONVENTIONAL_REGEX"; then
    echo "================================================================================" >&2
    echo "❌ COMMIT MESSAGE REJECTED: Violates Conventional Commits Specification!" >&2
    echo "--------------------------------------------------------------------------------" >&2
    echo "Current summary: \"$FIRST_LINE\"" >&2
    echo "" >&2
    echo "Expected format:" >&2
    echo "  <type>(<scope>): <subject>" >&2
    echo "  <type>: <subject>" >&2
    echo "" >&2
    echo "Valid types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert" >&2
    echo "Rules:" >&2
    echo "  - Subject must start with lowercase letter or number" >&2
    echo "  - Subject must NOT end with a period" >&2
    echo "  - Subject must use imperative mood (e.g., 'add payment provider', not 'added' or 'adds')" >&2
    echo "  - First line must be 72 characters or less (under 50 recommended)" >&2
    echo "================================================================================" >&2
    exit 1
fi

# 2. Validate that the subject does NOT end with a period
if echo "$FIRST_LINE" | grep -Eq '\.[[:space:]]*$'; then
    echo "================================================================================" >&2
    echo "❌ COMMIT MESSAGE REJECTED: Subject line must NOT end with a period!" >&2
    echo "--------------------------------------------------------------------------------" >&2
    echo "Current summary: \"$FIRST_LINE\"" >&2
    echo "Action required: Remove the trailing period '.' from the end of the summary line." >&2
    echo "================================================================================" >&2
    exit 1
fi

# 3. Validate line length (max 72 chars on summary line)
LINE_LENGTH=$(printf "%s" "$FIRST_LINE" | wc -m | tr -d ' ')
if [ "$LINE_LENGTH" -gt 72 ]; then
    echo "================================================================================" >&2
    echo "❌ COMMIT MESSAGE REJECTED: Summary line is too long (${LINE_LENGTH} chars)!" >&2
    echo "--------------------------------------------------------------------------------" >&2
    echo "Current summary: \"$FIRST_LINE\"" >&2
    echo "Action required: Keep summary line to 72 characters or fewer (under 50 recommended)." >&2
    echo "Move detailed explanations to the commit message body separated by a blank line." >&2
    echo "================================================================================" >&2
    exit 1
fi

exit 0
