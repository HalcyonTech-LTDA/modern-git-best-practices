---
name: modern-git-recovery-and-security
description: >-
  Use this skill when recovering lost commits or deleted branches using git reflog,
  conducting automated binary-search debugging with git bisect, executing non-destructive production rollbacks (git revert),
  configuring SSH or GPG cryptographic commit signing, and sanitizing leaked secrets with git-filter-repo.
---

# Modern Git Recovery, Investigation & Security Engineering

This skill provides disaster recovery runbooks, automated regression hunting protocols, cryptographic signing standards, and security sanitization procedures for enterprise Git repositories.

---

## Core Engineering Principles

1. **The Inviolable Safety Net (`git reflog`)**:
   - Commits are almost never deleted immediately; unreachable objects survive for 30–90 days.
   - Use `git reflog` to resurrect hard-reset commits, deleted branches, and botched rebases.
2. **Precision Undoing & Reverts**:
   - For unpublished commits: use `git reset` (`--soft` for re-authoring, `--mixed` for re-staging).
   - For published/shared commits: mandate non-destructive `git revert` (using `-m 1` for merge commits).
3. **Automated Bug Hunting (`git bisect run`)**:
   - Never manually test hundreds of commits to find a regression.
   - Use `git bisect run <script>` to execute O(log N) binary search autonomously in seconds.
4. **Cryptographic Signing (SSH Keys Standard)**:
   - Deprecate complex GPG setups in favor of Git 2.34+ native SSH key signing (`gpg.format ssh`).
   - Mandate signed commits and tags across all team members for identity verification.
5. **Zero-Tolerance Secret Hygiene**:
   - Treat any leaked credential as compromised immediately (rotate first, scrub second).
   - Use `git-filter-repo` to permanently purge sensitive files or tokens from history (never use deprecated `filter-branch`).

---

## Detailed Topic Guides

1. **Disaster Recovery & Undo Strategies**:
   - Navigating `git reflog` syntax and entry pointers.
   - Recovering from `git reset --hard`, deleted branches (`branch -D`), and corrupted rebases (`ORIG_HEAD`).
   - Comparing `git reset` variants (`--soft`, `--mixed`, `--hard`) and non-destructive `git revert`.
   - [Read Guide](./references/reflog_and_undo_strategies.md)

2. **Automated Regression Hunting & Investigation**:
   - Manual vs. fully autonomous `git bisect run` workflows.
   - Handling unbuildable intermediate commits with exit code `125`.
   - High-signal history exploration: Pickaxe (`git log -S`), regex diffs (`git log -G`), and noise-free `git blame -w -C -C`.
   - [Read Guide](./references/git_bisect_and_investigation.md)

3. **Cryptographic Commit Signing**:
   - Migrating from cumbersome GPG keys to modern SSH key signing (`id_ed25519`).
   - GitHub and GitLab signing configuration and local verification with `allowed_signers`.
   - Enterprise hardware security key signing (FIDO2 / YubiKey `ed25519-sk`).
   - [Read Guide](./references/cryptographic_signing_gpg_ssh.md)

4. **Secret Hygiene & Repository Sanitization**:
   - The Golden Rule: immediate credential rotation in cloud providers.
   - Prevention with `.gitignore` and `gitleaks` pre-commit hooks.
   - Complete purging runbooks with `git-filter-repo` (files and inline regex patterns).
   - Post-scrubbing coordination and remote force-pushing.
   - [Read Guide](./references/secret_hygiene_and_repository_cleanup.md)

---

## Maintenance Scripts

- **Safe Branch Cleanup Script (`git-cleanup-branches.sh`)**:
  Production-tested shell script to prune remote tracking references and safely delete local branches already merged into `main` (with `--dry-run` support).
  - [View Script](./scripts/git-cleanup-branches.sh)

---

## Verification & Sanity Checks

Before executing recovery or security actions:
- Inspect recent HEAD movements: `git reflog -n 10`
- Verify signature status on latest commits: `git log --show-signature -n 3`
- Dry-run branch cleanup: `./scripts/git-cleanup-branches.sh --dry-run`
