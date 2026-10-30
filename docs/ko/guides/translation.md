---
title: 번역 규칙
nav_order: 90
description: 한국어·일본어 문서와 인터페이스 문구의 정본 스타일 규칙, 용어집, 검사.
---
# 번역 규칙

> [!NOTE]
> 이 페이지는 [영어 원문](../../../guides/translation/)의 번역입니다. 내용이 다르면 영어 문서가 우선합니다.

원문은 영어입니다. 한국어(`ko`)와 일본어(`ja`) 페이지, `README.ko.md`, 예제 사이트, `i18n/<code>.yml`의 인터페이스 카탈로그는 모두 영어를 현지화한 것입니다. 이 페이지가 유일한 규칙이고, `i18n/glossary.yml`은 기계가 읽는 용어집이며, `script/i18n-build --check`가 두 가지를 모두 검사합니다.

## 원칙

- 영어 페이지의 내용을 더하거나 빼지 않고 그대로 전합니다. 내용이 다르면 영어가 우선하며 번역을 고칩니다.
- 옮겨 적지 말고 현지화합니다. 한국어 기술 문서 작성자가 처음부터 쓴 것처럼 어순과 문장 길이를 바꾸고, 영어식 명사 나열을 풀어 씁니다.
- 한 개념에는 한 단어만 씁니다. 모든 페이지에서 용어집의 용어를 그대로 씁니다.
- 일부 개발자만 쓰는 말보다 표준어를 고릅니다. 외래어보다 우리말이 더 분명하면 우리말을 씁니다(“브레드크럼”이 아니라 “이동 경로”).
- 식별자는 그대로 둡니다. 코드, 인라인 코드, 경로, Liquid, front matter 키와 테마가 읽는 값, 컴포넌트와 섹션 이름, 배지 값, CSS 클래스, `--mt-*` 토큰, 설정 키, 명령, URL, 제품 이름, `[!NOTE]` 같은 표시가 해당합니다.

## 문체

| 글 | 한국어 | 일본어 |
|---|---|---|
| 문서, README, 저장소 글 | 합니다체(안내에는 ~하세요 허용) | です・ます |
| 인터페이스 문장(`i18n/*.yml`) | 해요체 | です・ます |
| 레이블, 버튼, 제목 | 명사형 | 体言止め |
| 표 셀, 목록 조각 | 명사형 또는 합니다체 | 体言止め 또는 常体 |
| 샘플 페이지(`noindex: true`) | 장르 고유의 문체 | 장르 고유의 문체 |

한국어 기술 참고 문서(Microsoft, MDN, Mozilla)가 합니다체를 쓰고 이 사이트에서도 이미 다수였기 때문에 문서는 합니다체를 씁니다. 인터페이스 메시지는 한국 제품 UI에서 흔한 부드러운 해요체를 씁니다. 한 페이지 안에서 문체를 섞지 않습니다.

## 한국어

- 표준 맞춤법과 띄어쓰기(국립국어원 표준국어대사전, 외래어 표기법)를 따릅니다: 내비게이션, 배지, 레이블, 사용자.
- 번역 투를 쓰지 않습니다: “~를 가진”, “~에 의해”, “되어지다”, “~하는 것이 가능합니다”, “~에 대해서”, “~것이 필요합니다”. 대신 “~가 있는”, 능동태, “~할 수 있습니다”, “~해야 합니다”를 씁니다.
- 영어 복수형을 옮기지 않고, 기술 명사에 “들”을 붙이지 않습니다.
- 조사는 코드에 붙여 쓰고 읽는 소리에 맞춥니다: `theme`을, `index.md`를.
- 문장 부호는 ASCII를 쓰고, 따옴표는 “ ”를 씁니다.

## 일본어

- JTF 스타일 가이드의 표기를 따릅니다. -er, -or, -ar로 끝나는 외래어는 장음을 붙입니다: サーバー, ブラウザー, フォルダー, パラメーター, ヘッダー, フッター, ユーザー.
- 번역 투를 쓰지 않습니다: “〜を持つ”, “〜することが可能です”, “〜によって行われる”. 대신 “〜がある”, “〜できます”, 능동태를 씁니다.
- 본문에는 전각 、。（）「」를 씁니다. 일본어와 라틴 문자·인라인 코드 사이에는 반각 공백 하나를 둡니다. JTF는 공백을 두지 않지만, 이 사이트는 코드 옆 가독성을 위해 둡니다.

## 숫자와 날짜

ASCII 숫자와 언어별 자릿수 구분(1,000)을 씁니다. 본문 날짜는 2026년 10월 30일, 2026年10月30日로 쓰고, 기계가 읽는 날짜는 ISO 8601을 유지합니다. 버전과 단위는 영어와 같게 씁니다(`1.0.0`, 360 px).

## 주요 용어

피해야 할 표현까지 담은 전체 목록은 `i18n/glossary.yml`에 있습니다.

| 영어 | 한국어 | 일본어 | 피할 표현 |
|---|---|---|---|
| Markdown twin | Markdown 버전 | Markdown 版 | 쌍둥이, 트윈, ツイン, 双子 |
| front matter | front matter | front matter | 머리말, 프런트 매터, フロントマター |
| include | include | include | 인클루드, インクルード |
| breadcrumb | 이동 경로 | パンくずリスト | 브레드크럼, ブレッドクラム |
| checker | 검사기 | チェッカー | 체커 |
| navigation | 내비게이션 | ナビゲーション | 네비게이션 |
| repository | 저장소 | リポジトリ | 레포지토리 |
| screen reader | 스크린 리더 | スクリーンリーダー | 화면 낭독기 |
| component | 컴포넌트 | コンポーネント | 部品 |

## 인터페이스 문구

카탈로그는 `i18n/en.yml`의 모든 키와 자리 표시자(`[n]`, `[total]`, `[section]`, `%{x}`)를 그대로 유지하고 값만 바꿉니다. 레이블은 짧은 명사형으로 씁니다. 수정한 뒤에는 `script/i18n-build`를 실행해 Liquid 카탈로그를 다시 만듭니다.

## 검사 항목

`script/i18n-build --check`는 `script/i18n/lint.rb`를 실행하며, 다음 경우에 실패합니다.

- 카탈로그: 빠졌거나 모르는 키, 빈 값, 앞뒤 공백, 자리 표시자 불일치, 한국어 인터페이스 문장의 합니다체
- 한국어·일본어 페이지, README, 글, 예제 페이지(코드 제외): 피해야 할 용어, 번역 투, 잘못된 문체(한국어 문서의 해요체·한다체, 일본어 본문의 常体), 번역하지 않은 영어 문장

어순, 관용 표현, 어조처럼 검사기가 판단할 수 없는 부분은 리뷰에서 이 페이지를 기준으로 확인합니다.

## 다른 언어

나머지 20개 카탈로그도 같은 원칙을 따릅니다. 원어민 검토자가 승인하면 해당 언어의 용어를 용어집에 추가합니다.

## 참고 자료

- [Microsoft localization style guides](https://learn.microsoft.com/globalization/reference/microsoft-style-guides) (Korean and Japanese)
- [MDN translated content guidelines](https://github.com/mdn/translated-content) and the Korean team notes
- [Mozilla Korean style guide](https://mozilla-l10n.github.io/styleguides/ko/)
- [JTF 日本語標準スタイルガイド](https://www.jtf.jp/tips/styleguide)
- [Toss technical writing guide](https://technical-writing.dev/)
- [국립국어원 한국어 어문 규범](https://kornorms.korean.go.kr/)
- [Google developer documentation style guide](https://developers.google.com/style)
- [W3C Internationalization](https://www.w3.org/International/)
