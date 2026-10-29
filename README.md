# jekyll-theme-modootoday

[한국어](README.ko.md)

A Jekyll theme for documentation sites whose pages stay **plain GitHub Markdown**. Bodies use only GFM that also renders on github.com; layouts, includes, CSS and a little optional JavaScript add the design:

- GitHub alerts (`> [!NOTE]` …) become styled callouts
- status code spans (`` `status:available` ``) become badges
- `##` sections can be mapped to components (feature grid, install tabs, call-to-action)
- byte-identical Markdown "twins" of every page for agents and LLMs (`/guide/index.md`, `llms.txt`)
- `modootoday-check` validates sources and build output

Works with the GitHub Pages stack (`github-pages` gem, Jekyll 3.10) and with Jekyll 4. Layouts and includes are Liquid only, so `remote_theme` works on GitHub Pages.

> [!NOTE]
> The content rules are `md-components v1 (draft)`. They may still change before v1 is declared final. See [RULES.md](RULES.md).

## Install

### As a gem (`theme:`)

```ruby
# Gemfile
gem "jekyll-theme-modootoday", "~> 0.1"
```

```yaml
# _config.yml
theme: jekyll-theme-modootoday
```

### On GitHub Pages without a Gemfile (`remote_theme:`)

```yaml
# _config.yml
remote_theme: modootoday/jekyll-theme-modootoday@v0.1.0
plugins:
  - jekyll-remote-theme
```

Pin a tag (or a commit) instead of `main`. The `modootoday-check` executable is not available this way; run it from a checkout of this repository or with `gem install jekyll-theme-modootoday`.

## Configuration

```yaml
lang: en                      # default page language
markdown: kramdown
kramdown: {input: GFM, syntax_highlighter: rouge}
permalink: pretty
defaults:
  - {scope: {path: ""}, values: {layout: doc}}
  - {scope: {path: "ko"}, values: {lang: ko}}
modootoday:
  badges: true                # turn `status:*` code spans into badges (default true; per page: badges: false)
```

Labels come from `_data/i18n/<lang>.yml` (English is the fallback):

```yaml
callout: {note: Note, tip: Tip, important: Important, warning: Warning, caution: Caution}
tabs: {label: Install method}
status: {available: Available, partial: Partial, planned: Planned}
skip: Skip to content
```

### Layouts

| Layout | Use |
|---|---|
| `default` | HTML shell: stylesheet, skip link, site title, `md-tabs.js` |
| `doc` | Pages: alerts, badges, then optional sections |
| `twin` | Markdown twin stub: outputs the source body byte for byte |

### Customising

- Override design tokens in your own CSS, e.g. `:root { --md-accent: #c2410c; --md-measure: 52rem; }`. Light and dark values follow `prefers-color-scheme`. All tokens: [`_sass/modootoday/_tokens.scss`](_sass/modootoday/_tokens.scss).
- Add tags to `<head>` with your own `_includes/head-custom.html`.
- Replace the whole stylesheet by adding your own `assets/css/modootoday.scss`.

## Front matter rules

- **Every content page needs front matter**, even an empty one (`---` / `---`). On GitHub Pages, a Markdown file without front matter is rendered by `jekyll-optional-front-matter` *and* copied raw to `_site/<name>.md`. The checker reports it.
- `sections:` (optional) maps each `##` heading, in order, to a name or `{c: component, name: key, ...params}`. The number of items must equal the number of `##` headings. Without `sections:` the page is one `div.md-prose`.
- `badges: false` turns badges off for one page.

## Components

| Write in Markdown | Output |
|---|---|
| `> [!NOTE]` (also `TIP`, `IMPORTANT`, `WARNING`, `CAUTION`) at top level | `blockquote.md-callout.md-callout-note[role=note]` with a localised title |
| `` `status:available` `` / `partial` / `planned` | `span.md-badge.md-badge-<value>` (symbol + label) |
| text before the first `##` (with `sections:`) | `section.md-hero` |
| a `##` section | `section.md-section[data-section=<name>]`, plus `md-c-<c>` |
| `c: features` + list `- **Title** — text` | card grid |
| link-only paragraph in the hero or a `c: cta` section | buttons; the first link is the primary one |
| `c: tabs` + `### name` + code block, repeated | ARIA tabs (with JS); without JS all blocks stay visible |
| GFM table | horizontally scrollable table |

Not allowed in bodies (outside code): raw HTML, Liquid, kramdown IAL/ALD (`{: .x}`), header ids (`{#id}`), definition lists, alerts nested in lists, tables or quotes. Details: [RULES.md](RULES.md).

### Markdown twins (optional)

Next to `guide.md`, add `guide.md.txt`:

```yaml
---
layout: twin
twin_of: guide.md
permalink: /guide/index.md
---
```

The build then contains `/guide/index.md`, identical to the body of `guide.md`. Provide `llms.txt` and `llms-full.txt` at `/` and under each `/<lang>/`.

## Checker

```sh
bundle exec jekyll build
bundle exec modootoday-check . _site [--twins] [--github-pages[=232]] [--strict] [--gh]
```

| Flag | Checks |
|---|---|
| (always) | front matter present, forbidden syntax, `status:` values, `sections:` count, `_data/components.yml` (if present), unconverted markers in the build |
| `--twins` | twin stubs, byte-identical twins, per-language `llms.txt` / `llms-full.txt` |
| `--github-pages[=VER]` | `Gemfile.lock` pins `github-pages` VER (default 232) |
| `--strict` | warnings (e.g. unknown alert type `> [!FOO]`) fail the run |
| `--gh` | renders each page with `gh api markdown` (network, `gh` login) |

It uses only the Ruby standard library and exits 1 on problems.

## Example and development

```sh
BUNDLE_GEMFILE=gemfiles/jekyll4.gemfile bundle install
BUNDLE_GEMFILE=gemfiles/jekyll4.gemfile bundle exec rake   # Ruby tests + example build + checker
npm ci && npm test                                         # jsdom tests for md-tabs.js
```

Use `gemfiles/github-pages.gemfile` for the GitHub Pages stack. See [CONTRIBUTING.md](CONTRIBUTING.md).

## Versioning

The gem follows [Semantic Versioning](https://semver.org/); changes are listed in [CHANGELOG.md](CHANGELOG.md). Files copied from the theme carry a `md-components v1 (draft)` header so copies can be compared with the rules version.

## License

[MIT](LICENSE) © modootoday (모두의오늘)
