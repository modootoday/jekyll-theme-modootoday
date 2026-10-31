---
toc: false
hero: {visual: showcase}
title: Αρχική
description: Τεκμηρίωση σε απλό Markdown, ευανάγνωστη στο GitHub, στο GitHub Pages και για πράκτορες τεχνητής νοημοσύνης.
sections:
  - {c: features, name: why, cols: 3}
  - {c: tabs, name: quickstart}
  - journey
  - {c: cta, name: start}
---
# Τεκμηρίωση που μένει απλό Markdown

Το jekyll-theme-modootoday μετατρέπει το τυπικό GitHub Flavored Markdown σε έναν καθαρό ιστότοπο τεκμηρίωσης. Το ίδιο αρχείο διαβάζεται άνετα στο github.com, στο GitHub Pages και ως έκδοση Markdown για πράκτορες τεχνητής νοημοσύνης.

[Ξεκινήστε](../guides/install/) [Δείτε τα στοιχεία](../components/) [GitHub](https://github.com/modootoday/jekyll-theme-modootoday)

## Γιατί το θέμα modoo.today

- **Μόνο τυπικό Markdown** — Ειδοποιήσεις, πίνακες, λίστες και μπλοκ κώδικα. Χωρίς HTML, Liquid ή επεκτάσεις kramdown στις σελίδες σας.
- **Λειτουργεί στο GitHub Pages** — Θέμα μόνο με Liquid για την κλασική δόμηση `github-pages`, και Jekyll 4 για όλα τα υπόλοιπα.
- **Αναγνώσιμο από πράκτορες** — Κάθε σελίδα έχει μια πανομοιότυπη, byte προς byte, έκδοση Markdown, καθώς και `llms.txt` και `llms-full.txt`.

## Γρήγορη έναρξη

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

## Η διαδρομή σας στην τεκμηρίωση

1. [Εγκαταστήστε](../guides/install/) το θέμα στο GitHub Pages ή στο Jekyll 4.
2. [Γράψτε την πρώτη σας σελίδα](../guides/first-page/) σε απλό Markdown.
3. Επιλέξτε από τα [στοιχεία](../components/) και τη [σελίδα με όλα τα στοιχεία](../components/kitchen-sink/).
4. Ρυθμίστε τη [διαμόρφωση](../guides/configuration/) και [προσαρμόστε την εμφάνιση](../guides/customize/) με tokens και `_sass`.
5. Κάντε τον ιστότοπο [αναγνώσιμο από πράκτορες](../guides/agents/) με εκδόσεις Markdown και `llms.txt`.

> [!NOTE]
> Η σελίδα αυτή είναι μετάφραση του [αγγλικού πρωτοτύπου](../)· σε περίπτωση διαφοράς ισχύει το αγγλικό κείμενο. Οι οδηγοί στους συνδέσμους είναι στα αγγλικά.

## Ξεκινήστε τώρα

[Εγκατάσταση θέματος](../guides/install/) [Όλα τα στοιχεία](../components/kitchen-sink/)
