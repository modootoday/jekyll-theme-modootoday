---
toc: false
hero: {visual: showcase}
title: 홈
description: 평범한 Markdown을 그대로 두고, GitHub·GitHub Pages·AI 에이전트 모두에서 잘 읽히는 문서를 만듭니다.
sections:
  - {c: features, name: why, cols: 3}
  - {c: tabs, name: quickstart}
  - journey
  - {c: cta, name: start}
---
# 문서는 평범한 Markdown으로

jekyll-theme-modootoday는 표준 GitHub Flavored Markdown을 깔끔한 문서 사이트로 바꿔 줍니다. 같은 파일이 github.com에서도, GitHub Pages에서도, AI 에이전트가 가져가는 Markdown 버전으로도 잘 읽힙니다.

[시작하기](guides/install/) [컴포넌트 보기](components/) [GitHub](https://github.com/modootoday/jekyll-theme-modootoday)

## 왜 모두의오늘 테마인가

- **표준 Markdown만** — 알림, 표, 목록, 코드 블록. 페이지에 HTML, Liquid, kramdown 전용 문법이 없습니다.
- **GitHub Pages에서 동작** — 기본 `github-pages` 빌드용 Liquid 전용 테마이고, 그 밖에는 Jekyll 4를 지원합니다.
- **에이전트가 읽기 쉬움** — 모든 페이지에 원본과 바이트 단위로 같은 Markdown 버전과 `llms.txt`, `llms-full.txt`가 있습니다.

## 빠른 시작

### remote_theme

```yaml
remote_theme: modootoday/jekyll-theme-modootoday@v1.2.2
plugins: [jekyll-remote-theme]
```

### Gemfile

```ruby
gem "jekyll-theme-modootoday", "~> 1.2"
```

### _config.yml

```yaml
theme: jekyll-theme-modootoday
permalink: pretty
```

## 문서 따라가기

1. GitHub Pages나 Jekyll 4에 테마를 [설치](guides/install/)합니다.
2. 평범한 Markdown으로 [첫 페이지](guides/first-page/)를 씁니다.
3. [컴포넌트](components/)와 [키친싱크](components/kitchen-sink/)에서 고릅니다.
4. [설정](guides/configuration/)을 조정하고 토큰과 `_sass`로 [모양을 바꿉니다](guides/customize/).
5. Markdown 버전과 `llms.txt`로 [에이전트가 읽게](guides/agents/) 합니다.

> [!NOTE]
> 이 페이지는 [영어 원문](../)의 번역입니다. 내용이 다르면 영어 문서가 우선합니다.

## 지금 시작

[테마 설치하기](guides/install/) [모든 컴포넌트 보기](components/kitchen-sink/)
