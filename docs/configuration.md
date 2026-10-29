---
title: Configuration
description: Site-wide settings under the modootoday key in _config.yml.
sections:
  - keys
  - i18n
  - registry
  - {c: cta, name: next}
---
# Configuration

Everything is optional. Settings live under one `modootoday:` key so they never clash with other plugins.

## Keys

```yaml
modootoday:
  badges: true        # status badges on code spans
  color_scheme: auto  # auto | light | dark
  components: [callout, badge, cta, card, tabs]
  tokens: {primary: "#4f46e5", radius: "0.5rem"}
```

| Key | Default | Effect |
|---|---|---|
| `badges` | `true` | turn status code spans into badges; `false` keeps code |
| `color_scheme` | `auto` | follow the OS or force light or dark |
| `components` | all core | limit the CSS and JS that are shipped |
| `tokens` | theme values | override design tokens inline |

> [!NOTE]
> Keys other than `badges` arrive with v0.2. Until then they are ignored safely.

## Languages

Put interface strings in `_data/i18n/<lang>.yml` and pages in `<lang>/`:

```yaml
language: 한국어
callout: {note: 참고, tip: 팁, important: 중요, warning: 경고, caution: 주의}
tabs: {label: 설치 방법}
status: {available: 사용 가능, partial: 일부 구현, planned: 계획}
skip: 본문으로 건너뛰기
```

Missing keys fall back to English.

## Component registry

An optional `_data/components.yml` lets the checker validate `sections:` parameters:

```yaml
features: {params: {cols: {allowed: [2, 3], required: false}}}
tabs: {i18n: [tabs.label]}
cta: {}
```

## Next

[Customize the look](../customize/) [Components](../components/)
