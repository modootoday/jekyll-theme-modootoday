# Translating

English is canonical; Korean (`ko`) and Japanese (`ja`) are localized from it. The decision and its reasons are in the ADR "Translations are localized from English, not literal" under [`.spec/adr/`](.spec/adr/). This file is the working guide and glossary for contributors. It is not part of the user docs.

## Rules in short

- Say what the English page says, no more and no less. Rewrite each sentence the way a native technical writer would; never translate word for word.
- Korean: 해요체 in docs, 합니다체 only for formal notices. Japanese: です・ます体; headings, table cells and list fragments are noun phrases.
- Leave untouched: code blocks, inline code, paths, Liquid, front matter keys and theme-read values, component and section names, badge values, CSS classes, `--mt-*` tokens, config keys, commands, URLs, product names, `[!NOTE]`-style markers.
- No plural markers in ko/ja (no 들/たち on technical nouns). ASCII digits; versions and units as in English (`1.0.0`, 360 px). Prose dates: 2026년 10월 30일, 2026年10月30日.
- Korean: standard 띄어쓰기, ASCII punctuation, particle attached to code (`theme`를), quotes “ ”.
- Japanese: full-width 、。（）「」 in prose, no spaces between Japanese characters, one half-width space between Japanese and Latin text or code.
- Update translations in the same pull request as the English change, or list the pages left behind. Run `modootoday-check`: a translation key missing from `en.yml` is an error; a key or page missing from a translation is a warning and falls back to English.

## Glossary

Use exactly these words. "keep" means the English word or identifier stays as is.

| English | 한국어 | 日本語 | Notes |
|---|---|---|---|
| theme | 테마 | テーマ | |
| layout | 레이아웃 | レイアウト | file name stays `default`, `doc` |
| include | 인클루드 | インクルード | |
| component | 컴포넌트 | コンポーネント | |
| section | 섹션 | セクション | |
| slot | 슬롯 | スロット | |
| part (of a component) | 부분 | パーツ | |
| token (design token) | 토큰 | トークン | `--mt-*` kept |
| twin (Markdown twin) | 트윈 | ツイン | "Markdown 트윈", "Markdown ツイン" |
| front matter | front matter | front matter | keep |
| checker (`modootoday-check`) | 검사기 | チェッカー | command name kept |
| alert | 알림 | アラート | `[!NOTE]` markers kept |
| callout | 콜아웃 | コールアウト | |
| badge | 배지 | バッジ | |
| status: Available / Partial / Planned | 사용 가능 / 일부 구현 / 계획 | 利用可能 / 一部実装 / 予定 | badge labels |
| registry | 레지스트리 | レジストリ | `_data/components.yml` |
| page | 페이지 | ページ | |
| docs site | 문서 사이트 | ドキュメントサイト | |
| release | 릴리스 | リリース | |
| deprecated | 지원 중단 예정 | 非推奨 | |
| breaking change | 호환성이 깨지는 변경 | 破壊的変更 | |
| right-to-left (RTL) | 오른쪽에서 왼쪽(RTL) | 右から左（RTL） | |
| dark mode | 다크 모드 | ダークモード | |
| agent (AI agent) | 에이전트 | エージェント | |

## Interface strings

The theme's labels live in `i18n/<code>.yml`; `i18n/en.yml` is the registry of every key. A translation has the same keys and placeholders (`%{n}`) and only changes the values. Labels are short: 이 페이지 편집 / このページを編集, not full sentences. Use `.yml`, never `.yaml`.

After editing `i18n/*.yml`, run `rake i18n` (or `script/i18n-build`). It regenerates `_includes/modootoday/i18n/<code>.html`, the loader `_includes/modootoday/i18n.html` and `_includes/modootoday/t.html`; never edit those by hand. CI runs `script/i18n-build --check` and fails when they are stale or a catalog has missing keys or mismatched placeholders. Layouts and includes read labels only through these generated files, with no inline English.

## Adding a language

1. Add the language to `i18n/languages.yml` (code, endonym, English name, `dir`).
2. Copy `i18n/en.yml` to `i18n/<code>.yml`, set `language:` and `direction:` and localize the values.
3. Run `rake i18n` and `rake test`; the build test renders a page in every language.
4. Add a column to the glossary above.
5. For the docs site, also add `docs/_data/i18n/<code>.yml` with the docs-only keys (`title`, `description`, `tabs.label`) and translate at least `<code>/index.md` before listing the code in `modootoday.languages`. Check that the font covers the script.

## Languages

The docs target the 23 languages in `docs/_data/languages.yml`. Interface labels come from the theme catalogs; `docs/_data/i18n/<code>.yml` holds only docs-specific strings and deliberate overrides; a language is listed in `modootoday.languages` only when its home page is localized. Per-language tone notes are in the ADR. Never leave a page half-translated: until a page is fully localized, the language uses the labeled English fallback.
