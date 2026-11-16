---
id: plan:modootoday/20261116084808
title: 1.8 publishes the starter waves 2 to 6 of the docs demo map
status: draft
created: 2026-11-16T08:48:08Z
updated: 2026-11-16T08:48:08Z
rel:
  governs: [example/starters.yml]
  implements: [sot:modootoday/docs-demo-to-starter-map]
---

# 1.8 publishes the starter waves 2 to 6 of the docs demo map

## Goal

[[sot:modootoday/docs-demo-to-starter-map]] plans twelve starters in six waves; only wave 1 (docs, blog, landing)
was published, so 5 of the 31 layout demos link a live starter. The operator decided on 2026-11-14 that waves 2 to 6
are 1.8 work, one wave per work item, each public repository created only after the operator approves it. Until a
wave ships, its layout pages keep their own demo in the docs.

## Steps

1. **Wave 2 (existing starters):** archive, download, reference and the API page move into the blog, landing and docs
   starters; the docs layout pages become reference pages with a Live demo link. No new repository.
2. **Wave 3 (saas, help-center):** case-study, feature, brand, contact, changelog, roadmap, glossary, hub. Two new
   repositories, each asked for before it is created.
3. **Wave 4 (portfolio):** portfolio, project, links.
4. **Wave 5 (company, oss, newsroom, course):** team, jobs, job, sponsors, news, news-article, course, book.
5. **Wave 6 (conference, podcast):** events, event, episode.

Each wave runs the release procedure of the theme goal before its version ships: the visual run against the last
tag, the screenshot review, a usability audit from the public docs, the release checks, and the operator's approval.
`rake starters:check` must pass with every new gitlink, and the docs demo map's "Docs keep" column says what stays at
each old URL.

## Record

- 2026-11-14: operator decision ("1.8 작업으로 차수별 진행"), from the check that found 5 of 31 layout demos linked.
