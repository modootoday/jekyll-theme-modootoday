---
title: "API 레퍼런스 데모"
description: "그룹으로 묶은 사이드바와 패키지 표가 있는 라이브러리 레퍼런스입니다."
layout: reference
nav_order: 8
twin: false
edit: false
sections: []
sidebar: true
packages_title: "패키지"
members:
  - {name: "build", group: "CLI", signature: "modootoday build [--drafts]", text: "사이트를 `_site`로 빌드합니다."}
  - {name: "serve", group: "CLI", signature: "modootoday serve [--port N]", text: "사이트를 빌드해 띄우고 바뀌면 다시 빌드합니다."}
  - {name: "Site.load", group: "라이브러리", signature: "Site.load(path) -> Site", text: "`path` 아래의 설정과 페이지를 읽습니다."}
  - {name: "Site#render", group: "라이브러리", signature: "site.render(page) -> String", text: "페이지 하나를 HTML로 렌더링합니다."}
  - {name: "Page#data", group: "라이브러리", signature: "page.data -> Hash", text: "페이지의 front matter입니다."}
packages:
  - {name: "modootoday-core", version: "1.4.0", text: "파싱, 렌더링, 페이지 모델.", url: "#", links: [{label: "문서", url: "#"}, {label: "소스", url: "#"}]}
  - {name: "modootoday-cli", version: "1.4.0", text: "`modootoday` 명령.", url: "#", links: [{label: "문서", url: "#"}, {label: "소스", url: "#"}]}
  - {name: "modootoday-lint", version: "0.9.2", text: "페이지를 레이아웃 계약과 대조해 검사합니다.", url: "#", links: [{label: "문서", url: "#"}, {label: "소스", url: "#"}]}
---
사이드바는 멤버를 `group:`으로 묶고, 표는 라이브러리를 이루는 패키지를 보여 줍니다.

> [!TIP]
> 표와 멤버 설명이 어긋나지 않도록 패키지를 같은 마이너 버전으로 고정하세요.
