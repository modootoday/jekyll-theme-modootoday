---
lang: ko
permalink: /ko/recipes/charts/
source_rev: sha256:5fa88f046dfa
nav_order: 26
title: 차트
description: Markdown 표를 차트 figure로 바꾸거나 데이터 파일을 차트로 보여 주고, 표는 모든 독자가 받는 텍스트로 남깁니다.
---
# 차트

> [!NOTE]
> 이 페이지는 [영어 원문](../../../recipes/charts/)의 번역입니다. 내용이 다르면 영어 문서가 우선합니다.

차트는 Markdown 표에서 시작합니다. 테마는 표를 차트 figure(`figure.mt-chart`)에 넣고, 표는 그 안에 차트의 텍스트로 남습니다. 그래서 JavaScript가 없는 독자, 스크린 리더, github.com, 페이지의 Markdown 버전과 `llms-full.txt`가 모두 숫자를 받습니다. 차트 스크립트가 figure를 그리기 전까지 독자에게는 표가 보입니다.

## 차트 켜기

```yaml
modootoday:
  chart: {enabled: true}
```

이 설정이 없으면 `chart:` 코드 스팬은 지금까지처럼 코드 스팬으로 남고, `modootoday-check`는 아직 차트가 아니라고 경고합니다.

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

[키친싱크](../../components/kitchen-sink/#차트)에 예가 있습니다.

## 데이터 파일로 만드는 차트

`c: chart` 섹션은 `_data/charts/`의 파일을 보여 줍니다. 그래서 숫자 한 벌을 여러 페이지에서 쓸 수 있습니다.

```yaml
# _data/charts/traffic.yml
label: Month
labels: [Jan, Feb, Mar]
series:
  - {name: Docs, values: [1200, 1350, 1610]}
  - {name: Blog, values: [640, 700, 690]}
```

```yaml
sections:
  - {c: chart, name: traffic, type: line, data: traffic}
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

## 검사기가 알려 주는 것

`modootoday-check`는 알 수 없는 유형이나 옵션, 바로 뒤에 표가 없는 `chart:` 줄, 표와 `data:`가 둘 다 있거나 둘 다 없는 `c: chart` 섹션, 없는 데이터 파일, 시리즈의 값 개수가 레이블 개수와 다른 데이터 파일을 오류로 알립니다. 숫자가 아닌 칸이나 값은 경고입니다. 차트를 켰을 때 빌드 결과에 `chart:`만 있는 문단이 남아 있으면 오류입니다.
