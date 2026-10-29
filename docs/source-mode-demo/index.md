# Source mode demo

This page has no front matter. GitHub Pages renders it to HTML, and the same file is also served as is, so it is its own Markdown twin. No stub file is needed.

## How it works

`jekyll-optional-front-matter` is on by default on classic GitHub Pages. For a `.md` file without front matter it does two things:

1. It renders the file with the site's default layout.
2. It copies the raw file to the same path in the built site.

So this page is available in two forms:

- HTML: [/source-mode-demo/](./)
- Markdown: [/source-mode-demo/index.md](index.md)

## Turn it on

Set the mode in your site's `_config.yml`:

```yaml
modootoday:
  twins: source
defaults:
  - {scope: {path: ""}, values: {layout: doc}}
```

Pages without front matter then use their source file as the twin. Pages that keep front matter still use a stub, so both kinds can live in one site.

> [!NOTE]
> Without front matter, settings such as `layout` and `lang` come from `defaults:` and the title comes from the first heading.

## Check it

Run the checker on your build:

```sh
bundle exec modootoday-check . _site --twins
```

It fails if a raw copy is missing or differs from its source.
