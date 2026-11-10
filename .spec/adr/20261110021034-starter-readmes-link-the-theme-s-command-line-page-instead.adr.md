---
id: adr:modootoday/20261110021034
title: Starter READMEs link the theme's Command line page instead of copying its option tables
status: active
created: 2026-11-10T02:10:34Z
updated: 2026-11-10T02:10:54Z
rel:
  governs: [script/starters/templates/README.md.erb, script/starters/theme.rb]
  depends_on: [adr:modootoday/20261103152846, adr:modootoday/20261109150907]
---

# Starter READMEs link the theme's Command line page instead of copying its option tables

## Context

[[adr:modootoday/20261103152846]] rendered each starter's README with the `--help=markdown` tables of `modootoday-check` and `modootoday-stubs` taken from the checkout. Under [[adr:modootoday/20261109150907]] a change to a rendered file fails `rake starters:check` until every published starter is re-rendered and its gitlink bumped, so each new or reworded option forced commits in three starter repositories between releases, although nothing a starter pins had changed.

Two ways out were weighed:

- **Link the theme's Command line page** (`reference/cli/` under the manifest's `demo.docs_url`), which already carries both tables from the same `--help=markdown`.
- **Render the tables from the starter's pinned release.** The tables would then change only with the pin, but the renderer would need the executables of that release (a gem install or a tag checkout) on every render and check, offline runs could not render, and the README would still be a second copy of the tables.

## Decision

- The starter README's Commands section says what the two commands do, links the Command line page, and names `bundle exec modootoday-check --help` and `bundle exec modootoday-stubs --help`, which print the options of the installed, pinned version.
- `Starters::Theme` no longer runs the executables; the README render reads no command output.
- The link was chosen because it needs no upkeep: an option change touches the theme alone, and the `--help` line covers the gap while the docs site, which follows `main`, is ahead of a starter's pin.

## Consequences

- An option change no longer changes any starter's rendered files, so it needs no starter commit.
- A reader of a starter's README follows a link for the option tables. The docs page can name an option the pinned release does not have yet; `--help` is the exact list.
