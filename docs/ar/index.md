---
toc: false
hero: {visual: showcase}
title: الرئيسية
description: توثيق يبقى بلغة Markdown العادية، ويُقرأ بوضوح على GitHub وGitHub Pages ولدى وكلاء الذكاء الاصطناعي.
sections:
  - {c: features, name: why, cols: 3}
  - {c: tabs, name: quickstart}
  - journey
  - {c: cta, name: start}
---
# توثيق يبقى Markdown عاديًا

يحوّل jekyll-theme-modootoday ملفات GitHub Flavored Markdown القياسية إلى موقع توثيق مرتّب. يُقرأ الملف نفسه بوضوح على github.com وعلى GitHub Pages، وكنسخة Markdown لوكلاء الذكاء الاصطناعي.

[ابدأ الآن](../guides/install/) [تصفّح المكوّنات](../components/) [GitHub](https://github.com/modootoday/jekyll-theme-modootoday)

## لماذا قالب modoo.today

- **Markdown القياسية فقط** — تنبيهات وجداول وقوائم وكتل برمجية. لا HTML ولا Liquid ولا امتدادات kramdown في صفحاتك.
- **يعمل على GitHub Pages** — قالب يعتمد على Liquid وحدها لبناء `github-pages` الكلاسيكي، وJekyll 4 لما سوى ذلك.
- **مقروء للوكلاء** — لكل صفحة نسخة Markdown مطابقة لها بايتًا ببايت، إضافةً إلى `llms.txt` و`llms-full.txt`.

## بداية سريعة

### remote_theme

```yaml
remote_theme: modootoday/jekyll-theme-modootoday@v1.3.0
plugins: [jekyll-remote-theme]
```

### Gemfile

```ruby
gem "jekyll-theme-modootoday", "~> 1.3"
```

### _config.yml

```yaml
theme: jekyll-theme-modootoday
permalink: pretty
```

## مسارك في التوثيق

1. [ثبّت](../guides/install/) القالب على GitHub Pages أو Jekyll 4.
2. [اكتب صفحتك الأولى](../guides/first-page/) بلغة Markdown العادية.
3. اختر من [المكوّنات](../components/) ومن [صفحة جميع المكوّنات](../components/kitchen-sink/).
4. اضبطه عبر [الإعدادات](../guides/configuration/) و[خصّص المظهر](../guides/customize/) باستخدام الرموز المميّزة و`_sass`.
5. اجعل موقعك [مقروءًا للوكلاء](../guides/agents/) بفضل نسخ Markdown و`llms.txt`.

> [!NOTE]
> هذه الصفحة مترجمة عن [الأصل الإنجليزي](../)، وعند أي اختلاف يُعتمد النص الإنجليزي. الأدلة المرتبطة متاحة بالإنجليزية.

## ابدأ الآن

[ثبّت القالب](../guides/install/) [اعرض جميع المكوّنات](../components/kitchen-sink/)
