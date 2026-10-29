---
id: adr:modootoday/20261029234209
title: "schema.org JSON-LD is one @graph per page, validated offline"
status: active
created: 2026-10-29T23:42:09Z
updated: 2026-10-29T23:42:09Z
rel:
  governs: [_includes/modootoday/jsonld/, lib/modootoday/check/structured_data.rb, docs/structured-data.md]
---

# schema.org JSON-LD is one @graph per page, validated offline

## Context

Search engines and AI tools rely on schema.org structured data. The theme printed none, sites adding their own risked duplicate or invalid blocks, and github-pages forbids plugins such as jekyll-seo-tag's richer output.

## Decision

The head prints one application/ld+json block holding a single @graph (WebSite, publisher, WebPage subtype, main entity, BreadcrumbList) with stable @ids (#website, #publisher, #webpage, #main, #breadcrumb), absolute URLs, inLanguage and ISO 8601 dates. It is built in Liquid from small includes under _includes/modootoday/jsonld/, uses jsonify and escapes < as \u003c so it is inert under a strict CSP. Types follow the layout; front matter schema: adds or overrides properties; modootoday.schema configures or disables it. Without site.url nothing is printed. FAQ and sitelinks-search rich results are retired by Google, so SearchAction is opt-in. modootoday-check validates the output against a vocabulary file generated from the schema.org release (script/schema-vocab) and a required-property table from Google's guidance, without network access.

## Consequences

Every theme site gets valid structured data by default and one place to extend it. The vocabulary file must be regenerated when schema.org releases new terms. Nested URLs in front matter are not rewritten and must be absolute; the checker reports them.
