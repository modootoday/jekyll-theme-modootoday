---
lang: ko
permalink: /ko/guides/translate-site/
source_rev: sha256:a6aa3012649d
nav_order: 85
title: 사이트 번역하기
description: 내 사이트를 여러 언어로 게시하는 순서를 언어 목록, 페이지 번역, 언어별 홈 페이지와 메뉴부터 빠지거나 오래된 번역을 찾는 검사까지 단계별로 정리합니다.
---
# 사이트 번역하기

> [!NOTE]
> 이 페이지는 [영어 원문](../../../guides/translate-site/)의 번역입니다. 내용이 다르면 영어 문서가 우선합니다.

이 페이지는 사이트 작성자를 위한 것입니다. 테마 자체의 문서나 인터페이스 문구를 번역하려면 [번역 규칙](../translation/)을 보세요. 아래 단계마다 자세한 규칙은 [설정](../configuration/#언어)에 있습니다.

## 단계

1. `_config.yml`에 언어를 적습니다. `lang:`은 기본 언어이고, `languages`에는 `[en, ko]`처럼 사이트의 모든 언어를 적습니다. 검색 엔진에 번역을 알리는 `hreflang` 링크는 `url:`도 있을 때만 만들어집니다. GitHub Pages는 이 값을 채워 주고, 다른 빌드에서는 `_config.yml`에 적어야 합니다. 테마의 레이블은 이미 23개 언어로 들어 있으므로 복사할 것은 없습니다.
2. 각 페이지를 Markdown으로 번역합니다. 원문 옆에 두거나(`guides/start.md` 옆의 `guides/start.ko.md`, `lang: ko`와 `permalink: /ko/guides/start/`), 언어 폴더에 둡니다(`ko/guides/start.md`, `path: ko`에 `lang: ko`를 주는 `defaults` 범위). 경로가 다른 페이지끼리는 같은 `ref:`를 씁니다.
3. 언어마다 `/<lang>/`에 홈 페이지를 둡니다. 예를 들어 `lang: ko`와 `permalink: /ko/`를 쓴 `index.ko.md`입니다. 언어 메뉴는 번역이 없는 페이지에서 독자를 이 페이지로 보냅니다.
4. `language_switcher: header`나 `footer`로 언어 메뉴를 켭니다.
5. `tabs.label`처럼 사이트에 속한 레이블은 언어마다 `_data/i18n/<lang>.yml`에 둡니다. 테마 레이블의 표현을 바꾸고 싶을 때도 여기에 둡니다. 점으로 이은 이름은 중첩 키입니다. `tabs.label`은 `tabs: {label: ...}`로 적으며, [설정](../configuration/#언어)의 카탈로그 예시와 같습니다.
6. 모든 페이지를 번역하는 언어를 `full_languages`에 적고, 빌드할 때마다 아래 검사를 실행합니다. 번역이 없는 페이지와, `source_rev`가 없거나 그 뒤로 원문이 바뀐 번역을 알려 줍니다. 현재 `source_rev` 값도 출력하므로, 번역을 원문에 맞춘 뒤 그 값을 번역의 front matter에 적습니다. `modootoday-stubs --pwa`가 언어마다 쓰는 오프라인 페이지에는 `source_rev`가 필요 없으며, 검사에서 빠집니다.

```yaml
lang: en
modootoday:
  languages: [en, ko]
  full_languages: [ko]
  language_switcher: header
```

```sh
bundle exec modootoday-check . _site --i18n-pages
```

결과는 경고입니다. CI처럼 실패로 다루려면 `--strict`를 더합니다. 없는 홈 페이지로 가는 언어 메뉴 링크를 찾으려면 `--links`를 더합니다.
