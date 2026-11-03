---
id: adr:modootoday/20261103222336
title: Korean body text uses break-word instead of anywhere
status: active
created: 2026-11-03T22:23:36Z
updated: 2026-11-03T22:24:04Z
rel:
  governs: [_sass/modootoday/base/_prose.scss]
---

# Korean body text uses break-word instead of anywhere

## Context

Korean running text uses `word-break: keep-all`, so a line breaks between words, not between syllables. The core sheet paired it with `overflow-wrap: anywhere` on `:lang(ko)`, so a word longer than its line could still break. Two side effects showed up in the table research of 2026-11-03 (live docs site, 360 and 390px):

- `anywhere` also lowers an element's min-content width to one glyph. A table column holding Korean text then shrinks instead of overflowing: the key column of the configuration table was 49px wide, `badges` broke letter by letter and a description cell grew to 26 lines.
- `:lang(ko)` matches every element of a Korean page, not only the one carrying `lang`, so it re-sets both properties on each element. A table cell or a code element cannot change them for its descendants by inheritance.

## Decision

- The rule becomes `[lang|="ko"] { word-break: keep-all; overflow-wrap: break-word; }`. It applies to the element that carries the language (`html`, or a `lang="ko"` island) and its descendants inherit it.
- `break-word` still breaks a word that would overflow its line, but it does not change min-content widths, so tables and shrink-to-fit boxes size by whole words and scroll when they must.
- Japanese keeps `line-break: strict` and `word-break: auto-phrase`; headings keep their CJK tracking through `:lang()`.
- The 1.2.2 choice of `overflow-wrap: anywhere` for inline code (CHANGELOG 1.2.2) stays outside tables; inside table cells the table work replaces it.

## Consequences

Korean table columns no longer collapse to one syllable; wide tables scroll inside their wrapper instead. A flex or grid item with `min-width: auto` that holds a single unbroken Korean phrase longer than its box can now grow with it; the theme's grids use `minmax(0, ...)` tracks, and the docs QA (cjk-clip on the Korean and Japanese home heroes at 360px, horizontal overflow at every width) watches for it. The core sheet changes by a few bytes.
