---
lang: ko
permalink: /ko/layouts/demo/code-github/
source_rev: sha256:ed6279dfbed8
title: GitHub 코드 색 데모
description: GitHub 라이트·다크 팔레트로 칠한 코드 블록입니다. 사이트에서 modootoday.code_theme을 github로 설정했을 때의 모습을 보여 줍니다.
twin: false
sitemap: false
edit: false
nav_exclude: true
site_css: [/assets/css/code-github.css]
---
# GitHub 코드 색

이 페이지는 `code_theme: github`를 켠 사이트에서 코드 블록이 어떻게 보이는지 보여 줍니다. 라이트와 다크를 바꿔 두 팔레트를 확인하세요. 문서의 다른 페이지는 기본 코드 색을 그대로 씁니다.

```yaml
# _config.yml
modootoday:
  code_theme: github
```

색은 GitHub의 라이트·다크 편집기 테마에서 가져왔습니다. Rouge는 편집기와 토큰을 다르게 나누므로 팔레트는 GitHub와 같아도 단어 하나의 색은 다를 수 있습니다. [커스터마이즈](../../../guides/customize/)를 보세요.

## Ruby

```ruby
# Greets everyone on the list.
class Greeter
  DEFAULT = "world"

  def initialize(names = [DEFAULT])
    @names = names
  end

  def greet(times: 2)
    @names.each { |n| puts "Hello, #{n}!" * times if n.length > 0 }
  end
end
```

## JavaScript

```js
const total = (items) => items.reduce((sum, item) => sum + item.price * 1.1, 0);
export async function load(url) {
  const res = await fetch(url, { cache: "no-store" });
  return res.ok ? res.json() : null;
}
```

## HTML

```html
<a class="mt-cta" href="/guides/install/" aria-label="Install">Install</a>
```

## SCSS

```scss
$mt-overrides: (code-keyword: #cf222e);
.site-note { color: var(--mt-code-comment); }
```

## Diff

```diff
- code_theme: theme
+ code_theme: github
```

## Shell

```sh
bundle exec jekyll build --config _config.yml && echo "done: $?"
```
