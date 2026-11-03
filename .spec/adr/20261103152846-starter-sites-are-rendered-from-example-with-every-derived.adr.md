---
id: adr:modootoday/20261103152846
title: "Starter sites are rendered from example/, with every derived file owned by the theme"
status: active
created: 2026-11-03T15:28:46Z
updated: 2026-11-03T15:29:06Z
rel:
  governs: [example/starters.yml, script/starters]
---

# Starter sites are rendered from example/, with every derived file owned by the theme

## Context

The theme needs starter repositories (docs, blog, landing) that a user can copy and deploy on either stack. `example/` was one site that mixed docs and blog content, committed its twin stubs, record pages and a `Gemfile` with a path to the checkout, carried the `remote_theme` tag in a comment, and held the front-matter-less test site. Copying it into three repositories by hand would create a second owner for the version, the Gemfile lines, the Pages workflow, the README and the language list.

## Decision

- `example/` is the starter source, not a new copy. `example/starters.yml` is the only list of starters: name, target repository, languages (first = default), stacks and `modootoday-check` flags. Each folder beside it is a Jekyll site that builds on its own and holds only what a person writes. The front-matter-less site is a test fixture in `test/fixtures/sites/source-mode/`.
- The split is by content: `docs` keeps the home, guide, records with the byte-exact API folder, the component registry, the token bridge sample and the Korean and Japanese pages in `<lang>/` folders (directory mode, since starter users have no translation generator); `blog` keeps the posts, news, author and feed, with the grid listing as its home; `landing` is new and English-only. New starters default to English only.
- `script/starters/` renders each starter for each stack into `pkg/starters/<stack>/<name>/`. Everything else is derived there from its owner: the `remote_theme` pin of the `github-pages` stack and the theme gem line from the gemspec; the other gem lines from `gemfiles/<stack>.gemfile` without the test tools; `README.md` and `.github/workflows/pages.yml` from one ERB template each, shared by every starter (the README command tables from `--help=markdown`); missing catalogs of the listed languages from `i18n/`, the way `--i18n-init` copies them; twin, record and alias stubs from `modootoday-stubs`. A source folder that contains a rendered file name (`Gemfile`, `README.md`, `.github`) is refused.
- Tests pin the derivations: two renders are byte-identical, `starters:check` names every drifting file, manifest languages and stacks must be the theme's lists, the workflow's action versions equal the theme CI's, and the sources hold no stub or record page.
- Rake tasks live in the `Rakefile` (`starters:render`, `starters:check`, `starters:build`), since the repository has no `rakelib/` yet; they move with the planned `rakelib/` regroup. There is no `starters:publish` stub: publishing waits until after 1.5.0, and RELEASING says how to upload a rendered starter by hand.
- `.github/workflows/starters.yml` replaces the example steps and the `pages-action` job of `ci.yml`. The `ruby` matrix builds the starters only on the entries it does not share with `starters.yml`.
- `modootoday-check` leaves out a Markdown file named in `exclude:`, as it already did for folders, so a starter's `README.md` is not checked as a page.

## Consequences

A starter cannot drift from the theme release it names. The tests and CI build three smaller sites instead of one, and the blog listing's tags are read from the blog starter. A full English catalog lands in the blog and landing starters (`_data/i18n/en.yml`), which pins their interface strings until the site owner removes or trims it. The published repository of a starter takes one rendered stack; which one is decided when publishing is automated.
