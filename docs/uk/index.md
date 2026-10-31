---
toc: false
hero: {visual: showcase}
title: Головна
description: Документація у звичайному Markdown, яку зручно читати на GitHub, у GitHub Pages та ШІ-агентам.
sections:
  - {c: features, name: why, cols: 3}
  - {c: tabs, name: quickstart}
  - journey
  - {c: cta, name: start}
---
# Документація залишається звичайним Markdown

jekyll-theme-modootoday перетворює стандартний GitHub Flavored Markdown на охайний сайт документації. Той самий файл добре читається на github.com, у GitHub Pages і як Markdown-версія для ШІ-агентів.

[Почати](../guides/install/) [Компоненти](../components/) [GitHub](https://github.com/modootoday/jekyll-theme-modootoday)

## Чому тема modoo.today

- **Лише стандартний Markdown** — Сповіщення, таблиці, списки та блоки коду. Жодного HTML, Liquid чи розширень kramdown на сторінках.
- **Працює в GitHub Pages** — Тема лише на Liquid для класичного збирання `github-pages`, а для решти — Jekyll 4.
- **Зрозуміло ШІ-агентам** — Кожна сторінка має побайтово однакову Markdown-версію, а також `llms.txt` і `llms-full.txt`.

## Швидкий старт

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

## Як читати документацію

1. [Встановіть](../guides/install/) тему в GitHub Pages або Jekyll 4.
2. [Напишіть першу сторінку](../guides/first-page/) звичайним Markdown.
3. Оберіть потрібне серед [компонентів](../components/) і на [сторінці з усіма компонентами](../components/kitchen-sink/).
4. Налаштуйте сайт у [конфігурації](../guides/configuration/) та [змініть оформлення](../guides/customize/) за допомогою токенів і `_sass`.
5. Зробіть сайт [зрозумілим для ШІ-агентів](../guides/agents/) з Markdown-версіями та `llms.txt`.

> [!NOTE]
> Ця сторінка перекладена з [англійського оригіналу](../); у разі розбіжностей чинною є англійська версія. Посібники за посиланнями доступні англійською.

## Почніть зараз

[Встановити тему](../guides/install/) [Усі компоненти](../components/kitchen-sink/)
