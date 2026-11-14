---
lang: ru
permalink: /ru/
source_rev: sha256:553827506a0a
toc: false
hero: {visual: showcase}
title: Главная
description: Документация в обычном Markdown, которая хорошо читается на GitHub, в GitHub Pages и ИИ-агентами.
sections:
  - {c: features, name: why, cols: 3}
  - {c: tabs, name: quickstart}
  - journey
  - {c: cta, name: start}
---
# Документация остаётся обычным Markdown

jekyll-theme-modootoday превращает стандартный GitHub Flavored Markdown в аккуратный сайт документации. Один и тот же файл хорошо читается на github.com, в GitHub Pages и как Markdown-версия для ИИ-агентов.

[Начать](../guides/install.md) [Компоненты](../components/index.md) [GitHub](https://github.com/modootoday/jekyll-theme-modootoday)

## Почему тема modoo.today

- **Только стандартный Markdown** — Уведомления, таблицы, списки и блоки кода. Никакого HTML, Liquid или расширений kramdown на страницах.
- **Работает в GitHub Pages** — Тема только на Liquid для классической сборки `github-pages`, а для остального — Jekyll 4.
- **Понятно ИИ-агентам** — У каждой страницы есть побайтно совпадающая Markdown-версия, а также `llms.txt` и `llms-full.txt`.

## Быстрый старт

### remote_theme

```yaml
remote_theme: modootoday/jekyll-theme-modootoday@v1.6.0
plugins: [jekyll-remote-theme]
```

### Gemfile

```ruby
gem "jekyll-theme-modootoday", "~> 1.6"
```

### _config.yml

```yaml
theme: jekyll-theme-modootoday
permalink: pretty
```

## Как читать документацию

1. [Установите](../guides/install.md) тему в GitHub Pages или Jekyll 4.
2. [Напишите первую страницу](../guides/first-page.md) на обычном Markdown.
3. Выберите нужное среди [компонентов](../components/index.md) и на [странице со всеми компонентами](../components/kitchen-sink.md).
4. Настройте сайт в [конфигурации](../guides/configuration.md) и [измените оформление](../guides/customize.md) с помощью токенов и `_sass`.
5. Сделайте сайт [понятным ИИ-агентам](../guides/agents.md) с Markdown-версиями и `llms.txt`.

> [!NOTE]
> Эта страница переведена с [английского оригинала](../index.md); при расхождениях действует английская версия. Руководства по ссылкам доступны на английском.

## Начните сейчас

[Установить тему](../guides/install.md) [Все компоненты](../components/kitchen-sink.md)
