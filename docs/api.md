---
title: Public API
description: The names this theme keeps stable, and how they are deprecated and removed.
---
# Public API

From 1.0 on, the names below follow [Semantic Versioning](https://semver.org/): they change incompatibly only in a major version. Anything not listed (internal includes, Sass partial paths, private `--mt-p-*` primitives, HTML details that no rule describes) can change in any release.

## Stable names

| Area | Stable names |
|---|---|
| Settings | every key under `modootoday:` listed in [Configuration](../configuration/) |
| Design tokens | semantic and component custom properties `--mt-*` (not the primitives `--mt-p-*`); the generated `tokens.json` mirrors them |
| Markdown rules | the patterns in `RULES.md` and their output classes `mt-*` |
| Layouts | `default`, `doc`, `post`, `twin`, `llms`, `llms-full` |
| Includes you may override | `head-custom.html`, `footer-custom.html` |
| Data files | `_data/i18n/<lang>.yml` keys, `_data/nav/<name>.yml`, `_data/components.yml` |
| Checker | the `modootoday-check` options, exit code 0 (no problems) and 1 (problems or bad usage) |

## Deprecation policy

1. A name that will go away is marked deprecated in `CHANGELOG.md` and in the docs, and the checker warns where it can.
2. It keeps working for at least one minor release.
3. It is removed only in the next major release.

> [!IMPORTANT]
> The old `md-*` classes and `--md-*` properties are aliases of `mt-*` and `--mt-*`. They stay through 1.x, are marked deprecated in 1.0, and are removed in 2.0. `modootoday-check` warns when your own Sass, CSS, includes, layouts or pages use them. See the [mapping table](../upgrade/).

## Component structure

This is the markup you can target from your own CSS today. Classes and attributes in this table are stable under the policy above; elements inside them that the table does not name (wrappers, generated ids, the order of child elements) are not. The [slot contract](#slot-contract) names the Markdown parts each component consumes.

| Component | Root | Parts you may style | State and variants |
|---|---|---|---|
| Page shell | `body.mt-body` | `a.mt-skip`, `header.mt-header` > `.mt-header-inner` (`.mt-site-title`, `nav.mt-nav`, `.mt-search`, `.mt-theme-toggle`), `main.mt-main`, `footer.mt-footer` > `.mt-footer-inner` | `html[data-theme=light\|dark]` (fixed scheme, or set by the toggle) |
| Doc page | `article.mt-doc` | `.mt-doc-layout` > `.mt-doc-main` and `.mt-doc-aside` (holds `nav.mt-toc`), `nav.mt-toc-mobile`, `nav.mt-breadcrumb`, `.mt-page-meta`, `nav.mt-pagination` | — |
| Hero | `section.mt-hero` | the `h1`, lead `p`, link-only `p` (CTA buttons; first link is primary) | — |
| Section | `section.mt-section` | the `h2` and its content | `[data-section]` = name; `[data-c]` and `.mt-c-<c>` = component; `.mt-cols-<n>`; `.mt-cta` |
| Prose (no `sections:`) | `div.mt-prose` | the rendered body | — |
| Card grid | `section.mt-section` | `ul > li`, its leading `strong` is the title | `.mt-cols-2`, `.mt-cols-3` (`c: features`) |
| Tabs | `section.mt-c-tabs[data-tabs]` | `[role=tablist]`, `[role=tab]`, `[role=tabpanel]` (built by JS; without JS the `h3` + code blocks stay) | `[aria-selected]` |
| Accordion | `section.mt-c-accordion` | `h3 > button[aria-expanded]`, the panel after it | `[aria-expanded=true\|false]` |
| Steps / Timeline | `section.mt-c-steps`, `section.mt-c-timeline` | `ol > li` or `h3` items | — |
| Alert | `blockquote.mt-callout[role=note]` | `p.mt-callout-title`, the body | `.mt-callout-<type>`, `[data-variant]` = note, tip, important, warning, caution |
| Badge | `span.mt-badge` | the symbol (`aria-hidden`), the label | `.mt-badge-<status>`, `.mt-badge-tag`, `.mt-badge-since`, `[data-variant]` |
| Keyboard keys | `kbd.mt-kbd` | `kbd` per key | — |
| Figure | `figure.mt-figure` | `img`, `figcaption` | — |
| Post meta | `p.mt-post-meta` | `time`, `.mt-post-author`, tag badges | — |
| Search | `div.mt-search[role=search]` | the input, `.mt-search-results` | — |

Each `mt-*` class above also has a deprecated `md-*` twin on the shell, doc, hero, section, prose, alert and badge elements until 2.0 (see [Migrate and upgrade](../upgrade/)).

## Slot contract

`since:1.0` A slot is a named part of a section's Markdown. Slot names are stable under the policy above, and declaring them never changes the generated markup. `modootoday-check` counts each slot in every section whose `c:` has a `slots:` entry in `_data/components.yml`, and fails when a count is outside the declared range.

| Slot | What it counts in the section (after its `##` heading) | Renders as |
|---|---|---|
| `lead` | Plain paragraphs before the first list, `###`, code block or quote | `p` |
| `items` | List items | `ul > li` or `ol > li` (cards, steps) |
| `panels` | `###` headings | tab, accordion or step panels |
| `actions` | Link-only lines | CTA buttons (`c: cta`) |
| `code` | Fenced code blocks | `pre` (tab content) |
| `figures` | Lines that start with an image | `figure.mt-figure` |

Each slot takes `required: true` (same as `min: 1`), `min` and `max`. An unknown slot name is an error.

```yaml
features: {params: {cols: {allowed: [2, 3]}}, slots: {items: {min: 1}}}
tabs: {i18n: [tabs.label], slots: {panels: {min: 2}, code: {min: 2}}}
cta: {slots: {actions: {required: true}}}
accordion: {slots: {panels: {min: 1}}}
```

Components without `slots:` are not counted, so existing registries keep working.

## Right-to-left and math

- Pages in Arabic, Persian, Hebrew, Urdu and other RTL languages get `dir="rtl"` from `lang`; set `direction: rtl` or `ltr` in front matter (or `direction:` in `_data/i18n/<lang>.yml`) to override. Components use logical properties and mirror; code stays left-to-right.
- The theme bundles no math or diagram renderer; see [Math and diagrams](../math-diagrams/).
