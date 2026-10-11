---
description: Automatically enforces modern Git engineering standards, CLI ergonomics (switch, restore, worktree, sparse-checkout), Trunk-Based Development, Conventional & Atomic Commits, rebase discipline, safe force-push (--force-with-lease), conflict resolution (zdiff3, rerere), disaster recovery (reflog, bisect), and cryptographic signing.
trigger: model_decision
---

# Modern Git Engineering Guardrails & Skill Router

When executing Git commands, designing branching strategies, authoring commits, rebasing history, resolving conflicts, or managing repository hygiene and security, strictly adhere to Modern Git Engineering Standards and the corresponding specialized skills:

| When working on... | Consult & Activate Skill | Key Focus Areas |
| :--- | :--- | :--- |
| **CLI Ergonomics & Workflows** | `modern-git-cli-and-workflows` | `git switch`, `git restore`, Trunk-Based Development, `git worktree`, sparse checkout, and `.gitattributes`. |
| **Commit Craftsmanship & Staging** | `modern-git-commit-craftsmanship` | Atomic commits, Conventional Commits v1.0.0, 50/72 rule, patch staging (`git add -p`), and bisectability. |
| **Rebase, History & Conflicts** | `modern-git-rebase-and-history` | Linear history, interactive rebase, autosquash, safe force-push (`--force-with-lease`), `zdiff3`, and `rerere`. |
| **Recovery, Bisect & Security** | `modern-git-recovery-and-security` | `git reflog` disaster recovery, `git bisect`, non-destructive rollbacks, commit signing, and `git-filter-repo`. |

---

## Non-Negotiable Guardrails (Absolute Invariants)

1. **Modern CLI Ergonomics**: Use `git switch` for branch operations and `git restore` for file checkout/unstaging. Prohibit overloaded `git checkout` in newly authored scripts or documentation.
2. **Linear History & Safe Branch Synchronization**: Maintain linear history via rebasing for private feature branches; never rewrite public/shared history (`main`, `release/*`). Mandate `git push --force-with-lease --force-if-includes`; raw `git push -f` is strictly forbidden.
3. **Atomic Commits & Conventional Commits**: Every commit must be an independently compilable, bisectable logical unit conforming to the Conventional Commits specification (`type(scope): subject`).
4. **Patch-Level Staging & Workspace Isolation**: Avoid blind staging (`git add .`); inspect diffs and utilize interactive patch staging (`git add -p`). Prefer `git worktree` over stashing when context-switching across branches.
5. **Zero Secrets & Modern Remediation**: Never commit credentials. If committed, rotate credentials immediately and purge history using `git-filter-repo` (prohibit deprecated `git filter-branch`).
6. **Deterministic Repository Normalization**: Maintain a root `.gitattributes` enforcing deterministic line endings (`eol=lf`) and manage team hooks via version-controlled paths (`core.hooksPath`).

Consult the corresponding skill for complete workflows, step-by-step guides, and configuration references.
