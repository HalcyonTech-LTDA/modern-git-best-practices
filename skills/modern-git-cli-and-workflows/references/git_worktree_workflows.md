# Git Worktrees: Zero-Stash Parallel Branch Workflows

In modern development, switching branches often triggers expensive side-effects: invalidating build caches, reindexing IDE language servers, re-running dependency installations (`node_modules`, Gradle caches, Maven downloads), and dealing with messy `git stash` chains.

`git worktree` solves this problem permanently by allowing a single Git repository to have **multiple working trees linked to different branches active on your filesystem simultaneously**.

---

## 1. How Git Worktrees Work

Instead of having multiple clones of a repository (which duplicates disk space, objects, and remotes), all worktrees share the exact same underlying `.git` object store:

```text
/my-project/ (Primary Working Tree)
└── .git/ (Single shared object database, refs, remotes)

/my-project-hotfix/ (Linked Working Tree)
└── .git (Plain file pointing to /my-project/.git/worktrees/my-project-hotfix)

/my-project-review/ (Linked Working Tree)
└── .git (Plain file pointing to /my-project/.git/worktrees/my-project-review)
```

### Benefits:
- **Instant Context Switching**: Open the hotfix or PR review in a separate terminal window or IDE instance without altering your current feature state.
- **No Stash Churn**: Your uncommitted changes, staged files, and local build artifacts remain completely untouched.
- **Shared Object Database**: Commits created in any worktree are immediately accessible in all others without pushing or pulling.

---

## 2. Core Commands Reference

| Operation | Command | Description |
| :--- | :--- | :--- |
| **Add (Existing Branch)** | `git worktree add ../hotfix fix/urgent-bug` | Checks out existing branch `fix/urgent-bug` to `../hotfix` |
| **Add (New Branch)** | `git worktree add -b feat/checkout ../feature main` | Creates `feat/checkout` from `main` and mounts in `../feature` |
| **List Worktrees** | `git worktree list` | Displays all active worktrees, their paths, HEAD commit, and branch |
| **Remove Worktree** | `git worktree remove ../hotfix` | Deletes the worktree directory and unlinks it from `.git` |
| **Prune Stale Trees** | `git worktree prune` | Cleans up administrative records for manually deleted directories |
| **Lock Worktree** | `git worktree lock ../hotfix --reason "waiting for QA"` | Prevents automated pruning or deletion |
| **Unlock Worktree** | `git worktree unlock ../hotfix` | Re-enables pruning/removal |

---

## 3. Real-World Production Workflows

### Scenario 1: Urgent Production Hotfix Mid-Feature
You are deep in the middle of a complex refactoring on `feat/billing-v2` with dozens of uncommitted files when a P1 production incident occurs:

```bash
# 1. Do NOT stash or discard your changes!
# 2. Spawn a dedicated worktree for the hotfix branched from production main
git worktree add -b fix/p1-stripe-webhook ../project-hotfix origin/main

# 3. Navigate to the hotfix directory and resolve the issue
cd ../project-hotfix
# Edit files, run tests, commit
git commit -m "fix(billing): handle null payload in stripe webhook"
git push -u origin fix/p1-stripe-webhook

# 4. Once PR is submitted, clean up the worktree
cd ../project-billing
git worktree remove ../project-hotfix

# 5. Your original work in 'project-billing' was NEVER interrupted!
```

---

### Scenario 2: Peer PR Code Review & Local Testing
A teammate requests a review on a complex PR (`feat/user-migration`). Instead of switching branches, running build scripts, and wiping your IDE state:

```bash
# 1. Fetch remote branch
git fetch origin feat/user-migration

# 2. Open worktree in a dedicated review directory
git worktree add ../project-pr-review feat/user-migration

# 3. Launch test suite or open in a second IDE window
cd ../project-pr-review
./gradlew test # or npm test

# 4. Finish review and remove worktree
cd -
git worktree remove ../project-pr-review
```

---

### Scenario 3: Parallel Benchmark / Performance Comparison
When comparing the performance of an optimization against the baseline:

```bash
# Worktree A: Baseline
git worktree add ../baseline main

# Worktree B: Candidate
git worktree add ../candidate perf/simd-optimization

# Execute benchmarks in parallel across terminal tabs
# Tab 1:
cd ../baseline && ./run-benchmark.sh
# Tab 2:
cd ../candidate && ./run-benchmark.sh
```

---

## 4. Best Practices & Invariants

1. **Rule: One Branch per Worktree**:
   Git explicitly forbids checking out the same branch simultaneously in two different worktrees. This prevents conflicting index modifications.
2. **Directory Placement Convention**:
   Keep worktree directories as siblings of your main project directory (e.g., `../project-worktree-name`) or organize them under a `.worktrees/` directory added to your global `.gitignore`.
3. **Always Clean Up with `git worktree remove`**:
   Do not simply delete the folder with `rm -rf`. Using `git worktree remove` cleanly unregisters the worktree from Git's internal metadata. If a directory was manually removed, run `git worktree prune`.
