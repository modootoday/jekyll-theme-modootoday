---
toc: false
hero: {visual: showcase}
title: Startseite
description: Dokumentation in reinem Markdown, gut lesbar auf GitHub, in GitHub Pages und für KI-Agenten.
sections:
  - {c: features, name: why, cols: 3}
  - {c: tabs, name: quickstart}
  - journey
  - {c: cta, name: start}
---
# Dokumentation, die reines Markdown bleibt

jekyll-theme-modootoday macht aus standardmäßigem GitHub Flavored Markdown eine aufgeräumte Dokumentationsseite. Dieselbe Datei liest sich gut auf github.com, in GitHub Pages und als Markdown-Fassung für KI-Agenten.

[Loslegen](../guides/install/) [Komponenten ansehen](../components/) [GitHub](https://github.com/modootoday/jekyll-theme-modootoday)

## Warum das modoo.today Theme

- **Nur Standard-Markdown** — Hinweise, Tabellen, Listen und Codeblöcke. Kein HTML, kein Liquid und keine kramdown-Erweiterungen in Ihren Seiten.
- **Läuft in GitHub Pages** — Ein reines Liquid-Theme für den klassischen `github-pages`-Build, für alles andere Jekyll 4.
- **Für Agenten lesbar** — Jede Seite hat eine bytegleiche Markdown-Fassung, dazu `llms.txt` und `llms-full.txt`.

## Schnellstart

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

## Ihr Weg durch die Dokumentation

1. [Installieren](../guides/install/) Sie das Theme in GitHub Pages oder Jekyll 4.
2. [Schreiben Sie Ihre erste Seite](../guides/first-page/) in reinem Markdown.
3. Wählen Sie aus den [Komponenten](../components/) und der [Gesamtübersicht](../components/kitchen-sink/).
4. Passen Sie die [Konfiguration](../guides/configuration/) an und [gestalten Sie das Aussehen](../guides/customize/) mit Tokens und `_sass`.
5. Machen Sie die Seite mit Markdown-Fassungen und `llms.txt` [für Agenten lesbar](../guides/agents/).

> [!NOTE]
> Diese Seite ist eine Übersetzung des [englischen Originals](../); bei Abweichungen gilt die englische Fassung. Die verlinkten Anleitungen sind auf Englisch.

## Jetzt starten

[Theme installieren](../guides/install/) [Alle Komponenten ansehen](../components/kitchen-sink/)
