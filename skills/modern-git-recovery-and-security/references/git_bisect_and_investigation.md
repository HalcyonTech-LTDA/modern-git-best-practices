# Automated Regression Hunting: `git bisect` & Deep History Investigation

When a bug or performance degradation appears and the codebase has accumulated hundreds of commits since the last known good release, locating the root cause through manual testing is slow and error-prone.

`git bisect` solves this by applying **binary search** across the commit history, finding the culprit in **O(log N)** steps. For a history of 1,000 commits, `git bisect` identifies the offending commit in just 10 checks.

---

## 1. Manual Bisect Walkthrough

```text
Commit 1000 (v1.0.0 - GOOD) ──●──●──●──[Midpoint 1]──●──●──●── Commit 1 (HEAD - BAD)
                                            │
                                            ▼
                                   Test: Good or Bad?
```

### Step-by-Step Command Sequence:

```bash
# 1. Initiate bisect session
git bisect start

# 2. Mark current broken state as bad
git bisect bad

# 3. Mark the last known working release or commit as good
git bisect good v2.1.0
# Git calculates midpoint and checks out the commit:
# Bisecting: 128 revisions left to test after this (roughly 7 steps)
# [4f3a2b1...] feat(orders): cache tax computation

# 4. Run tests or inspect application
./gradlew test --tests "OrderCheckoutTest"

# 5. Report the result back to Git:
# If the test passed:
git bisect good
# If the test failed:
git bisect bad
# If the commit cannot be compiled due to an unrelated broken dependency:
git bisect skip

# 6. Git repeats the binary search until it reports:
# 4f3a2b1c8d... is the first bad commit
# Author: Alex <alex@example.com>
# Date:   Wed Oct 14 10:20:15 2026 -0400

# 7. End the session and return to your original branch:
git bisect reset
```

---

## 2. Fully Autonomous Bisect: `git bisect run`

Instead of manually compiling and testing at each midpoint, you can automate the entire search using `git bisect run`. Provide a test script or command that exits with:
- **`0`**: Commit is GOOD.
- **`1` to `127` (except 125)**: Commit is BAD.
- **`125`**: Commit cannot be tested and should be SKIPPED.

### One-Line Automated Execution:

```bash
git bisect start HEAD v2.1.0
git bisect run ./gradlew test --tests "TaxCalculationTest"
```

Git executes the binary search completely autonomously across hundreds of commits in seconds and prints the exact offending commit hash and diff.

### Handling Unbuildable Commits in Scripts:
If you need a custom test script that skips unbuildable intermediate commits:

```bash
#!/usr/bin/env bash
# bisect-runner.sh

# If compilation fails, tell bisect to skip (exit 125)
./gradlew compileJava || exit 125

# Run the specific regression test
./gradlew test --tests "TaxCalculationTest"
```
Run with: `git bisect run ./bisect-runner.sh`

---

## 3. High-Signal Investigation Tools

Beyond bisect, modern Git includes specialized search flags to pinpoint when specific logic entered or left the codebase:

### Pickaxe Search (`git log -S`)
Finds commits that added or removed an exact string (not just modified a line containing it):
```bash
git log -S "StripeGatewayException" --source --all -p
```

### Regex Diff Search (`git log -G`)
Finds commits whose diff changes match a regular expression:
```bash
git log -G "timeout\s*=\s*[0-9]+" -p src/config/
```

### Modern `git blame` Ergonomics
Standard `git blame` is easily confused by code reformats or method extractions. Use modern flags to look past noise:
```bash
# -w : Ignore whitespace changes
# -C : Detect lines moved or copied from other files in the same commit
# -C -C : Detect lines copied across any commit in the file's creation
git blame -w -C -C -L 120,160 src/services/PaymentService.java
```
