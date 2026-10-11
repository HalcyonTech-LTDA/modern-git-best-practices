---
name: modern-git-engineering
description: "Automatically enforces modern Git engineering standards, CLI ergonomics (switch, restore, worktree, sparse-checkout), Trunk-Based Development, Conventional & Atomic Commits, rebase discipline, safe force-push (--force-with-lease), conflict resolution (zdiff3, rerere), disaster recovery (reflog, bisect), and cryptographic signing."
---

# Modern Git Engineering Guardrails & Skill Router

Entry point for this plugin's guardrails in Claude Code. Before acting, read the full standard:

`${CLAUDE_PLUGIN_ROOT}/rules/modern-git-engineering.md`

It routes each kind of task to the specialized skill of this plugin and lists the non-negotiable rules.
In Claude Code those skills are namespaced: invoke `modern-git-best-practices:<skill-name>`.

> Generated from `rules/modern-git-engineering.md`, which is also the Antigravity rule. Edit the rule, not this file.
