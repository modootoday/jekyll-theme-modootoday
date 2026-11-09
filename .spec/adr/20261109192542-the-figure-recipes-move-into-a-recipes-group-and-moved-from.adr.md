---
id: adr:modootoday/20261109192542
title: "The figure recipes move into a recipes group, and moved_from keeps their old URLs as redirects"
status: active
created: 2026-11-09T19:25:42Z
updated: 2026-11-09T19:26:21Z
rel:
  governs: [script/docs/redirects.rb, test/system/docs/structure.rb, docs/recipes/figures/index.md]
  supersedes: [adr:modootoday/20261109124854]
  depends_on: [adr:modootoday/20261109141344, adr:modootoday/20261030083000]
---

# The figure recipes move into a recipes group, and moved_from keeps their old URLs as redirects

## Context

The recipes sidebar held 13 entries in every language (seven single recipes and six site groups), one over the cap of 12 in [[adr:modootoday/20261030083000]], under a temporary limit of 14 ([[adr:modootoday/20261109124854]]). [[adr:modootoday/20261109141344]] asks for 12 or fewer with every published URL kept. The docs site has no server redirects, and the theme's `redirect` layout (meta refresh, canonical, `noindex`, no script) is what the moved starter demos already use. A group is a subdirectory with its own index, so grouping pages means moving them.

## Decision

- **Math and diagrams, Charts and Widgets move into a new group, `recipes/figures/` ("Figures and widgets").** They share a purpose: Markdown that GitHub already reads (a fence, a table) or a custom element, shown as a figure that works under the strict CSP. The six site groups and the four other single recipes stay where they are. The recipes sidebar holds 11 entries in every language, and the 14-entry exception in `test/system/docs/structure.rb` is gone.
- **An English page that moved lists its old source paths in front matter, `moved_from: [recipes/charts.md]`.** `ruby script/docs-index` writes a redirect stub at each old path, in English and in every language the page has (`layout: redirect`, `redirect_to:` the page's new URL in that language, `twin: false`, `sitemap: false`, `nav_exclude: true`), and `--check` fails on a missing or stale stub. The page's front matter is the only list, as for every other generated docs file.
- The static math of the moved page follows its path (`_data/math/recipes--figures--math-diagrams.yml`); links in the docs, the README and the QA page lists use the new URLs.

## Consequences

- `/recipes/math-diagrams/`, `/recipes/charts/` and `/recipes/widgets/` and their `/ko/` and `/ja/` forms keep working as redirects to the pages under `/recipes/figures/`.
- A later move inside the docs needs only `moved_from:` on the moved page.
- A recipes group past 12 entries again needs another group, not an exception.
