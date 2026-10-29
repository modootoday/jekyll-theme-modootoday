---
id: adr:modootoday/20261029224006
title: "Authoring conventions: single responsibility, grouped directories, standards first"
status: draft
created: 2026-10-29T22:40:06Z
updated: 2026-10-29T22:40:06Z
---

# Authoring conventions: single responsibility, grouped directories, standards first

## Context

The repository grew flat directories (`test/` with 16 files side by side, `qa/` mixing build, audit, visual, Lighthouse and link tools) and multi-purpose files (`qa/qa.mjs` ran budgets, contrast, screenshots, axe, parts and the report in one script). The maintainer asked that four conventions apply to the whole project, including tools, tests, QA and new code: single responsibility, no flat file listings, modularization, and a context-based directory structure that follows the ecosystem's standards first.

## Decision

1. Standards first: Jekyll, RubyGems, Bundler, Rake, minitest and npm decide places and names where they have a convention.
2. One responsibility per file; a second responsibility means a split.
3. An assembling file sits beside a directory of the same name that holds its parts (`lib/modootoday/check.rb` + `lib/modootoday/check/`, `qa/audit.mjs` + `qa/audit/`).
4. At most 12 tracked files per directory; more are grouped by context. Exceptions fixed by a standard (Jekyll pages, the repository root) or pending a regroup carry a reason in `FLAT_OK`.
5. Code files under `lib/`, `qa/`, `exe/`, `script/`, `assets/js/` and test helpers: at most 150 lines; test files at most 300. Exceptions carry a reason in `LONG_OK`.

`test/project/layout_test.rb` checks rules 4 and 5 against `git ls-files`, and fails when an allowlist entry no longer applies, so exceptions cannot linger. `CONTRIBUTING.md` ("Project layout") holds the developer-facing wording and the map of where things live.

Applied now: `test/` grouped into `checker/`, `theme/`, `consumer/`, `project/`, `js/` (Rake globs `test/**/*_test.rb`); `qa/` grouped into `site/`, `audit/`, `visual/`, `lighthouse/`, `docs/`, `css/`, with the audit split into one module per check and a shared static server.

## Consequences

- Paths in workflows, `package.json`, `.gitignore` and `CONTRIBUTING.md` moved with the files. The visual workflow builds an older base commit with whichever `build-docs.sh` path it has.
- Still listed as exceptions, to be resolved: `lib/modootoday/check/` (16 files) and `test/checker/check_test.rb` (414 lines) are regrouped together once concurrent checker edits land. `_sass/modootoday/components` is pending a regroup after the concurrent visual work. `docs/`, `docs/ko`, `docs/ja`, `.spec/adr`, `test/fixtures/md` and the repository root stay flat by convention. The public API is not frozen before the first release, so no path is exempt for being public.
- The docs site, `example/` and the i18n generator follow the same rules when they are next restructured.
