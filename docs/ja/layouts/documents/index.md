---
title: 文書
description: 法的なページと印刷優先の履歴書です。
nav_order: 60
---
# 文書

印刷したり保管したりするページ向けの 2 つのレイアウトです。どちらも紙ではサイトのヘッダー、フッター、バナーを隠します。

| レイアウト | front matter | バンドル | 構造化データ | デモ |
|---|---|---|---|---|
| `legal` | `effective`（必須）、`updated`、`version`、`toc: false` | pages | 日付付きの WebPage | [規約](/jekyll-theme-modootoday/ja/layouts/documents/legal/) |
| `resume` | `name`、`headline`、`email`、`phone`、`location`、`links`、`experience`、`education`、`skills` | resume | ProfilePage + Person | [履歴書](/jekyll-theme-modootoday/ja/layouts/documents/resume/) |

## 法的ページ

```yaml
---
layout: legal
effective: 2026-01-01
updated: 2026-10-30
---
```

目次は本文の `##` と `###` の見出しから作られ、`toc: false` で隠せます。日付は `datePublished` と `dateModified` になります。

## 履歴書

```yaml
experience:
  - {role: リードエンジニア, org: Example Docs, start: 2024-03-01}
education:
  - {degree: 学士, school: Example University, end: 2019-02-01}
skills:
  - {group: 言語, items: [Ruby, JavaScript]}
```

`end` のない項目は「現在」と表示され、Person の `worksFor` になります。学校は `alumniOf`、スキルは `knowsAbout` になります。マークアップには h-card クラスも付きます。まず A4 と Letter の用紙に合わせて配置し、画面ではリフローします。
