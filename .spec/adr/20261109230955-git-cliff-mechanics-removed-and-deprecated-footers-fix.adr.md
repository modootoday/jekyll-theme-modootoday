---
id: adr:modootoday/20261109230955
title: "git-cliff mechanics: Removed and Deprecated footers, fix(security), internal docs scopes, an empty Unreleased between release-prep and the tag, and amend after regenerating"
status: active
created: 2026-11-09T23:09:55Z
updated: 2026-11-09T23:10:10Z
rel:
  governs: [cliff.toml]
---

# git-cliff mechanics: Removed and Deprecated footers, fix(security), internal docs scopes, an empty Unreleased between release-prep and the tag, and amend after regenerating

## Context

[[adr:modootoday/20261109225758]] maps commit types and footers to the Keep a Changelog sections but leaves some details open: how Removed and Security entries are made, which `docs` commits are internal, what [Unreleased] holds between `script/release-prep` and the tag, and how a commit can carry its own generated line.

## Decision

- `cliff.toml` parsers, first match wins:
  - `Changelog: none` skips the commit;
  - `!` or a `BREAKING CHANGE:` footer goes to Changed, rendered with a `**Breaking:**` prefix;
  - a `Deprecated: <text>` footer goes to Deprecated, a `Removed: <text>` footer to Removed, with the footer text as the line;
  - `feat` goes to Added, `fix(security)` to Security, other `fix` to Fixed, `perf` to Changed;
  - any other commit with a `Changelog: <text>` footer goes to Changed with that text;
  - `docs(spec|changelog|contributing|agents|releasing)` is internal and skipped; other `docs` commits change the published docs site and go to Changed;
  - a commit that only has a `Visual:` footer lends it to the entry's `Visual:` line and adds no line;
  - everything else (chore, ci, test, build, style, refactor) is skipped.
- `Refs:` ids follow the line in parentheses; a `Migration:` footer follows it as `Upgrade: <text>`.
- The rendered text depends on commit messages only, never on hashes or dates (except a release's date). So a contributor commits, runs `ruby script/changelog` (or `rake fix`), and amends: the amended commit renders the same text.
- Between `script/release-prep` and the tag, the newest dated entry has no tag yet. Its commits belong to that entry, so the expected [Unreleased] is empty.
- A release entry from `cliff.toml` holds two `<!-- release-prep: ... -->` placeholders, one for the Visual line and one for the summary paragraph. `script/release-prep` refuses to dispatch the release checks while one is left, and the CHANGELOG lint fails on one in a released entry.
- git-cliff is the exact npm devDependency `git-cliff` (`npx git-cliff`), so local runs and CI use one version.

## Consequences

- A refactor or chore that users notice needs a `Changelog:` footer; the commit check (`script/commit-check`) asks for one on shipped paths.
- Removed and Security entries need the footer or the scope; a `feat` that removes something is written as `feat!` with a `Removed:` footer.
