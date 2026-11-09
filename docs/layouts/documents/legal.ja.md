---
lang: ja
permalink: /ja/layouts/documents/legal/
source_rev: sha256:ff251ffedd04
title: 規約のレイアウト
description: "日付、版、目次の付いた規約やポリシーのページです。印刷を前提にしています。"
layout: layout-reference
nav_order: 1
twin: true
---
# 規約のレイアウト

`layout: legal` は、利用規約やプライバシーポリシーのように保管したり印刷したりするページに使います。本文の上に施行日、最終更新日、版を表示し、`##` と `###` の見出しから目次を作ります。印刷時にはサイトのヘッダー、フッター、バナーを隠します。ライブデモは landing スターターのプライバシーポリシーです。

## Front matter

| キー | 用途 |
|---|---|
| `effective` | 施行日、`YYYY-MM-DD`（必須） |
| `updated` | 最終更新日 |
| `version` | 版の表示（`"3"` など） |
| `toc` | `false` で目次を隠します |

```yaml
---
title: Privacy policy
layout: legal
effective: 2026-01-01
updated: 2026-10-30
version: "1"
---
```

日付はページの構造化データの `datePublished` と `dateModified` になります。履歴書のレイアウトは[ドキュメント](../)で説明しています。
