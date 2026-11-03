# frozen_string_literal: true

module Modootoday
  module Stubs
    # Command line: options, modes (preview by default, --write, --check) and exit codes.
    module CLI
      USAGE = "usage: modootoday-stubs SRC [--twins] [--aliases] [--write | --check] [--no-prune] [--json] [--quiet]"
      # Single source for --help and the README "Commands" table (script/readme-commands).
      OPTIONS = [
        ["SRC", "the site source; without `--write` or `--check` nothing is written and the planned creates, updates and deletes are listed"],
        ["--twins", "a stub `<name>.md.txt` per page (`layout: twin`) for its twin at `/<name>/index.md`"],
        ["--aliases", "the aliases `modootoday.aliases` turns on: `md` a stub `<name>.flat.md.txt` (`layout: twin`) at `/<name>.md`, `html` a stub `<name>.html.md.txt` (`layout: redirect`) at `/<name>.html`"],
        ["--write", "write the planned stubs; files whose content is already right are not touched"],
        ["--check", "write nothing; exit 1 when a stub is missing, out of date or orphaned"],
        ["--no-prune", "keep orphan stubs (by default a twin stub whose page is gone, or an alias stub no page wants, is deleted)"],
        ["--json", "print the plan as JSON (`mode`, `kinds`, `changes` with `path`, `action`, `reason`)"],
        ["--quiet", "print only drift found by `--check` and errors"],
        ["--help, -h", "print usage and options (`--help=markdown` prints the README table)"],
        ["--version", "print the version"],
      ].freeze
      KINDS = { "--twins" => :twins, "--aliases" => :aliases }.freeze
      FLAGS = (KINDS.keys + %w[--write --check --no-prune --prune --json --quiet]).freeze

      module_function

      def run(argv)
        return help(argv.find { |a| a == "-h" || a.start_with?("--help") }) if argv.any? { |a| a == "-h" || a.start_with?("--help") }
        return (puts "modootoday-stubs (md-components v1)"; 0) if argv.include?("--version")
        opts, pos = argv.partition { |a| a.start_with?("-") }
        bad = opts - FLAGS
        return usage("unknown option #{bad.first}") unless bad.empty?
        return usage("give one SRC") unless pos.size == 1
        return usage("--write and --check exclude each other") if opts.include?("--write") && opts.include?("--check")
        kinds = KINDS.select { |flag, _| opts.include?(flag) }.values
        return usage("choose what to make: --twins, --aliases or both") if kinds.empty?
        execute(pos.first, kinds, opts)
      end

      def execute(src, kinds, opts)
        source = Source.new(src)
        plan = Plan.new(source, kinds, prune: !opts.include?("--no-prune"))
        mode = opts.include?("--write") ? "write" : (opts.include?("--check") ? "check" : "preview")
        Writer.apply(source, plan.changes) if mode == "write"
        opts.include?("--json") ? Report.json(plan, mode) : Report.text(plan, mode, quiet: opts.include?("--quiet"))
        mode == "check" && !plan.empty? ? 1 : 0
      rescue ConfigError => e
        warn "modootoday-stubs: #{e.message}"
        2
      rescue DataError => e
        warn "modootoday-stubs: #{e.message}"
        3
      end

      def usage(why)
        warn "modootoday-stubs: #{why}", USAGE
        2
      end

      def help(h)
        if h == "--help=markdown"
          puts "| Option | Does |", "|---|---|"
          OPTIONS.each { |o, d| puts "| `#{o}` | #{d.gsub("|", "\\|")} |" }
        else
          puts USAGE, "", "options:"
          OPTIONS.each { |o, d| puts format("  %-12s %s", o, d.delete("`")) }
          puts "", "exit status: 0 nothing to do, previewed or written; 1 --check found drift; 2 usage or _config.yml error;",
               "3 data error (front matter, unsafe permalink, alias conflict)"
        end
        0
      end
    end
  end
end
