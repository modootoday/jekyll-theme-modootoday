---
lang: ja
permalink: /ja/recipes/figures/
source_rev: sha256:e242e2dd1f34
title: 図とウィジェット
description: ダイアグラム、数式、グラフをスクリプトなしでも表示される図にし、独自のインタラクティブな要素を代わりのテキストと一緒に配置するレシピをまとめました。
nav_order: 10
---
# 図とウィジェット

これらのレシピは、GitHub がそのまま理解する Markdown(Mermaid や数式のフェンス、表)をサイト上の図に変え、テキストの代替表示つきのカスタム要素を配置します。どれも厳格な CSP の下で動作します。

<!-- spec:docs-index:begin -->
- [数式と図](math-diagrams/) — Mermaid の図と数式をコミットした静的な SVG と MathML として表示する方法、または組み込みのローダーや独自のローダーで図と KaTeX の数式を描画する方法と、それぞれの CSP とプライバシーへの影響です。
- [図と数式のローダー](loaders/) — 組み込みのローダーや独自のローダーで Mermaid の図と KaTeX の数式をブラウザーで描画する方法と、それぞれが CSP とプライバシーに求めることを説明します。
- [グラフ](charts/) — Markdown の表をグラフの figure にしたり、データファイルをグラフとして表示したりします。表はすべての読者が受け取るテキストとして残ります。
- [ウィジェット](widgets/) — 自作の custom element を Markdown からページに置き、JavaScript のない読者には代わりに読むテキストを渡します。
<!-- spec:docs-index:end -->
