# frozen_string_literal: true
require "minitest/autorun"
require "yaml"
require "tmpdir"
require_relative "../../script/starters/render"

# The starters' workflows use the same action versions as the theme's own CI wherever both use an action; the
# published tree carries the Theme update workflow, guarded to its own repository (adr:modootoday/20261109225836).
class StarterWorkflowTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  USES = %r{^\s*(?:-\s+)?uses:\s*([\w.-]+/[\w.-]+)@(\S+)}
  THEME = Starters::Theme.new(ROOT)
  TINY = Starters::Manifest.new(File.join(ROOT, "test/fixtures/starters/starters.yml"), THEME)

  def uses(text) = text.scan(USES).group_by(&:first).transform_values { |v| v.map(&:last).uniq }

  def rendered(stack)
    Dir.mktmpdir do |d|
      dir = Starters::Render.new(TINY, THEME).one(TINY.fetch("tiny"), stack, "#{d}/tiny")
      Dir.glob("#{dir}/.github/workflows/*.yml").to_h { |f| [File.basename(f), File.read(f)] }
    end
  end

  def test_the_published_tree_updates_itself_only_in_its_own_repository
    wf = rendered("github-pages")
    update = YAML.safe_load(wf.fetch("theme-update.yml"))
    repo = TINY.fetch("tiny").repo
    assert_equal "github.repository == '#{repo}'", update.dig("jobs", "update", "if")
    assert_equal({ "contents" => "write" }, update.dig("jobs", "update", "permissions"))
    assert_equal "./.github/workflows/pages.yml", update.dig("jobs", "pages", "uses")
    assert_includes wf.fetch("theme-update.yml"), "https://api.github.com/repos/#{THEME.repo}/releases/latest"
    refute_match(/secrets\./, wf.fetch("theme-update.yml"), "no token beyond GITHUB_TOKEN")
    pages = YAML.safe_load(wf.fetch("pages.yml"))
    assert_equal "string", pages.dig(true, "workflow_call", "inputs", "ref", "type"), "the updater calls Pages with its commit"
    assert_equal ["pages.yml"], rendered("jekyll4").keys, "the gem stack is not published"
  end

  def test_a_published_release_rebuilds_the_default_branch
    %w[github-pages jekyll4].each do |stack|
      text = rendered(stack).fetch("pages.yml")
      pages = YAML.safe_load(text)
      assert_equal({ "types" => ["published"] }, pages.dig(true, "release"), stack)
      rebuild = pages.dig("jobs", "rebuild")
      assert_equal "github.event_name == 'release'", rebuild["if"], stack
      assert_equal({ "actions" => "write" }, rebuild["permissions"], stack)
      assert_match(/gh workflow run pages\.yml .*--ref "\$BRANCH"/, rebuild.dig("steps", 0, "run"), stack)
      assert_equal "github.event_name != 'release'", pages.dig("jobs", "build", "if"), "#{stack}: a tag run never deploys"
      refute pages[true].key?("schedule"), "#{stack}: the weekly rebuild is opt-in"
      assert_match(/^  # schedule:\n  #   - cron: /, text, stack)
    end
  end

  def test_theme_workflows_parse_and_use_no_secret
    Dir[File.join(ROOT, ".github/workflows/*.yml")].each do |f|
      assert_kind_of Hash, YAML.safe_load(File.read(f)), f
      refute_match(/secrets\.(?!GITHUB_TOKEN)/, File.read(f), "#{f}: no stored token (adr:modootoday/20261109225836)")
    end
    gitlinks = YAML.safe_load(File.read(File.join(ROOT, ".github/workflows/starter-gitlinks.yml")))
    assert_equal({ "contents" => "write" }, gitlinks.dig("jobs", "gitlinks", "permissions"))
    assert_includes gitlinks.dig(true).keys, "workflow_dispatch"
  end

  def test_action_versions_match_the_theme_ci
    starter = uses(%w[pages theme-update].map { |t| File.read(File.join(ROOT, "script/starters/templates/#{t}.yml.erb")) }.join("\n"))
    theme = uses(Dir[File.join(ROOT, ".github/workflows/*.yml")].map { |f| File.read(f) }.join("\n"))
    shared = starter.keys & theme.keys
    assert_includes shared, "actions/checkout"
    assert_includes shared, "actions/jekyll-build-pages"
    shared.each { |a| assert_equal theme[a], starter[a], a }
  end
end
