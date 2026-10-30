---
toc: false
hero: {visual: showcase}
title: Accueil
description: Une documentation en Markdown simple, lisible sur GitHub, sur GitHub Pages et par les agents d’IA.
sections:
  - {c: features, name: why, cols: 3}
  - {c: tabs, name: quickstart}
  - journey
  - {c: cta, name: start}
---
# Une documentation qui reste du Markdown simple

jekyll-theme-modootoday transforme du GitHub Flavored Markdown standard en un site de documentation soigné. Le même fichier se lit bien sur github.com, sur GitHub Pages et sous forme de version Markdown pour les agents d’IA.

[Commencer](../guides/install/) [Parcourir les composants](../components/) [GitHub](https://github.com/modootoday/jekyll-theme-modootoday)

## Pourquoi le thème modoo.today

- **Uniquement du Markdown standard** — Alertes, tableaux, listes et blocs de code. Pas de HTML, pas de Liquid, pas d’extensions kramdown dans vos pages.
- **Compatible GitHub Pages** — Un thème uniquement en Liquid pour la compilation classique `github-pages`, et Jekyll 4 pour tout le reste.
- **Lisible par les agents** — Chaque page dispose d’une version Markdown identique octet par octet, ainsi que de `llms.txt` et `llms-full.txt`.

## Démarrage rapide

### remote_theme

```yaml
remote_theme: modootoday/jekyll-theme-modootoday@v1.1.0
plugins: [jekyll-remote-theme]
```

### Gemfile

```ruby
gem "jekyll-theme-modootoday", "~> 1.1"
```

### _config.yml

```yaml
theme: jekyll-theme-modootoday
permalink: pretty
```

## Votre parcours dans la documentation

1. [Installez](../guides/install/) le thème sur GitHub Pages ou Jekyll 4.
2. [Rédigez votre première page](../guides/first-page/) en Markdown simple.
3. Choisissez parmi les [composants](../components/) et la [page de tous les composants](../components/kitchen-sink/).
4. Réglez la [configuration](../guides/configuration/) et [personnalisez](../guides/customize/) l’apparence avec les tokens et `_sass`.
5. Rendez le site [lisible par les agents](../guides/agents/) grâce aux versions Markdown et à `llms.txt`.

> [!NOTE]
> Cette page est une traduction de l’[original anglais](../) ; en cas d’écart, la version anglaise fait foi. Les guides liés sont en anglais.

## Commencez maintenant

[Installer le thème](../guides/install/) [Voir tous les composants](../components/kitchen-sink/)
