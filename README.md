# Claude Code Configuration

My personal [Claude Code](https://docs.claude.com/claude-code) configuration
(global `CLAUDE.md`, hooks, custom skills, and MCP server definitions),
kept in a repo so it stays in sync with my live `~/.claude` setup.

## What's here, and what isn't

| Included                         | Why                                                                                                                                   |
| -------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| `CLAUDE.md`                      | Global instructions, applies to every project.                                                                                        |
| `rules/`                         | Path-scoped global rules (`~/.claude/rules/`). Frontmatter `paths:` globs load a file only when matching files are in context — e.g. `terraform.md`, `taskfile.md`, `prose.md`.  |
| `hooks/load-agents-md.sh`        | The only custom hook script in use.                                                                                                   |
| `statusline-command.sh`          | Status line script.                                                                                                                   |
| `settings-snippet.json`          | The `settings.json` keys that register the hook and status line above, plus the AWS profile/env vars that drive Bedrock access.       |
| `skills/tf-source-local-testing` | Custom global skill, authored locally; no upstream to track.                                                                          |
| `skills/ADDITIONAL_SKILLS.md`    | Skills better installed via their own tooling or a marketplace plugin than vendored (e.g. `playwright-cli`, `wand-cli`, `humanizer`). |
| `agents/`                        | Custom global subagents. Empty for now: one `.md` file per agent.                                                                     |
| `commands/`                      | Custom global slash commands. Empty for now: one `.md` file per command.                                                              |
| `mcp-servers.json`               | Global MCP server definitions, secrets redacted.                                                                                      |
| `bin/claude-mode.sh`             | Toggles `~/.claude/settings.json` between AWS Bedrock and Claude subscription. Symlinked to `~/bin/claude-mode`.                      |

Some skills are managed a different way than the folder + symlink pattern
above: installed by their own tooling instead (an npm package's
`install --skills`, a marketplace plugin, the `~/.agents/skills` lockfile
installer). Vendoring a copy of those here would just drift, so
`skills/ADDITIONAL_SKILLS.md` tracks them by documenting the install
command instead. See that file for the full list and how to tell the two
patterns apart.

Deliberately left out, full stop: the rest of `settings.json` (model pin,
attribution, effort level, auto-update channel). Machine-specific, not
worth tracking anywhere.

## Setup

Requires [`task`](https://taskfile.dev). `task lint` additionally requires
[`shellcheck`](https://www.shellcheck.net/), which isn't needed for
`install`, `sync`, or `install:skills`.

```
git clone <this repo>
cd claude-configuration
task install
```

Run bare `task` (or `task --list`) to see all available tasks.

`task install` symlinks the repo's `CLAUDE.md`, `rules/`, hook script, status
line script, skill, `agents/`, `commands/`, and `bin/claude-mode.sh` into
`~/.claude` and `~/bin`, in place of whatever is there now. Anything real
that's already at those paths gets backed up (not deleted) to
`~/.claude/backups/`. Re-running is safe: it no-ops if the links already
point at the repo. Use `task clean` to remove old install backups once
you're confident you don't need them, and `task lint` to shellcheck the
scripts and validate the JSON config files.

After that, a few manual steps, because they live inside larger files this
repo shouldn't own outright, or are installed by tooling outside this repo:

1. **Settings merge**: merge the `hooks`, `statusLine`, `awsAuthRefresh`,
   and `env` keys from `settings-snippet.json` into your
   `~/.claude/settings.json`. Change `env.AWS_PROFILE` (and
   `awsAuthRefresh`) to your own AWS SSO profile.
2. **MCP servers**: add the servers from `mcp-servers.json`, e.g.
   `claude mcp add-json ref-context '<block>' -s user`. Fill in your own
   `x-ref-api-key`; it's redacted here on purpose.
3. **Additional skills**: run `task install:skills`, or see
   `skills/ADDITIONAL_SKILLS.md` for what that installs and why those
   skills aren't vendored here.

## Switching between Bedrock and subscription

`claude-mode` flips `~/.claude/settings.json` between AWS Bedrock and a
Claude subscription: the `env.CLAUDE_CODE_USE_BEDROCK` flag and the
`model` field are the only two keys that matter, so that's all it touches.

```
claude-mode           # interactive arrow-key picker (needs fzf)
claude-mode bedrock   # switch to Bedrock directly
claude-mode sub       # switch to subscription directly
claude-mode status    # show current mode
```

Start a new Claude Code session afterwards, since `env` is read at startup
and a running session won't pick up the change.

## Staying in sync

The live `~/.claude` setup is always the source of truth. This repo exists
to document and reproduce it, not the other way around.

`CLAUDE.md`, `rules/`, the hook script, the status line script, `agents/`,
`commands/`, `tf-source-local-testing`, and `bin/claude-mode.sh` are
symlinks once installed: edit them from either side and `git status` here
shows the real diff. Commit and push as normal.

`mcp-servers.json` and `settings-snippet.json` can't be symlinked: they're
extracted from files (`~/.claude.json`, `~/.claude/settings.json`) that mix
this config with per-machine state and secrets. Run `task sync` after
changing MCP servers, hooks, the status line, or the AWS env vars, to pull
the current `mcpServers`, `hooks`, `statusLine`, `awsAuthRefresh`, and `env`
blocks out of those files with `jq` and overwrite the copies here.
Header/env values in `mcp-servers.json` get replaced with `<PLACEHOLDER>`
tags automatically, but review the diff before committing; `task sync`
prints one.

Skills installed by their own tooling (`skills/ADDITIONAL_SKILLS.md`) sync by
re-running that tool's install command, not by editing files in this repo,
since committing a copy would just go stale.
