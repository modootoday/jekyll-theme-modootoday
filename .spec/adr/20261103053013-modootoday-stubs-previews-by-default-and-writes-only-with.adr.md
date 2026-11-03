---
id: adr:modootoday/20261103053013
title: modootoday-stubs previews by default and writes only with --write
status: active
created: 2026-11-03T05:30:13Z
updated: 2026-11-03T05:30:43Z
rel:
  governs: [lib/modootoday/stubs]
---

# modootoday-stubs previews by default and writes only with --write

## Context

Classic GitHub Pages runs no plugins, so every twin, and now every URL alias, is a front-matter-only stub file next to its page. Sites kept those by hand, and `script/docs-index` had its own copy of the twin rule for the docs site. The feature design had the new command write by default and report with `--check`. `modootoday-check` stays read-only apart from the explicit `--i18n-init`.

## Decision

- A second executable, `exe/modootoday-stubs` (Ruby standard library only, packaged through `spec.executables`), keeps the checker read-only. Its parts are in `lib/modootoday/stubs/`: `source.rb` (the pages Jekyll renders: front matter present, not under `_` or `.` folders, `vendor`, `node_modules` or `exclude:`), one generator per kind (`twins.rb`, `aliases.rb`) with `wanted` and `orphans`, `plan.rb`, `writer.rb`, `report.rb`, `cli.rb`.
- Without `--write` the command only lists the creates, updates and deletes, and exits 0; a site cannot lose or change a file by running it to see what it does. `--write` applies the plan and writes only files whose bytes differ, so a second run changes nothing. `--check` writes nothing and exits 1 on any change, for CI. `--write` with `--check` is a usage error.
- Exit codes: 0, 1 drift under `--check`, 2 usage or `_config.yml`, 3 data (front matter that is not a map, a permalink that is not a plain YAML scalar, two pages with one alias, an alias over a source file). A stub whose page is gone is deleted (prune, as `script/docs-index` did); `--no-prune` keeps it.
- `script/docs-index` gets its twin stubs and orphans from `Modootoday::Stubs::Twins`, so the docs site and user sites follow one rule. Regenerating all 149 docs stubs from nothing with the old and the new script gives identical trees.
- `--records` and `--pwa` from the feature design are later work items and are not in the usage yet.

## Consequences

The README has a second generated table (`stubs:begin` markers, `script/readme-commands`). A pre-commit hook on a site runs `--write`; CI runs `--check`.
