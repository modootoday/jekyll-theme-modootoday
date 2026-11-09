# frozen_string_literal: true

require "open3"

module Release
  # The commit rules the generated CHANGELOG relies on (adr:modootoday/20261109225758): a commit that touches what the
  # gem ships has a Conventional Commit subject, and one the changelog would skip says so with a Changelog: footer.
  class CommitCheck
    ROOT = File.expand_path("../..", __dir__)
    TYPES = %w[feat fix perf refactor docs test ci chore build style revert].freeze
    SUBJECT = /\A(#{TYPES.join("|")})(\(([\w.\/-]+)\))?(!)?: \S/
    LISTED = /\A(feat|fix|perf)\b|\A[a-z]+(\([^)]*\))?!:|\Adocs(?!\((spec|changelog|contributing|agents|releasing)\))/
    TEXT_FOOTERS = %w[Changelog Visual Migration Deprecated Removed].freeze
    REF = /\A(adr|audit|research|sot):[\w.\/-]+\z/

    # The gem's shipped directories, read from the runtime pattern in the gemspec (its one owner).
    def self.shipped
      src = File.read(File.join(ROOT, "jekyll-theme-modootoday.gemspec"))
      src[%r{runtime = %r\{\\A\(\?:([^)]+)\)/}, 1].to_s.split("|")
    end

    Commit = Struct.new(:sha, :message, :files)

    def initialize(shipped: self.class.shipped) = @shipped = shipped

    # Problems of one commit, as strings; empty when it passes.
    def problems(message, files)
      subject = message.lines.first.to_s.strip
      footers = self.class.footers(message)
      out = footer_problems(footers)
      return out unless files.any? { |f| @shipped.any? { |d| f.start_with?("#{d}/") } }

      return out << "changes shipped files, so the subject is a Conventional Commit (type(scope): text): #{subject}" unless subject.match?(SUBJECT)
      return out if subject.match?(LISTED) || footers.any? { |k, _| %w[Changelog Deprecated Removed BREAKING\ CHANGE].include?(k) }

      out << "changes shipped files but the changelog skips its type: add a footer, Changelog: <text> or Changelog: none"
    end

    # Token => value pairs of the last paragraph, when every line of it is a footer (or continues one).
    def self.footers(message)
      para = message.strip.split(/\n\s*\n/)
      return [] if para.size < 2

      lines = para.last.lines.map(&:chomp)
      return [] unless lines.first.match?(/\A([\w-]+|BREAKING CHANGE):(\s|\z)/)

      lines.each_with_object([]) do |l, acc|
        m = l.match(/\A([\w-]+|BREAKING CHANGE): ?(.*)\z/)
        m ? acc << [m[1], m[2]] : (acc.last[1] += " #{l.strip}" if acc.last)
      end
    end

    def commits(range)
      shas = git("rev-list", "--no-merges", "--reverse", *range).split
      shas.map do |sha|
        Commit.new(sha, git("log", "-1", "--format=%B", sha), git("diff-tree", "--no-commit-id", "--name-only", "-r", sha).split("\n"))
      end
    end

    private

    def footer_problems(footers)
      footers.filter_map do |k, v|
        next "#{k}: footer is empty" if TEXT_FOOTERS.include?(k) && v.strip.empty?
        next unless k == "Refs"

        bad = v.split(/,\s*/).reject { |r| r.match?(REF) }
        "Refs: #{bad.join(", ")} is not a spec id (adr:, audit:, research: or sot:)" unless bad.empty?
      end
    end

    def git(*args)
      out, err, st = Open3.capture3("git", "-C", ROOT, *args)
      raise ArgumentError, err.strip unless st.success?

      out
    end
  end
end
