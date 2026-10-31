---
toc: false
hero: {visual: showcase}
title: خانه
description: مستنداتی که Markdown ساده می‌مانند و در GitHub، GitHub Pages و برای عامل‌های هوش مصنوعی خوانا هستند.
sections:
  - {c: features, name: why, cols: 3}
  - {c: tabs, name: quickstart}
  - journey
  - {c: cta, name: start}
---
# مستنداتی که Markdown ساده می‌مانند

jekyll-theme-modootoday فایل‌های استاندارد GitHub Flavored Markdown را به یک سایت مستندات مرتب تبدیل می‌کند. همان فایل در github.com، در GitHub Pages و به‌صورت نسخهٔ Markdown برای عامل‌های هوش مصنوعی خوانا است.

[شروع کنید](../guides/install/) [مرور مؤلفه‌ها](../components/) [GitHub](https://github.com/modootoday/jekyll-theme-modootoday)

## چرا پوستهٔ modoo.today

- **فقط Markdown استاندارد** — هشدارها، جدول‌ها، فهرست‌ها و بلوک‌های کد. در صفحه‌های شما HTML، Liquid یا افزونه‌های kramdown لازم نیست.
- **روی GitHub Pages کار می‌کند** — پوسته‌ای فقط با Liquid برای ساخت کلاسیک `github-pages`، و Jekyll 4 برای بقیهٔ موارد.
- **خوانا برای عامل‌ها** — هر صفحه یک نسخهٔ Markdown بایت‌به‌بایت یکسان دارد، به‌علاوهٔ `llms.txt` و `llms-full.txt`.

## شروع سریع

### remote_theme

```yaml
remote_theme: modootoday/jekyll-theme-modootoday@v1.4.0
plugins: [jekyll-remote-theme]
```

### Gemfile

```ruby
gem "jekyll-theme-modootoday", "~> 1.4"
```

### _config.yml

```yaml
theme: jekyll-theme-modootoday
permalink: pretty
```

## مسیر شما در مستندات

1. پوسته را روی GitHub Pages یا Jekyll 4 [نصب کنید](../guides/install/).
2. [نخستین صفحهٔ خود را](../guides/first-page/) با Markdown ساده بنویسید.
3. از میان [مؤلفه‌ها](../components/) و [صفحهٔ همهٔ مؤلفه‌ها](../components/kitchen-sink/) انتخاب کنید.
4. در [پیکربندی](../guides/configuration/) تنظیم کنید و ظاهر را با توکن‌ها و `_sass` [سفارشی کنید](../guides/customize/).
5. با نسخه‌های Markdown و `llms.txt` سایت را [برای عامل‌ها خوانا کنید](../guides/agents/).

> [!NOTE]
> این صفحه از [متن اصلی انگلیسی](../) ترجمه شده است؛ در صورت تفاوت، متن انگلیسی معتبر است. راهنماهای پیوندشده به انگلیسی هستند.

## همین حالا شروع کنید

[نصب پوسته](../guides/install/) [دیدن همهٔ مؤلفه‌ها](../components/kitchen-sink/)
