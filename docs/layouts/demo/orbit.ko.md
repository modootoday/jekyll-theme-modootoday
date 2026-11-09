---
lang: ko
permalink: /ko/layouts/demo/orbit/
source_rev: sha256:8989380cb3b1
nav_exclude: true
title: 히어로 모듈 데모
twin: false
sitemap: false
edit: false
description: "사이트 모듈 스크립트가 포스터 이미지 위에 그림을 그리는 분할 히어로입니다. script:와 poster:를 설정하는 방법입니다."
hero: {c: split, visual: orbit-stage, script: orbit, turn: 12, poster: {path: /assets/images/hero/orbit-960.webp, srcset: "/assets/images/hero/orbit-640.webp 640w, /assets/images/hero/orbit-960.webp 960w", width: 960, height: 960}}
sections: [setup, contract]
---
# 히어로 모듈 데모

그림 가운데를 점 세 개가 돕니다. 이 사이트의 모듈 스크립트가 포스터 이미지 위에 점을 그리고 돌립니다. 처음 보이는 것은 포스터이고, JavaScript가 꺼져 있거나 동작 줄이기를 설정했으면 포스터가 그대로 남습니다.

[섹션 비주얼](../../../guides/customize/)

## 설정

`_config.yml`에 모듈을 한 번 등록하고, 히어로에서 포스터와 함께 이름을 적습니다.

```yaml
# _config.yml
modootoday:
  scripts:
    orbit: {src: /assets/js/hero/orbit.js, css: /assets/css/orbit.css}
```

```yaml
# front matter
hero:
  c: split
  visual: orbit-stage
  script: orbit
  poster: {path: /assets/images/hero/orbit-960.webp, width: 960, height: 960}
```

`orbit.js`와 그 시트, 그리고 이 모듈이 가져오는 테마의 작은 도우미는 이 페이지에만 실립니다. 포스터는 페이지에서 가장 큰 이미지이며 가장 먼저 받습니다.

## 모듈이 하는 일

- 동작 줄이기를 설정했으면 바로 멈추므로 포스터가 남습니다.
- `orbit-stage` include가 만든 `mt-visual-stage` 클래스 요소에 그립니다. 이 요소는 포스터를 덮습니다.
- 다 그리면 비주얼 열에 `data-mt-ready`를 붙여 포스터를 숨깁니다.
- `readConfig`로 `data-turn`을 읽고, `onThemeChange`로 라이트와 다크 전환을 따라갑니다.
