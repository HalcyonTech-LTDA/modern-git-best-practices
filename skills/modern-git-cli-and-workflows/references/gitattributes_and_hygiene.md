# Repository Attributes (`.gitattributes`) & Team Hook Automation

In multi-platform engineering teams (developers using macOS, Linux, and Windows), cross-environment inconsistencies frequently cause severe developer friction: phantom diffs across entire files due to carriage return line endings (`CRLF` vs. `LF`), corrupted binary assets, noisy pull requests flooded by generated lockfiles, and inconsistent local pre-commit hooks.

Modern Git provides two essential mechanisms to resolve these issues permanently:
1. **`.gitattributes`**: Version-controlled repository attribute mappings.
2. **`core.hooksPath`**: Seamless team-wide Git hook orchestration.

---

## 1. Line Ending Normalization (`* text=auto eol=lf`)

### The Flaw of `core.autocrlf`:
For years, teams relied on individual developer configuration via `git config --global core.autocrlf true/input`. This approach failed in practice:
- It relies on human discipline: one teammate with wrong local settings commits hundreds of files with `CRLF`.
- Every subsequent PR displays massive, unreadable diffs where every line is marked as deleted and re-added.

### The Solution: Root `.gitattributes`:
When committed to the repository root, `.gitattributes` overrides all local machine configurations deterministically:

```gitattributes
# Normalize all text files to LF on checkout and commit
* text=auto eol=lf

# Explicitly declare source files
*.java text eol=lf
*.ts text eol=lf
*.json text eol=lf
*.md text eol=lf

# Windows command scripts must retain CRLF
*.bat text eol=crlf
*.cmd text eol=crlf
```

### Retroactive Normalization Runbook:
If a repository has accumulated mixed line endings, normalize the entire codebase in a single atomic commit:

```bash
# 1. Commit or stash any active changes
git add .
git commit -m "chore: save working changes before normalization"

# 2. Add and commit .gitattributes at repository root
git add .gitattributes
git commit -m "chore(repo): configure .gitattributes line ending normalization"

# 3. Renormalize all files in the working directory
git add --renormalize .

# 4. Commit normalized files
git commit -m "chore(repo): normalize repository line endings to LF"
```

---

## 2. Binary File Protection

Git attempts to guess whether files are text or binary using heuristic null-byte detection. If an uncommon binary format or asset is mistaken for text, Git may attempt line ending normalization, corrupting the file payload.

Explicitly declare all binary formats:

```gitattributes
*.png binary
*.jpg binary
*.pdf binary
*.jar binary
*.keystore binary
*.woff2 binary
```

The `binary` macro is shorthand for `-diff -merge -text`. It guarantees that Git will never attempt line ending conversion, diff chunking, or merge conflict marker injection into these files.

---

## 3. GitHub & GitLab Linguist Overrides (Clean PR Reviews)

Huge files such as package lockfiles (`package-lock.json`, `pnpm-lock.yaml`, `yarn.lock`), compiled bundles, and generated code (Protobuf, OpenAPI generators) routinely clutter code reviews with thousands of lines of noise.

Linguist attributes allow you to collapse them automatically in web code reviews:

```gitattributes
# Collapse lockfiles in PR review diffs by default
package-lock.json linguist-generated=true
pnpm-lock.yaml linguist-generated=true
yarn.lock linguist-generated=true

# Collapse generated code
*.generated.java linguist-generated=true
*.pb.go linguist-generated=true
dist/** linguist-generated=true

# Exclude documentation or third-party assets from repository language percentage calculations
docs/** linguist-documentation=true
vendor/** linguist-vendored=true
```

Reviewers see a collapsed note: *"Generated file collapsed by default"* with an option to expand only if necessary.

---

## 4. Semantic Function / Class Diff Drivers

When reviewing unified diffs in terminal or web UIs, the hunk header line typically displays the enclosing function or class (e.g., `@@ -120,7 +120,12 @@ public void executeTask()`).

Assigning dedicated diff drivers improves the accuracy of hunk contextual headers:

```gitattributes
*.java diff=java
*.kt diff=kotlin
*.go diff=golang
*.py diff=python
*.rs diff=rust
*.ts diff=javascript
*.md diff=markdown
```

---

## 5. Team-Wide Hook Sharing via `core.hooksPath`

Traditionally, Git hooks lived in `.git/hooks/`, which cannot be checked into version control. Teams resorted to complex Node.js or Python packages just to install hooks.

Since Git 2.9, Git supports **`core.hooksPath`**, allowing you to store and execute hooks directly from a version-controlled directory:

### Step 1: Create a Committed Hooks Directory
```bash
mkdir -p .githooks
```

### Step 2: Add Your Hooks
Place scripts (such as `commit-msg` or `pre-commit`) inside `.githooks/` and make them executable:
```bash
chmod +x .githooks/commit-msg
chmod +x .githooks/pre-commit
```

### Step 3: Configure Git to Use the Directory
```bash
git config core.hooksPath .githooks
```

### Step 4: Automate for All Teammates
In modern build files or setup scripts, ensure the hook path is registered automatically:
- In `package.json`: `"prepare": "git config core.hooksPath .githooks"`
- In Gradle (`build.gradle.kts`):
  ```kotlin
  tasks.register<Exec>("setupGitHooks") {
      commandLine("git", "config", "core.hooksPath", ".githooks")
  }
  ```
- Or document in the project onboarding runbook.

Every developer pulling the repository now shares identical, versioned verification checks across the entire team.
