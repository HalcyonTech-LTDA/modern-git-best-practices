# Disaster Recovery: `git reflog` & Undo Strategies

In Git, almost nothing is truly lost as long as it was committed at least once. Even if you run an accidental `git reset --hard`, delete an unmerged branch with `git branch -D`, or botch a complex rebase, Git retains those unreachable commit objects in its local database for 30 to 90 days before running garbage collection (`git gc`).

The key to retrieving them is the **Reference Log (`git reflog`)**.

---

## 1. Navigating `git reflog`

The reflog is an audit trail that records every single time `HEAD` or a branch pointer moved (checkouts, commits, rebases, merges, resets).

```bash
git reflog
```

### Sample Reflog Output:
```text
7b3a12d (HEAD -> feat/auth) HEAD@{0}: reset: moving to HEAD~2
9c4e5f1 HEAD@{1}: commit: feat(auth): add jwt middleware
3d2b1a0 HEAD@{2}: commit: feat(auth): add token generation
1a2b3c4 (origin/main) HEAD@{3}: checkout: moving from main to feat/auth
```

### Reading the Reflog:
- `HEAD@{0}`: The current position.
- `HEAD@{1}`: Where HEAD was 1 operation ago.
- `HEAD@{2.hours.ago}`: Where HEAD was 2 hours ago.
- `7b3a12d`: The exact commit SHA associated with that state.

---

## 2. Real-World Disaster Recovery Scenarios

### Scenario A: Accidental `git reset --hard` Wiped Your Work
You ran `git reset --hard HEAD~2` by mistake, wiping out two crucial commits:

```bash
# 1. Inspect the reflog
git reflog -n 5
# You see: 9c4e5f1 HEAD@{1}: commit: feat(auth): add jwt middleware

# 2. Resurrect your commits immediately
git reset --hard 9c4e5f1
# Your working directory and history are restored exactly as they were!
```

---

### Scenario B: Accidentally Deleted an Unmerged Branch
You ran `git branch -D feat/payments` by mistake and thought your branch was gone forever:

```bash
# 1. Search the reflog for the last commit on that branch
git reflog | grep "feat/payments"
# Output: 4d2e1a8 HEAD@{4}: commit: feat(payments): stripe integration

# 2. Re-create the branch pointer directly at that commit!
git switch -c feat/payments 4d2e1a8
# Branch restored in 1 second!
```

---

### Scenario C: A Complex Rebase Went Horribly Wrong
You attempted an interactive rebase, resolved conflicts incorrectly, and ended up in a mangled state:

```bash
# Git stores the pre-rebase HEAD in ORIG_HEAD
git reset --hard ORIG_HEAD

# Or locate the pre-rebase checkout entry in reflog:
git reset --hard HEAD@{rebase-start-index}
```

---

### Scenario D: Committed to a "Detached HEAD"
You started working and made commits while in detached HEAD state:

```bash
# Simply bind the commits to a new named branch
git switch -c feat/my-new-feature
```

---

## 3. Precision Undo: `git reset` vs. `git revert`

Choosing between `reset` and `revert` depends on whether the code has been pushed to a remote shared repository:

```text
                  ┌──────────────────────────────────────────┐
                  │ Have these commits been pushed to remote?│
                  └────────────────────┬─────────────────────┘
                                       │
                      ┌────────────────┴────────────────┐
                      ▼                                 ▼
                    [YES]                             [NO]
                      │                                 │
                      ▼                                 ▼
               Use `git revert`                  Use `git reset`
            (Non-destructive rollback)          (Rewrites local history)
```

### Understanding `git reset` Modes:
| Flag | HEAD pointer | Staging Index | Working Tree | Use Case |
| :--- | :--- | :--- | :--- | :--- |
| **`--soft`** | Moved | **Kept** | **Kept** | Undo commit to re-author message or split commits |
| **`--mixed`** (default) | Moved | **Reset** | **Kept** | Undo commit & unstage files; re-stage with `git add -p` |
| **`--hard`** | Moved | **Reset** | **Discarded** | Nuclear option: wipe out everything back to target commit |

```bash
# Example: Undo the last commit, but keep all file edits staged
git reset --soft HEAD~1

# Example: Undo the last commit and unstage changes so you can re-pick files
git reset HEAD~1
```

---

## 4. Non-Destructive Production Rollbacks with `git revert`

`git revert` does not alter history. Instead, it creates an entirely **new commit that inverts the changes** introduced by the target commit.

### Reverting a Standard Commit:
```bash
# Revert commit 9c4e5f1 and generate commit "Revert 'feat(auth): add jwt middleware'"
git revert 9c4e5f1

# Revert without committing immediately (allows verifying before commit)
git revert -n 9c4e5f1
```

### Reverting a Merge Commit (`-m` flag):
A merge commit has two parents: Parent 1 (the branch being merged into, e.g., `main`) and Parent 2 (the feature branch). When reverting a merge commit, you must specify the parent to keep:

```bash
# Revert merge commit, preserving Parent 1 (mainline)
git revert -m 1 3d2b1a0
```
This safely rolls back all changes introduced by the merged feature branch.

---

## 5. The Re-Merge Trap: Safely Re-Merging a Reverted Branch

A common, dangerous pitfall occurs after reverting a merge commit (first documented by Linus Torvalds):

### The Scenario:
1. Feature branch `feat/billing` is merged into `main` via merge commit `M`.
2. A production bug is found; `M` is rolled back via `git revert -m 1 M`, producing revert commit `R`.
3. The developer fixes the bug on `feat/billing` and tries to merge `feat/billing` into `main` again.

### The Trap:
Git considers all original commits from `feat/billing` already merged into `main`. Merging `feat/billing` again will **ONLY bring in new commits**, leaving all original code from the feature branch missing in production!

### The Solution: Revert the Revert:
To properly bring back the original feature code along with subsequent fixes:

```bash
# 1. Revert the revert commit (R) on main or integration branch
git revert <hash-of-revert-commit-R>

# 2. Now merge (or rebase and merge) the updated feature branch
git merge feat/billing
```
Reverting the revert reinverts the rollback, restoring the original feature code so subsequent improvements apply seamlessly without missing dependencies.
