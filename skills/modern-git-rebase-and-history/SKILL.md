---
name: modern-git-rebase-and-history
description: >-
  Use this skill when managing branch integration (rebase vs merge), rewriting local commit history,
  executing interactive rebases (git rebase -i), utilizing autosquash and fixup workflows,
  safely force-pushing with lease (--force-with-lease), and resolving conflicts using modern 3-way tools and rerere.
---

# Modern Git Rebase & History Engineering

This skill provides architectural guidance, rebase workflows, and conflict resolution protocols to maintain clean, linear, and safe Git repository history.

---

## Core Engineering Principles

1. **The Golden Rule of Rebasing**:
   - Never rebase, amend, or squash commits on shared or public branches (`main`, `release/*`, or team branches).
   - Freely rebase and polish local, unpublished feature branches to maintain pristine linear history.
2. **Autosquash & Fixup Workflow**:
   - Never commit messy "review fixes" or "wip" updates to pull requests.
   - Use `git commit --fixup <hash>` and `git rebase -i --autosquash` to fold review revisions seamlessly into original commits.
3. **Safe Force-Pushing Exclusively**:
   - Strict ban on raw `git push -f` or `--force`.
   - Always mandate `git push --force-with-lease --force-if-includes` to prevent overwriting teammates' contributions.
4. **Context-Aware Conflict Resolution**:
   - Configure `merge.conflictstyle zdiff3` to inspect the common ancestor base alongside incoming changes.
   - Enable `rerere` (Reuse Recorded Resolution) to eliminate redundant conflict resolution during rebase chains.
5. **Continuous Verification During Rebase**:
   - Use `git rebase -i --exec "<test-command>"` to guarantee that every commit in a rebase chain compiles and passes tests.

---

## Detailed Topic Guides

1. **Rebase vs. Merge: Strategic Integration**:
   - Architectural comparison: topology preservation vs. linear history.
   - The Golden Rule of Rebasing and decision flowcharts.
   - PR integration strategies: Squash & Merge vs. Rebase & Merge vs. Explicit Merge.
   - [Read Guide](./references/rebase_vs_merge.md)

2. **Interactive Rebase & Autosquash Workflows**:
   - Interactive rebase commands (`pick`, `reword`, `edit`, `squash`, `fixup`, `drop`, `exec`).
   - The Autosquash workflow: automated commit folding during PR code reviews.
   - Splitting monolithic commits into granular units and testing chains with `--exec`.
   - [Read Guide](./references/interactive_rebase_and_autosquash.md)

3. **Safe Force-Pushing (`--force-with-lease`)**:
   - Why raw `git push -f` causes data loss in teams.
   - Comparing `--force-with-lease` and `--force-if-includes` (atomic compare-and-swap).
   - Step-by-step recovery runbook when a lease push is rejected.
   - [Read Guide](./references/safe_force_push_and_lease.md)

4. **Conflict Resolution & `git rerere`**:
   - Upgrading from 2-way conflicts to 3-way `zdiff3` visualization.
   - Automating repeated conflict resolutions with `git rerere` (`rr-cache`).
   - Complete conflict resolution and abort protocol.
   - [Read Guide](./references/conflict_resolution_and_rerere.md)

---

## Verification & Sanity Checks

Before force-pushing or closing a rebase:
- Verify linear log without conflict remnants: `git log --oneline -n 10`
- Confirm work tree is clean: `git status -sb`
- Execute safe push: `git push --force-with-lease --force-if-includes`
