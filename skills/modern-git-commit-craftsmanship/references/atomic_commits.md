# Atomic Commits & Bisectability: The Foundation of Clean History

An **atomic commit** is a self-contained, indivisible unit of work that implements exactly one logical change. At every single commit in your repository's history, the codebase must compile cleanly, pass all linting rules, and succeed across the entire automated test suite.

---

## 1. Why Atomic Commits Matter

### 1. Guaranteed Bisectability (`git bisect`)
When a regression is discovered weeks or months later, `git bisect` performs a binary search across history to locate the responsible commit. If intermediate commits fail to compile or break unrelated tests, automated bisect tools abort or produce false positives, turning bug isolation into a grueling manual ordeal.

### 2. Surgical Production Reverts (`git revert`)
If a newly deployed feature causes an incident in production, an atomic commit can be cleanly rolled back with `git revert <commit-hash>` in seconds without collateral damage. If the commit bundled unrelated bug fixes or refactorings, reverting it pulls out good code alongside the bad.

### 3. High-Signal Code Reviews
Reviewers can review a complex 500-line PR commit-by-commit, following the author's logical progression step-by-step, rather than drowning in an incomprehensible monolithic diff.

---

## 2. The Anatomy of an Atomic Commit Sequence

When building a complex feature or undertaking a significant refactoring, split the work into logical, compiling phases:

```text
Commit 1: refactor(billing): extract payment calculation strategy
          ↳ Pure refactor. Zero behavioral change. Tests pass.

Commit 2: feat(billing): implement paypal payments provider
          ↳ New isolated domain logic + comprehensive unit tests. Tests pass.

Commit 3: feat(billing): wire paypal provider into checkout controller
          ↳ Integration of the new capability + end-to-end API tests. Tests pass.

Commit 4: chore(billing): remove deprecated legacy v1 checkout stubs
          ↳ Clean dead code removal. Tests pass.
```

Each commit tells a chapter of the story, builds successfully, and could theoretically be shipped independently.

---

## 3. Common Anti-Patterns to Eliminate

### Anti-Pattern 1: The "Kitchen Sink" Commit
```text
❌ BAD:
commit 7f3a12d
feat: add user profile page, fix db connection pool bug, reformat css
```
- **Consequence**: If the database connection pool fix introduces an edge-case deadlock, reverting it also destroys the user profile page.

### Anti-Pattern 2: The Broken Intermediate Commit
```text
❌ BAD:
Commit A: refactor: change calculateTax signature to require Currency
          (Code does not compile! Callers not updated yet!)
Commit B: fix: update callers of calculateTax
          (Code compiles again)
```
- **Consequence**: Breaks `git bisect`. If a binary search lands on Commit A, CI and tests fail regardless of whether Commit A is related to the bug being hunted.

### Anti-Pattern 3: The "Checkpoint / WIP" Litter
```text
❌ BAD:
commit 1: wip
commit 2: fix typo
commit 3: still broken
commit 4: worked!
```
- **Consequence**: Pollutes history with noise, renders commit logs useless, and wastes review bandwidth. These should always be squashed locally before opening a pull request.

---

## 4. Mental Checklists Before Finalizing a Commit

Before finalizing any commit, evaluate these three validation criteria:

1. **The Single Responsibility Test**:
   - Can you summarize what this commit does in one concise sentence without using the word "and"? If you need "and", split the commit.
2. **The Clean Build Test**:
   - If you check out this exact commit in isolation (`git switch --detach <hash>`), does `./gradlew test` (or `npm test`) pass completely?
3. **The Rollback Test**:
   - If this specific commit is reverted tomorrow in production, does the rest of the application remain completely coherent and operational?
