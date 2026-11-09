---
lang: ko
permalink: /ko/recipes/charts/
source_rev: sha256:1f9d4ced30db
nav_order: 26
title: 차트
description: Markdown 표를 차트 figure로 바꾸거나 데이터 파일을 차트로 보여 주고, 표는 모든 독자가 받는 텍스트로 남깁니다.
---
# 차트

> [!NOTE]
> 이 페이지는 [영어 원문](../../../recipes/charts/)의 번역입니다. 내용이 다르면 영어 문서가 우선합니다.

차트는 Markdown 표에서 시작합니다. 테마는 표를 차트 figure(`figure.mt-chart`)에 넣고, 표는 그 안에 차트의 텍스트로 남습니다. 그래서 JavaScript가 없는 독자, 스크린 리더, github.com, 페이지의 Markdown 버전과 `llms-full.txt`가 모두 숫자를 받습니다. 사이트에 Chart.js를 두면 테마가 표에서 차트를 그리고, 표는 그 아래 *차트 데이터* 펼침 상자로 접힙니다. Chart.js가 없으면 독자에게는 표가 보입니다.

## 차트 켜기

```yaml
modootoday:
  chart:
    enabled: true
    src: /js/chart.min.js
    integrity: sha384-…
```

`src`는 사이트에 둔 Chart.js 4입니다([Chart.js 직접 호스팅](#chartjs-직접-호스팅) 참고). `src`가 없으면 차트는 표로 남습니다. `enabled`가 없으면 `chart:` 코드 스팬은 지금까지처럼 코드 스팬으로 남고, `modootoday-check`는 아직 차트가 아니라고 경고합니다. front matter `chart: false`를 쓰면 그 페이지의 차트는 표로 남습니다.

## 표로 만드는 차트

표 바로 앞에 `chart:<type>`만 있는 줄을 두고, 바로 뒤에 캡션이 될 강조만 있는 줄을 둡니다.

```markdown
`chart:bar stacked`

| Quarter | Docs | Blog |
|---|---|---|
| Q1 | 4,160 | 2,030 |
| Q2 | 5,270 | 2,770 |

*Visits per quarter*
```

- 첫 열은 레이블이고 머리행은 시리즈 이름입니다. 나머지 칸은 숫자이며 `,`와 `%`는 무시합니다.
- 유형은 `bar`, `line`, `area`, `pie`, `doughnut` 중 하나입니다.
- 옵션은 유형 뒤에 공백으로 이어 씁니다. `stacked`는 시리즈를 쌓고, `horizontal`은 막대를 가로로 눕힙니다.

이 페이지는 같은 차트를 네 분기로 그립니다.

`chart:bar stacked`

| 분기 | 문서 | 블로그 |
|---|---|---|
| 1분기 | 4,160 | 2,030 |
| 2분기 | 5,270 | 2,770 |
| 3분기 | 6,020 | 3,140 |
| 4분기 | 6,480 | 3,610 |

*분기별 방문 수*

[키친싱크](../../components/kitchen-sink/#차트)에 예가 더 있습니다.

## 데이터 파일로 만드는 차트

`c: chart` 섹션은 `_data/charts/`의 파일을 보여 줍니다. 그래서 숫자 한 벌을 여러 페이지에서 쓸 수 있습니다.

```yaml
# _data/charts/traffic.yml
label: Month
labels: [Jan, Feb, Mar]
series:
- name: Docs
  values: [1200, 1350, 1610]
- name: Blog
  values: [640, 700, 690]
```

```yaml
sections:
  - c: chart
    name: traffic
    type: line
    data: traffic
```

테마는 섹션 끝에 데이터를 표로 씁니다. 레이블마다 행 하나, 시리즈마다 열 하나이고, `label`은 첫 열의 제목입니다. 섹션의 텍스트가 먼저 오고, 섹션의 마지막 문단이 강조만 있으면 캡션이 됩니다. 레이블과 시리즈 이름은 텍스트이므로 언어마다 파일을 따로 두고(`traffic-ko.yml`) 번역 페이지가 그 파일을 가리키게 합니다. `stacked: true`와 `horizontal: true`는 위의 옵션과 같습니다.

`data:`가 없는 `c: chart` 섹션은 대신 첫 표를 쓰고, 캡션도 위와 같은 방식으로 붙습니다. 차트 섹션은 이름으로 차트를 요청하므로 `modootoday.chart.enabled`가 꺼져 있어도 표를 차트 figure로 바꿉니다.

## 색

figure에는 색 구성마다 시리즈 색 8개가 있고, 모두 페이지 배경과의 대비가 3:1 이상입니다. 브랜드 색을 쓰려면 사이트 스타일시트에서 훅을 설정합니다.

```css
:root {
  --mt-chart-1: #0f766e;
  --mt-chart-2: #b45309;
}
```

`--mt-chart-1`부터 `--mt-chart-8`까지는 시리즈, `--mt-chart-grid`는 격자선, `--mt-chart-text`는 축 텍스트입니다. 테마는 이 값을 설정하지 않으므로 설정한 값은 두 색 구성에 모두 적용됩니다. 다크 구성만 바꾸려면 사이트의 다크 구성 선택자 아래에서 한 번 더 설정합니다.

## Chart.js 직접 호스팅

테마는 Chart.js를 포함하지 않습니다. 버전을 고정한 사본 하나를 사이트에 두면 엄격한 콘텐츠 보안 정책에 아무것도 더하지 않아도 되고, 독자의 요청이 CDN으로 가지 않습니다.

1. 정확한 Chart.js 4 릴리스의 `dist/chart.umd.min.js`를 내려받아(예: `https://cdn.jsdelivr.net/npm/chart.js@4.5.1/dist/chart.umd.min.js`) `js/chart.min.js`로 저장하고, MIT 라이선스는 그 옆에 `js/chart.LICENSE.txt`로 둡니다. 라이선스는 `.txt` 파일로 두세요. GitHub Pages는 front matter가 없는 Markdown 파일도 페이지로 만들기 때문에 `chart.LICENSE.md`는 페이지가 되고, `modootoday-check`가 이를 알립니다.
2. 해시를 계산합니다. `openssl dgst -sha384 -binary js/chart.min.js | openssl base64 -A`
3. `src: /js/chart.min.js`와 `integrity: sha384-<그 해시>`를 설정합니다.

CDN도 쓸 수 있습니다. 이때 `src`는 버전을 고정한 https URL이고 `integrity`는 필수이며(없으면 아무것도 불러오지 않습니다), CDN 출처를 `script-src`에 더해야 하고, 독자의 IP 주소가 CDN에 전달됩니다. `modootoday-check`는 두 형태를 모두 검사하고, 그 밖의 외부 스크립트를 불러오는 페이지를 실패로 처리합니다.

Chart.js(gzip 약 70 KB)와 테마의 차트 모듈은 차트가 있는 페이지에서만, 페이지를 해석한 뒤에 불러오므로 첫 화면 표시를 늦추지 않습니다.

## 독자가 받는 것

- 차트는 `role="img"`인 `canvas`이고, 캡션이 이름이 됩니다(캡션이 없으면 시리즈 이름). 표는 figure 안에 *차트 데이터* 펼침 상자로 접혀 남고, 스크린 리더와 키보드로 여느 펼침 상자처럼 엽니다. 접근 가능한 이름에는 차트 이름이 붙고("차트 데이터, 방문"), 두 차트의 이름이 같으면 번호가 붙어서 한 페이지의 펼침 상자를 서로 구별할 수 있습니다.
- 색, 격자선, 축 텍스트는 위의 훅에서 오고, 새로 고침 없이 테마 전환과 시스템 색 구성을 따라갑니다. 선 차트는 시리즈마다 점선 모양도 달라서 색을 구별하기 어려울 때도 시리즈가 구분됩니다. 범례도 시리즈마다 그 점선 모양의 짧은 선으로 보여 줍니다.
- 시스템에서 동작 줄이기를 켜면 차트를 애니메이션 없이 그립니다.
- 강제 색 모드(Windows 고대비)에서는 차트를 그리지 않고 표를 펼친 채 시스템 색으로 보여 줍니다.
- 엄격한 CSP에서도 예외가 필요 없습니다. Chart.js는 CSSOM으로 canvas 크기를 정하고, `style-src 'self'`는 이를 허용합니다([CSP](../csp/)).

## 검사기가 알려 주는 것

`modootoday-check`는 알 수 없는 유형이나 옵션, 바로 뒤에 표가 없는 `chart:` 줄, 표와 `data:`가 둘 다 있거나 둘 다 없는 `c: chart` 섹션, 없는 데이터 파일, 시리즈의 값 개수가 레이블 개수와 다른 데이터 파일을 오류로 알립니다. 숫자가 아닌 칸이나 값은 경고이고, 줄의 유형이 틀려도 함께 알립니다. 차트를 켰을 때 빌드 결과에 올바른 `chart:` 줄만 있는 문단이 남아 있으면 오류입니다. 유형이 틀린 줄은 소스에서 한 번만 알립니다. `modootoday.chart.src`는 버전을 고정한 https URL과 `integrity`, 또는 사이트 안의 경로여야 합니다.
