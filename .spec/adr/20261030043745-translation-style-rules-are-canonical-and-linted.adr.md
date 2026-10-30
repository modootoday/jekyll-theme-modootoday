---
id: adr:modootoday/20261030043745
title: "Translation style rules are canonical and linted"
status: active
created: 2026-10-30T04:37:45Z
updated: 2026-10-30T04:37:45Z
rel:
  governs: [docs, i18n/glossary.yml, script/i18n/lint.rb, script/i18n-build, TRANSLATING.md]
---

# Translation style rules are canonical and linted

## Context

The Korean and Japanese pages read as machine translation: a made-up word for the Markdown twin (쌍둥이, ツイン), transliterated jargon (인클루드, 브레드크럼, インクルード), calques (〜を持つ, ~를 가진), mixed 해요체 and 합니다체 on one page, inconsistent Japanese long vowels (サーバ/サーバー) and leftover English sample text. The glossary lived in TRANSLATING.md, nothing enforced it, and adr:modootoday/20261029220746 decision 3 asked for 해요체 although most Korean pages were already 합니다체.

## Decision

1. docs/guides/translation.md (with ko and ja versions) is the canonical rule set; i18n/glossary.yml is its machine-readable glossary with the wordings to avoid. TRANSLATING.md is only a contributor checklist. This replaces decisions 3 and 4 of adr:modootoday/20261029220746; its other decisions stay.
2. Register: Korean docs, READMEs and repository posts use 합니다체, as Microsoft, MDN and Mozilla Korean documentation do; Korean interface sentences use 해요체; labels and headings are noun phrases. Japanese uses です・ます with 体言止め labels; table cells and list fragments may be 常体. Sample pages (`noindex: true`) keep their genre voice.
3. Terms: the Markdown twin is "Markdown 버전" / "Markdown 版"; `front matter` and `include` stay in English; Korean follows the national spelling rules (내비게이션, 배지, 레이블); Japanese follows the JTF long-vowel spelling (サーバー, ブラウザー).
4. script/i18n-build --check runs script/i18n/lint.rb and fails on catalog key, placeholder and whitespace drift, glossary terms to avoid, calques, the wrong register and untranslated English sentences in ko/ja prose. The lint is dev-only and never runs in a site build.
5. Japanese keeps one half-width space between Japanese and Latin text, unlike JTF, for readability next to inline code.

## Consequences

Machine-translation tells become CI failures instead of review comments. Word order, idiom and tone still need human review against the rules page. The other 20 catalogs follow the same principles; their glossary columns are added only after a native reviewer signs off.
