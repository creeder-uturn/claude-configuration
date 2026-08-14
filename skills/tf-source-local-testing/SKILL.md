---
name: tf-source-local-testing
description: Explains the `tf-source-local` / `tf-source-remote` scripts that swap OpenTofu/Terraform module and stack `source` lines between committed git refs and local relative paths, for iterating on an uncommitted cross-repo change without pushing every attempt and waiting on CI. Use this skill whenever the user wants to test a local module/stack change against a dependent repo before pushing, mentions `tf-source-local` or `tf-source-remote`, or is about to commit `.tf` files in a repo that pins module/stack sources to git refs (`source = "git@...?ref=..."`) — check whether a local source swap is active before that commit even if the user doesn't bring it up, since committing one silently ships broken infrastructure.
---

# tf-source-local / tf-source-remote

Two scripts (commonly on `PATH` as `tf-source-local` and `tf-source-remote`, e.g. from `~/bin/`) swap `.tf` module/stack sources between their normal git-ref form and a local relative path, so you can point a stack at an uncommitted checkout of a module instead of a pushed tag. Confirm the scripts still exist on `PATH` (or at their expected location) before relying on this — they're typically unversioned personal/team scripts, not a published package, so the install location can vary by environment.

## What they actually do

**`tf-source-local`** — run from the directory whose sources you want to swap. For every `*.tf` file in the **current directory only** (not recursive), it finds lines shaped like:

```hcl
source = "git@github.com:org/some-repo.git//modules/vpc?ref=v1.2.0"
```

— specifically the SSH-style `git@host:org/repo.git//path` form; HTTPS-style sources aren't matched and are left untouched — and rewrites each match into two lines: the original, commented out (preserving its exact `?ref=...`), followed by a new line pointing at a local relative path:

```hcl
# source = "git@github.com:org/some-repo.git//modules/vpc?ref=v1.2.0"
source = "../../some-repo/modules/vpc"
```

The relative path assumes **the dependency repo is checked out as a sibling directory of the current repo's root** (same parent folder) — it computes `../` depth from the current file down to that repo root, then descends into `<repo-name>/<path>`. If that sibling checkout doesn't exist, the rewrite still succeeds (it's a pure text edit) but `tf init`/`plan` will fail to find the path. Verify the sibling checkout exists before running it.

Because it only matches un-commented `git@...` source lines, running it twice is a no-op the second time — safe to re-run.

**`tf-source-remote`** — the reverse, also current-directory-only. It looks for the commented `# source = "git@...` marker line; when found, it uncomments that line and **deletes the line immediately following it**, on the assumption that's the local-path line `tf-source-local` inserted. It doesn't verify that assumption — if something else got inserted between the comment and the next line (e.g. a hand-edit while the swap was active), that line gets deleted instead. Don't edit inside a swapped two-line block; restore with `tf-source-remote` first, then make the edit against the real source line.

It restores the **exact ref that was there before** (preserved verbatim in the comment) — it has no way to know about a newer tag. If the local testing was meant to validate a change that should ship at a new version, restore first, then bump the ref with `wand pin` (see the `wand-cli` skill) — don't try to change the ref while the local swap is still in place.

Also a no-op if there's nothing swapped, which is what makes it safe to run unconditionally (see below) rather than only when you're sure something needs restoring.

## When to use tf-source-local

Use it when actively developing a module or stack and iterating against an **uncommitted** change in a repo it depends on — you'd otherwise have to push every attempt and wait for CI to cut a tag just to test whether it works, which is slow and litters the dependency repo's history with throwaway/broken pushes. Swapping to a local path makes edits in the dependency repo take effect immediately on the next `tf plan`.

Only run it when the user has explicitly said they're testing or iterating on a local change — it rewrites tracked file contents in place, so it shouldn't happen proactively or as a guess.

## When to use tf-source-remote — and the rule that matters

**Before committing `.tf` files in any directory `tf-source-local` may have touched, run `tf-source-remote` in that directory first — unconditionally, without waiting to be asked.** A local relative-path source is dev-machine-only wiring: if it lands in a commit, the source resolves to nothing (or a different local checkout) for anyone else, and CI has no ref to build from.

Since both scripts only operate on the current directory, this is a per-directory check: if local testing touched a stack and the modules underneath it, each directory needs its own `tf-source-remote` pass before its own changes get committed. Don't rely on remembering which directories were swapped earlier in a session — that's easy to lose track of. A quick way to check whether a directory needs it:

```bash
grep -l '^\s*#\s*source\s*=\s*"git@' *.tf
```

Any match means a swap is active there; running `tf-source-remote` regardless of whether you've checked is also fine, since it's a no-op when there's nothing to restore.
