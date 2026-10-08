# Conventional Commits Specification (v1.0.0)

The **Conventional Commits** specification provides a lightweight convention on top of commit messages. It creates an explicit commit history that powers automated changelog generation, deterministic Semantic Versioning (SemVer), and frictionless cross-team collaboration.

---

## 1. Structure of a Conventional Commit

```text
<type>[optional scope][!]: <description>

[optional body wrapped at 72 characters]

[optional footer(s)]
```

### Full Example:
```text
feat(auth)!: replace legacy session cookies with JWT bearer tokens

Migrate the authentication mechanism to stateless JWT tokens to support
horizontal autoscaling across Kubernetes pods. Deprecated session cookie
endpoints have been permanently removed.

BREAKING CHANGE: The '/auth/cookie-login' endpoint has been removed. All clients
must use '/auth/token' and provide the 'Authorization: Bearer <token>' header.

Fixes: #1042
Reviewed-by: @security-team
```

---

## 2. Canonical Commit Types

| Type | SemVer Impact | Description & Usage | Example |
| :--- | :--- | :--- | :--- |
| **`feat`** | **MINOR** | Introduces a new feature or user-facing capability | `feat(search): add fuzzy matching for product titles` |
| **`fix`** | **PATCH** | Patches a bug in production or library code | `fix(billing): resolve null pointer when tax rate is zero` |
| **`refactor`** | None / Patch | Restructures code without changing behavior or adding features | `refactor(orders): extract discount calculation into policy` |
| **`perf`** | **PATCH** | Code change that improves execution performance | `perf(db): add composite index on user_id and created_at` |
| **`test`** | None | Adds missing tests or corrects existing test suites | `test(auth): add integration test for token expiry renewal` |
| **`build`** | None | Changes that affect build system or external dependencies | `build(gradle): update Spring Boot to 3.4.1` |
| **`ci`** | None | Changes to CI/CD workflows and automated scripts | `ci(github): add matrix testing for JDK 21 and 25` |
| **`docs`** | None | Documentation changes only (README, OpenAPI specs) | `docs(readme): add docker compose local setup guide` |
| **`style`** | None | Whitespace, formatting, or missing semicolon adjustments | `style(core): enforce spotless google-java-format` |
| **`chore`** | None | Miscellaneous maintenance, repository housekeeping | `chore(repo): update .gitignore for local scratch files` |
| **`revert`** | Depends | Reverts a previous commit | `revert: feat(auth): rollback experimental oauth flow` |

---

## 3. Scopes & Granularity

Scopes contextualize where the change occurs. Keep scopes concise and standardized per repository:

- **Clean Architecture scopes**: by feature package: `feat(ordering):`, `fix(inventory):`, `refactor(billing):`.
- **Infrastructure scopes**: `ci(workflows):`, `build(deps):`, `docs(api):`.
- **Do not invent micro-scopes**: Use broader domain module names rather than single class or function names (e.g., use `(auth)` instead of `(auth-user-token-service-impl)`).

---

## 4. Breaking Changes & Semantic Versioning

A **Breaking Change** indicates that consumers of your API, library, or service must update their code when upgrading. Under Semantic Versioning, any breaking change mandates a **MAJOR** version bump.

### Two Ways to Signal a Breaking Change:

1. **The `!` Indicator in the Prefix**:
   Place an exclamation point right before the colon:
   ```text
   feat(api)!: remove deprecated v1 user profile endpoint
   ```
   Or with a scope:
   ```text
   refactor(database)!: drop legacy customer_id column
   ```

2. **The `BREAKING CHANGE:` Footer**:
   Include a footer starting with `BREAKING CHANGE:` followed by a space and description:
   ```text
   feat(payments): update webhook payload schema
   
   BREAKING CHANGE: The payload field 'amount_cents' has been renamed to 'amount' and is now formatted as an ISO currency object.
   ```

*(Best Practice: Use both the `!` indicator and the `BREAKING CHANGE:` footer for maximum visibility in tools and logs).*

---

## 5. Footers & Issue Tracking References

Footers follow the `token: value` or `token #value` format (inspired by Git trailers):

```text
Fixes: #482
Closes: JIRA-8921
Refs: #123, #456
Signed-off-by: Jane Doe <jane.doe@example.com>
Co-authored-by: Alex Smith <alex.smith@example.com>
```

---

## 6. Semantic Release Automation

Adhering strictly to Conventional Commits enables fully autonomous CI/CD release tools (e.g., `semantic-release`, `release-please`, `standard-version`):
- Automatically calculates the next version (`1.2.3` -> `1.3.0` for `feat`, `2.0.0` for breaking change).
- Generates beautiful, categorized `CHANGELOG.md` files grouped by features and bug fixes.
- Creates Git tags and GitHub/GitLab Releases with zero manual human intervention.
