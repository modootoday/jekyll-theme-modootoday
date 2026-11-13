# jekyll-theme-modootoday

A Jekyll theme that keeps page bodies in plain GitHub Markdown and styles them with layouts, includes and CSS.

[![CI](https://github.com/modootoday/jekyll-theme-modootoday/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/modootoday/jekyll-theme-modootoday/actions/workflows/ci.yml)
[![Gem Version](https://img.shields.io/gem/v/jekyll-theme-modootoday)](https://rubygems.org/gems/jekyll-theme-modootoday)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

[Documentation](https://modootoday.github.io/jekyll-theme-modootoday/) · [한국어](README.ko.md) · [日本語](README.ja.md)

## Why

- **Only standard Markdown in your pages.** GFM plus GitHub alerts; the same file reads well on github.com.
- **Works on GitHub Pages.** Layouts and includes are Liquid only, so `remote_theme` works on the classic build; Jekyll 4 works too.
- **Components without markup.** Alerts, status badges, card grids, tabs, buttons, accordion, steps, timeline and more come from plain Markdown patterns.
- **Page families.** Layouts beyond docs ([the full list](https://modootoday.github.io/jekyll-theme-modootoday/reference/api/#layouts)): home, blog and news, directory (team, jobs, events, sponsors, portfolio), detail pages, marketing (pricing, feature, contact, links), documents (legal, resume) and docs extras (reference, changelog, roadmap, glossary, course, book).
- **Sections that look designed.** `sections:` items take options such as `c: split` with a `visual:` include or code, full-width `bleed:` bands, `reveal:` fade-ins and four-column cards; a split hero works the same way.
- **23 languages, LTR and RTL.** Theme labels ship localized for 23 languages, with a language menu, `hreflang` and right-to-left layouts.
- **Readable by agents.** Every page can have a byte-identical Markdown twin, plus `llms.txt` and `llms-full.txt`.
- **Accessible.** Keyboard shortcuts, visible focus, safe areas on phones, 44 px touch targets, high contrast and reduced motion are built in.
- **Checked.** `modootoday-check` validates the sources and the built site.
- **Optional extras.** Search, a light/dark toggle, Mermaid diagrams and KaTeX math (off by default, loaded only on pages that use them), static diagrams and math from SVG files and MathML you commit, and schema.org JSON-LD.

## Install

As a gem (`theme:`):

```ruby
# Gemfile
gem "jekyll-theme-modootoday", "~> 1.7"
```

```yaml
# _config.yml
theme: jekyll-theme-modootoday
```

On GitHub Pages without a Gemfile (`remote_theme:`):

```yaml
# _config.yml
remote_theme: modootoday/jekyll-theme-modootoday@v1.7.0
plugins: [jekyll-remote-theme]
```

Pin a tag or a commit. The [Install guide](https://modootoday.github.io/jekyll-theme-modootoday/guides/install/) has the minimal configuration, the checker and the starter sites.

## Quick start

```sh
mkdir my-docs && cd my-docs
printf 'source "https://rubygems.org"\ngem "jekyll", "~> 4.4"\ngem "jekyll-theme-modootoday", "~> 1.7"\n' > Gemfile
printf 'theme: jekyll-theme-modootoday\nmarkdown: kramdown\nkramdown: {input: GFM}\nsass: {style: compressed, silence_deprecations: [import, global-builtin]}\n' > _config.yml
printf -- '---\nlayout: doc\ntitle: Home\n---\n# Hello\n\n> [!TIP]\n> Plain Markdown, styled.\n' > index.md
bundle install && bundle exec jekyll build
bundle exec modootoday-check . _site
```

Walkthrough: [Write your first page](https://modootoday.github.io/jekyll-theme-modootoday/guides/first-page/).

## Concepts

- **Plain body, rich layout.** The body is GFM; `sections:` front matter maps each `##` to a component. See [Components](https://modootoday.github.io/jekyll-theme-modootoday/components/) and the [kitchen sink](https://modootoday.github.io/jekyll-theme-modootoday/components/kitchen-sink/).
- **Rules.** What may appear in a body, and what each pattern becomes, is defined in [RULES.md](RULES.md) (`md-components v1`).
- **Plain Jekyll first.** A site `jekyll new` made builds once the theme line in `_config.yml` and the theme gem in the `Gemfile` (in place of `gem "minima"`) change: `layout: page`, the home post list, `header_pages` or titled pages in the header, and `author:` in every shape. See [Migrate and upgrade](https://modootoday.github.io/jekyll-theme-modootoday/guides/upgrade/).
- **Settings and tokens.** One `modootoday:` block in `_config.yml`, CSS custom properties `--mt-*` that a site sets from one Sass hook (`_sass/modootoday/_site.scss`, no inline style), one Sass partial per component. See [Configuration](https://modootoday.github.io/jekyll-theme-modootoday/guides/configuration/) and [Customize](https://modootoday.github.io/jekyll-theme-modootoday/guides/customize/).
- **Blog and news.** `blog`, `news`, `news-article`, `author` and `feed` layouts: paginated card lists (list, grid, magazine), bylines from `_data/authors.yml`, series, related posts, share, JSON-LD, per-language Atom feeds; Liquid only, styles and script in an optional bundle. See [Blog and news](https://modootoday.github.io/jekyll-theme-modootoday/layouts/blog-news/).
- **Pages from data.** `modootoday.records` gives every record of a `_data` file its own page on classic Pages: `modootoday-stubs --records` writes one front-matter-only page per record, a directory page with `records:` lists them, and `modootoday-check --byte-exact=api` proves a folder is published byte for byte. See [Generated pages](https://modootoday.github.io/jekyll-theme-modootoday/recipes/generated-pages/).
- **Twins.** Every page can have a Markdown twin for agents, published in one of three ways; see [AI agents](#ai-agents) below.

## Commands

Both commands are also listed on the [Command line](https://modootoday.github.io/jekyll-theme-modootoday/reference/cli/) page. `modootoday-check SRC SITE [options]` (run after `jekyll build`):

<!-- commands:begin (generated by script/readme-commands; do not edit) -->
| Option | Checks |
|---|---|
| `SRC SITE` | always: front matter, forbidden syntax, alerts, fence info strings, `status:`/`tag:`/`kbd:` values (`since:` is rejected), `sections:` count, `feed:` (false, or a site path to an Atom feed page in the build), `_data/i18n/<lang>.yml` keys against the default language and translated pages against default-language pages, `_data/components.yml` (keys, slot contract counts per section, `parts` against `api.md` and the built HTML), Sass/CSS rules, the token hook `_sass/modootoday/_site.scss` (only the three override maps, known token names), `site_css`, `preload` and `scripts` files present in the build, `script:` and `poster:` on hero and section items (a registered script, a sized poster that exists), `filter:` on section items and pages (a list or table to filter, a `facet` column the table has), `chart:` lines and `c: chart` sections (a type and options, a table or a `_data/charts` file, number cells), `widget:` lines, `widget_props` and `c: widget` sections (an element a `modootoday.scripts` entry defines, plain prop values, a lead paragraph), `diagrams:` (an entry per Mermaid fence, `alt`, the SVG files, an SVG drawn from another fence), static math (an entry per math block in `_data/math`, entries rendered from other TeX, no inline math),`modootoday.search` keys and collections, `modootoday.showcase` (also in `_config.demo.yml`) and, while it is enabled, the robots `noindex` on every built page (warning), `search.json` over 1.5 MB (warning), unconverted markers in the build, schema.org JSON-LD in the build (valid JSON, vocabulary, required properties per type, absolute URLs, ISO 8601 dates, one graph per page, agreement with Open Graph, a `DefinedTerm` page's `term_set` glossary), `modootoday.schema.faq`, `modootoday.records` (a page per record and a record per page, as `modootoday-stubs --records --check` judges), `modootoday.pwa` (its keys and icons, the stub `modootoday-stubs --pwa` writes, the built manifest's fields, icon files and their PNG sizes, the manifest link on every page) |
| `--twins` | every page has a byte-identical Markdown twin, per-language `llms.txt` and `llms-full.txt` |
| `--links` | same-site links in the built HTML (`a`, `link`, `img`, `script`, `source srcset`) point at files that exist and `#` fragments match an `id` or `a[name]` on the target page; external URLs are not fetched. Warnings, failures with `--strict`; needs the nokogiri gem |
| `--aliases` | the URL aliases `modootoday.aliases` declares: `/<page>.md` byte-identical to the twin (`md`), `/<page>.html` redirecting to the page with the page URL as canonical (`html`); two pages with one alias, or an alias over another source file, fail |
| `--byte-exact=DIR,...` | files under these source folders (an API, downloads) are in the build with the same sha256; a folder under `_` or `.` or excluded, a file with front matter, or one Jekyll converts (Markdown, Sass) fails |
| `--github-pages[=VERSION]` | `Gemfile.lock` pins `github-pages` VERSION (default 232) |
| `--schema-recommended` | also warn about schema.org properties Google Search recommends (author, image, dates, ...) that a JSON-LD node lacks |
| `--strict` | warnings fail the run |
| `--i18n` | `_data/i18n/<lang>.yml` against the theme registry (`i18n/en.yml` in the gem): unknown keys, `%{name}` placeholder mismatches, and pages marked `translation: pending` |
| `--i18n-pages` | warn about default-language pages with no translation in a `modootoday.full_languages` language (the page with the same `ref:`, else `<name>.<lang>.md` beside it or the same path under `<lang>/`) and about translations without `source_rev` or whose source changed since it; with `--strict` they fail. A translation beside its source whose `permalink` is not the source's URL under `/<lang>` is an error |
| `--i18n-init=LANG,...` | copy the theme's catalogs (`i18n/<lang>.yml`, 23 languages) into `SRC/_data/i18n/` as a starting point for overrides (optional; the theme already uses them), and list keys an existing catalog lacks |
| `--diagrams` | instead of checking, print the static diagrams whose SVG is missing or stale as JSON (`page`, `name`, `line`, `fence`, `digest`, `files`, `reason`) and exit 1 when there is any; SITE may be omitted. A pre-commit hook or a render script reads it |
| `--math` | with `modootoday.math.mode: static`, instead of checking, print the `_data/math` files whose page has math blocks without an entry or with a stale one as JSON (`key`, `file`, `page`, `blocks` with `line`, `tex` and `digest`, `reason`) and exit 1 when there is any; SITE may be omitted. `script/figures/math.mjs` reads it |
| `--gh` | also render each page with `gh api markdown` (network, `gh` login) |
| `--help, -h` | print usage and options (`--help=markdown` prints the README table) |
| `--version` | print the rules version |
<!-- commands:end -->

`modootoday-stubs SRC [options]` (writes the stub pages for twins, URL aliases and record pages; run before `jekyll build`):

<!-- stubs:begin (generated by script/readme-commands; do not edit) -->
| Option | Does |
|---|---|
| `SRC` | the site source; without `--write` or `--check` nothing is written and the planned creates, updates and deletes are listed |
| `--twins` | a stub `<name>.md.txt` per page (`layout: twin`) for its twin at `/<name>/index.md` |
| `--aliases` | the aliases `modootoday.aliases` turns on: `md` a stub `<name>.flat.md.txt` (`layout: twin`) at `/<name>.md`, `html` a stub `<name>.html.md.txt` (`layout: redirect`) at `/<name>.html` |
| `--records[=SET,...]` | a page `<dir>/<key>.md` per record of each set in `modootoday.records` (or only the named sets): front matter only, with the title, description, permalink and `record:` the layout reads |
| `--pwa` | the files `modootoday.pwa` needs (with `enabled: true` or `kill`): `manifest.webmanifest`, the service worker `sw.js` and the offline pages `offline.md` and `offline.<lang>.md` for each `full_languages` entry; never pruned, and a site file already at one of those paths is never overwritten |
| `--write` | write the planned stubs; files whose content is already right are not touched |
| `--check` | write nothing; exit 1 when a stub is missing, out of date or orphaned |
| `--no-prune` | keep orphan stubs (by default a twin stub whose page is gone, an alias stub no page wants, or a record page whose record is gone, is deleted) |
| `--json` | print the plan as JSON (`mode`, `kinds`, `changes` with `path`, `action`, `reason`) |
| `--quiet` | print only drift found by `--check` and errors |
| `--help, -h` | print usage and options (`--help=markdown` prints the README table) |
| `--version` | print the version |
<!-- stubs:end -->

## AI agents

- Each page `guide.md` has a twin at `/guide/index.md` with the same bytes as its body, linked with `rel="alternate" type="text/markdown"`.
- `llms.txt` and `llms-full.txt` exist at `/` and under each `/<lang>/`.
- Jekyll 4: `plugins: [jekyll-theme-modootoday]` creates them; the classic GitHub Pages build uses one-file stubs, which `modootoday-stubs SRC --twins --write` writes.
- Optional URL aliases (`modootoday.aliases`): `/guide.md` (the twin again) and `/guide.html` (a redirect to `/guide/`), from `modootoday-stubs SRC --aliases --write`.
- Details, including source mode (front-matter-less pages, no stubs): the [AI agents guide](https://modootoday.github.io/jekyll-theme-modootoday/guides/agents/), the contract in [RULES.md §5a](RULES.md#5a-markdown-twins), and this repository's own [llms.txt](https://modootoday.github.io/jekyll-theme-modootoday/llms.txt).

## Guides

- [Documentation site](https://modootoday.github.io/jekyll-theme-modootoday/) (built with this theme from [`docs/`](docs/))
- [Install](https://modootoday.github.io/jekyll-theme-modootoday/guides/install/) · [First page](https://modootoday.github.io/jekyll-theme-modootoday/guides/first-page/) · [Components](https://modootoday.github.io/jekyll-theme-modootoday/components/) · [Configuration](https://modootoday.github.io/jekyll-theme-modootoday/guides/configuration/) · [Customize](https://modootoday.github.io/jekyll-theme-modootoday/guides/customize/) · [Layouts](https://modootoday.github.io/jekyll-theme-modootoday/layouts/) · [Blog and news](https://modootoday.github.io/jekyll-theme-modootoday/layouts/blog-news/) · [Recipes](https://modootoday.github.io/jekyll-theme-modootoday/recipes/) · [Math and diagrams](https://modootoday.github.io/jekyll-theme-modootoday/recipes/figures/math-diagrams/) · [Charts](https://modootoday.github.io/jekyll-theme-modootoday/recipes/figures/charts/) · [Widgets](https://modootoday.github.io/jekyll-theme-modootoday/recipes/figures/widgets/) · [Generated pages](https://modootoday.github.io/jekyll-theme-modootoday/recipes/generated-pages/) · [Search](https://modootoday.github.io/jekyll-theme-modootoday/recipes/search/) · [Brand tokens](https://modootoday.github.io/jekyll-theme-modootoday/recipes/brand-tokens/) · [AI agents](https://modootoday.github.io/jekyll-theme-modootoday/guides/agents/) · [Translation rules](https://modootoday.github.io/jekyll-theme-modootoday/guides/translation/) · [Structured data](https://modootoday.github.io/jekyll-theme-modootoday/guides/structured-data/) · [Public API](https://modootoday.github.io/jekyll-theme-modootoday/reference/api/) · [Command line](https://modootoday.github.io/jekyll-theme-modootoday/reference/cli/) · [Migrate and upgrade](https://modootoday.github.io/jekyll-theme-modootoday/guides/upgrade/) · [CSP](https://modootoday.github.io/jekyll-theme-modootoday/recipes/csp/) · [Accessibility](https://modootoday.github.io/jekyll-theme-modootoday/guides/accessibility/) · [Performance](https://modootoday.github.io/jekyll-theme-modootoday/guides/performance/) · [Roadmap](https://modootoday.github.io/jekyll-theme-modootoday/reference/roadmap/) · [Changelog](https://modootoday.github.io/jekyll-theme-modootoday/reference/changelog/) ([CHANGELOG.md](CHANGELOG.md))
- Supported stacks: classic GitHub Pages and Jekyll 4, with the versions listed in [Install > Requirements](https://modootoday.github.io/jekyll-theme-modootoday/guides/install/#requirements).
- [Security policy](SECURITY.md) · [Code of conduct](CODE_OF_CONDUCT.md)

## Exit codes

| Code | Meaning |
|---|---|
| 0 | no problems (`modootoday-stubs`: nothing to do, previewed or written) |
| 1 | problems found (listed on stderr) or bad usage (`modootoday-stubs`: `--check` found drift) |
| 2 | `modootoday-stubs`: bad usage or a `_config.yml` error |
| 3 | `modootoday-stubs`: a data error (front matter, unsafe permalink, alias conflict, a record without a key or with a duplicate key) |

## Contributing

Issues and pull requests are welcome. English is the canonical language; translations follow it. See [CONTRIBUTING.md](CONTRIBUTING.md).

The three starter sites, `docs`, `blog` and `landing`, are template repositories with live demos, listed in `example/starters.yml` and held in [`example/`](example/) as git submodules (clone with `--recurse-submodules`). `bundle exec rake starters:render` writes each one for GitHub Pages (`remote_theme`) and Jekyll 4, with its `Gemfile`, `README.md`, a Pages workflow that runs `modootoday-check`, and its stubs.

## License

[MIT](LICENSE) © modootoday (모두의오늘)
