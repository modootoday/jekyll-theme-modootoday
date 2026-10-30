---
title: Translation rules
nav_order: 90
description: The canonical style rules, glossary and lint for the Korean and Japanese docs and interface strings.
---
# Translation rules

English is the source. Korean (`ko`) and Japanese (`ja`) pages, `README.ko.md`, the example site and the interface catalogs in `i18n/<code>.yml` are localized from it. This page is the single set of rules; `i18n/glossary.yml` is its machine-readable glossary, and `script/i18n-build --check` enforces both.

## Principles

- Say what the English page says, no more and no less. When they disagree, English wins and the translation is fixed.
- Localize, do not transliterate. Rewrite each sentence the way a native technical writer would: natural word order, the language's own sentence length, no stacked nouns copied from English.
- One concept, one word. Use the glossary term every time, on every page.
- Prefer the standard word over the jargon a few developers use. When a native word is clearer than a loanword, use it ("이동 경로", not "브레드크럼").
- Keep identifiers as they are: code, inline code, paths, Liquid, front matter keys and theme-read values, component and section names, badge values, CSS classes, `--mt-*` tokens, configuration keys, commands, URLs, product names and the `[!NOTE]`-style markers.

## Register

| Text | 한국어 | 日本語 |
|---|---|---|
| Docs, README, repository posts | 합니다체 (instructions may use ~하세요) | です・ます |
| Interface sentences (`i18n/*.yml`) | 해요체 | です・ます |
| Labels, buttons, headings | noun phrase | 体言止め |
| Table cells, list fragments | noun phrase or 합니다체 | 体言止め or 常体 |
| Sample pages (`noindex: true`) | the genre's own voice | the genre's own voice |

Korean docs use 합니다체 because it is the register of Korean reference documentation (Microsoft, MDN, Mozilla) and was already the majority on this site. Interface messages use the softer 해요체 common in Korean product UI. Never mix registers inside one page.

## Korean

- Standard spelling and spacing (국립국어원 표준국어대사전, 외래어 표기법): 내비게이션, 배지, 레이블, 사용자.
- No calques: "~를 가진", "~에 의해", "되어지다", "~하는 것이 가능합니다", "~에 대해서", "~것이 필요합니다". Write "~가 있는", the active voice, "~할 수 있습니다", "~해야 합니다".
- Drop English plurals; do not add 들 to technical nouns.
- Particles attach to code with no space and follow its pronunciation: `theme`을, `index.md`를.
- ASCII punctuation; quotes “ ”.

## Japanese

- JTF style guide spelling. Loanwords ending in -er, -or, -ar keep the long vowel: サーバー, ブラウザー, フォルダー, パラメーター, ヘッダー, フッター, ユーザー.
- No calques: "〜を持つ" for "has", "〜することが可能です", "〜によって行われる". Write "〜がある", "〜できます", the active voice.
- Full-width 、。（）「」 in prose. One half-width space between Japanese and Latin words or inline code; JTF omits it, this site keeps it for readability next to code.

## Numbers and dates

ASCII digits with the language's grouping (1,000). Prose dates: 2026년 10월 30일, 2026年10月30日; machine dates stay ISO 8601. Versions and units as in English (`1.0.0`, 360 px).

## Glossary highlights

The full list, with the wordings to avoid, is in `i18n/glossary.yml`.

| English | 한국어 | 日本語 | Avoid |
|---|---|---|---|
| Markdown twin | Markdown 버전 | Markdown 版 | 쌍둥이, 트윈, ツイン, 双子 |
| front matter | front matter | front matter | 머리말, 프런트 매터, フロントマター |
| include | include | include | 인클루드, インクルード |
| breadcrumb | 이동 경로 | パンくずリスト | 브레드크럼, ブレッドクラム |
| checker | 검사기 | チェッカー | 체커 |
| navigation | 내비게이션 | ナビゲーション | 네비게이션 |
| repository | 저장소 | リポジトリ | 레포지토리 |
| screen reader | 스크린 리더 | スクリーンリーダー | 화면 낭독기 |
| component | 컴포넌트 | コンポーネント | 部品 |

## Interface strings

Catalogs keep every key of `i18n/en.yml` and every placeholder (`[n]`, `[total]`, `[section]`, `%{x}`); only values change. Labels are short noun phrases. After an edit run `script/i18n-build` to regenerate the Liquid catalogs.

## What the lint checks

`script/i18n-build --check` runs `script/i18n/lint.rb` and fails on:

- catalogs: missing or unknown keys, empty values, leading or trailing spaces, placeholder mismatches, 합니다체 in Korean interface sentences;
- ko and ja pages, READMEs, posts and example pages, outside code: glossary terms to avoid, calques, the wrong register (해요체 or 한다체 in Korean docs, 常体 sentences in Japanese prose) and untranslated English sentences.

Style the lint cannot judge (word order, idiom, tone) is checked in review against this page.

## Other languages

The other 20 catalogs follow the same principles. A term joins the glossary for a language once a native reviewer approves it.

The docs site lists all 23 languages in the language menu. For the 20 languages beyond English, Korean and Japanese, only the home page is localized. It links to the English guides and says so in a note at the end, and the sidebar shows the English menu. A page is translated whole or not at all.

## Sources

- [Microsoft localization style guides](https://learn.microsoft.com/globalization/reference/microsoft-style-guides) (Korean and Japanese)
- [MDN translated content guidelines](https://github.com/mdn/translated-content) and the Korean team notes
- [Mozilla Korean style guide](https://mozilla-l10n.github.io/styleguides/ko/)
- [JTF 日本語標準スタイルガイド](https://www.jtf.jp/tips/styleguide)
- [Toss technical writing guide](https://technical-writing.dev/)
- [국립국어원 한국어 어문 규범](https://kornorms.korean.go.kr/)
- [Google developer documentation style guide](https://developers.google.com/style)
- [W3C Internationalization](https://www.w3.org/International/)
