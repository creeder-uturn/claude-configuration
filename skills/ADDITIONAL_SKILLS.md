# Additional skills (not vendored here)

`skills/` in this repo only holds skills authored here, with no
upstream to track (see `tf-source-local-testing`). Some skills are better
installed with their own tooling instead of vendored as a static copy —
vendoring would drift from whatever version/reference docs the upstream
package ships.

| Skill | Install with | Source | Notes |
|---|---|---|---|
| `playwright-cli` | `npx @playwright/cli install --skills` | [`@playwright/cli`](https://github.com/microsoft/playwright-cli) (npm) | Copies the package's own bundled `skills/playwright-cli/SKILL.md` + reference docs into `~/.claude/skills/playwright-cli`. Requires the package available (global install: `npm i -g @playwright/cli`). Re-run after upgrading the package to pick up skill changes. |

## Installing a skill from a GitHub repo via `npx skills`

The [`skills`](https://www.npmjs.com/package/skills) CLI copies a skill
straight from a GitHub repo into `~/.claude/skills/<name>` (add `--global`
for the user-level directory used here):

```
npx skills add <owner>/<repo> --global
```

This writes plain files, not a symlink — same category as `playwright-cli`
above, not the `~/.agents/skills` lockfile-managed installer.

## Marketplace-installed skills

Claude Code plugins can be skill-only — no agents, hooks, MCP servers, or
LSP servers, just a skill wrapped in the plugin format for marketplace
distribution. These behave like any other global skill once enabled, so
they're documented here rather than lumped in with plugins that install
personal dev tooling. This excludes anything from the official
`claude-plugins-official` marketplace. What's listed below comes from
`rocketry-ai-skills` (`uturndata/rocketry_ai_skills`) plus one from a public
marketplace:

| Skill (plugin) | Marketplace | Install with |
|---|---|---|
| `update-template` | `rocketry-ai-skills` | `claude plugin install update-template@rocketry-ai-skills` |
| `spec-driven-dev` | `rocketry-ai-skills` | `claude plugin install spec-driven-dev@rocketry-ai-skills` |
| `wand-cli` | `rocketry-ai-skills` | `claude plugin install wand-cli@rocketry-ai-skills` |
| `pin-upgrade-workflow` | `rocketry-ai-skills` | `claude plugin install pin-upgrade-workflow@rocketry-ai-skills` |
| `de-slop` | `rocketry-ai-skills` | `claude plugin install de-slop@rocketry-ai-skills` |
| `humanizer` | `humanizer` | `claude plugin install humanizer@humanizer` |

The marketplaces need to be registered once first:

```
claude plugin marketplace add uturndata/rocketry_ai_skills
claude plugin marketplace add blader/humanizer
```

`task install:skills` runs the same `marketplace add` calls, guarded to
skip a marketplace that's already registered — re-running `add` on one
that's already there is what silently drops `autoUpdate` if you'd set it
(there's no `--auto-update` flag on `add` or `update` to restore it via the
CLI). `install:skills` re-asserts `autoUpdate: true` on `rocketry-ai-skills`
every run via `task settings:autoupdate`, so it's self-healing here even
though the CLI itself can't do it. `humanizer` doesn't get this — it was
never set to auto-update in the first place.

To set `autoUpdate` on a different marketplace, or re-run this one by
itself:

```
task settings:autoupdate
```

or by hand:

```
jq '.extraKnownMarketplaces["<marketplace>"].autoUpdate = true' ~/.claude/settings.json > /tmp/settings.json \
  && mv /tmp/settings.json ~/.claude/settings.json
```

Before adding a plugin to this table, check `claude plugin details
<plugin>@<marketplace>` — its component inventory needs to show only
Skills, nothing under Agents/Hooks/MCP servers/LSP servers. If it's not
skill-only, it belongs in the reference list below instead.

## Other plugins in use (reference only)

Some enabled plugins also ship an agent, a hook, an MCP server, or an LSP
server, so they don't behave like a plain global skill and aren't part of
the install/sync flow above. Listed here for reference, not for setup:

| Plugin | Provides |
|---|---|
| `aws-core` | Skills for AWS development, plus a hook and an MCP server |
| `code-simplifier` | An agent that simplifies and refines code |
| `gopls-lsp` | Go language server (LSP) |

Install with `claude plugin install <name>`; check `claude plugin details
<name>@<marketplace>` for the full component breakdown first.

## Adding a new entry to this file

When installing a skill this way and it's worth keeping around, add a row
above rather than committing a copy of the installed files. Only vendor a
skill directly under `skills/` if there's no upstream package, repo, or
marketplace behind it — i.e. it was authored here, not a downstream copy.
