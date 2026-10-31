---
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

[Начать](../guides/install/) [Компоненты](../components/) [GitHub](https://github.com/modootoday/jekyll-theme-modootoday)

## Почему тема modoo.today

- **Только стандартный Markdown** — Уведомления, таблицы, списки и блоки кода. Никакого HTML, Liquid или расширений kramdown на страницах.
- **Работает в GitHub Pages** — Тема только на Liquid для классической сборки `github-pages`, а для остального — Jekyll 4.
- **Понятно ИИ-агентам** — У каждой страницы есть побайтно совпадающая Markdown-версия, а также `llms.txt` и `llms-full.txt`.

## Быстрый старт

### remote_theme

```yaml
remote_theme: modootoday/jekyll-theme-modootoday@v1.2.3
plugins: [jekyll-remote-theme]
```

### Gemfile

```ruby
gem "jekyll-theme-modootoday", "~> 1.2"
```

### _config.yml

```yaml
theme: jekyll-theme-modootoday
permalink: pretty
```

## Как читать документацию

1. [Установите](../guides/install/) тему в GitHub Pages или Jekyll 4.
2. [Напишите первую страницу](../guides/first-page/) на обычном Markdown.
3. Выберите нужное среди [компонентов](../components/) и на [странице со всеми компонентами](../components/kitchen-sink/).
4. Настройте сайт в [конфигурации](../guides/configuration/) и [измените оформление](../guides/customize/) с помощью токенов и `_sass`.
5. Сделайте сайт [понятным ИИ-агентам](../guides/agents/) с Markdown-версиями и `llms.txt`.

> [!NOTE]
> Эта страница переведена с [английского оригинала](../); при расхождениях действует английская версия. Руководства по ссылкам доступны на английском.

## Начните сейчас

[Установить тему](../guides/install/) [Все компоненты](../components/kitchen-sink/)
