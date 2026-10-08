# Secret Hygiene & Emergency Repository Sanitization

Accidentally committing credentials, cloud provider tokens (AWS, GCP), private SSH keys, or database passwords to a Git repository is one of the most common causes of enterprise security breaches. Public bots scan GitHub commits within seconds of being pushed.

---

## 1. The Fundamental Law of Secret Leaks

> **Any secret that has touched a committed Git object must be treated as COMPROMISED immediately.**

### Step 0: Immediate Revocation & Rotation
Before attempting any Git history cleanup:
1. **Immediately rotate/revoke the leaked token** in AWS, Stripe, GitHub, or your database console.
2. Generating a new credential renders the leaked token useless, stopping active exploitation.
3. *Never rely on Git history rewriting alone to protect a leaked secret.*

---

## 2. Prevention: Defense-in-Depth

### 1. Robust `.gitignore` Hygiene
Maintain a standardized ignore list covering local environment files and certificates:
```gitignore
# Credentials & Secrets
.env
.env.*
!.env.example
*.pem
*.key
*.p12
*.jks
credentials.json
service-account*.json
token.txt

# Local IDE / OS
.DS_Store
.idea/
.vscode/
```

### 2. Pre-Commit Secret Scanning (`gitleaks`)
Integrate automated secret scanners into your development workflow:
```bash
# Run gitleaks against staged files before committing
gitleaks protect --staged --verbose
```

### 3. GitHub Push Protection
Enable **Push Protection** in your repository settings under *Security -> Code security and analysis*. GitHub will automatically block `git push` if a recognized token pattern is detected.

---

## 3. Emergency History Scrubbing: `git-filter-repo`

Simply running `git rm secret.txt` in a new commit **does NOT remove the file from history**. The secret remains fully accessible in Git's historical tree and can be viewed with `git log -p`.

### Why `git filter-branch` Is Deprecated:
Git's legacy `filter-branch` tool is officially deprecated. It is slow, alters timestamps unpredictably, and leaves dangling ref references.

### The Modern Standard: `git-filter-repo`
`git-filter-repo` is the official Python-based replacement officially endorsed by the Git project.

### Installation:
```bash
# macOS
brew install git-filter-repo

# Linux / Python
pip install git-filter-repo
```

---

## 4. Remediation Runbooks with `git-filter-repo`

> **Warning**: History rewriting alters all downstream commit hashes. Coordinate with your team before executing.

### Runbook A: Permanently Purge a Sensitive File from History
```bash
# 1. Make a fresh bare backup clone of your repository
git clone --bare git@github.com:my-org/my-project.git backup-repo.git

# 2. In your working repository, run git-filter-repo to scrub the file
git filter-repo --invert-paths --path config/production-credentials.json

# 3. Verify the file no longer exists anywhere in git history
git log --all -- config/production-credentials.json
# (Must return zero output!)
```

---

### Runbook B: Redact an API Token Across All Files in History
If an API token was pasted inline into a source file, replace the string with a redacted placeholder:

1. Create a replacement file named `expressions.txt`:
   ```text
   AKIAIOSFODNN7EXAMPLE==>REDACTED_AWS_KEY
   ghp_1234567890abcdef==>REDACTED_GITHUB_TOKEN
   ```

2. Run `git-filter-repo`:
   ```bash
   git filter-repo --replace-text expressions.txt
   ```

---

## 5. Force-Pushing the Sanitized Repository

After scrubbing:
1. Re-add your remote (git-filter-repo unregisters remotes to prevent accidental pushes):
   ```bash
   git remote add origin git@github.com:my-org/my-project.git
   ```
2. Force push the rewritten branches and tags:
   ```bash
   git push origin --force --all
   git push origin --force --tags
   ```
3. Contact GitHub/GitLab Support to invalidate any cached PR diffs or ref views on the remote server.
4. Instruct all team members to discard their local clones and re-clone the repository afresh.
