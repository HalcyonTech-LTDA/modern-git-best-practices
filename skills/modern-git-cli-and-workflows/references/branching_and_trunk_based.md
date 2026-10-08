# Branching Models: Trunk-Based Development vs. Legacy GitFlow

A team's branching model dictates their integration frequency, feedback loop speed, and deployment velocity. In modern software engineering with CI/CD and automated pipelines, **Trunk-Based Development (TBD)** is the proven industry standard for high-performing engineering teams (Accelerate / DORA metrics).

---

## 1. Why GitFlow Is an Anti-Pattern in Modern CI/CD

GitFlow was designed in 2010 when deployments were manual, software was distributed on physical media or quarterly cycles, and continuous integration was in its infancy.

```text
LEGACY GITFLOW ANTI-PATTERN:
develop ───────────────────────────────────────────────────────── (long-lived)
          \                                         /
feature    \────── commit ── commit ── commit ─────/ (weeks/months)
             \                                   /
release       \─────────────────────────────────/ (merge hell)
main    ─────────────────────────────────────────────────────────
```

### Critical Flaws of GitFlow:
1. **Deferred Integration Hell**: Long-lived feature branches diverge drastically from the mainline. Merging becomes painful and risky.
2. **Delayed Feedback**: Bugs are discovered days or weeks after code was written, multiplying context-switching costs.
3. **Impeded Refactoring**: Developers avoid codebase refactoring because changing shared abstractions causes catastrophic conflicts across pending branches.
4. **False Sense of Safety**: Staging/develop branches accumulate half-baked features that block releases.

---

## 2. Trunk-Based Development (TBD)

In Trunk-Based Development, all developers integrate small, frequent batches into a single shared branch (the "trunk" or `main`):

```text
TRUNK-BASED DEVELOPMENT:
main   ──●──────●──────●──────●──────●──────●──────●──> Deploy to Prod
          \    /        \    /        \    /
branch     ●──●          ●──●          ●──●
           (2-24h)       (2-24h)       (2-24h)
```

### Core Principles:
- **Short-Lived Branches**: Branches live less than 1 to 2 days (ideally merged within 24 hours).
- **Small Batches**: Pull requests are compact (typically < 300–400 lines of code), facilitating thorough, rapid code reviews.
- **Continuous Integration**: Every merge to `main` triggers automated test suites and produces a deployable artifact.
- **Feature Flags / Toggles**: Large or incomplete capabilities are merged into `main` behind dynamic feature flags rather than kept on long-lived branches. This decouples code deployment from feature release.
- **Branch by Abstraction**: Architecture changes are rolled out incrementally behind an abstract interface, replacing implementations over successive PRs.

---

## 3. Branch Naming Taxonomy

Standardized branch prefixes enforce organizational consistency, integrate cleanly with CI/CD automation, and convey intent immediately.

```text
<type>/<issue-id>-<kebab-case-description>
```

### Standard Prefix Taxonomy:
| Prefix | Purpose | Example |
| :--- | :--- | :--- |
| `feat/` | New user-facing or technical capability | `feat/PAY-104-stripe-webhooks` |
| `fix/` | Bug repair for an existing feature | `fix/AUTH-82-jwt-expiry-drift` |
| `refactor/` | Code restructuring without functional change | `refactor/cleanup-user-service` |
| `perf/` | Performance optimization | `perf/cache-redis-query-plan` |
| `chore/` | Tooling, dependency, or config maintenance | `chore/bump-spring-boot-3.4` |
| `docs/` | Documentation or specifications only | `docs/openapi-contract-v2` |
| `spike/` | Experimental prototype (not for direct merge) | `spike/testcontainers-localstack` |
| `release/` | Ephemeral release stabilization branch | `release/v2.5.0` |

### Rules for Clean Branch Names:
1. **Always use lowercase and hyphens**: No underscores, no spaces, no camelCase.
2. **Keep it concise**: Under 40 characters after the prefix.
3. **Include the ticket/issue identifier**: If using Jira, Linear, or GitHub Issues.
4. **Avoid developer usernames in branch names**: Git commits already record authorship; branches belong to the project.

---

## 4. Release Strategies Under Trunk-Based Development

Depending on the deployment target (SaaS vs. distributed binary), TBD supports two clean release workflows:

### Model A: Direct Continuous Deployment from Trunk (SaaS/Cloud)
- Every commit on `main` that passes CI/CD is automatically deployed to production or staging.
- Tags are generated automatically via semantic release (`git tag v1.4.2`).
- No separate release branches exist.

### Model B: Release Branches from Trunk (Enterprise / Scheduled Releases)
When an enterprise release must undergo manual certification or freeze:
1. A release branch is cut from `main`:
   ```bash
   git switch -c release/v3.1.0 origin/main
   ```
2. Only critical bug fixes are cherry-picked into the release branch:
   ```bash
   # Fix the bug on main first!
   git switch main
   git commit -m "fix(billing): correct vat calculation for de"
   
   # Cherry-pick the fix into the release branch
   git switch release/v3.1.0
   git cherry-pick -x <commit-hash>
   ```
3. Never merge `release/` back into `main`. The fix originated on `main`, preventing regressions.

---

## 5. Branch Hygiene & Lifecycle Management

- **Delete Immediately Upon Merge**: Configure GitHub/GitLab repository settings to `"Automatically delete head branches"`.
- **Prune Local Tracking Branches Regularly**:
  ```bash
  # Prune remote tracking branches that no longer exist on origin
  git fetch --prune
  
  # Delete local branches that have already been merged into main (robust format avoids * and + markers)
  git branch --format='%(refname:short)' --merged main | grep -vE '^(main|master|trunk|develop)$' | xargs -r git branch -d
  ```
- **Never Abandon Stale Branches**: If a spike or feature is canceled, delete the branch. Git reflog and remote audit trails retain history if retrieval is ever needed.
