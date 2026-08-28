## Core Guidelines

### Don't make irreversible changes without explicit direction

This is the single most important rule. Never break this.

- All changes must be reversible. This applies to all work.
- Only use read only `git` commands unless explicitly prompted.
- Only use `tf init`, `tf fmt`, and `tf validate` unless explicitly prompted.

### Communication preferences:

In word choice and language:

- Use Simplified Technical English where possible
- Respond professionally but terse
- Drop filler (just/really/basically/actually/simply) in responses
- Drop pleasantries (sure/certainly/of course/happy to) in responses
- Use short synonyms (big not extensive, fix not "implement a solution for").
- Keep technical terms and code blocks the same without modification

### When working with code:

- **Flag existing issues**: When reading code before modifying it, flag existing bugs or tech debt.

- **Plan before non-trivial changes** — For 3+ step or architectural work, write the plan first, execute second, replan if reality diverges. Skip for mechanical one-liners.

- **When possible, prove work is complete** - Run tests, formatters, linters (if relevant). If verification isn't possible, say so explicitly.

- Don't touch what you weren't asked to touch: No drive-by refactors, no unsolicited formatting changes, no adding types/comments to untouched code — unless explicitly asked for a thorough review.

- **Prefer elegance to hacks** — On non-trivial changes, pause and ask "is there a cleaner way?" before shipping. If a fix feels hacky, do it right. Skip for obvious one-liners.
  - Simplicity First: Make every change as simple as possible. Minimal impact.
  - Find root causes. No temporary fixes. Senior developer standards.
  - Minimal Impact: Changes should only touch what's necessary. Avoid introducing bugs.
  - When uncertain between two approaches, pick the simpler one and move forward rather than asking.
  - Skip for simple, obvious fixes — don't over-engineer.
  - **Signs a fix is hacky** (if any apply, look for an elegant alternative):
    - Special-case branches for the one caller that's broken
    - A comment apologizing for the approach ("hack:", "temporary", "TODO: revisit")
    - A `try`/`except` (or equivalent) swallowing a symptom rather than fixing the cause
    - A new flag or config knob added just to route around the problem
    - Duplicated logic with slight differences between copies

### When working with Git:

- Only use read only `git` commands unless explicitly prompted.

- **When asked to git commit or write a commit message**, use conventional commits. Don't be unneccessarily verbose. If the change is non-trivial, include the "why" in the description if it's known. Only describe what is in the commit itself — no references to source material, files replaced, or conversation context. Before writing a line, ask: "does this describe a file or change in this commit?" If not, cut it.

- **Don't create a git tag unless specifically asked.** - If you are going to create a git tag, make sure that there's not a CI workflow already responsible for it.

### pre-commit:

- **Use `prek`, not `pre-commit`** - `prek` is a drop-in replacement (same `.pre-commit-config.yaml`, same subcommands: `prek run`, `prek run --all-files`). Fall back to `pre-commit` only if `prek` is not installed.

### Terraform/OpenTofu:

Full conventions (commands & permissions, code style, verification) load from
`~/.claude/rules/terraform.md` when a `.tf`/`.tofu` file is in context. Always-on
essentials:

- **Always use tf** - Use the `tf` command, not `tofu` or `terraform`. If it fails for lack of a `.opentofu-version` or `.terraform-version` file, tell the user and pause.

- **Never truncate `tf` output** - Redirect full plan/apply output to a file in the session scratchpad directory (e.g. `<scratchpad>/plan.txt`); never pipe through `head`/`tail` or any length filter — truncation hides deletions and replacement cascades.

- TF and AWS commands must set an `AWS_PROFILE` (or `--profile`). If unsure which profile, ask the user and pause.

### Taskfile conventions:

Authoring conventions (`default` task, `desc`, shared vocabulary, `deps:`
composition, `clean` semantics) load from `~/.claude/rules/taskfile.md` when a
Taskfile is in context.

- **Prefer Taskfile.yml for repeated tasks** - Examples include `build`, `clean`, `test`. If a project has a `Taskfile.yml`, use it.

### When calling Bash:

- Prefer creating scripts in the session scratchpad directory (given in the environment block; e.g. `/private/tmp/claude-<uid>/<project>/<session>/scratchpad`) for multiline shell commands instead of running them directly. Fall back to `/tmp/claude/<project>` only if no scratchpad directory is provided.
- **I have GNU sed installed, not BSD sed**, make sure all sed commands follow that syntax
- **Be aware of the current working directory and avoid `cd` whenever possible**: the Bash tool persists `cwd` between commands within a session — it is almost never necessary to `cd` at all. Before issuing a Bash call, check the environment block for the current working directory and the project's primary/additional working directories; if the command's target is already reachable from there, just use a relative or absolute path. Reach for `cd` only when you genuinely need to switch contexts (e.g., running `npm` in a sub-package that resolves config from its own directory), and prefer absolute paths in command arguments over `cd` to that directory first.

### Tool Usage

**Prefer native tools over Bash for file operations**

- Native tools are faster, safer, and do not trigger permission prompts:
- **Read files**: use the `Read` tool, not `cat`/`head`/`tail`/`less`
- **Edit files**: use `Edit` (or `Write` for new files), not `sed`/`awk`/heredoc-to-file
- **Find files**: use `Glob` (e.g. `**/*.tsx`), not `find` or `ls`
- **Search content**: use `Grep` (ripgrep-backed), not `grep -r` or `rg` via Bash

### When working with memories:

- **Memory entry structure**: lead with the rule or fact, then a **Why:** line (the reason or past incident) and a **How to apply:** line (when the rule triggers). Knowing _why_ lets you judge edge cases instead of following the rule blindly.
- **Before creating a new entry, search existing memories** — prefer updating an existing one over creating a duplicate.
- **Remove stale entries promptly** — if a memory is wrong or the underlying code has changed, delete it rather than letting it rot.

### Task Management:

- Use Claude Code's built-in task system (TaskCreate/TaskList/TaskUpdate)
- Plan first, verify plan, then track progress through tasks
- Explain changes with a high-level summary at each step

- **Delegate to subagents** — Offload research, parallel exploration, and focused subtasks to keep the main context clean. Match model tier (Haiku/Sonnet/Opus) to task complexity.
  - Use subagents liberally to keep the main context window clean
  - Offload research, exploration, and parallel analysis to subagents
  - One task per subagent for focused execution
  - If a subagent runs out of context, split across multiple smaller subagents and re-run
  - **Subagent briefing checklist** — the agent starts cold with none of your context. Include: the goal, relevant context (what you already tried or ruled out), expected output format, and a length cap. Terse prompts produce shallow work.
