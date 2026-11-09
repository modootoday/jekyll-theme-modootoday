---
lang: ko
permalink: /ko/guides/install/
source_rev: sha256:5874158aea48
nav_order: 10
title: 설치
description: GitHub Pages 또는 Jekyll 4 사이트에 테마를 추가합니다.
sections:
  - {c: tabs, name: methods}
  - minimal
  - check
  - starters
---
# 설치

이미 쓰는 빌드 방식을 고르세요. 세 방식 모두 같은 Markdown을 읽습니다.

> [!NOTE]
> 이 페이지는 [영어 원문](../../../guides/install/)의 번역입니다. 내용이 다르면 영어 문서가 우선합니다.

## 방식 고르기

### GitHub Pages

```yaml
# _config.yml (로컬 빌드는 github-pages gem 탭 참고)
remote_theme: modootoday/jekyll-theme-modootoday@v1.6.0
plugins: [jekyll-remote-theme]
```

### Jekyll 4

```ruby
# Gemfile
source "https://rubygems.org"
gem "jekyll", "~> 4.4"
gem "jekyll-theme-modootoday", "~> 1.6"
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
sass: {silence_deprecations: [import, global-builtin]}   # Jekyll 4: Dart Sass의 @import 안내 숨김
defaults:
  - {scope: {path: ""}, values: {layout: doc}}
```

> [!TIP]
> `remote_theme`을 쓸 때는 `theme:` 줄 대신 GitHub Pages 탭의 `remote_theme` 두 줄을 넣으세요.
>
> 이 사이트를 내 컴퓨터에서 github-pages gem으로 빌드하려면 `repository: <owner>/<name>`(GitHub 저장소)도 추가하거나 환경 변수 `PAGES_REPO_NWO=<owner>/<name>`을 설정하세요. 둘 다 없고 GitHub `origin` 원격이 있는 복제본 밖에서 빌드하면 "No repo name found. Specify using PAGES_REPO_NWO environment variables, 'repository' in your configuration, or set up an 'origin' git remote pointing to your github.com repository." 오류로 멈춥니다. GitHub Pages에서는 이 값을 자동으로 정합니다.

`sass:` 줄은 Jekyll 4 빌드에서 `@import`에 관한 Dart Sass 안내가 수천 줄 출력되지 않게 합니다. 결과물은 어느 쪽이든 같습니다.

## 빌드 확인

`--twins`는 테마가 AI 에이전트용으로 내보내는 파일도 확인합니다([에이전트용](../agents/)). 페이지마다 하나씩인 Markdown 버전과 `llms.txt`, `llms-full.txt`입니다. Jekyll 4에서는 `plugins: [jekyll-theme-modootoday]`를 추가하면 빌드가 만들어 줍니다. 기본 GitHub Pages에서는 `modootoday-stubs . --twins --write`를 한 번 실행해 페이지마다 Markdown 버전의 스텁을 추가하고, 사이트 루트에 front matter만 담은 파일 두 개를 둡니다. `layout: llms`인 `llms.txt`와 `layout: llms-full`인 `llms-full.txt`입니다. 오류 페이지(`404.md` 같은 `layout: error`)에는 Markdown 버전이 생기지 않습니다. 그 밖에 Markdown 버전이 필요 없는 페이지에는 `twin: false`를 넣으세요. Markdown만 검사하려면 `--twins`를 빼세요.

```sh
bundle exec jekyll build
bundle exec modootoday-check . _site --twins
```

검사기는 github.com에서 똑같이 보이지 않을 문법을 알려 줍니다.

`remote_theme` 사이트는 Gemfile에 테마가 없으므로 `bundle exec modootoday-check`를 쓸 수 없습니다. 테마 태그와 같은 마이너 버전으로 gem을 한 번 설치하고, 빌드한 사이트에 검사기를 실행합니다.

```sh
gem install jekyll-theme-modootoday -v '~> 1.6'
modootoday-check . _site --twins
```

셸이 `modootoday-check`를 찾지 못하면 gem의 bin 디렉터리가 `PATH`에 없는 것입니다. `ruby -S modootoday-check . _site --twins`로 실행합니다. `can't find gem jekyll-theme-modootoday (Gem::GemNotFoundException)`으로 멈추면 `PATH`에 있는 스크립트가 다른 gem 위치(다른 Ruby, 또는 버전 관리자가 설정한 `GEM_HOME`/`GEM_PATH`)의 것입니다. `gem install`이 쓴 위치를 Ruby에 알려 줍니다.

```sh
GEM_PATH="$(gem env gemdir)" ruby -S modootoday-check . _site --twins
```

gem을 설치하지 않으려면 릴리스 소스에서 검사기를 실행합니다. Ruby만 있으면 됩니다.

```sh
curl -sL https://github.com/modootoday/jekyll-theme-modootoday/archive/refs/tags/v1.6.0.tar.gz | tar xz -C /tmp
ruby /tmp/jekyll-theme-modootoday-1.6.0/exe/modootoday-check . _site --twins
```

`remote_theme` 줄에 적은 태그를 씁니다.

GitHub Actions에서는 빌드 다음 단계에 같은 두 줄을 넣습니다. 예: `run: gem install jekyll-theme-modootoday -v '~> 1.6' && modootoday-check docs docs/_site --twins`.

`github-pages` gem이 내는 경고 두 가지는 무시해도 됩니다. `To use retry middleware with Faraday v2.0+, install faraday-retry gem`이 나와도 원격 테마는 정상으로 내려받습니다. `@import`에 관한 Sass 안내는 GitHub Pages의 Sass가 `sass: silence_deprecations` 옵션을 읽지 않는 이전 버전이라서 `_config.yml`에 설정해도 계속 나옵니다. 어느 쪽이든 빌드 결과는 정상입니다.

## 시작 사이트

테마에는 시작 사이트 세 개가 있고, 각각 라이브 데모가 딸린 GitHub 템플릿 저장소입니다. [docs](https://github.com/modootoday/jekyll-theme-modootoday-docs-starter)(가이드, 데이터에서 만드는 페이지, `ko/`와 `ja/`의 한국어·일본어), [blog](https://github.com/modootoday/jekyll-theme-modootoday-blog-starter)(글, 뉴스 기사, 작성자 페이지, 피드), [landing](https://github.com/modootoday/jekyll-theme-modootoday-landing-starter)(히어로, 요금제, 약관 페이지)입니다. 하나로 시작하려면 그 저장소에서 **Use this template**을 고르고, GitHub Pages의 소스를 GitHub Actions로 켭니다. 복사본은 `remote_theme`으로 테마를 불러오고, `Gemfile`, `README.md`, 스텁, 그리고 사이트를 빌드하고 `modootoday-check`를 실행한 뒤 배포하는 Pages 워크플로가 들어 있습니다. `_config.demo.yml`도 함께 들어 있는데, 그 스타터 자체 라이브 데모의 설정([쇼케이스](../configuration/#스타터-데모-쇼케이스) 바나 필, `noindex`)입니다. 워크플로는 스타터 자신의 저장소에서만 이 설정을 빌드에 합치므로 복사본은 이 설정 없이 빌드되고, 파일을 지워도 됩니다. 테마 gem을 쓰는 Jekyll 4로 시작하려면 테마 저장소를 `--recurse-submodules`로 복제한 곳에서 `bundle exec rake starters:render`를 실행하고 `pkg/starters/jekyll4/<name>/`을 복사합니다.
