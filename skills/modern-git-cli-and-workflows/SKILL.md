---
name: modern-git-cli-and-workflows
description: >-
  Use this skill when interacting with the Git CLI, navigating branches, discarding or unstaging files,
  structuring branching strategies (Trunk-Based Development), setting up git worktrees for parallel branch work,
  configuring sparse-checkouts or partial clones for monorepos, and establishing modern global Git configuration defaults.
---

# Modern Git CLI Tooling & Workflow Engineering

This skill provides comprehensive architectural patterns, production standards, and runbooks for modern Git CLI operations, branching models, worktrees, and repository performance.

---

## Core Engineering Principles

1. **Explicit Porcelain (`switch` & `restore`)**:
   - Strictly avoid legacy `git checkout` for branch navigation and file discarding.
   - Use `git switch` for branch operations and `git restore` for index/working tree restoration.
2. **Trunk-Based Development (TBD)**:
   - Eliminate long-lived feature branches and sprawling GitFlow models.
   - Merge small, atomic PRs (< 300–400 lines) into `main` frequently (< 24–48 hours).
   - Use Feature Flags to decouple code deployment from feature release.
3. **Zero-Stash Context Switching with Worktrees**:
   - Never risk dirty stash drops or rebuild churning during urgent context switches or peer code reviews.
   - Use `git worktree add` to mount multiple branches simultaneously from a single `.git` repository.
4. **Monorepo Scaling with Partial & Sparse Checkouts**:
   - Avoid monolithic clones on massive codebases.
   - Use blobless clones (`--filter=blob:none`) and Cone Mode sparse checkouts (`git sparse-checkout set --cone`).
5. **Robust Global Production Defaults**:
   - Mandate `pull.rebase true`, `rebase.autoStash true`, `merge.conflictstyle zdiff3`, and `push.autoSetupRemote true`.
6. **Repository Attribute & Hook Standardization**:
   - Normalize line endings deterministically with `.gitattributes` (`* text=auto eol=lf`) and protect binary files.
   - Standardize team-wide hooks via version-controlled `core.hooksPath .githooks`.

---

## Detailed Topic Guides

1. **Modern CLI Porcelain & Daily Inspection**:
   - Branch switching, creation, and detached HEAD navigation with `git switch`.
   - Precise unstaging, discarding, and cross-commit retrieval with `git restore`.
   - Concise status and graph inspections (`status -sb`, modern log aliases).
   - [Read Guide](./references/modern_cli_tooling.md)

2. **Branching Strategies & Trunk-Based Development**:
   - Transitioning away from GitFlow; eliminating integration bottlenecks.
   - Standardized branch naming taxonomy (`feat/`, `fix/`, `chore/`, `refactor/`).
   - Enterprise release trains and cherry-pick stabilization workflows.
   - [Read Guide](./references/branching_and_trunk_based.md)

3. **Git Worktrees for Parallel Workflows**:
   - Zero-stash parallel development: hotfixes, peer code reviews, benchmark runs.
   - Managing, listing, removing, and pruning linked worktrees.
   - Sibling directory conventions and index safety constraints.
   - [Read Guide](./references/git_worktree_workflows.md)

4. **Monorepos & Large Repositories Performance**:
   - Blobless (`--filter=blob:none`) vs. Treeless (`--filter=tree:0`) partial clones.
   - Sparse-checkout in Cone Mode (`git sparse-checkout init --cone`).
   - Filesystem monitoring (`core.fsmonitor`), commit graphs, and background maintenance.
   - [Read Guide](./references/monorepos_sparse_checkout.md)

5. **Repository Attributes & Team Hooks Configuration**:
   - Line ending normalization (`* text=auto eol=lf`) and binary safety.
   - Linguist generated file collapsing for clean GitHub/GitLab PR reviews.
   - Team-wide hook sharing via `core.hooksPath`.
   - [Read Guide](./references/gitattributes_and_hygiene.md)

---

## Configuration Resources

- **Recommended Modern `.gitconfig`**:
  Production-tested configuration template with optimal diff algorithms, auto-setup remotes, rebase auto-stash, and high-signal aliases.
  - [View Template](./resources/gitconfig-recommended.ini)
- **Recommended Production `.gitattributes`**:
  Comprehensive template for cross-platform line ending normalization, binary protection, linguist review collapsing, and diff drivers.
  - [View Template](./resources/gitattributes-recommended.txt)

---

## Verification & Sanity Checks

Before executing operations, verify:
- Current branch state and divergence: `git status -sb`
- Attached worktrees: `git worktree list`
- Global rebase and pull configuration: `git config --get pull.rebase`
