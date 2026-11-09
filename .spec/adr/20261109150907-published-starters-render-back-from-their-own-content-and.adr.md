---
id: adr:modootoday/20261109150907
title: Published starters render back from their own content and the docs demos move through script/docs-index
status: active
created: 2026-11-09T15:09:07Z
updated: 2026-11-09T15:32:46Z
rel:
  governs: [script/starters, script/docs/moves.rb, docs/_includes/live-demo.html, test/system/site/demos.mjs, docs/_layouts/layout-reference.html]
  depends_on: [adr:modootoday/20261104171142, adr:modootoday/20261104171141]
---

# Published starters render back from their own content and the docs demos move through script/docs-index

## Context

- [[adr:modootoday/20261104171142]] makes each published starter a gitlink at `example/<name>` whose work tree holds the rendered `github-pages` tree, and asks `rake starters:check` to render it from its own content at the release it pins.
- [[adr:modootoday/20261104171141]] and [[sot:modootoday/docs-demo-to-starter-map]] move the docs demos of a wave in the change that publishes its starters: reference pages with one "Live demo" component, and redirect stubs generated from the map rows.
- Wave 1 (docs, blog, landing) is the first such change. Neither document settles how the content is recovered, what "a released tag" means in a CI checkout without tags, which tool writes the stubs, or where the slower suites run on the demo builds.

## Decision

- **Content of a published starter.** It is the work tree without the files the renderer owns (`Gemfile`, `README.md`, `.github`, `_config.demo.yml`), with the `remote_theme: <repo>@vX.Y.Z` line turned back into `theme:` and `jekyll-remote-theme` dropped from `plugins`. Stubs stay in the content; the stub planner rewrites stale ones and prunes orphans, so a render is idempotent.
- **The pin.** `rake starters:check` renders with this checkout's renderer and templates at the pinned version. A released version is a dated `## [X.Y.Z] - YYYY-MM-DD` heading in `CHANGELOG.md`, read offline, because CI checks out without tags. A pin behind the gemspec version only warns.
- **Tasks.** `rake starters:render[NAME,DIR]` always renders `pkg/starters`. Only when NAME is a published starter does it also rewrite that work tree, pinned to the gemspec version, so a plain `rake starters:render starters:check` in CI never hides drift. In `pkg/starters/github-pages/<name>/`, a published starter is a copy of its work tree as committed, so CI jobs read one path for every starter.
- **Docs moves.** The map's wave table gains a Status column. `script/docs-index` reads the rows of waves marked `done` and writes the redirect stubs at the demo paths. A translation's stub carries `lang`, `permalink` and the `source_rev` of the English stub, so the translation tooling leaves it unchanged. It also writes `docs/_data/starters.yml`, keyed by the English source path without `.md`, with the starter page URL derived from `example/starters.yml`. A row of a done wave names a page path, never a description.
- **One component.** `docs/_includes/live-demo.html` prints the static preview, when one is committed at `docs/assets/images/layouts/<layout>.webp`, and the link. A reference page uses `layout: layout-reference`, a docs layout that places the component after the lead paragraph. The page body stays plain Markdown, because the docs check requires each twin and `llms-full.txt` to match the body byte for byte, and a Liquid tag in the body breaks that.
- **New-window link.** The link takes the theme's own new-window attributes: `target`, `rel`, `data-mt-new-window` and `aria-describedby` pointing at the localized hint the default layout prints. It does not use a hidden span inside the link, because `modootoday-check` warns about a new-window link without the hint, and the docs then hold no second copy of the string.
- **Other docs pages.** A page that links a moved demo, such as the shell layouts or the generated pages recipe, uses a plain Markdown link titled `new-window`. A test fails when a starter address in `docs/` is not the page of a moved row.
- **Previews.** Each preview is an 800 by 500 WebP screenshot of the live demo, taken with a remote browser. A row without a committed preview shows only the link.
- **QA on demo builds.** The Starters workflow runs the starter audit: the showcase, then shots, overflow, axe, page types, offsets and CSP from the `STARTERS` lists in `test/system/audit/config.mjs`, each naming only `qa:` pages. Visual regression and Lighthouse on the demo builds run as their own jobs in `visual.yml` and `lighthouse.yml`, which the release check already starts. Lighthouse does not score SEO there, because a demo is `noindex`.
- **Docs data removed.** The docs site's record set (`records:` in `docs/_config.yml` and `docs/_data/plugins.json`) moved with the records demo to the docs starter.

## Consequences

- A change to the renderer's templates or to the command tables in the README changes every published starter's rendered files. `rake starters:check` then fails until each starter is re-rendered and its gitlink bumped. A change that documents an unreleased feature goes to the starter's `next` branch.
- The docs QA, the Ruby tests and any job that runs `script/docs-index` need the submodules checked out.
- Moving a later wave means marking it `done`, running `ruby script/docs-index`, and writing the reference pages that call the include. The tests fail when a moved page is neither a reference page nor a stub, or when a list names a moved URL.
