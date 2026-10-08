# Conflict Resolution: `zdiff3` Conflictstyle & `git rerere`

Merge and rebase conflicts are an inevitable part of software engineering. However, dealing with conflicts becomes vastly simpler when using modern conflict visualization tools and Git's automated memory engine: **`zdiff3`** and **`git rerere`** (Reuse Recorded Resolution).

---

## 1. The Power of `merge.conflictstyle zdiff3`

By default, Git provides a 2-way conflict view showing only what changed in HEAD and what changed in the incoming commit:

```text
<<<<<<< HEAD (Current change)
int timeout = 5000;
=======
int timeout = 3000;
>>>>>>> origin/main (Incoming change)
```
**The Problem**: You cannot tell what the original code was! Did someone lower it from 10,000 to 5,000, or did someone raise it from 1,000? Without context, choosing the right resolution is guesswork.

### Enter `zdiff3` (Zealous diff3 - Git 2.35+)
`zdiff3` shows a 3-way conflict that includes the common base ancestor while intelligently trimming non-conflicting lines:

```bash
git config --global merge.conflictstyle zdiff3
```

Now, the conflict marker looks like this:

```text
<<<<<<< HEAD
int timeout = 5000;
||||||| base (Common Ancestor)
int timeout = 1000;
=======
int timeout = 3000;
>>>>>>> origin/main
```
**Instant Clarity**: You immediately see that the base was `1000`. Your branch increased it to `5000` for a specific reason, while `origin/main` increased it to `3000`. You can now make an informed, correct engineering decision.

---

## 2. `git rerere`: Reuse Recorded Resolution

When rebasing a feature branch with multiple commits on top of `main`, you might resolve a conflict on commit 1, only to have Git stop and ask you to resolve the **exact same conflict** on commits 3, 5, and 8! If you ever have to abort the rebase and start over, you have to manually re-resolve every conflict again.

`git rerere` solves this by **remembering how you resolved a conflict and automatically re-applying your resolution in the future**.

```bash
# Enable rerere globally
git config --global rerere.enabled true

# Automatically stage resolved files when rerere applies a recorded fix
git config --global rerere.autoUpdate true
```

### How `rerere` Works in Action:

```bash
# 1. You start a rebase and hit a conflict:
git rebase origin/main
# Output:
# Recorded preimage for 'src/BillingService.java'
# Automatic merge failed; fix conflicts and then commit the result.

# 2. You manually resolve the conflict in BillingService.java and continue:
git add src/BillingService.java
git rebase --continue
# Output:
# Recorded postimage for 'src/BillingService.java'

# 3. Later, the exact same conflict occurs in another commit or future rebase:
# Output:
# Resolved 'src/BillingService.java' using previous resolution.
# (Git fixed it automatically without pausing!)
```

### Managing `rerere` Cache:
- Check what resolutions were applied: `git rerere diff`
- If you accidentally resolved a conflict incorrectly and want Git to forget it:
  ```bash
  git rerere forget src/BillingService.java
  ```
- Clear all stale resolutions: `git rerere clear`

---

## 3. Resolving Conflicts Safely: The Complete Protocol

When an interactive rebase or merge hits a conflict, execute this reliable protocol:

```bash
# 1. Identify which files have conflicts
git status -sb
# Unmerged paths are flagged with 'UU' (both modified)

# 2. Inspect the 3-way conflict in each file
# Use your editor or graphical merge tool:
git mergetool

# 3. Edit the file: remove conflict markers and verify logic
# 4. Compile the project and run relevant unit tests!
./gradlew test --tests "BillingServiceTest"

# 5. Stage the resolved file
git add src/BillingService.java

# 6. Resume the rebase
git rebase --continue

# Emergency Escape: If the rebase goes completely off the rails
git rebase --abort
```
*(With `git rebase --abort`, Git returns your repository to the exact pristine state it was in before you started the rebase).*
