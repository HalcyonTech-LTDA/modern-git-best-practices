# Monorepos & Large Repositories: Partial Clones & Sparse-Checkout

As repositories grow into multi-gigabyte monorepos containing millions of files and commits, standard Git operations (`git clone`, `git status`, `git checkout`) degrade significantly. Modern Git provides native primitives to scale performance: **Partial Clones**, **Sparse-Checkout in Cone Mode**, and **Background Maintenance**.

---

## 1. Partial Clones: Blobless & Treeless Clones

Traditional Git clones download every file (blob), every directory tree, and every commit across the repository's entire history. Partial Clones download only what you need, fetching the rest lazily on demand.

### A. Blobless Clone (`--filter=blob:none`) - Recommended for Developers
Downloads all commits and tree objects, but **zero file contents (blobs)** from history. File contents for the active commit are fetched when you check out:
```bash
git clone --filter=blob:none <repo-url>
```
- **Advantages**:
  - Extremely fast clone times (often 90% bandwidth reduction).
  - Full commit history, log navigation, and branch switching work seamlessly.
  - File blobs are only downloaded on demand when opening files or checking out diffs.

### B. Treeless Clone (`--filter=tree:0`) - Recommended for CI/CD
Downloads only commit objects; trees and blobs are fetched strictly on demand:
```bash
git clone --filter=tree:0 <repo-url>
```
- **Ideal for**: Automated build agents, CI runners, and ephemeral pipelines where speed is critical and history exploration is not required.

### C. Shallow Clone (`--depth 1`) - For Ephemeral Builds
```bash
git clone --depth 1 --no-tags <repo-url>
```
- Fetches only the single latest commit. Note: Not recommended for local development because history rewriting, merging, and rebasing become restricted.

---

## 2. Sparse-Checkout: Cone Mode

Sparse-checkout allows developers working in a monorepo to populate only the subdirectories relevant to their team or service into the working tree, leaving millions of untouched files unmaterialized on disk.

### Modern Cone Mode (`--cone`)
Introduced in Git 2.25+, Cone Mode restricts sparse patterns to directory prefixes, enabling O(1) matching performance and eliminating slow regex evaluations.

### Complete Workflow:
```bash
# 1. Clone a monorepo bloblessly with sparse-checkout enabled
git clone --filter=blob:none --no-checkout <repo-url> my-monorepo
cd my-monorepo

# 2. Initialize sparse-checkout in Cone Mode
git sparse-checkout init --cone

# 3. Specify only the directories your team works on
git sparse-checkout set services/billing shared/common-libs

# 4. Check out the active branch
git switch main

# 5. Later, add another service when needed
git sparse-checkout add services/payments

# 6. Verify current sparse patterns
git sparse-checkout list

# 7. Disable sparse-checkout if you ever need the entire repository tree
git sparse-checkout disable
```

---

## 3. High-Performance Repository Settings

For repositories with over 100,000 files, enable Git's internal performance accelerators:

```bash
# 1. Enable Built-in File System Monitor (macOS / Windows / Linux)
# Drastically accelerates 'git status' by tracking OS-level file system events
git config core.fsmonitor true
git config core.untrackedCache true

# 2. Precompute commit graphs for instantaneous log traversals
git config core.commitGraph true
git commit-graph write --reachable --changed-paths

# 3. Enable automated background maintenance
git maintenance start
```

### What `git maintenance start` Does:
It registers OS-level cron/systemd/launchd tasks that periodically:
- Recomputes commit graphs.
- Cleans and repacks loose objects (`git gc`).
- Prefetches remote objects in the background without blocking your terminal.

---

## 4. Scalar (Enterprise Monorepos)

For ultra-massive codebases (e.g., Windows OS, Chromium scale), Git includes **Scalar**, an orchestration tool that automatically applies optimal flags and virtualized filesystem drivers:

```bash
# Register an existing large repository with Scalar
scalar register

# Or clone directly through Scalar
scalar clone <repo-url>
```
Scalar automatically enables blobless partial clone, sparse-checkout cone mode, fsmonitor, multi-pack indexes, and scheduled maintenance out of the box.
