---
id: adr:modootoday/20261103092250
title: One owner for front matter parsing and for a page's URL
status: active
created: 2026-11-03T09:22:50Z
updated: 2026-11-03T09:23:07Z
rel:
  governs: [lib/modootoday/markdown.rb, lib/modootoday/stubs/page.rb, script/docs/tree.rb, qa/docs/coverage.rb]
---

# One owner for front matter parsing and for a page's URL

## Context

Front matter was parsed in six places with three different patterns: the checker's `Check::Markdown`, `modootoday-stubs` (`Source`), `script/docs/tree.rb`, `qa/docs/coverage.rb` (twice), the checker's new-window rule and the translation lint. A page's directory URL (permalink ending in `/`, else the path without `.md` and `index`) was computed three times: in `modootoday-stubs` (`Page#url`), in `script/docs/tree.rb` and in the checker's `--aliases` rule.

## Decision

- `Modootoday::Markdown` in `lib/modootoday/markdown.rb` (moved from `lib/modootoday/check/markdown.rb`) owns front matter parsing: `FM`, `front_matter?`, `fm` and `body`, with the fence, code span and comment helpers it already had. Every caller requires it: both executables, `script/docs/tree.rb`, `script/i18n/lint.rb` and `qa/docs/coverage.rb`.
- `Modootoday::Stubs::Page` in `lib/modootoday/stubs/page.rb` (split out of `stubs/source.rb`) owns a page's URL and whether it is a directory URL. `script/docs/tree.rb` and the checker's `--aliases` rule build one and ask it.
- Callers keep their own error policy: `modootoday-stubs` still raises its data error on a front matter that is not a map or not valid YAML, and the checker rules keep their rescues.

## Consequences

One pattern decides what front matter is, for the checker, the stubs, the docs index and the docs QA. The built example and docs sites, the generated nav and stubs, and the test results are unchanged. A Markdown file the old docs pattern treated differently (front matter with Windows line ends or an empty block) is now read the way Jekyll and the checker read it.
