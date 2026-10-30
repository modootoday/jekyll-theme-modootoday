---
nav_order: 10
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
> 이 페이지는 [영어 원문](../../../guides/install/)의 번역입니다. 내용이 다르면 영어 문서가 우선합니다.

## 방식 고르기

### GitHub Pages

```yaml
# _config.yml (기본 GitHub Pages 빌드, Gemfile 불필요)
remote_theme: modootoday/jekyll-theme-modootoday@v1.2.0
plugins: [jekyll-remote-theme]
```

### Jekyll 4

```ruby
# Gemfile
source "https://rubygems.org"
gem "jekyll", "~> 4.4"
gem "jekyll-theme-modootoday", "~> 1.2"
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

`remote_theme` 사이트는 Gemfile에 테마가 없습니다. 검사기를 쓰려면 gem을 한 번 설치한 뒤 빌드한 사이트에 실행합니다.

```sh
gem install jekyll-theme-modootoday
modootoday-check . _site --twins
```

`gem install` 뒤에 셸이 `modootoday-check`를 찾지 못하면 gem의 bin 디렉터리가 `PATH`에 없는 것입니다. `ruby -S modootoday-check . _site --twins`로 실행하거나 `"$(gem env gemdir)/bin/modootoday-check"`를 호출합니다. 스크립트 위치는 `gem contents jekyll-theme-modootoday | grep bin/`로 확인합니다.

GitHub Actions에서는 빌드 다음 단계에 같은 두 줄을 넣습니다. 예: `run: gem install jekyll-theme-modootoday && modootoday-check docs docs/_site --twins`.

`github-pages` gem이 내는 경고 두 가지는 무시해도 됩니다. `To use retry middleware with Faraday v2.0+, install faraday-retry gem`이 나와도 원격 테마는 정상으로 내려받습니다. `@import`에 관한 Sass 안내는 GitHub Pages의 Sass가 경고 숨김 옵션을 읽지 않는 이전 버전이라서 `_config.yml`에 설정해도 계속 나옵니다. 어느 쪽이든 빌드 결과는 정상입니다.

## 다음

[첫 페이지 쓰기](../first-page/) [홈으로](../../)
