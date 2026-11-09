---
lang: ko
permalink: /ko/reference/showcase/
source_rev: sha256:91d858b34d4d
nav_order: 30
title: 스타터 데모 쇼케이스
description: 스타터의 라이브 데모에 테마 이름과 문서 링크를 담은 막대나 알약을 보여 주고, 복사한 사이트에는 나오지 않게 하는 방법을 설명합니다.
---
# 스타터 데모 쇼케이스

[설정](../../guides/configuration/) 표의 한 행인 `modootoday.showcase` 설정을 여기서 자세히 설명합니다.

> [!NOTE]
> 이 페이지는 [영어 원문](../../../reference/showcase/)의 번역입니다. 내용이 다르면 영어 문서가 우선합니다.

스타터의 라이브 데모에는 테마와 스타터 이름을 알리고 테마 문서로 돌아가는 링크를 담은 막대를 표시할 수 있습니다. 이 막대는 데모 빌드에만 씁니다. 데모 배포만 `_config.yml` 위에 겹치는 두 번째 설정 파일에 넣으면, 스타터로 만든 사이트에는 나타나지 않습니다. GitHub Pages 빌더는 `_config.yml`만 읽으므로, 이 빌더를 쓰는 워크플로는 빌드 전에 데모 파일을 `_config.yml`에 합칩니다. 테마의 스타터는 `if: github.repository == '<owner>/<repo>'` 조건이 붙은 워크플로 단계에서 이 일을 하므로, 포크나 템플릿으로 만든 저장소는 쇼케이스 없이 빌드됩니다.

```yaml
# _config.demo.yml: jekyll build --config _config.yml,_config.demo.yml
modootoday:
  showcase:
    enabled: true
    style: bar            # bar (default) or pill
    starter: blog         # names the starter in the label
    docs_url: https://modootoday.github.io/jekyll-theme-modootoday/
    use_url: https://github.com/<owner>/<repo>/generate   # optional
```

클래식 GitHub Pages에서는 GitHub Actions 워크플로로 빌드하고(Settings > Pages > Source: GitHub Actions), 빌더가 실행되기 전에 조건이 붙은 단계에서 파일을 합칩니다. 아래는 스타터의 `pages.yml`이 쓰는 단계입니다. 빌드 다음 단계가 `_config.yml`을 되돌려 놓으므로, 이어지는 검사는 사이트 자체의 설정을 봅니다.

```yaml
# .github/workflows/pages.yml: steps of the build job, around the build
- name: Layer the demo config
  if: github.repository == '<owner>/<repo>'
  run: |
    cp _config.yml "$RUNNER_TEMP/_config.yml"
    ruby -ryaml -rdate -e '
      read = ->(f) { YAML.safe_load_file(f, permitted_classes: [Date, Time], aliases: true) || {} }
      merge = ->(a, b) { a.merge(b) { |_, x, y| x.is_a?(Hash) && y.is_a?(Hash) ? merge.(x, y) : y } }
      File.write("_config.yml", YAML.dump(merge.(read.("_config.yml"), read.("_config.demo.yml"))))'
- uses: actions/jekyll-build-pages@v1   # the classic GitHub Pages builder
  with:
    source: .
    destination: ./_site
- name: Restore _config.yml
  if: github.repository == '<owner>/<repo>'
  run: mv "$RUNNER_TEMP/_config.yml" _config.yml
```

- **막대**(`style: bar`, 기본값): 헤더 위의 44 px 막대에 테마 이름, 스타터 이름, 문서 링크, 이 스타터로 시작 링크(`use_url`이 있을 때), 숨기기 버튼이 들어갑니다. 고정 헤더와 앵커 대상의 오프셋은 막대 높이만큼 내려갑니다. 40rem(640 px)보다 좁으면 테마 이름, 문서 링크, 버튼만 남습니다. 휴대폰을 가로로 들거나 200%로 확대해 창 높이가 30rem(480 px)보다 낮으면 막대가 페이지와 함께 스크롤됩니다.
- **알약**(`style: pill`): 아래 가운데에 떠 있는 알약에 테마 이름, 스타터 이름, 문서 링크, 버튼이 들어갑니다. 페이지 아래에 여백을 두므로 알약이 마지막 줄, 맨 위로 링크, 안전 영역을 가리지 않습니다.
- **색**은 페이지 색을 뒤집습니다. 밝은 페이지에는 어두운 막대, 어두운 페이지에는 밝은 막대가 나옵니다. `brand` 토큰은 표시 칸에만 씁니다.
- **링크**는 설정에서만 읽습니다. 새 창으로 열리고, 화살표를 보여 주며, 이름에도 새 창에서 열린다고 적힙니다.
- **포커스 순서**: 쇼케이스는 "테마 쇼케이스"라는 이름의 영역이며, 그 링크는 "본문으로 건너뛰기" 바로 다음에 옵니다.
- **숨기기**는 그 탭에서 방문이 끝날 때까지 유지됩니다(`sessionStorage`). `<head>`의 작은 스크립트가 페이지를 그리기 전에 이 값을 읽으므로, 다음 페이지에는 막대도 그 자리도 없고 화면이 밀리지 않습니다. JavaScript가 없거나 저장소가 막혀 있으면 쇼케이스는 그대로 남습니다.
- **검색 엔진**: 쇼케이스를 켜면 모든 페이지에 `<meta name="robots" content="noindex">`가 붙습니다. 데모의 예시 글은 스타터로 만든 모든 사이트가 처음에 갖는 글이기 때문입니다. 사이트맵에는 페이지가 남지만 noindex가 우선하며, 데모 빌드의 Lighthouse SEO 감사는 페이지가 색인에서 막혔다고 보고합니다.
- **레이블**은 페이지 언어를 따릅니다. `starter`는 `showcase.starters.<name>` 레이블을 고르며, 테마에는 `docs`, `blog`, `landing`이 들어 있습니다. 다른 스타터는 `_data/i18n/<lang>.yml`에 그 키를 추가하세요. 없으면 레이블에 테마 이름만 나옵니다.
- `modootoday-check`는 `_config.yml`과 `_config.demo.yml`의 키를 검사하고, `_config.yml` 자체에서 켜면 경고하며, 쇼케이스가 나오는 빌드에서는 noindex 태그가 없는 페이지도 경고합니다. `_config.demo.yml`이 있어도 그 파일 없이 빌드한 사이트에는 경고하지 않습니다.
