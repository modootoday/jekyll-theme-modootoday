# frozen_string_literal: true

module Modootoday
  module Check
    # Command line: usage, --help/--version, running the rule groups in order, reporting.
    module CLI
      USAGE = "usage: modootoday-check SRC SITE [--twins] [--aliases] [--links] [--byte-exact=DIR,...] [--github-pages[=VERSION]] [--gh] [--strict] [--schema-recommended] [--i18n] [--i18n-pages] [--i18n-init=LANG,...]\n       modootoday-check SRC --diagrams\n       modootoday-check SRC --math"
      # Single source for --help and the README "Commands" table (script/readme-commands, test/project/readme_test.rb).
      OPTIONS = [
        ["SRC SITE", "always: front matter, forbidden syntax, alerts, fence info strings, `status:`/`tag:`/`kbd:` values (`since:` is rejected), `sections:` count, `feed:` (false, or a site path to an Atom feed page in the build), `_data/i18n/<lang>.yml` keys against the default language and translated pages against default-language pages, `_data/components.yml` (keys, slot contract counts per section, `parts` against `api.md` and the built HTML), Sass/CSS rules, the token hook `_sass/modootoday/_site.scss` (only the three override maps, known token names), `site_css`, `preload` and `scripts` files present in the build, `script:` and `poster:` on hero and section items (a registered script, a sized poster that exists), `filter:` on section items and pages (a list or table to filter, a `facet` column the table has), `chart:` lines and `c: chart` sections (a type and options, a table or a `_data/charts` file, number cells), `widget:` lines, `widget_props` and `c: widget` sections (an element a `modootoday.scripts` entry defines, plain prop values, a lead paragraph), `diagrams:` (an entry per Mermaid fence, `alt`, the SVG files, an SVG drawn from another fence), static math (an entry per math block in `_data/math`, entries rendered from other TeX, no inline math),`modootoday.search` keys and collections, `modootoday.showcase` (also in `_config.demo.yml`) and, while it is enabled, the robots `noindex` on every built page (warning), `search.json` over 1.5 MB (warning), unconverted markers in the build, schema.org JSON-LD in the build (valid JSON, vocabulary, required properties per type, absolute URLs, ISO 8601 dates, one graph per page, agreement with Open Graph, a `DefinedTerm` page's `term_set` glossary), `modootoday.schema.faq`, `modootoday.records` (a page per record and a record per page, as `modootoday-stubs --records --check` judges), `modootoday.pwa` (its keys and icons, the stub `modootoday-stubs --pwa` writes, the built manifest's fields, icon files and their PNG sizes, the manifest link on every page)"],
        ["--twins", "every page has a byte-identical Markdown twin, per-language `llms.txt` and `llms-full.txt`"],
        ["--links", "same-site links in the built HTML (`a`, `link`, `img`, `script`, `source srcset`) point at files that exist and `#` fragments match an `id` or `a[name]` on the target page; external URLs are not fetched. Warnings, failures with `--strict`; needs the nokogiri gem, and fails the run without it"],
        ["--aliases", "the URL aliases `modootoday.aliases` declares: `/<page>.md` byte-identical to the twin (`md`), `/<page>.html` redirecting to the page with the page URL as canonical (`html`); two pages with one alias, or an alias over another source file, fail"],
        ["--byte-exact=DIR,...", "files under these source folders (an API, downloads) are in the build with the same sha256; a folder under `_` or `.` or excluded, a file with front matter, or one Jekyll converts (Markdown, Sass) fails"],
        ["--github-pages[=VERSION]", "`Gemfile.lock` pins `github-pages` VERSION (default 232)"],
        ["--schema-recommended", "also warn about schema.org properties Google Search recommends (author, image, dates, ...) that a JSON-LD node lacks"],
        ["--strict", "warnings fail the run"],
        ["--i18n", "`_data/i18n/<lang>.yml` against the theme registry (`i18n/en.yml` in the gem): unknown keys, `%{name}` placeholder mismatches, and pages marked `translation: pending`"],
        ["--i18n-pages", "warn about default-language pages with no translation in a `modootoday.full_languages` language (the page with the same `ref:`, else `<name>.<lang>.md` beside it or the same path under `<lang>/`) and about translations without `source_rev` or whose source changed since it; with `--strict` they fail. A translation beside its source whose `permalink` is not the source's URL under `/<lang>` is an error"],
        ["--i18n-init=LANG,...", "copy the theme's catalogs (`i18n/<lang>.yml`, 23 languages) into `SRC/_data/i18n/` as a starting point for overrides (optional; the theme already uses them), and list keys an existing catalog lacks"],
        ["--diagrams", "instead of checking, print the static diagrams whose SVG is missing or stale as JSON (`page`, `name`, `line`, `fence`, `digest`, `files`, `reason`) and exit 1 when there is any; SITE may be omitted. A pre-commit hook or a render script reads it"],
        ["--math", "with `modootoday.math.mode: static`, instead of checking, print the `_data/math` files whose page has math blocks without an entry or with a stale one as JSON (`key`, `file`, `page`, `blocks` with `line`, `tex` and `digest`, `reason`) and exit 1 when there is any; SITE may be omitted. `script/figures/math.mjs` reads it"],
        ["--gh", "also render each page with `gh api markdown` (network, `gh` login)"],
        ["--help, -h", "print usage and options (`--help=markdown` prints the README table)"],
        ["--version", "print the rules version"],
      ].freeze
      # Rule groups in report order.
      RULES = [Registry, SiteConfig.method(:source_mode), Pages, Layouts, Native::Layouts, Native::Collections, I18n, Registry.method(:i18n_keys), BuiltParts,
               BuildOutput.method(:residue), NewWindow.method(:built), Illustration, StructuredData, TermSets, Stylesheets, SiteHook, BuildOutput.method(:css), BuildOutput.method(:search_index), SiteConfig, ShowcaseBuild, SiteAssets, Renderers, Blog, GithubPages, Twins, Aliases, Records, Links, Feeds, Pwa, ByteExact, GhRender].freeze

      module_function

      def run(argv)
        return help(argv.find { |a| a == "-h" || a.start_with?("--help") }) if argv.any? { |a| a == "-h" || a.start_with?("--help") }
        return (puts "modootoday-check (md-components v1)"; 0) if argv.include?("--version")

        pos = argv.reject { |a| a.start_with?("--") }
        src, site = pos[0]&.chomp("/"), pos[1]&.chomp("/")
        return FigureFreshness.list(Context.new(src, site, argv)) if src && argv.include?("--diagrams")
        return MathStatic.list(Context.new(src, site, argv)) if src && argv.include?("--math")
        abort "modootoday-check: SITE is missing: the checker reads the source and the built site, so build first and name both, such as\n  bundle exec jekyll build && bundle exec modootoday-check #{src} _site\n(--diagrams and --math need no SITE)\n\n#{USAGE}" if src && !site
        abort USAGE unless src && site
        ctx = Context.new(src, site, argv)
        RULES.each { |r| r.call(ctx) }
        report(ctx)
      end

      def help(h)
        if h == "--help=markdown"
          puts "| Option | Checks |", "|---|---|"
          OPTIONS.each { |o, d| puts "| `#{o}` | #{d.gsub("|", "\\|")} |" }
        else
          puts USAGE, "", "options:"
          OPTIONS.each { |o, d| puts format("  %-26s %s", o, d.delete("`")) }
          puts "", "exit status: 0 no problems, 1 problems found or bad usage"
        end
        0
      end

      def report(ctx)
        errs, warns = ctx.errs, ctx.warns
        errs.concat(warns.map { |w| "#{w} [strict]" }) if ctx.option?("--strict")
        warns.each { |w| warn "warning: #{w}" } unless ctx.option?("--strict")
        puts errs
        puts errs.empty? ? "md-components check: OK (#{ctx.mds.size} pages)" : "md-components check: #{errs.size} problem(s)"
        errs.empty? ? 0 : 1
      end
    end
  end
end
