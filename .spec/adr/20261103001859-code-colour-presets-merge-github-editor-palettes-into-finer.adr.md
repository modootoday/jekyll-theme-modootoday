---
id: adr:modootoday/20261103001859
title: Code colour presets merge GitHub editor palettes into finer code tokens that default to the old colours
status: active
created: 2026-11-03T00:18:59Z
updated: 2026-11-03T09:26:19Z
rel:
  governs: [_sass/modootoday/tokens/_code-presets.scss, _sass/modootoday/base/_code.scss, lib/modootoday/check/config/keys/appearance/tokens.rb]
---

# Code colour presets merge GitHub editor palettes into finer code tokens that default to the old colours

## Context

Code blocks used five tokens (`code-keyword`, `code-string`, `code-comment`, `code-function`, `code-constant`), with variables, attributes and numbers sharing `code-constant` and tags sharing `code-keyword`. Sites that document code want the look readers know from GitHub, and a palette needs more than five slots to reproduce it. The default look must not move.

## Decision

- Ten finer tokens join the five: `code-background`, `code-foreground`, `code-variable`, `code-type`, `code-number`, `code-operator`, `code-tag`, `code-attribute`, `code-inserted`, `code-deleted`. Each default points at the token its Rouge classes used before (`var(--mt-code-constant)`, `var(--mt-tip)`, ...), so computed colours stay the same. They sit in both colour maps, like `link`, so a light-only override cannot leak into dark mode.
- `code-foreground` defaults to `currentColor`: `pre` and `.o` had no colour rule and inherited it, and code blocks inside accordions, cards or quotes inherit a muted colour. `currentColor` keeps that; `var(--mt-foreground)` would not. `code-background` defaults to `var(--mt-muted)`, the old `pre` background.
- `base/_code.scss` maps the Rouge classes to the tokens; `test/theme/tokens/code_tokens_test.rb` holds the table and checks every class against its old colour. `.kt` (keyword types) stays a keyword, as GitHub colours storage types; `.nv` keeps no rule, as GitHub leaves plain variables in the text colour.
- `modootoday.code_theme: theme | github` reaches Sass as `$mt-code-theme` (Liquid in `assets/css/modootoday.scss`, `!default` `theme` in `_settings.scss`). `tokens/_code-presets.scss` merges the preset maps into `$mt-light` and `$mt-dark` after `_semantic.scss` and before `tokens/_merge.scss`, so the token bridge still overrides a preset colour.
- The `github` values are taken from `github-light-default` and `github-dark-default` in tm-themes 1.12.12 (MIT), the palettes github.com uses, not the older `github-light`/`github-dark`. The background is the editor background (`#ffffff`, `#0d1117`): on the lighter `#f6f8fa` the light comment colour `#6e7781` is 4.27:1, under AA; on white it is 4.55:1. The goal is the palette, not pixel parity, since Rouge classes tokens differently from TextMate scopes.
- The key lives in `config/keys/tokens.rb` (that directory holds its 12-file limit). `modootoday-check` warns when `github` is set and the site highlights with something other than Rouge.

## Consequences

The default theme renders the same; the core sheet grows by the ten custom properties in `:root` and the two dark-scheme rules. The docs QA measures every code colour against `code-background` at 4.5:1 on the default palette, the brand recipe and a GitHub demo page in both schemes. `tokens.json` lists the new tokens as aliases, and `code-foreground` as the colour keyword `currentColor`.
