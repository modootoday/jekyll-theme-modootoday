---
id: adr:modootoday/20261029201227
title: English is the canonical language for public docs
status: active
created: 2026-10-29T20:12:27Z
updated: 2026-10-29T20:12:27Z
---

# English is the canonical language for public docs

## Context

Contributors and agents work in several languages; the theme ships en/ko/ja content and README.ko.md is a translation.

## Decision

English is canonical. Every public document (`.spec/`, RULES.md, README.md, CHANGELOG.md) is written in English; translations follow it. Local-only notes may be in Korean or English, but anything promoted to public is written in English.

## Consequences

When an English text and a translation disagree, the English text wins and the translation is updated.
