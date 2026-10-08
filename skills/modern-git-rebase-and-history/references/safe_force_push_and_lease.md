# Safe Force-Pushing: `--force-with-lease` & `--force-if-includes`

After rebasing a feature branch or polishing commits locally, pushing the updated commits to a remote repository requires overwriting the remote ref pointer. However, using raw `git push --force` (or `-f`) is dangerous and has caused countless incidents of lost code in collaborative engineering teams.

---

## 1. The Catastrophic Flaw of `git push --force`

Raw `git push -f` is a blind overwrite. It tells the remote Git server:
> *"Set the remote branch pointer to my current commit hash, regardless of what anyone else has done."*

### Disaster Scenario:
```text
1. Alice and Bob collaborate on branch 'feat/checkout'.
2. Bob pushes commit C3 to origin/feat/checkout.
3. Simultaneously, Alice rebases her local branch and generates C1' and C2'.
4. Alice runs: git push --force
5. RESULT: Bob's commit C3 is permanently obliterated from origin!
```
Bob's work is wiped out on the remote, causing panic, lost work, and wasted recovery time.

---

## 2. The Solution: `--force-with-lease`

`git push --force-with-lease` acts like an atomic compare-and-swap (CAS) lock on the remote ref:

```bash
git push --force-with-lease
```

### How It Operates:
1. Before overwriting the remote branch, Git checks the **current state of the remote branch**.
2. It compares it against what your local repository believes the remote branch is (your local remote-tracking ref, `origin/feat/checkout`).
3. If anyone else pushed a new commit to the branch since you last fetched, the hashes do not match.
4. **Git instantly rejects the push with an error:**
   ```text
   ! [rejected]        feat/checkout -> feat/checkout (stale info)
   error: failed to push some refs to 'github.com:org/repo.git'
   ```
Your teammate's work is protected.

---

## 3. The Edge Case & The Modern Standard: `--force-if-includes`

There is one subtle edge case with `--force-with-lease` alone:
- If your IDE (e.g., VS Code or IntelliJ) or a background process executes `git fetch` automatically, your local remote-tracking branch (`origin/feat/checkout`) gets silently updated to Bob's commit C3.
- If you subsequently run `git push --force-with-lease`, Git sees that `origin/feat/checkout` matches the remote, and pushes anyway—still clobbering Bob's work because your rebased commits did not incorporate C3!

### The Ultimate Defense: `--force-if-includes` (Git 2.30+)
When combined with `--force-with-lease`, `--force-if-includes` verifies that any commit present in the remote-tracking ref has actually been incorporated into your local commit history:

```bash
git push --force-with-lease --force-if-includes
```

This is the **absolute gold standard** for safe force-pushing in modern software engineering.

---

## 4. Recovering from a Rejected Lease Push

When your safe force-push is rejected, follow this resolution runbook:

```bash
# 1. DO NOT override with --force!
# 2. Fetch the incoming changes
git fetch origin

# 3. Inspect what commits your teammate pushed
git log HEAD..origin/feat/checkout --oneline

# 4. Rebase your work on top of the newly fetched remote commit
git rebase origin/feat/checkout

# 5. Run your project's tests to ensure compatibility
./gradlew test # or npm test

# 6. Re-push safely
git push --force-with-lease --force-if-includes
```

---

## 5. Recommended Team Aliases & Repository Rules

Add a safe push shortcut to your global configuration:
```bash
git config --global alias.push-safe "push --force-with-lease --force-if-includes"
```

### GitHub / GitLab Branch Protection Rules:
Configure these settings on all production repositories:
1. **Require pull request before merging**.
2. **Require status checks to pass before merging**.
3. **Require linear history** (enforces squash or rebase merges).
4. **Do not allow force pushes** on `main`, `release/*`, and protected branches.
