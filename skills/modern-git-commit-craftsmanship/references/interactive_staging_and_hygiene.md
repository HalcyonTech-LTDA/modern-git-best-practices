# Interactive Staging, Commit Hygiene & Message Anatomy

Clean repositories are not created by accident; they are the result of deliberate staging discipline. Blindly running `git add .` bundles unrelated changes, temporary debugging prints, and accidental formatting drifts into dirty commits.

Modern Git provides powerful tools to dissect working tree modifications into surgical, high-signal commits.

---

## 1. Precision Staging with `git add -p`

The interactive patch mode (`-p` / `--patch`) presents changes file-by-file and hunk-by-hunk, allowing you to selectively stage only what belongs in the next logical commit.

```bash
git add -p [optional-file-or-path]
```

### Interactive Hunk Commands:
| Key | Action | Description |
| :--- | :--- | :--- |
| **`y`** | Stage hunk | Adds this specific diff hunk to the staging index |
| **`n`** | Skip hunk | Leaves this diff hunk unstaged in your working directory |
| **`q`** | Quit | Exits patch staging immediately, keeping already staged hunks |
| **`a`** | Stage all | Stages this hunk and all remaining hunks in this file |
| **`d`** | Do not stage | Skips this hunk and all remaining hunks in this file |
| **`s`** | Split hunk | Splits the current hunk into smaller, granular sub-hunks |
| **`e`** | Edit hunk | Manually edit the patch text in your editor to stage individual lines |
| **`?`** | Help | Displays help text explaining available commands |

### Splitting (`s`) and Editing (`e`) Hunks
- If a hunk contains both a feature change and an accidental debug line or formatting change, press **`s`**. Git will automatically attempt to split it into two independent hunks.
- If changes are on adjacent lines, press **`e`**. Git opens the hunk in your editor:
  - To stage an added line (`+`), leave it.
  - To exclude an added line (`+`), delete that line.
  - To exclude a deleted line (`-`), change `-` to a space (keep original).
  - Save and exit to stage your edited patch.

---

## 2. The 50/72 Commit Message Rule

A universally recognized engineering standard for commit messages is the **50/72 Rule**:

```text
Capitalized, imperative summary line under 50 chars (no period)
│<───────────────────── max 50 chars ────────────────────────>│

More detailed explanatory text, if necessary. Wrap it to 72
characters per line. Blank line separating summary from body.

Explain the problem that this commit is solving. Focus on WHY you
are making this change rather than HOW (the code diff already shows
the how). Mention any side-effects, trade-offs, or architectural
decisions made.

- Bullet points are completely acceptable
- Typically use a hyphen or asterisk for the bullet
- Wrap hanging lines at 72 characters as well

Fixes: #108
```

### Why the 50/72 Limits Exist:
- **50 characters**: Git tools (e.g., `git log --oneline`, GitHub PR UI, terminal graphs) truncate subject lines that exceed ~50-70 characters.
- **72 characters**: Git commands like `git log` indent message bodies by 4 spaces. An 80-column terminal needs margin padding to prevent awkward word-wrapping.

---

## 3. The Imperative Mood Standard

The subject line must always be written in the **imperative mood** (as a command or instruction), never past tense:

| ❌ Anti-Pattern (Past/Descriptive) | ✅ Modern Standard (Imperative) |
| :--- | :--- |
| `fixed null pointer in auth` | `fix(auth): prevent null pointer on missing token` |
| `adding stripe webhook handler` | `feat(billing): handle stripe invoice payment event` |
| `changes to database pool size` | `perf(db): increase connection pool size to 50` |
| `refactored user repository` | `refactor(users): simplify query projection logic` |

### The Litmus Test:
Complete the sentence:
> *"If applied, this commit will [your subject line here]."*
- "If applied, this commit will *fix null pointer on missing token*" ✅ (Grammatically correct).
- "If applied, this commit will *fixed null pointer on missing token*" ❌ (Grammatically incorrect).

---

## 4. Verbose Commits (`git commit -v`)

Always run commit in verbose mode:
```bash
git commit -v
```
Or configure it globally:
```bash
git config --global commit.verbose true
```

### Why `-v` Is Invaluable:
When Git opens your text editor to write the commit message, `-v` embeds the **full staged unified diff** at the bottom of the buffer (prefixed with `#` so it won't be saved in the commit message).
- You can review every single line you are about to commit while writing your summary.
- You instantly catch leftover `console.log`, `System.out.println`, unused imports, or temporary test credentials before they are permanently committed.

---

## 5. Pre-Commit Verification Workflow

Follow this strict sequence before every commit:

```bash
# 1. Inspect working tree status
git status -sb

# 2. Interactively stage logical hunks
git add -p

# 3. Double-check the staged index diff
git diff --cached --stat
git diff --cached

# 4. Commit with verbose diff review
git commit -v
```
