---
lang: tr
permalink: /tr/
source_rev: sha256:553827506a0a
toc: false
hero: {visual: showcase}
title: Ana sayfa
description: Düz Markdown olarak kalan, GitHub'da, GitHub Pages'te ve yapay zekâ ajanlarında rahat okunan belgeler.
sections:
  - {c: features, name: why, cols: 3}
  - {c: tabs, name: quickstart}
  - journey
  - {c: cta, name: start}
---
# Düz Markdown olarak kalan belgeler

jekyll-theme-modootoday, standart GitHub Flavored Markdown dosyalarını sade bir belge sitesine dönüştürür. Aynı dosya github.com'da, GitHub Pages'te ve yapay zekâ ajanları için Markdown sürümü olarak rahatça okunur.

[Başlayın](../guides/install.md) [Bileşenlere göz atın](../components/index.md) [GitHub](https://github.com/modootoday/jekyll-theme-modootoday)

## Neden modoo.today teması

- **Yalnızca standart Markdown** — Uyarılar, tablolar, listeler ve kod blokları. Sayfalarınızda HTML, Liquid ya da kramdown eklentisi yok.
- **GitHub Pages'te çalışır** — Klasik `github-pages` derlemesi için yalnızca Liquid kullanan bir tema; diğer her şey için Jekyll 4.
- **Ajanlar için okunaklı** — Her sayfanın kaynakla bayt bayt aynı bir Markdown sürümü, ayrıca `llms.txt` ve `llms-full.txt` dosyaları vardır.

## Hızlı başlangıç

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

## Belgelerde izleyeceğiniz yol

1. Temayı GitHub Pages'e veya Jekyll 4'e [kurun](../guides/install.md).
2. Düz Markdown ile [ilk sayfanızı yazın](../guides/first-page.md).
3. [Bileşenler](../components/index.md) ve [tüm bileşenler sayfası](../components/kitchen-sink.md) arasından seçin.
4. [Yapılandırma](../guides/configuration.md) ile ayarlayın, görünümü token'lar ve `_sass` ile [özelleştirin](../guides/customize.md).
5. Markdown sürümleri ve `llms.txt` ile sitenizi [ajanların okuyabileceği](../guides/agents.md) hâle getirin.

> [!NOTE]
> Bu sayfa [İngilizce aslından](../index.md) çevrilmiştir; farklılık olursa İngilizce sürüm geçerlidir. Bağlantı verilen kılavuzlar İngilizcedir.

## Hemen başlayın

[Temayı kurun](../guides/install.md) [Tüm bileşenleri görün](../components/kitchen-sink.md)
