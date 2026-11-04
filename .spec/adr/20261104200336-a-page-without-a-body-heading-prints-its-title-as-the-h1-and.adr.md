---
id: adr:modootoday/20261104200336
title: "A page without a body heading prints its title as the h1, and the search form needs a url"
status: active
created: 2026-11-04T20:03:36Z
updated: 2026-11-04T20:06:52Z
rel:
  governs: [_includes/modootoday/pages/title.html, _includes/modootoday/pages/search-form.html]
---

# A page without a body heading prints its title as the h1, and the search form needs a url

## Context

The usability audit of the 1.5.0 candidate (audit:modootoday/20261104191444, M4 and M6) switched a `jekyll new` site to the theme. The `doc` layout (and `page`, its alias) printed only the body, so minima's About page, which relies on the layout printing `title:`, had no `h1`, and neither had the `home` page without a hero; axe reported page-has-heading-one on both. The `search` layout had the same gap, and its no-JavaScript form and the header box were two unnamed search landmarks (landmark-unique). With `url: ""`, as `jekyll new` writes it, the form's site filter was empty and the outside engine searched the whole web.

## Decision

- `modootoday/pages/title.html` prints `<h1>` with the escaped title when the rendered body contains no `<h1`. The `doc` layout (so `page`) puts it before the body, so with `sections:` it lands in the hero; the `search` layout uses it too; the `home` layout uses it when there is no hero title, with the page title or else the site title. A body with its own `# ` heading is unchanged.
- The search page's form is named by its label (`aria-labelledby`), apart from the header search box.
- Without a host in `url:`, the search layout leaves the form out instead of sending an unfiltered query to an outside engine. `fallback: false` still hides it everywhere.

## Consequences

A `jekyll new` site gets one `h1` on every page with no edits, as with minima. A doc page that relied on having no `h1` now shows its title; such a page adds a `# ` heading or `title:` that suits it. A site without `url:` has no no-JavaScript search form until it sets one; the Layouts page says so.
