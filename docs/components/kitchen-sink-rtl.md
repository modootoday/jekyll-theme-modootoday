---
nav_exclude: true
title: Kitchen sink (RTL)
description: A right-to-left sample in Arabic to check that every component mirrors with dir="rtl".
lang: ar
twin: false
sections:
  - badge
  - typography
  - callout
  - code
  - table
  - {c: accordion, name: accordion}
  - {c: steps, name: steps}
  - {c: tabs, name: tabs}
  - {c: timeline, name: timeline}
  - {c: features, name: cards, cols: 3}
  - {c: cta, name: cta}
---
# صفحة العرض من اليمين إلى اليسار

تعرض هذه الصفحة المكوّنات باتجاه من اليمين إلى اليسار. تضبط السمة `dir="rtl"` تلقائيًا للغات مثل العربية والعبرية والفارسية، أو عبر `direction: rtl` في رأس الصفحة.

[ابدأ الآن](../../guides/install/) [المكوّنات](../)

## الشارات

`status:available` `status:partial` `status:planned` `tag:beta` واختصار لوحة المفاتيح `kbd:Ctrl+K`.

## الطباعة

نص عادي مع **خط عريض** و*مائل* و[رابط](#).[^1]

> اقتباس عادي ليس تنبيهًا.

- عنصر أول
  - عنصر متداخل
- عنصر ثانٍ

[^1]: حاشية.

## التنبيهات

> [!NOTE]
> معلومة مفيدة ينبغي أن يعرفها القارئ حتى عند التصفح السريع.

> [!TIP]
> نصيحة تساعد على إنجاز العمل بشكل أفضل.

> [!IMPORTANT]
> معلومة أساسية لتحقيق الهدف.

> [!WARNING]
> معلومة عاجلة تتطلب الانتباه لتجنّب المشكلات.

> [!CAUTION]
> تحذير من المخاطر أو النتائج السلبية.

## الشيفرة

تبقى الشيفرة من اليسار إلى اليمين داخل النص العربي:

```ruby
puts "Hello, #{name}"
```

## الجداول

| المفتاح | النوع | الافتراضي |
|---|---|---|
| `badges` | منطقي | `true` |
| `color_scheme` | نص | `auto` |

`chart:bar`

| الربع | الزيارات |
|---|---|
| الأول | 4,160 |
| الثاني | 5,270 |
| الثالث | 5,910 |

*الزيارات في كل ربع*

## الأسئلة الشائعة

### ما فائدة هذه الصفحة؟

تكشف أي خاصية فيزيائية (left أو right) لم تتحول إلى خاصية منطقية.

### هل تعمل بلا JavaScript؟

نعم، تبقى كل إجابة ظاهرة تحت سؤالها.

## الخطوات

1. أضف السمة إلى `_config.yml`.
2. اكتب `index.md` بلغة Markdown.
3. شغّل `bundle exec jekyll build`.

## التبويبات

### macOS

```sh
brew install ruby
```

### Linux

```sh
sudo apt install ruby-full
```

### Windows

```sh
winget install RubyInstallerTeam.Ruby
```

## السجل الزمني

### البداية

أول إصدار عام.

### 1.0.0

عقد المكوّنات، ودعم الاتجاه من اليمين إلى اليسار، ودليل الرياضيات والمخططات.

## البطاقات

- **التنبيهات** — خمسة أنواع من تنبيهات GitHub. `status:available`
- **التبويبات** — تبويبات تثبيت سهلة الوصول. `status:partial`
- **البحث** — بحث داخل الموقع. `status:planned`

## دعوة إلى العمل

[ابدأ الآن](../../guides/install/) [اقرأ القواعد](https://github.com/modootoday/jekyll-theme-modootoday/blob/main/RULES.md)
