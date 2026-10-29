---
title: 설치
description: GitHub Pages 또는 Jekyll 4 사이트에 테마를 추가합니다.
sections:
  - {c: tabs, name: methods}
  - minimal
  - check
  - {c: cta, name: next}
---
# 설치

이미 쓰는 빌드 방식을 고르세요. 세 방식 모두 같은 Markdown을 읽습니다.

> [!NOTE]
> 이 페이지는 [영어 원문](../../install/)의 번역입니다. 내용이 다르면 영어 문서가 우선합니다.

## 방식 고르기

### GitHub Pages

```yaml
# _config.yml (기본 GitHub Pages 빌드, Gemfile 불필요)
remote_theme: modootoday/jekyll-theme-modootoday@v1.0.0
plugins: [jekyll-remote-theme]
```

### Jekyll 4

```ruby
# Gemfile
source "https://rubygems.org"
gem "jekyll", "~> 4.4"
gem "jekyll-theme-modootoday", "~> 1.0"
```

### github-pages gem

```ruby
# Gemfile (GitHub Pages 환경을 로컬에서 재현)
source "https://rubygems.org"
gem "github-pages", "~> 232", group: :jekyll_plugins
```

## 최소 설정

pretty 퍼머링크를 쓰고 모든 페이지에 `doc` 레이아웃을 지정합니다.

```yaml
theme: jekyll-theme-modootoday
lang: ko
permalink: pretty
markdown: kramdown
kramdown: {input: GFM}
defaults:
  - {scope: {path: ""}, values: {layout: doc}}
```

> [!TIP]
> `remote_theme`을 쓸 때는 `theme:` 줄 대신 GitHub Pages 탭의 `remote_theme` 두 줄을 넣으세요.

## 빌드 확인

```sh
bundle exec jekyll build
bundle exec modootoday-check . _site --twins
```

검사기는 github.com에서 똑같이 보이지 않을 문법을 알려 줍니다.

## 다음

[첫 페이지 쓰기](../first-page/) [홈으로](../)
