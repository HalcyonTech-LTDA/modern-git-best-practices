# Interactive Rebase & Autosquash: History Polishing Workflows

Interactive rebasing (`git rebase -i`) is the definitive tool for polishing a branch before submitting it for code review. It allows you to clean up exploratory work, reword unclear messages, split monolithic changes, and squash temporary checkpoint commits.

Combined with Git's **Autosquash (`--fixup`)** workflow, it turns PR revisions and code review iterations into a frictionless, automated process.

---

## 1. The Interactive Rebase Todo List

Start an interactive rebase against your base branch:
```bash
git rebase -i origin/main
# Or across the last N commits on the current branch:
git rebase -i HEAD~4
```

Git opens your editor with a list of commits in **chronological order (oldest at top, newest at bottom)**:

```text
pick 1a2b3c4 feat(auth): add jwt token generation
pick 4d5e6f7 fix typo in jwt secret config
pick 8a9b0c1 feat(auth): validate token signature in middleware
pick 2d3e4f5 test(auth): add unit tests for jwt validation

# Commands:
# p, pick <commit> = use commit
# r, reword <commit> = use commit, but edit the commit message
# e, edit <commit> = use commit, but stop for amending
# s, squash <commit> = meld into previous commit, combining messages
# f, fixup [-C | -c] <commit> = meld into previous commit, discard message
# d, drop <commit> = remove commit
# x, exec <command> = run command (the rest of the line) using shell
# b, break = stop here (continue rebase later with 'git rebase --continue')
```

### Essential Operations:
- **Squashing Fixes**: Change `pick` to `f` (fixup) on commit `4d5e6f7` to seamlessly meld the typo fix into `1a2b3c4` without polluting the commit log.
- **Rewording**: Change `pick` to `r` (reword) to update a commit message to adhere to Conventional Commits.
- **Reordering**: Move lines up or down to change the order in which commits are applied.
- **Dropping**: Delete the line or change `pick` to `d` to drop unwanted experimental code.

---

## 2. The Autosquash & Fixup Workflow (PR Review Iteration)

When a reviewer asks for revisions on an open PR, inexperienced developers often create ugly commits like `"fix review comments"` or `"try again"`. The Autosquash workflow solves this cleanly:

### Step-by-Step Workflow:

1. **Identify the Commit to Fix**:
   Find the hash of the commit that needs modification:
   ```bash
   git log --oneline -n 5
   # 7b1a2c3 feat(billing): implement stripe payment processor
   ```

2. **Make the Code Changes**:
   Edit the file to address the review comment.

3. **Commit with `--fixup`**:
   Tell Git to target that specific commit:
   ```bash
   git commit --fixup 7b1a2c3
   # Creates commit with message: "fixup! feat(billing): implement stripe payment processor"
   ```

4. **Rebase with `--autosquash`**:
   ```bash
   git rebase -i --autosquash origin/main
   ```
   **Git automatically rearranges the todo list!** It places your fixup commit directly underneath `7b1a2c3` and changes its command to `fixup` automatically.
   
5. Simply save and exit the editor. Git cleanly folds the revision directly into the original commit!

*(Enable globally so you don't even have to pass the flag: `git config --global rebase.autoSquash true`)*

---

## 3. Splitting a Monolithic Commit

If you have a large commit that bundles two distinct concerns, split it cleanly:

1. Start interactive rebase: `git rebase -i origin/main`
2. Mark the target commit as **`edit`** (or `e`), then save and exit.
3. Git pauses immediately after applying that commit:
   ```bash
   # Reset HEAD to the parent commit, keeping all changes unstaged in working directory
   git reset HEAD~1
   
   # Interactively stage the first logical change
   git add -p
   git commit -m "feat(domain): add customer balance calculation"
   
   # Stage the remaining changes
   git add .
   git commit -m "feat(api): expose customer balance endpoint"
   
   # Resume rebase
   git rebase --continue
   ```

---

## 4. Automated Testing across Rebase Chains (`exec`)

To guarantee that **every single commit** in your branch compiles and passes tests (bisectability guarantee), use the `--exec` flag:

```bash
git rebase -i --exec "./gradlew test" origin/main
# Or for Node.js:
git rebase -i --exec "npm test" origin/main
```

Git will automatically pause the rebase at any commit that breaks tests or compilation, allowing you to fix it on the spot before proceeding!
