---
description: Automatically enforces modern Git engineering standards, CLI ergonomics (switch, restore, worktree, sparse-checkout), Trunk-Based Development, Conventional & Atomic Commits, rebase discipline, safe force-push (--force-with-lease), conflict resolution (zdiff3, rerere), disaster recovery (reflog, bisect), and cryptographic signing.
trigger: model_decision
---

# Modern Git Engineering Guardrails & Skill Router

When executing Git commands, designing branching strategies, authoring commits, rebasing history, resolving conflicts, or managing repository hygiene and security, strictly adhere to Modern Git Engineering Standards and the corresponding specialized skills:

| When working on... | Consult & Activate Skill | Key Focus Areas |
| :--- | :--- | :--- |
| **CLI Ergonomics & Workflows** | `modern-git-cli-and-workflows` | `git switch`, `git restore`, Trunk-Based Development, `git worktree`, sparse checkout, `.gitattributes`, `core.hooksPath`, and global configs. |
| **Commit Craftsmanship & Staging** | `modern-git-commit-craftsmanship` | Atomic commits, Conventional Commits v1.0.0, 50/72 commit message rule, patch staging (`git add -p`), and bisectability. |
| **Rebase, History & Conflicts** | `modern-git-rebase-and-history` | Linear history, interactive rebase, autosquash (`--fixup`), safe force-push (`--force-with-lease`), `zdiff3`, and `git rerere`. |
| **Recovery, Bisect & Security** | `modern-git-recovery-and-security` | `git reflog` disaster recovery, `git bisect run`, non-destructive rollbacks, SSH/GPG signing, and secret remediation with `git-filter-repo`. |

---

## Non-Negotiable Guardrails (Absolute Invariants)

1. **Deprecate Overloaded `checkout`**:
   - Never use `git checkout` for switching branches or restoring files in new workflows, scripts, or instructions.
   - Use `git switch <branch>` (or `git switch -c <branch>`) for branch switching and creation.
   - Use `git restore <file>` (or `git restore --staged <file>`) for working tree and staging area file restoration.

2. **Absolute Ban on Unsafe Force-Push (`git push -f`)**:
   - Never run raw `git push --force` or `git push -f` on any repository or branch.
   - Always mandate `git push --force-with-lease --force-if-includes` to guarantee you never inadvertently overwrite or destroy a teammate's commits.

3. **Never Rewrite Public or Shared History**:
   - History rewriting (rebase, squash, amend) is strictly restricted to local, unpushed branches or private pull-request feature branches.
   - Never rebase, amend, or squash commits on shared, protected branches (`main`, `master`, `trunk`, `release/*`).

4. **Atomic Commits & Conventional Commits Specification**:
   - Commits must represent a single logical unit of change that compiles and passes automated tests independently (guaranteeing `git bisect` fidelity).
   - Format commit messages according to Conventional Commits (`type(scope): subject`). Subjects must use imperative mood, be lowercase, and not end with a period.

5. **Worktrees Over Branch Stash Gymnastics**:
   - Prefer `git worktree` over stashing (`git stash`) when context-switching across branches, conducting code reviews, or investigating production hotfixes. Stashes are error-prone and easily forgotten or clobbered.

6. **Patch-Level Staging Discipline**:
   - Avoid blind `git add .` or `git add -A`. Inspect diffs before committing. Use interactive patch staging (`git add -p`) to isolate unrelated changes into clean, focused commits.

7. **Zero Secrets in Git History**:
   - Never commit secrets, credentials, API keys, or private tokens to a Git repository.
   - If a secret is committed, treating it as compromised (rotation) is mandatory, followed by complete history scrubbing with `git-filter-repo` (never a simple `git rm` in a subsequent commit).

8. **Deterministic Line Ending & Attribute Normalization (`.gitattributes`)**:
   - Every repository MUST define a root `.gitattributes` declaring `* text=auto eol=lf` to prevent cross-platform (macOS/Linux/Windows) line ending churn and noisy PR diffs.
   - Mark generated code and vendor assets with `linguist-generated=true` to keep code reviews high-signal.

9. **Team Hook Automation via `core.hooksPath`**:
   - Prefer version-controlled Git hooks stored in `.githooks/` configured via `core.hooksPath .githooks` over untracked `.git/hooks/` copies or bulky external wrappers.

10. **Absolute Ban on Deprecated `git filter-branch`**:
    - Never recommend or use `git filter-branch`. Mandate `git-filter-repo` for repository history rewrites, secret sanitization, and tree restructuring.

Consult the corresponding skill for complete workflows, step-by-step guides, and configuration references.
