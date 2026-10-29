# frozen_string_literal: true

module Modootoday
  module Check
    # Command line: usage, --help/--version, running the rule groups in order, reporting.
    module CLI
      USAGE = "usage: modootoday-check SRC SITE [--twins] [--github-pages[=VERSION]] [--gh] [--strict] [--i18n] [--i18n-init=LANG,...]"
      # Single source for --help and the README "Commands" table (script/readme-commands, test/project/readme_test.rb).
      OPTIONS = [
        ["SRC SITE", "always: front matter, forbidden syntax, alerts, fence info strings, `status:`/`tag:`/`kbd:` values (`since:` is rejected), `sections:` count, `_data/i18n/<lang>.yml` keys against the default language and translated pages against default-language pages, `_data/components.yml` (keys, slot contract counts per section, `parts` against `api.md` and the built HTML), Sass/CSS rules, unconverted markers in the build"],
        ["--twins", "every page has a byte-identical Markdown twin, per-language `llms.txt` and `llms-full.txt`"],
        ["--github-pages[=VERSION]", "`Gemfile.lock` pins `github-pages` VERSION (default 232)"],
        ["--strict", "warnings fail the run"],
        ["--i18n", "`_data/i18n/<lang>.yml` against the theme registry (`i18n/en.yml` in the gem): unknown keys, `%{name}` placeholder mismatches, and pages marked `translation: pending`"],
        ["--i18n-init=LANG,...", "copy the theme's catalogs (`i18n/<lang>.yml`, 23 languages) into `SRC/_data/i18n/` as a starting point for overrides (optional; the theme already uses them), and list keys an existing catalog lacks"],
        ["--gh", "also render each page with `gh api markdown` (network, `gh` login)"],
        ["--help, -h", "print usage and options (`--help=markdown` prints the README table)"],
        ["--version", "print the rules version"],
      ].freeze
      # Rule groups in report order.
      RULES = [Registry, SiteConfig.method(:source_mode), Pages, I18n, Registry.method(:i18n_keys), BuiltParts,
               BuildOutput.method(:residue), Stylesheets, BuildOutput.method(:css), SiteConfig, Blog, GithubPages, Twins, GhRender].freeze

      module_function

      def run(argv)
        return help(argv.find { |a| a == "-h" || a.start_with?("--help") }) if argv.any? { |a| a == "-h" || a.start_with?("--help") }
        return (puts "modootoday-check (md-components v1)"; 0) if argv.include?("--version")

        pos = argv.reject { |a| a.start_with?("--") }
        src, site = pos[0]&.chomp("/"), pos[1]&.chomp("/")
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
