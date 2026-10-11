# Modern Git Best Practices Plugin

A comprehensive, production-grade Antigravity plugin providing rules, design guidelines, workflow runbooks, and procedural skills for modern Git engineering: CLI ergonomics (Git 2.23+ `switch` and `restore`), Trunk-Based Development, Conventional Commits v1.0.0, Atomic Commits, interactive rebase, safe force-pushing (`--force-with-lease`), conflict resolution (`zdiff3`, `rerere`), disaster recovery (`reflog`, `bisect`), and modern cryptographic commit signing (SSH keys).

---

## Installation

### Antigravity

Install directly in Antigravity via the CLI:

```bash
agy plugin install https://github.com/HalcyonTech-LTDA/modern-git-best-practices
```

Verify that the plugin is installed and ready:

```bash
agy plugin list
```

### Claude Code

Add the Halcyon Tech marketplace once, then install the plugin:

```text
/plugin marketplace add HalcyonTech-LTDA/halcyon-plugins
/plugin install modern-git-best-practices@halcyon-plugins
```

Skills are namespaced by plugin in Claude Code (`/modern-git-best-practices:<skill-name>`). The guardrails in `rules/` load through the skills in `claude/skills/`.

---
## What's Included

#### 1. Contextual Rules & Guardrails (`rules/modern-git-engineering.md`)
Automatically enforced whenever Git commands, branching, commits, or repository operations are performed:
- **Deprecate Overloaded `checkout`**: Mandates `git switch` for branch navigation and `git restore` for index/working tree restoration.
- **Strict Ban on Blind Force-Push (`git push -f`)**: Mandates `git push --force-with-lease --force-if-includes` to guarantee zero overwritten peer commits.
- **Never Rewrite Shared/Public History**: Protects shared branches (`main`, `master`, `trunk`, `release/*`) from disruptive rebasing.
- **Atomic & Conventional Commits**: Enforces single-responsibility, bisectable commits adhering to Conventional Commits v1.0.0 (`type(scope): subject`).
- **Worktrees Over Stashes**: Encourages `git worktree` to eliminate dirty stash churn and rebuild overhead during context switches.
- **Patch-Level Staging Discipline**: Encourages hunk-level inspection (`git add -p`) over blind `git add .`.
- **Zero Secrets in Git History**: Strict rotation first, history purge with `git-filter-repo` second.
- **Line Ending & Attribute Normalization**: Mandates `.gitattributes` (`* text=auto eol=lf`) and `linguist-generated` for clean reviews.
- **Team Hook Automation**: Standardizes team-wide verification via `core.hooksPath .githooks`.
- **Ban Deprecated `filter-branch`**: Enforces modern `git-filter-repo`.

---

## 2. Specialized On-Demand Skills (`skills/`)

#### 1. `modern-git-cli-and-workflows`
- **Modern Porcelain Tooling**: Replacing `checkout` with `git switch` and `git restore`. Inspection with `git status -sb` and one-line graph logs.
- **Branching Strategies**: Transitioning away from legacy GitFlow to Trunk-Based Development (TBD). Standardized branch naming taxonomy (`feat/`, `fix/`, `chore/`, `refactor/`).
- **Git Worktrees**: Parallel branch workflows without stashing or cache invalidation (`git worktree add`, `list`, `remove`). Sibling directory conventions.
- **Monorepos & Large Repositories**: Blobless clones (`--filter=blob:none`), partial clones, Cone Mode sparse-checkout (`git sparse-checkout set --cone`), and background maintenance.
- **Repository Attributes & Hooks**: Deterministic line ending normalization (`* text=auto eol=lf`), binary safety, PR diff collapsing (`linguist-generated`), and `core.hooksPath`.
- **Configuration Templates**: Production-ready `.gitconfig` and `.gitattributes` templates.

#### 2. `modern-git-commit-craftsmanship`
- **Atomic Commits & Bisectability**: Constructing single logical change commits that compile and pass tests at every step of history.
- **Conventional Commits v1.0.0**: Comprehensive specification of commit types (`feat`, `fix`, `refactor`, `perf`, `test`, `build`, `ci`, `docs`, `style`, `chore`, `revert`), breaking change indicators (`!`, `BREAKING CHANGE:`), and semantic versioning automation.
- **Commit Message Anatomy & 50/72 Rule**: Writing imperative-mood summaries under 50 characters and informative bodies wrapped at 72 characters.
- **Interactive Staging & Hygiene**: Precision staging with `git add -p` (hunk splitting, editing), verbose commit review (`git commit -v`).
- **Tools & Templates**: Pre-configured commit message template and zero-dependency POSIX `commit-msg` verification hook supporting fixup/squash/amends, merge commits, and nested scopes.

#### 3. `modern-git-rebase-and-history`
- **Rebase vs. Merge Philosophy**: Strategic trade-offs between linear history and topology preservation. The Golden Rule of Rebasing.
- **Interactive Rebase (`git rebase -i`)**: Rewording, squashing, splitting, dropping commits, and testing chains with `--exec`.
- **Autosquash & Fixup Workflow**: Streamlining PR review feedback with `git commit --fixup` and `git rebase -i --autosquash`.
- **Safe Force-Pushing**: Deep dive into `--force-with-lease` and `--force-if-includes`. Recovery from rejected lease pushes.
- **Conflict Resolution**: Upgrading to 3-way `zdiff3` conflict visualization. Automated conflict memory with `git rerere`.

#### 4. `modern-git-recovery-and-security`
- **Disaster Recovery (`git reflog`)**: Resurrecting hard-reset commits, accidentally deleted branches, and botched rebases.
- **Precision Undoing**: Choosing between `git reset` (`--soft`, `--mixed`, `--hard`) and non-destructive `git revert` (including merge commits with `-m 1` and the Linus Torvalds re-merge trap).
- **Automated Bug Hunting (`git bisect run`)**: Autonomous binary-search debugging using test scripts to find regressions in O(log N) time.
- **Cryptographic Commit Signing**: Modern SSH key signing (`gpg.format ssh`, `id_ed25519`) replacing legacy GPG complexity. Hardware token signing with FIDO2 YubiKeys.
- **Secret Sanitization**: Immediate rotation protocol, purge runbooks using `git-filter-repo` (files and regex patterns).
- **Maintenance Script**: Automated, worktree-aware, offline-resilient safe branch cleanup script (`git-cleanup-branches.sh`).

---

## Directory Layout

```text
modern-git-best-practices/
├── plugin.json
├── README.md
├── rules/
│   └── modern-git-engineering.md
└── skills/
    ├── modern-git-cli-and-workflows/
    │   ├── SKILL.md
    │   ├── references/
    │   │   ├── modern_cli_tooling.md
    │   │   ├── branching_and_trunk_based.md
    │   │   ├── git_worktree_workflows.md
    │   │   ├── monorepos_sparse_checkout.md
    │   │   └── gitattributes_and_hygiene.md
    │   └── resources/
    │       ├── gitconfig-recommended.ini
    │       └── gitattributes-recommended.txt
    ├── modern-git-commit-craftsmanship/
    │   ├── SKILL.md
    │   ├── references/
    │   │   ├── atomic_commits.md
    │   │   ├── conventional_commits.md
    │   │   └── interactive_staging_and_hygiene.md
    │   ├── resources/
    │   │   └── gitmessage-template.txt
    │   └── examples/
    │       └── commit-msg-hook.sh
    ├── modern-git-rebase-and-history/
    │   ├── SKILL.md
    │   └── references/
    │       ├── rebase_vs_merge.md
    │       ├── interactive_rebase_and_autosquash.md
    │       ├── safe_force_push_and_lease.md
    │       └── conflict_resolution_and_rerere.md
    └── modern-git-recovery-and-security/
        ├── SKILL.md
        ├── references/
        │   ├── reflog_and_undo_strategies.md
        │   ├── git_bisect_and_investigation.md
        │   ├── cryptographic_signing_gpg_ssh.md
        │   └── secret_hygiene_and_repository_cleanup.md
        └── scripts/
            └── git-cleanup-branches.sh
```

---

## Quick Reference / Command Cheatsheet

### 1. Modern Porcelain (Replacing Checkout)
```bash
# Switch to existing branch
git switch <branch>

# Create and switch to new branch
git switch -c <new-branch>

# Discard uncommitted changes in working tree
git restore <file>

# Unstage a file without losing modifications
git restore --staged <file>

# Restore file from another branch or commit
git restore --source=<commit-or-branch> <file>
```

### 2. Worktrees (Zero-Stash Multi-Tasking)
```bash
# Spawn worktree for urgent hotfix
git worktree add -b fix/p1-bug ../repo-hotfix origin/main

# List active worktrees
git worktree list

# Clean up worktree after merge
git worktree remove ../repo-hotfix
```

### 3. Precision Staging & Commits
```bash
# Interactively stage hunks
git add -p

# Commit with full diff review in editor
git commit -v

# Target commit for automatic PR review fixup
git commit --fixup <commit-hash>
```

### 4. Interactive Rebase & History Polishing
```bash
# Rebase with automated fixup folding
git rebase -i --autosquash origin/main

# Validate every commit compiles during rebase
git rebase -i --exec "./gradlew test" origin/main

# Safe force push (mandatory)
git push --force-with-lease --force-if-includes
```

### 5. Recovery & Automated Bisect
```bash
# Inspect movement audit trail
git reflog -n 10

# Resurrect deleted branch at commit
git switch -c <branch-name> <commit-hash>

# Autonomous binary-search regression hunting
git bisect start HEAD v1.0.0
git bisect run ./test-script.sh
git bisect reset
```

---

## License

This project is licensed under the [MIT License](LICENSE) - see the LICENSE file for details.
Copyright (c) 2026 Halcyon Tech.
