---
paths:
  - "**/Taskfile.yml"
  - "**/Taskfile.yaml"
---

## Taskfile conventions

- **`default` task lists tasks, silently** - Include a `default` task that runs `task --list` with `silent: true`, so running bare `task` is discoverable instead of erroring.

- **Every task has a `desc`** - No undocumented tasks; `desc` is what makes `task --list` self-documenting.

- **Reuse the same task vocabulary across repos** - Prefer consistent verbs (`build`, `test`, `clean`, `install`, `tidy`/`lint`/`fmt`) instead of inventing repo-specific names, so the same command works from muscle memory in any project.

- **Compose with `deps:` instead of duplicating commands** - e.g. `install` should depend on `build-local` rather than repeating the build command.

- **`clean` removes whatever "clean" should mean for the project** - Build artifacts, temporary files, caches, etc. Not every project needs a `clean` task. Do not fold in broad or destructive deletes (e.g. `git clean`-style behavior).
