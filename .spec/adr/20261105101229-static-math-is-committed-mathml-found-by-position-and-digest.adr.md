---
id: adr:modootoday/20261105101229
title: "Static math is committed MathML found by position and digest, with math.base for the self-hosted loader"
status: active
created: 2026-11-05T10:12:29Z
updated: 2026-11-05T10:12:55Z
rel:
  governs: [lib/modootoday/check/page/figures/math_static.rb, _includes/modootoday/markdown/figures/math.html, script/figures/math.mjs]
  depends_on: [adr:modootoday/20261105075445, adr:modootoday/20261105092848]
---

# Static math is committed MathML found by position and digest, with math.base for the self-hosted loader

## Context

adr:modootoday/20261105075445 made committed renders a theme feature for diagrams and named static math blocks as the next user of its digest rule. The math loader needs KaTeX's script, stylesheet and fonts on every page with math, from a CDN or a self-hosted copy that took four keys to declare. The old recipe also claimed that KaTeX's static HTML passes `style-src 'self'`; it does not, because KaTeX writes `style` attributes.

## Decision

- **`modootoday.math.mode: client | static`, default `client`.** `static` applies unless `enabled: false`; it needs no `enabled`, `src` or `integrity`, and no loader script runs.
- **Blocks are found by position, like diagrams.** The n-th ```` ```math ```` fence or `$$` block of a page (kramdown prints a block as `\[` at the start of a line) is replaced by the `html` of the n-th entry of `_data/math/<key>.yml`, a list of `{src, html}`. A block without an entry stays TeX. The Liquid part is `markdown/figures/math.html`, called through `markdown/figures.html` only on pages whose body has a math block, so other pages build unchanged.
- **`<key>` is the default-language source path without its extension, with `/` as `--`.** Translations share the English page's file, so one render serves every language and a translation with other TeX is reported as stale. Front matter `math_key:` overrides it. `Modootoday::Figures.math_key` owns the rule; the Liquid copy follows `I18n::PageLang` (a `.<lang>` suffix, a `<lang>/` folder, `home/`) and a build test on a translation holds them together. A key outside `[A-Za-z0-9_-]` is an error, since Jekyll drops other characters from data file names.
- **`src` is the digest of the block's TeX** by the rule of 20261105075445 (for `$$`, the text between the delimiters without blockquote markers or indentation, trimmed). `Modootoday::Figures.math_blocks` is the only parser; `modootoday-check SRC --math` prints the files to write as JSON (`key`, `file`, `page`, `blocks` with `line`, `tex`, `digest`, `reason`), choosing the default-language page of each key, so renderers never parse Markdown.
- **MathML is the default output.** `script/figures/math.mjs` (repository only) renders the list with KaTeX `output: "mathml"` in Node and keeps only the `<math>` element: no `style` attribute, stylesheet or font, so `style-src 'self'` holds and no browser is needed to render. KaTeX 0.19.0 is a pinned devDependency (newest release older than two weeks, outside every published KaTeX advisory range). `--output=htmlAndMathml` stays possible: the theme then links `css` (or the `base` stylesheet) only on pages whose entries hold `katex-html`, and the CSP needs `style-src 'unsafe-inline'`; the checker reports KaTeX HTML without a stylesheet.
- **Output: `figure.mt-figure.mt-math > div.mt-figure-scroll[role=region][tabindex=0]`,** the diagram figure's shape, with the region named by the new label `math.label` ("Formula [n]", numbered so several regions on a page keep unique names). The plan's bare `div` was dropped after the remote render: kramdown prints no paragraph around a block, so the formulas touched each other and the next paragraph; the figure's existing margin spaces them. The class string starts with the figure row's trigger and the figure sheet already styles `.mt-figure-scroll`; the page links that sheet as diagram pages do. The plan's 0 bytes became one rule, `.mt-math > .mt-figure-scroll { padding-block: .5em }`, beside the region's own rule in the `figure-svg` part: with a fallback math font the glyphs pass the `<math>` box, so the region scrolled vertically by a few pixels and clipped them once scrolled or focused. The figure sheet grows by 15 bytes gzip (816 to 831 of its unchanged 896 cap); the core sheet is unchanged.
- **Inline math cannot be static.** In static mode `$…$` and `$$…$$` inside a sentence are checker errors naming the line, and `inline: true` is a configuration error.
- **`math.base`** (a site path) stands for `src`, `css` and `auto_render_src` as KaTeX's `dist/` folder lays them out; a key set explicitly wins. Being a site path, it needs no SRI.

## Consequences

A site with static math ships no script, stylesheet or font for it and passes a strict CSP; the docs site uses it on the Math and diagrams recipe. MathML is drawn by the browser with its own math font, so formulas look slightly different across browsers and fonts. On a static-math page, a code block line starting with `\[` would be taken for a block; the recipe says so. Authors run one command after editing a formula, and the full check fails until they do.
