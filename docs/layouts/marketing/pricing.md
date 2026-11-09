---
title: Pricing layout
description: "Plan cards with a monthly and yearly switch that needs no JavaScript."
layout: layout-reference
nav_order: 2
---
# Pricing layout

`layout: pricing` prints your text, then one card per plan. When the plans have yearly prices, a Monthly/Yearly switch made of two radio buttons changes the prices with CSS alone, and one plan can be marked as recommended in text. The live demo is the pricing page of the landing starter.

## Front matter

| Key | Use |
|---|---|
| `plans` | The cards: `name`, `monthly`, `yearly`, `features` (a list), `recommended: true`, `cta: {label, url}` |
| `currency` | The symbol printed before every price, such as `$` |
| `description` | The lead under the title |
| `actions` | Buttons under the lead: `[{label, url}]` |

```yaml
---
layout: pricing
currency: $
plans:
  - {name: Free, monthly: 0, yearly: 0, features: [One site]}
  - {name: Team, monthly: 12, yearly: 120, recommended: true, features: [Ten sites, Support], cta: {label: Choose Team, url: /buy/}}
---
```

Set `yearly` on every plan or on none. [Marketing pages](../) lists the other marketing layouts and their front matter.
