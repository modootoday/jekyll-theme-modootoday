---
title: Migrate and upgrade
description: Move a site from another Jekyll theme, adopt the theme in an existing project, and upgrade between versions.
---
# Migrate and upgrade

## From another theme

1. Replace `theme:` or `remote_theme:` with this theme (see [Install](../install/)) and pin a version.
2. Set `layout: doc` as a default in `_config.yml`, or keep your own layouts and include only the parts you need.
3. Keep page bodies as they are. GitHub alerts, tables and fenced code already work. Remove raw HTML and Liquid from bodies where you can; `modootoday-check` lists what is not portable.
4. Move colours and fonts into `modootoday.tokens` instead of overriding CSS selectors.
5. Run `jekyll build` and `modootoday-check SRC _site`, then fix what it reports.

Common mappings: minima `layout: page` and just-the-docs `layout: default` become `layout: doc`; callouts made with an `include note.html` tag become `> [!NOTE]`; badges written in HTML become `` `status:available` `` code spans.

## Adopting in an existing project

| Method | Use when | Updates |
|---|---|---|
| Gem (`theme:`) | the site has a `Gemfile` (Jekyll 4 or the `github-pages` gem) | `bundle update jekyll-theme-modootoday` |
| `remote_theme:` | classic GitHub Pages without a `Gemfile` | change the `@vX.Y.Z` tag |
| Copy-in | you need to fork layouts or cannot add a dependency | copy `_layouts`, `_includes`, `_sass` and `assets` from a tagged release and record the version; you merge updates by hand |

Prefer the gem or `remote_theme:` pinned to a tag. Copy-in loses upgrades and checker guarantees for the files you change.

## Markdown twins

Pick one of three ways to publish the agent-readable twin of each page:

- **Stub files** (default, classic GitHub Pages): one small `<page>.md.txt` per page.
- **Plugin** (Jekyll 4 or GitHub Actions): `plugins: [jekyll-theme-modootoday]` creates twins and `llms.txt` without stubs.
- **Source mode** (classic GitHub Pages, no stubs): `modootoday.twins: source` with pages that have no front matter. Classic GitHub Pages serves the raw copy as `text/markdown; charset=utf-8`, identical to the source (see RULES.md §5a for the limits).

Switching between them does not change page bodies. See [Agents](../agents/) and section 5a of `RULES.md`.

## Upgrading

Read `CHANGELOG.md` for every version you skip. From 1.0 on, rules and the public API change incompatibly only in a major version (see [Public API](../api/)).

| From | To | What to do |
|---|---|---|
| a build from the repository before 1.0.0 | 1.0 | pin `~> 1.0` or `@v1.0.0`; replace `md-*` classes and `--md-*` properties in your own CSS with `mt-*` and `--mt-*` (they still work in 1.x, with checker warnings); run `modootoday-check --strict` |
| 1.x | 2.0 | `md-*` aliases are removed |

If your pages come from a pre-1.0 draft that allowed fewer `sections:` items than `##` headings, add a plain name (such as `notes`) for each remaining heading: the count must now match, and `modootoday-check` reports the page and both numbers.

### `md-*` to `mt-*`

The `md-*` classes and `--md-*` custom properties are deprecated in 1.0 and removed in 2.0. `modootoday-check` warns where your own Sass, CSS, includes, layouts or pages use them (code blocks are ignored); `--strict` turns the warnings into errors. Replace each name with its `mt-*` equivalent. Only the names below exist; the theme never had other `md-*` names.

Search your site with `grep -rnE '(\.|class=.*)md-[a-z]|--md-' _sass _includes _layouts assets`.

Classes:

| Old | New |
|---|---|
| `.md-body` | `.mt-body` |
| `.md-header` | `.mt-header` |
| `.md-site-title` | `.mt-site-title` |
| `.md-skip` | `.mt-skip` |
| `.md-main` | `.mt-main` |
| `.md-doc` | `.mt-doc` |
| `.md-hero` | `.mt-hero` |
| `.md-section` | `.mt-section` |
| `.md-c-<c>` | `.mt-c-<c>` |
| `.md-cta` | `.mt-cta` |
| `.md-prose` | `.mt-prose` |
| `.md-callout` | `.mt-callout` |
| `.md-callout-<type>` | `.mt-callout-<type>` |
| `.md-callout-title` | `.mt-callout-title` |
| `.md-badge` | `.mt-badge` |
| `.md-badge-<value>` | `.mt-badge-<value>` |

Custom properties:

| Old | New |
|---|---|
| `--md-font-sans` | `--mt-font-sans` |
| `--md-font-mono` | `--mt-font-mono` |
| `--md-font-size` | `--mt-font-size` |
| `--md-line-height` | `--mt-line-height` |
| `--md-measure` | `--mt-measure` |
| `--md-space` | `--mt-space` |
| `--md-radius` | `--mt-radius` |
| `--md-bg` | `--mt-background` |
| `--md-bg-subtle` | `--mt-muted` |
| `--md-fg` | `--mt-foreground` |
| `--md-fg-muted` | `--mt-muted-foreground` |
| `--md-border` | `--mt-border` |
| `--md-accent` | `--mt-primary` |
| `--md-accent-fg` | `--mt-primary-foreground` |
| `--md-focus` | `--mt-ring` |
| `--md-note` | `--mt-note` |
| `--md-tip` | `--mt-tip` |
| `--md-important` | `--mt-important` |
| `--md-warning` | `--mt-warning` |
| `--md-caution` | `--mt-caution` |
| `--md-available` | `--mt-status-available` |
| `--md-partial` | `--mt-status-partial` |
| `--md-planned` | `--mt-status-planned` |

Under `--md-*`, `bg-subtle`, `fg`, `accent` and similar names were renamed, not only re-prefixed. The `mt-` names in the right column are part of the [Public API](../api/).
