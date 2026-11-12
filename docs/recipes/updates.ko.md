---
lang: ko
permalink: /ko/recipes/updates/
source_rev: sha256:7744f8126e43
nav_order: 28
title: 독자에게 업데이트 알리기
description: 피드, GitHub 릴리스 알림, 이메일 양식, 설치된 앱의 안내로 독자가 사이트의 변경을 따라오게 하고, 릴리스를 게시하면 사이트를 다시 빌드하는 방법을 설명합니다.
---
# 독자에게 업데이트 알리기

> [!NOTE]
> 이 페이지는 [영어 원문](../../../recipes/updates/)의 번역입니다. 내용이 다르면 영어 문서가 우선합니다.

정적 사이트는 스스로 독자에게 연락할 수 없습니다. 그래서 테마는 독자가 원할 때 소식을 가져가는 방법을 제공합니다. 독자에게 맞는 채널을 고르세요. 각 채널은 다른 채널 없이도 동작합니다.

| 채널 | 어울리는 독자 | 준비할 것 |
|---|---|---|
| Atom 피드 | 피드 리더를 쓰는 독자와 사이트를 지켜보는 도구 | 언어마다 `feed.xml` 페이지 하나 |
| GitHub 릴리스 알림 | GitHub에서 프로젝트를 쓰는 사람 | GitHub에 릴리스를 게시하는 것 말고는 없음 |
| 이메일 양식 | 새 버전이 나오면 이메일을 받고 싶은 독자 | `c: subscribe` 섹션과 메일 서비스 |
| 업데이트 안내 | 설치한 앱을 쓰는 독자 | `modootoday.pwa` |
| 릴리스 막대 | 모든 방문자, 모든 페이지 | `banner: {release: latest}` |

## 피드

언어 폴더마다 `layout: feed`인 `feed.xml` 페이지를 추가합니다. 그러면 모든 페이지의 head가 그 언어의 피드를 링크하므로, 피드 리더는 어느 페이지 주소에서든 피드를 찾습니다. 블로그, 작성자, 아카이브 페이지는 자기 피드로 가는 구독 링크도 보여 줍니다(front matter `feed:`). [작성자와 피드](../../layouts/blog-news/#작성자와-피드)를 참고하세요. 피드는 사이트에 있는 파일일 뿐이어서 누구도 가입하지 않고, 누가 읽는지도 알 수 없습니다.

GitHub에 릴리스를 게시하면 GitHub가 `https://github.com/OWNER/REPO/releases.atom`에 릴리스 피드를 둡니다. 릴리스만 받고 싶은 독자를 위해 변경 기록이나 뉴스 페이지에서 링크하세요.

## GitHub 릴리스 알림

GitHub 계정이 있는 독자는 저장소에서 Watch, Custom을 차례로 고른 다음 Releases를 선택할 수 있습니다. 그러면 GitHub가 릴리스를 게시할 때마다 독자가 [알림 설정](https://docs.github.com/ko/account-and-profile/managing-subscriptions-and-notifications-on-github/setting-up-notifications/configuring-notifications)에서 정한 대로 GitHub나 이메일로 알려 줍니다. 설치 페이지나 변경 기록 페이지에 이 방법을 적어 두세요.

## 이메일 양식

`c: subscribe` 섹션은 본문과, 메일 서비스(`modootoday.subscribe.action`)로 보내는 이메일 양식을 출력합니다. 주소를 보관하고 이메일을 보내는 일은 서비스가 하고, 테마는 양식만 그립니다. [구독](../../components/#구독)을 참고하세요.

## 설치한 앱

`modootoday.pwa`를 켜면 열려 있는 앱은 배포가 테마 파일을 바꿨을 때 짧은 안내를 보여 주고, 페이지는 언제나 네트워크에서 먼저 가져옵니다. 설치할 수 있는 사이트 레시피의 [업데이트](../pwa/#업데이트)를 참고하세요. 안내는 사이트를 열어 둔 독자에게만 보이며 알림이 아닙니다.

## 릴리스 막대

`modootoday.banner: {release: latest}`는 모든 페이지에 최신 릴리스 버전과 그 릴리스로 가는 "새 기능 보기" 링크를 보여 줍니다. 값은 사이트를 빌드할 때 `site.github`에서 읽고, 프리릴리스는 빠집니다. 사이트를 다시 빌드해야 바뀌므로, 릴리스마다 다시 빌드하도록(아래) 함께 설정하세요. GitHub Pages 밖에서는 `release: {version, url}`을 대신 씁니다.

## 푸시가 없는 이유

푸시 알림에는 모든 독자의 구독을 보관하는 서버, 권한 요청, 브라우저 회사가 운영하는 푸시 서비스가 필요합니다. 정적 사이트용 테마에는 서버가 없고 어디에도 아무것도 보내지 않으므로 푸시를 제공하지 않습니다. 위의 채널은 직접 운영하는 서버가 필요 없고, 독자는 허락을 구하지 않고도 언제든 그만 받을 수 있습니다.

## 릴리스를 게시하면 다시 빌드하기

GitHub Pages는 푸시할 때 사이트를 빌드합니다. 그래서 빌드가 GitHub에서 읽는 데이터(`site.github`의 릴리스나 저장소 정보 등)는 마지막 푸시 때 그대로 남습니다. 릴리스를 게시해도 사이트는 다시 빌드되지 않습니다.

스타터의 Pages 워크플로(`.github/workflows/pages.yml`)는 릴리스가 게시되면 기본 브랜치를 다시 빌드하고, `schedule`의 주석을 풀면 켜지는 주간 빌드도 들어 있습니다. 직접 만든 [Pages 워크플로](https://docs.github.com/ko/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages)에는 같은 트리거를 추가하세요.

```yaml
on:
  push:
    branches: [main]
  release:
    types: [published]
  schedule:
    - cron: "17 3 * * 1"   # 매주 월요일 03:17 UTC
```

- 릴리스로 시작한 실행은 릴리스의 태그에서 돌고, `github-pages` 환경은 보통 기본 브랜치만 배포하게 합니다. 그래서 스타터의 워크플로는 태그를 빌드하지 않고 기본 브랜치에서 자신을 다시 시작합니다(`gh workflow run pages.yml --ref main`, `permissions: actions: write`가 필요합니다).
- 공개 저장소에서 60일 동안 활동이 없으면 GitHub는 예약된 워크플로를 끕니다. Actions 탭에서 다시 켜세요.
- GitHub가 브랜치에서 빌드하는 사이트(Settings, Pages, Deploy from a branch)에는 트리거를 추가할 워크플로가 없습니다. 릴리스 뒤에 커밋을 푸시하거나 Pages 소스를 GitHub Actions로 바꾸세요.
