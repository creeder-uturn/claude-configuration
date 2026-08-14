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
  - One exception: for OpenTofu/Terraform code, if `tf fmt` runs clean, running `tf validate` as an additional verification step is not required.

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

### Terraform/OpenTofu — commands & permissions:

- **Always use tf** - When running terraform or opentofu commands, always use the `tf` command, instead of `tofu` or `terraform`. If that command fails due to lack of `.opentofu-version` or `.terraform-version` file, let the user know and pause.

- **No risky commands** - Only run `tf init`, `tf validate`, and `tf fmt` without explicit prompting. Do not run any other `tf` commands unless explicitly prompted.

- Never `-auto-approve` in a real environment. It is only acceptable when explicitly told to use it in a limited sandbox/testing capacity.

- **Terraform output must never be truncated**: always capture the full output to a file (e.g. redirect to `/tmp/claude/<project>/plan.txt`); never pipe through `head`, `tail`, or any length-limiting filter — truncated plans hide resource deletions and replacement cascades. Use the Bash tool's output directly or redirect to a file and `Read` it — avoid `2>&1 | tee`.

- **OpenTofu is preferred over Terraform** - Generally, \*.tf code is OpenTofu, not Terraform. Terraform code will have a `.terraform-version` file with it.

- OpenTofu is a fork of Terraform, so most things that apply to Terraform also apply to OpenTofu.

- TF and AWS commands should always set an AWS_PROFILE (or --profile). If you are unsure of the profile to use for a given repository or project folder, ask the user and pause.

### Terraform/OpenTofu — code conventions:

- **IAM policies**: Always use `data "aws_iam_policy_document"` over `jsonencode()` for IAM policy JSON in Terraform/OpenTofu.

- **State backend can have local values** - OpenTofu supports local (static) values in state backend - follow the repositories conventions when writing a backend configuration (or `config.tf` file)

### Taskfile conventions:

- **Prefer Taskfile.yml for repeated tasks** - Examples include `build`, `clean`, `test`.

- **`default` task lists tasks, silently** - Include a `default` task that runs `task --list` with `silent: true`, so running bare `task` is discoverable instead of erroring.

- **Every task has a `desc`** - No undocumented tasks; `desc` is what makes `task --list` self-documenting.

- **Reuse the same task vocabulary across repos** - Prefer consistent verbs (`build`, `test`, `clean`, `install`, `tidy`/`lint`/`fmt`) instead of inventing repo-specific names, so the same command works from muscle memory in any project.

- **Compose with `deps:` instead of duplicating commands** - e.g. `install` should depend on `build-local` rather than repeating the build command.

- **`clean` removes whatever "clean" should mean for the project** - Build artifacts, temporary files, caches, etc. Not every project needs a `clean` task. Do not fold in broad or destructive deletes (e.g. `git clean`-style behavior).

### When calling Bash:

- Prefer creating scripts in `/tmp/claude/<project>` for multiline shell commands instead of running them directly.
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
