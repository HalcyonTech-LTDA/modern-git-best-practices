# Modern Git CLI Tooling: `switch`, `restore`, and Modern Porcelain

Historically, `git checkout` was one of the most confusing commands in Git because it was heavily overloaded: it simultaneously manipulated branch/HEAD navigation (branching, switching, detaching) and working tree / staging index contents (file discarding, restoring from tree).

Git 2.23 introduced two dedicated porcelain commands that cleanly divide these responsibilities:
- **`git switch`**: Dedicated exclusively to branch and HEAD navigation.
- **`git restore`**: Dedicated exclusively to unstaging and restoring files across the index and working directory.

---

## 1. Branch Navigation with `git switch`

### Branch Switching & Creation
| Legacy Command (`checkout`) | Modern Command (`switch`) | Behavior |
| :--- | :--- | :--- |
| `git checkout feature` | `git switch feature` | Switch to existing local branch `feature` |
| `git checkout -b feature` | `git switch -c feature` | Create and switch to new branch `feature` |
| `git checkout -B feature` | `git switch -C feature` | Reset/create branch `feature` and switch to it |
| `git checkout -` | `git switch -` | Switch back to the previously active branch |
| `git checkout --detach <hash>` | `git switch --detach <hash>` | Switch to commit in detached HEAD state |
| `git checkout remote-branch` | `git switch remote-branch` | Automatically track `origin/remote-branch` |

### Key Flags & Behaviors
- **`--create <new-branch>` (`-c`)**: Creates and checks out a new branch starting from HEAD.
- **`--detach`**: Explicitly notifies Git and the developer that you intend to inspect a commit without binding to a local branch reference.
- **`--track`**: Binds the newly created local branch to an upstream remote tracking branch.
- **`--orphan <new-branch>`**: Creates an empty branch with no commit history (ideal for documentation branches or independent assets).

```bash
# Create feature branch starting from upstream main
git switch -c feat/auth-service origin/main

# Jump back to previous branch quickly
git switch -

# Inspect a release tag safely in detached mode
git switch --detach v2.4.0
```

---

## 2. File & State Restoration with `git restore`

`git restore` safely operates on modified or staged files without risking accidental branch switching.

### Working Tree vs. Staging Area (Index)
Git has three primary areas:
1. **Working Tree**: Unstaged modifications in your filesystem.
2. **Staging Index (`--staged`)**: Files prepared for the next commit.
3. **Commit History (`--source=<tree-ish>`)**: The committed snapshots.

### Comparison Matrix
| Objective | Legacy Command | Modern Command |
| :--- | :--- | :--- |
| Discard uncommitted working directory changes | `git checkout -- <file>` | `git restore <file>` |
| Discard all working directory changes in folder | `git checkout -- .` | `git restore .` |
| Unstage a file (keep local changes) | `git reset HEAD <file>` | `git restore --staged <file>` |
| Unstage all staged files | `git reset HEAD` | `git restore --staged .` |
| Discard BOTH staged and working tree changes | `git checkout HEAD <file>` | `git restore --staged --worktree <file>` |
| Restore a file as it existed in another branch/commit | `git checkout <commit> -- <file>` | `git restore --source=<commit> <file>` |
| Interactively select hunks to discard | `git checkout -p <file>` | `git restore -p <file>` |

### Practical Workflows

```bash
# Scenario A: You staged an unwanted file by mistake
git add config/database.local.json
# Fix: Unstage it while keeping your local edits intact
git restore --staged config/database.local.json

# Scenario B: You made experimental edits in a file that didn't work out
# Fix: Discard edits and match the current commit index
git restore src/services/PaymentProcessor.java

# Scenario C: Revert a specific file to how it was on the 'main' branch
git restore --source=origin/main src/shared/Constants.java

# Scenario D: Interactively discard specific debugging statements in a file
git restore -p src/controllers/UserController.java
```

---

## 3. High-Signal Inspection Tools

Modern Git offers concise porcelain and formatting flags for instant repository state inspection:

### Short Status with Tracking (`git status -sb`)
Instead of verbose multiline status, `git status -sb` provides a compact view with tracking delta:
```bash
git status -sb
## feat/user-auth...origin/feat/user-auth [ahead 1, behind 2]
 M src/index.ts
?? tests/mock.json
```
- `## [ahead X, behind Y]`: Shows divergence from upstream immediately.
- `M`: Staged/unstaged markers.
- `??`: Untracked files.

### Informative One-Line Graph
```bash
git log --graph --oneline --decorate --boundary -n 25
```
Recommended alias:
```bash
git config --global alias.lg "log --graph --pretty=format:'%C(yellow)%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
```

### Word-Level Diff Inspection
When reviewing dense code changes or prose where line diffs obscure the exact token modified:
```bash
git diff --word-diff=color
```
Shows `[-removed-]` and `{+added+}` inline.

---

## 4. Modern Production Defaults Checklist

Every modern development environment should configure these baseline Git settings:

```bash
# 1. Standardize default branch name to 'main'
git config --global init.defaultBranch main

# 2. Avoid divergent merge commit mess on pulls: always rebase local commits
git config --global pull.rebase true

# 3. Automatically stash dirty working tree when rebasing and unstash on completion
git config --global rebase.autoStash true

# 4. Automatically prune deleted remote branches when fetching
git config --global fetch.prune true
git config --global fetch.pruneTags true

# 5. Automatically create remote tracking branch on first push
git config --global push.autoSetupRemote true

# 6. Superior 3-way conflict marker visualization
git config --global merge.conflictstyle zdiff3

# 7. Enable Reuse Recorded Resolution to remember conflict fixes
git config --global rerere.enabled true
git config --global rerere.autoUpdate true

# 8. Sort tags numerically by version
git config --global tag.sort version:refname
```
