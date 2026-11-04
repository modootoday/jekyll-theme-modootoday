---
nav_order: 60
nav_title: Migrate
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

A site that `jekyll new` made (minima) needs no other change: `layout: page` is the `doc` layout under that name, the home page lists the posts, the header lists `header_pages` or every top-level titled page, and posts show the site's `author:`. `modootoday-check` reports a layout that no site or theme file provides and names the replacement for Minimal Mistakes layouts such as `single` (`doc` or `post`) and `splash`.

Common mappings: just-the-docs `layout: default` becomes `layout: doc`; callouts made with an `include note.html` tag become `> [!NOTE]`; badges written in HTML become `` `status:available` `` code spans.

## Adopting in an existing project

| Method | Use when | Updates |
|---|---|---|
| Gem (`theme:`) | the site has a `Gemfile` (Jekyll 4 or the `github-pages` gem) | `bundle update jekyll-theme-modootoday` |
| `remote_theme:` | classic GitHub Pages without a `Gemfile` | change the `@vX.Y.Z` tag |
| Copy-in | you need to fork layouts or cannot add a dependency | copy `_layouts`, `_includes`, `_sass` and `assets` from a release tag; merge updates by hand |

Prefer the gem or `remote_theme:` pinned to a tag. With copy-in, record which version you copied. Copy-in loses upgrades and checker guarantees for the files you change.

## Markdown twins

Pick one of three ways to publish the agent-readable twin of each page:

- **Stub files** (default, classic GitHub Pages): one small `<page>.md.txt` per page.
- **Plugin** (Jekyll 4 or GitHub Actions): `plugins: [jekyll-theme-modootoday]` creates twins and `llms.txt` without stubs.
- **Source mode** (classic GitHub Pages, no stubs): `modootoday.twins: source` with pages that have no front matter. Classic GitHub Pages serves the raw copy as `text/markdown; charset=utf-8`, identical to the source (see RULES.md §5a for the limits).

Switching between them does not change page bodies. See [Agents](../agents/) and section 5a of `RULES.md`.

## From jekyll-seo-tag

To let the kit write the SEO tags instead of `jekyll-seo-tag`:

1. Remove `jekyll-seo-tag` from `plugins:` and the `Gemfile`, and the `seo` tag from `_includes/head-custom.html`.
2. Remove `seo: false` and `hreflang: true` from `modootoday:`. The kit writes the canonical link, the `hreflang` alternates and Open Graph again; delete any alternate links you added by hand, so no page lists them twice.
3. Set the browser bar colour with `modootoday.theme_color` (see [Configuration](../configuration/)). The kit writes two `theme-color` tags by default, one for light and one for dark; remove any `theme-color` tag of your own, or the page has three.
4. The kit writes only `twitter:card` (`summary_large_image` when the page has an image). It reads no `twitter:` setting; put a `twitter:site` meta tag in `_includes/head-custom.html` if you need one.
5. Rebuild and run `modootoday-check SRC _site`: the warning about jekyll-seo-tag JSON-LD should be gone.

## Upgrading

Read `CHANGELOG.md` for every version you skip. The [Public API](../../reference/api/) page lists the documented names. After upgrading, run `modootoday-check --strict`.

| From | To | What to do |
|---|---|---|
| a build from the repository before 1.0.0 | 1.0 | Pin `~> 1.0` or `@v1.0.0`. |
| 1.0 or 1.1 | 1.2 | Pin `~> 1.2` (with `remote_theme`, the newest `v1.2.x` tag). |
| 1.2 | 1.3 | Pin `~> 1.3` (with `remote_theme`, `@v1.3.0`). |
| 1.3 | 1.4 | Pin `~> 1.4` (with `remote_theme`, `@v1.4.1`). |
| 1.4 | 1.5 | Pin `~> 1.5` (with `remote_theme`, `@v1.5.0`). |

None of these upgrades needs page edits. What each one adds:

- 1.2: section and hero options (`bleed:`, `reveal:`, `c: split` with `visual:`), all opt-in.
- 1.3: the `reference` sidebar (`sidebar: true`) and package table (`packages:`), both opt-in.
- 1.4: `packages_compact` and `packages_position`, both opt-in; `reference` pages now convert alerts like `doc`.
- 1.5: the default look and the way pages load theme CSS and JavaScript change (see below).

If your pages come from a pre-1.0 draft that allowed fewer `sections:` items than `##` headings, add a plain name (such as `notes`) for each remaining heading: the count must now match, and `modootoday-check` reports the page and both numbers.

A `resume` or `links` page that sets `name:` showed its file name (`resume.md`) as the person's name, because Jekyll replaces `name:` on a page with the file name. Rename the key to `display_name:`; until you do, the title is shown and `modootoday-check` warns.

### The 1.5 look

1.5 makes the default style flat and neutral: a neutral gray ramp, an opaque 4rem header, no shadows except on menus and search results, plain bordered callouts, buttons and cards without lift, headings at weight 600 and body text at 1.75 line height. Headings are smaller and balanced (h1 2rem, h2 1.5rem, h3 1.25rem, at every width), Korean, Japanese and Chinese pages use a font stack of their own, and Japanese text breaks between phrases where the browser supports it. The token names are the same; only their values change. `modootoday.theme_color` now defaults to `#0a0a0a` in dark mode, the new page background. To keep the 1.4 colours, sizes and shadows, put the old values in the token bridge:

```scss
// _sass/modootoday/_site.scss
$mt-overrides-base: (heading-weight: 650, line-height: 1.7, measure: 46rem, container: 76rem, header-height: 3.75rem,
  space-section: 3rem);
$mt-overrides: (
  foreground: #1f2328, card-foreground: #1f2328, accent-foreground: #1f2328, muted: #f6f8fa, accent: #eff2f5,
  muted-foreground: #59636e, status-planned: #59636e, code-comment: #59636e, border: #d1d9e0,
  shadow-sm: 0 1px 2px rgba(31, 35, 40, 0.06), shadow: 0 6px 20px -6px rgba(31, 35, 40, 0.16)
);
$mt-overrides-dark: (
  background: #0d1117, primary-foreground: #0d1117, foreground: #e6edf3, card-foreground: #e6edf3,
  accent-foreground: #e6edf3, muted: #1a212b, card: #1a212b, accent: #151b23, muted-foreground: #9198a1,
  status-planned: #9198a1, code-comment: #9198a1, border: #3d444d,
  shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.3), shadow: 0 8px 24px -6px rgba(0, 0, 0, 0.5)
);
```

Set `modootoday.theme_color: {light: "#ffffff", dark: "#0d1117"}` as well. The header blur, the callout stripe and tint and the button lift are gone and come back only with your own `site_css`.

The header stays one 4rem row at every width. Below 64rem its links move into a menu button (`.mt-nav-sheet`), and the inline copies of group links (`.mt-nav-flat`) are gone, so rules a site wrote for `.mt-nav-flat` now target `.mt-nav-sheet`. Headings no longer set `scroll-margin-top`; anchors land below the header through `scroll-padding-top` on the page. The site name is now `span.mt-site-name` inside `.mt-site-title`: a long name takes a second line in the row (one step smaller below 64rem), and a word that still does not fit ends in an ellipsis instead of a cut letter, so rules a site wrote for the title's `white-space` or `text-overflow` now target `.mt-site-name`.

Callouts, quotes and figures follow the same flat style. A callout is a hairline box with 1rem padding whose type colour reaches only the 16px icon and the title. Body quotes have a 2px start rule (was 3px), and a `c: quote` section is no longer a filled card but a larger quote with the same rule. Figures, SVG figure frames and embeds have 8px corners (`radius`, was `radius-lg`), captions are 14/20, and an `.mt-illustration-tag` badge sits above the picture instead of over it. The callout rules leave the core sheet for `content/inline.css` and the figure and embed rules for `media/figure.css`, which only pages with one of them link; their partials keep the `components/core/inline/` paths, so a site that shadows one still changes it. With `modootoday.css: bundle` the core sheet still holds them.

Buttons, badges, tabs and cards follow the same flat style. A button is 40px tall (48px in a hero) with 14/20 text at weight 500, and the primary action (the first link of a hero or `c: cta` button row, and the first button of the marketing and detail layouts) is neutral: the foreground colour as fill and the background colour as text. The accent now fills nothing by default; to keep accent-filled buttons, set the new hooks in a site stylesheet: `:root { --mt-button-primary-bg: var(--mt-primary); --mt-button-primary-fg: var(--mt-primary-foreground); }`. Badges are 20px chips on the `accent` fill, a status badge shows its colour as a 6px dot, and a badge that is a link is no longer underlined. Tabs are 40px with a 2px foreground bar under the selected tab. Feature and link cards fit as many 16rem columns as the section holds (`cols-<n>` now counts the section's width, not the window's), and a link card draws its focus ring round the whole card. In the breadcrumb, each chevron ends the item before it.

Heroes and pricing are flat too. A hero title is `--mt-hero-title-size` (a new hook, default `clamp(2.5rem, 1.5rem + 3vw, 3.5rem)`) at weight 600, with -0.04em tracking in Latin text and none in Korean, Japanese and Chinese; the lead is 18/28 and at most 36rem wide. The showcase hero splits into two equal columns, puts a solid panel behind the text instead of a gradient, shows its second action as a text link and, below 48rem, gives the scene a full-width 16:9 band; in forced colours the photo and panel are hidden. Pricing plans (`c: pricing` and the `pricing` layout) form one bordered grid with hairline dividers: the recommended plan is the lighter cell with its label in the top corner (no 2px border), every plan's button spans the plan and sits at its bottom, and a grid narrower than 44rem stacks the plans. The selected Monthly/Yearly option is filled with the foreground colour.

Posts read on the `narrow` measure (40rem) at 18/28 (18/32 in Korean, Japanese and Chinese), with a title of `clamp(2.5rem, 2rem + 2vw, 3rem)`, and the tag footer no longer adds a second rule under the page meta line. Cover and body images have 8px corners and a hairline border. Post cards lose their box: the 16:9 cover has the corners and the border, the title is 18/28 at weight 600 and underlines on hover, the excerpt stops after two lines, and grid and magazine lists use 18rem columns with a 2rem gap. The blog list now shows the breadcrumb a post shows.

The footer has no fill and more room (3rem above, 2rem below), and the theme can now print one from `_data/nav/footer.yml` (see [Customize](../customize/#footer)). Search results mark the matched words, and the error layout shows a body paragraph of links as a row of chips; its status code is the foreground colour at weight 600 (was the accent at 800).

### How 1.5 pages load the theme

The core sheet keeps only the tokens, the base element rules, the header, the nav and the theme toggle. Every other component moved to a sheet that pages link only when they use it, right after the core sheet (code, callouts and badges, figures, the page footer navigation, the hero, the banner), and the context sheets moved to `assets/css/modootoday/<group>/<name>.css`. The rules and their order are the same, so pages look the same. Theme scripts are ES modules (`<script type="module">`) at `assets/js/modootoday/<group>/<name>.js`, and the header search loads on first use.

- If you shadow `assets/css/modootoday.scss`, copy the 1.5 version or delete your copy. An older copy still builds, but it keeps the moved components in the core sheet as well, so pages load those rules twice.
- If you link a theme sheet or script by hand (in `head-custom.html`, for example), use the new path, and `type="module"` for a script.
- If your stylesheets override a theme component, link them with `site_css`: it always comes after every theme sheet.
