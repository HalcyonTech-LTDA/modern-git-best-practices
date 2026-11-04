<div align="center">

<a href="https://www.halcyontech.com.br/" target="_blank" rel="noopener noreferrer">
  <img src="assets/halcyon-horizontal-cor.svg" alt="Halcyon Tech" height="60">
</a>

# Modern Git Best Practices Plugin
### Modern Git CLI Ergonomics, Trunk-Based Development & Commit Craftsmanship

[![Antigravity Plugin](https://img.shields.io/badge/Antigravity-Plugin%20v1.0.0-4F46E5.svg)](https://antigravity.google)
[![License: MIT](https://img.shields.io/badge/License-MIT-10B981.svg)](./LICENSE)
[![Website](https://img.shields.io/badge/Website-halcyontech.com.br-008080.svg)](https://www.halcyontech.com.br/)
[![Organization](https://img.shields.io/badge/Organization-HalcyonTech--LTDA-black.svg)](https://github.com/HalcyonTech-LTDA)

<p align="center">
  <b>Modern Git engineering best practices, CLI ergonomics (switch, restore, worktree, sparse-checkout), Trunk-Based Development, Conventional & Atomic Commits, interactive rebase, safe force-push (--force-with-lease), conflict resolution (zdiff3, rerere), disaster recovery (reflog, bisect), and SSH/GPG cryptographic signing.</b>
</p>

</div>

---

## Installation & Verification

### Antigravity CLI (`agy`)

Install directly into your Antigravity environment via the CLI:

```bash
agy plugin install https://github.com/HalcyonTech-LTDA/modern-git-best-practices
```

Verify that the plugin is active and adheres to the strict official schema:

```bash
agy plugin list
agy plugin validate --strict ./modern-git-best-practices
```

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

---

## What's Included (Component Catalog)

### Contextual Rules (`rules/`)
Automatically loaded to govern and protect project contexts:
- **[`modern-git-engineering.md`](rules/modern-git-engineering.md)**: Automatically enforces modern Git engineering standards, CLI ergonomics (switch, restore, worktree, sparse-checkout), Trunk-Based Development, Conventional & Atomic Commits, rebase discipline, safe force-push (--force-with-lease), conflict resolution (zdiff3, rerere), disaster recovery (reflog, bisect), and cryptographic signing.

### Procedural Skills (`skills/`)
On-demand actionable workflows and runbooks:
- **[`/modern-git-cli-and-workflows`](skills/modern-git-cli-and-workflows/SKILL.md)**: Use this skill when interacting with the Git CLI, navigating branches, discarding or unstaging files, structuring branching strategies (Trunk-Based Development), setting up git worktrees for parallel branch work, configuring sparse-checkouts or partial clones for monorepos, and establishing modern global Git configuration defaults.
- **[`/modern-git-commit-craftsmanship`](skills/modern-git-commit-craftsmanship/SKILL.md)**: Use this skill when preparing, structuring, and authoring Git commits, enforcing Conventional Commits v1.0.0, crafting atomic and bisectable commits, performing patch-level interactive staging (git add -p), and formulating high-signal commit messages (50/72 rule).
- **[`/modern-git-rebase-and-history`](skills/modern-git-rebase-and-history/SKILL.md)**: Use this skill when managing branch integration (rebase vs merge), rewriting local commit history, executing interactive rebases (git rebase -i), utilizing autosquash and fixup workflows, safely force-pushing with lease (--force-with-lease), and resolving conflicts using modern 3-way tools and rerere.
- **[`/modern-git-recovery-and-security`](skills/modern-git-recovery-and-security/SKILL.md)**: Use this skill when recovering lost commits or deleted branches using git reflog, conducting automated binary-search debugging with git bisect, executing non-destructive production rollbacks (git revert), configuring SSH or GPG cryptographic commit signing, and sanitizing leaked secrets with git-filter-repo.

---

## Directory Hierarchy

```text
modern-git-best-practices/
├── plugin.json              # Official Antigravity manifest (schema v1)
├── LICENSE                  # MIT License (Copyright 2026 HalcyonTech LTDA)
├── .gitignore               # System ignores & installed_version.json exclusions
├── .gitattributes           # Deterministic line endings (* text=auto eol=lf)
├── README.md                # Golden Standard documentation & runbook
├── assets/
│   ├── logo.svg             # Antigravity marketplace square icon
│   └── halcyon-horizontal-cor.svg # Official Halcyon Tech brand logo (white background)             # Official Halcyon Tech corporate vector symbol
├── rules/                   # Contextual rules discovered automatically
│   └── modern-git-engineering.md
├── skills/                  # Actionable procedural skills (Progressive Disclosure)
│   └── modern-git-cli-and-workflows/
│       └── SKILL.md
│   └── modern-git-commit-craftsmanship/
│       └── SKILL.md
│   └── modern-git-rebase-and-history/
│       └── SKILL.md
│   └── modern-git-recovery-and-security/
│       └── SKILL.md
```

---

## 💡 Prompt Recipes & Use Cases

```markdown
- "Guide an interactive rebase and clean up commit history with Conventional Commits"
- "Configure modern Git workflows, worktrees, and safe force-push protections"
- "Diagnose Git merge conflicts or recover lost commits using git reflog"
```

---

## 📄 License & Corporate Governance

Distributed under the **MIT License**. Copyright (c) 2026 **HalcyonTech LTDA**.  
Engineered with precision and excellence by [Halcyon Tech](https://www.halcyontech.com.br/) &mdash; [GitHub Organization](https://github.com/HalcyonTech-LTDA).
