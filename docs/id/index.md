---
toc: false
hero: {visual: showcase}
title: Beranda
description: Dokumentasi dalam Markdown biasa yang nyaman dibaca di GitHub, GitHub Pages, dan oleh agen AI.
sections:
  - {c: features, name: why, cols: 3}
  - {c: tabs, name: quickstart}
  - journey
  - {c: cta, name: start}
---
# Dokumentasi yang tetap Markdown biasa

jekyll-theme-modootoday mengubah GitHub Flavored Markdown standar menjadi situs dokumentasi yang rapi. Berkas yang sama nyaman dibaca di github.com, di GitHub Pages, dan sebagai versi Markdown untuk agen AI.

[Mulai](../guides/install/) [Lihat komponen](../components/) [GitHub](https://github.com/modootoday/jekyll-theme-modootoday)

## Mengapa tema modoo.today

- **Hanya Markdown standar** — Peringatan, tabel, daftar, dan blok kode. Tanpa HTML, Liquid, atau ekstensi kramdown di halaman Anda.
- **Berjalan di GitHub Pages** — Tema yang hanya memakai Liquid untuk build `github-pages` klasik, dan Jekyll 4 untuk kebutuhan lainnya.
- **Mudah dibaca agen** — Setiap halaman punya versi Markdown yang identik per byte, ditambah `llms.txt` dan `llms-full.txt`.

## Mulai cepat

### remote_theme

```yaml
remote_theme: modootoday/jekyll-theme-modootoday@v1.2.1
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

## Alur membaca dokumentasi

1. [Pasang](../guides/install/) tema di GitHub Pages atau Jekyll 4.
2. [Tulis halaman pertama](../guides/first-page/) dengan Markdown biasa.
3. Pilih dari [komponen](../components/) dan [halaman semua komponen](../components/kitchen-sink/).
4. Atur lewat [konfigurasi](../guides/configuration/) dan [sesuaikan tampilan](../guides/customize/) dengan token dan `_sass`.
5. Buat situs [mudah dibaca agen](../guides/agents/) dengan versi Markdown dan `llms.txt`.

> [!NOTE]
> Halaman ini diterjemahkan dari [naskah asli bahasa Inggris](../); jika ada perbedaan, versi bahasa Inggris yang berlaku. Panduan yang ditautkan tersedia dalam bahasa Inggris.

## Mulai sekarang

[Pasang tema](../guides/install/) [Lihat semua komponen](../components/kitchen-sink/)
