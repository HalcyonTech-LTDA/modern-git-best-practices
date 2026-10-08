---
name: modern-git-commit-craftsmanship
description: >-
  Use this skill when preparing, structuring, and authoring Git commits,
  enforcing Conventional Commits v1.0.0, crafting atomic and bisectable commits,
  performing patch-level interactive staging (git add -p), and formulating high-signal commit messages (50/72 rule).
---

# Modern Git Commit Craftsmanship & Staging Hygiene

This skill provides architectural guidance, commit message standards, and staging runbooks to ensure clean, bisectable, and production-grade Git commit history.

---

## Core Engineering Principles

1. **Atomic Commits & Bisectability**:
   - Every commit must represent exactly one logical unit of change.
   - At every commit, the project must compile, lint cleanly, and pass all automated tests.
   - Never combine refactorings, feature implementations, and formatting into a single commit.
2. **Conventional Commits v1.0.0**:
   - Enforce structured commit types (`feat`, `fix`, `refactor`, `perf`, `test`, `build`, `ci`, `docs`, `chore`).
   - Signal breaking changes explicitly using `!` or `BREAKING CHANGE:` footer to automate Semantic Versioning.
3. **The 50/72 Rule & Imperative Mood**:
   - Summaries under 50 characters, written in the imperative present tense ("add", never "added" or "adds").
   - Detailed body wrapped at 72 characters explaining *why* the change was made and any trade-offs.
4. **Interactive Patch Staging (`git add -p`)**:
   - Ban blind `git add .` or `git add -A`.
   - Inspect and stage changes hunk-by-hunk to prevent accidental debug prints or unrelated edits.
5. **Verbose Diff Review (`git commit -v`)**:
   - Always review the full staged unified diff while writing the commit message.

---

## Detailed Topic Guides

1. **Atomic Commits & Bisectability**:
   - Why atomic commits are critical for `git bisect` and automated regression tracing.
   - Anatomy of an atomic commit sequence: splitting refactoring from features.
   - Three validation checklists before committing (Single Responsibility, Clean Build, Rollback).
   - [Read Guide](./references/atomic_commits.md)

2. **Conventional Commits Specification (v1.0.0)**:
   - Canonical commit types, scopes, and SemVer impact matrix.
   - Breaking changes indicators (`!` and footers).
   - Issue linking, trailers, and automated release tooling integration (`release-please`, `semantic-release`).
   - [Read Guide](./references/conventional_commits.md)

3. **Interactive Staging & Message Anatomy**:
   - Mastering `git add -p` (staging, skipping, splitting `s`, and editing `e` hunks).
   - The 50/72 commit message rule and imperative mood litmus test.
   - Verbose commit diff review (`git commit -v`) and pre-commit verification workflows.
   - [Read Guide](./references/interactive_staging_and_hygiene.md)

---

## Resources & Examples

- **Standardized Commit Message Template**:
  Ready-to-use template for `commit.template` enforcing the 50/72 rule and Conventional Commits.
  - [View Template](./resources/gitmessage-template.txt)
- **Zero-Dependency `commit-msg` Hook**:
  Lightweight POSIX shell script to validate Conventional Commits locally before committing.
  - [View Hook Script](./examples/commit-msg-hook.sh)

---

## Verification & Sanity Checks

Before completing any commit:
- Check staged diff: `git diff --cached --stat`
- Verify clean compilation and tests pass: `./gradlew test` (or `npm test`)
- Ensure commit message matches pattern: `git log -1 --pretty=format:"%s"`
