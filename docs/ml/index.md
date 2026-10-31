---
toc: false
hero: {visual: showcase}
title: ഹോം
description: സാധാരണ Markdown ആയി തുടരുന്ന, GitHub-ലും GitHub Pages-ലും AI ഏജന്റുകൾക്കും എളുപ്പം വായിക്കാവുന്ന ഡോക്യുമെന്റേഷൻ.
sections:
  - {c: features, name: why, cols: 3}
  - {c: tabs, name: quickstart}
  - journey
  - {c: cta, name: start}
---
# എഴുത്ത് എന്നും സാധാരണ Markdown-ൽ

jekyll-theme-modootoday സാധാരണ GitHub Flavored Markdown-നെ വൃത്തിയുള്ള ഒരു ഡോക്യുമെന്റേഷൻ സൈറ്റാക്കി മാറ്റുന്നു. ഒരേ ഫയൽ github.com-ലും GitHub Pages-ലും AI ഏജന്റുകൾക്കുള്ള Markdown പതിപ്പായും നന്നായി വായിക്കാം.

[തുടങ്ങാം](../guides/install/) [ഘടകങ്ങൾ കാണുക](../components/) [GitHub](https://github.com/modootoday/jekyll-theme-modootoday)

## എന്തുകൊണ്ട് modoo.today തീം

- **സാധാരണ Markdown മാത്രം** — അലേർട്ടുകൾ, പട്ടികകൾ, ലിസ്റ്റുകൾ, കോഡ് ബ്ലോക്കുകൾ. പേജുകളിൽ HTML, Liquid, kramdown വിപുലീകരണങ്ങൾ ഒന്നും വേണ്ട.
- **GitHub Pages-ൽ പ്രവർത്തിക്കുന്നു** — ക്ലാസിക് `github-pages` ബിൽഡിനായി Liquid മാത്രം ഉപയോഗിക്കുന്ന തീം; മറ്റെല്ലാത്തിനും Jekyll 4.
- **ഏജന്റുകൾക്ക് വായിക്കാം** — ഓരോ പേജിനും ബൈറ്റ് തോറും ഒരുപോലെയുള്ള Markdown പതിപ്പും `llms.txt`, `llms-full.txt` എന്നിവയും ഉണ്ട്.

## വേഗത്തിൽ തുടങ്ങാം

### remote_theme

```yaml
remote_theme: modootoday/jekyll-theme-modootoday@v1.4.0
plugins: [jekyll-remote-theme]
```

### Gemfile

```ruby
gem "jekyll-theme-modootoday", "~> 1.4"
```

### _config.yml

```yaml
theme: jekyll-theme-modootoday
permalink: pretty
```

## വായനയുടെ വഴി

1. GitHub Pages-ലോ Jekyll 4-ലോ തീം [ഇൻസ്റ്റാൾ ചെയ്യുക](../guides/install/).
2. സാധാരണ Markdown-ൽ [ആദ്യ പേജ് എഴുതുക](../guides/first-page/).
3. [ഘടകങ്ങളിൽ](../components/) നിന്നും [എല്ലാ ഘടകങ്ങളുടെയും പേജിൽ](../components/kitchen-sink/) നിന്നും തിരഞ്ഞെടുക്കുക.
4. [ക്രമീകരണങ്ങളിൽ](../guides/configuration/) മാറ്റം വരുത്തി, ടോക്കണുകളും `_sass`-ഉം ഉപയോഗിച്ച് [രൂപം ഇഷ്ടാനുസൃതമാക്കുക](../guides/customize/).
5. Markdown പതിപ്പുകളും `llms.txt`-ഉം വഴി സൈറ്റ് [ഏജന്റുകൾക്ക് വായിക്കാവുന്നതാക്കുക](../guides/agents/).

> [!NOTE]
> ഈ പേജ് [ഇംഗ്ലീഷ് മൂലരൂപത്തിൽ](../) നിന്നുള്ള വിവർത്തനമാണ്; വ്യത്യാസമുണ്ടെങ്കിൽ ഇംഗ്ലീഷ് പതിപ്പാണ് ആധികാരികം. ലിങ്ക് ചെയ്ത ഗൈഡുകൾ ഇംഗ്ലീഷിലാണ്.

## ഇപ്പോൾ തുടങ്ങാം

[തീം ഇൻസ്റ്റാൾ ചെയ്യുക](../guides/install/) [എല്ലാ ഘടകങ്ങളും കാണുക](../components/kitchen-sink/)
