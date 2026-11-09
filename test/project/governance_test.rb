# frozen_string_literal: true
# Community and release files: present, pointing at private reporting, without invented contacts.
# AGENTS.md, the agent entry point, stays short and lists only commands and paths that exist.
require "minitest/autorun"
require "yaml"
require "json"

class GovernanceTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  PVR = "https://github.com/modootoday/jekyll-theme-modootoday/security/advisories/new"
  AGENTS_BUDGET = 8 * 1024 # bytes: past this, agents skim instead of following it; move detail to CONTRIBUTING.md
  EXTERNAL = %w[git gem bundle jekyll spec npx].freeze # tools this repository does not define
  def read(f) = File.read(File.join(ROOT, f))

  def test_agents_md_is_the_agent_entry_point_within_its_budget
    assert_operator File.size(File.join(ROOT, "AGENTS.md")), :<=, AGENTS_BUDGET, "AGENTS.md over #{AGENTS_BUDGET} bytes"
    assert_equal "@AGENTS.md\n", read("CLAUDE.md"), "CLAUDE.md only imports AGENTS.md"
    refute_match(%r{/home/|/tmp/|\.spec\.local|[\w.+-]+@[\w-]+\.[a-z]{2,}\b}, read("AGENTS.md"), "public-safe")
  end

  def test_agents_md_commands_exist
    lines = read("AGENTS.md").scan(/^```sh\n(.*?)^```/m).flatten.flat_map(&:lines).map(&:strip).reject(&:empty?)
    refute_empty lines
    lines.flat_map { |l| l.split(/\s*(?:&&|\|\|?|;)\s*/) }.each { |c| assert_nil missing(c), "AGENTS.md: `#{c}` names nothing in this repository" }
  end

  def test_agents_md_paths_exist
    paths = read("AGENTS.md").scan(/`([^`\s]+)`/).flatten.select { |t| t.match?(%r{\A[\w.-]+(?:/[\w.-]+)*/[\w.-]*\z}) }
    refute_empty paths
    paths.each { |p| assert File.exist?(File.join(ROOT, p)), "AGENTS.md: #{p} does not exist" }
  end

  def test_command_check_finds_what_is_missing
    assert_nil missing("BUNDLE_GEMFILE=gemfiles/jekyll4.gemfile bundle exec rake test")
    assert_nil missing("bundle exec rake starters:check")
    { "ruby script/nope" => "script/nope", "bundle exec rake nope:check" => "nope:check", "npm run nope" => "nope",
      "make all" => "make", "git config core.hooksPath nope/hooks" => "nope/hooks" }.each { |c, want| assert_equal want, missing(c), c }
  end

  def test_files_exist
    %w[SECURITY.md CODE_OF_CONDUCT.md CONTRIBUTING.md RELEASING.md .github/pull_request_template.md
       .github/ISSUE_TEMPLATE/bug_report.yml .github/ISSUE_TEMPLATE/feature_request.yml .github/ISSUE_TEMPLATE/config.yml].each do |f|
      assert File.file?(File.join(ROOT, f)), f
    end
  end

  def test_private_reporting_and_no_email_contacts
    assert_includes read("SECURITY.md"), PVR
    assert_includes read("CODE_OF_CONDUCT.md"), PVR
    assert_includes read("CODE_OF_CONDUCT.md"), "version 2.1"
    %w[SECURITY.md CODE_OF_CONDUCT.md RELEASING.md].each do |f|
      refute_match(/[\w.+-]+@[\w-]+\.[\w.]+/, read(f), "#{f}: no e-mail addresses")
      refute_includes read(f), "INSERT", f
    end
    assert_equal PVR, YAML.safe_load(read(".github/ISSUE_TEMPLATE/config.yml"))["contact_links"].first["url"]
  end

  def test_dependabot_covers_actions_bundler_and_npm
    eco = YAML.safe_load(read(".github/dependabot.yml"))["updates"].map { |u| u["package-ecosystem"] }
    assert_equal %w[bundler github-actions npm], eco.sort
  end

  def test_issue_forms_parse
    Dir.glob(File.join(ROOT, ".github/ISSUE_TEMPLATE/*.yml")).each { |f| assert YAML.safe_load(File.read(f)), f }
  end

  private

  # The part of one shell command this repository defines (a Rake task, an npm script, a file), or nil.
  def missing(cmd)
    words = cmd.split.drop_while { |w| w.match?(/\A[A-Z_]+=/) }
    words = words.drop(2) if words[0, 2] == %w[bundle exec]
    head, *args = words
    case head
    when "rake" then args.reject { |a| a.start_with?("-") }.map { |a| a.delete(%q("')).sub(/\[.*\z/, "") }.find { |t| !rake_task?(t) }
    when "npm" then npm_missing(args)
    when "ruby", "node", "sh" then args.first unless File.file?(File.join(ROOT, args.first.to_s))
    when "git" then args.last if args[0, 2] == %w[config core.hooksPath] && !File.directory?(File.join(ROOT, args.last))
    when %r{/} then head unless File.executable?(File.join(ROOT, head))
    when *EXTERNAL then nil
    else head
    end
  end

  def rake_task?(name)
    return true if %w[build install release].include?(name) # bundler/gem_tasks
    *spaces, task = name.split(":")
    src = (["Rakefile"] + Dir.glob("rakelib/*.rake", base: ROOT)).map { |f| read(f) }.join("\n")
    spaces.all? { |n| src.match?(/namespace[ (]:#{n}\b/) } && src.match?(/task[ (]:#{task}\b|task #{task}:|TestTask\.new\(:#{task}\)/)
  end

  def npm_missing(args)
    scripts = JSON.parse(read("package.json"))["scripts"]
    case args.first
    when "ci", "install" then nil
    when "run" then args[1] unless scripts.key?(args[1])
    else args.first unless scripts.key?(args.first)
    end
  end
end
