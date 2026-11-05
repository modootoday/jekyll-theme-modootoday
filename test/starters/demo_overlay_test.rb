# frozen_string_literal: true
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "rbconfig"
require "yaml"
require_relative "../../script/starters/render"

# The demo overlay of a rendered starter: _config.demo.yml and the Pages workflow steps that layer it, run here the way
# the runner would for the starter's own repository and for a fork or a repository created from the template.
class StarterDemoOverlayTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  THEME = Starters::Theme.new(ROOT)
  MANIFEST = Starters::Manifest.new(File.join(ROOT, "test/fixtures/starters/starters.yml"), THEME)
  REPO = "Owner/tiny-starter"
  GUARD = "github.repository == '#{REPO}'"

  def tree
    @tree ||= begin
      d = Dir.mktmpdir
      Minitest.after_run { FileUtils.rm_rf(d) }
      Starters::Render.new(MANIFEST, THEME).all(d)
    end
  end

  def steps(stack) = YAML.safe_load(File.read("#{tree}/#{stack}/tiny/.github/workflows/pages.yml")).dig("jobs", "build", "steps")
  def index(stack, &) = steps(stack).index(&)

  def test_the_overlay_holds_only_the_showcase_with_addresses_from_the_manifest
    %w[github-pages jekyll4].each do |stack|
      demo = YAML.safe_load(File.read("#{tree}/#{stack}/tiny/_config.demo.yml"))
      assert_equal({ "modootoday" => { "showcase" => { "enabled" => true, "style" => "pill", "starter" => "tiny",
                                                       "docs_url" => "https://docs.example.com/theme/",
                                                       "use_url" => "https://github.com/#{REPO}/generate" } } }, demo)
    end
    readme = File.read("#{tree}/github-pages/tiny/README.md")
    assert_includes readme, "Live demo: <https://owner.github.io/tiny-starter/>"
    assert_includes readme, "only when the repository is `#{REPO}`"
  end

  def test_both_demo_steps_are_guarded_by_the_repository_name_around_the_build
    { "github-pages" => ->(s) { s["uses"].to_s.start_with?("actions/jekyll-build-pages") }, "jekyll4" => ->(s) { s["name"] == "Build" } }.each do |stack, build|
      guarded = steps(stack).select { |s| s["if"].to_s.include?("github.repository") }
      assert_equal ["Layer the demo config", "Restore _config.yml"], guarded.map { |s| s["name"] }, stack
      assert_equal [GUARD], guarded.map { |s| s["if"] }.uniq, stack
      layer, built, restore = index(stack) { |s| s["name"] == "Layer the demo config" }, index(stack, &build), index(stack) { |s| s["name"] == "Restore _config.yml" }
      ruby = index(stack) { |s| s["uses"].to_s.start_with?("ruby/setup-ruby") }
      check = index(stack) { |s| s["name"] == "Check the built site" }
      assert_equal [ruby, layer, built, restore, check], [ruby, layer, built, restore, check].sort, stack
      assert_equal [1, 1], [built - layer, restore - built], "#{stack}: the overlay wraps the build step only"
    end
  end

  def test_the_starter_repository_builds_with_the_overlay_and_restores_its_config
    Dir.mktmpdir do |d|
      FileUtils.cp_r("#{tree}/github-pages/tiny/.", d)
      before = File.binread("#{d}/_config.yml")
      run_guarded(d, REPO, "Layer the demo config")
      merged = YAML.safe_load(File.read("#{d}/_config.yml"))
      assert_equal "pill", merged.dig("modootoday", "showcase", "style")
      assert_equal YAML.safe_load(before).merge("modootoday" => YAML.safe_load(before).fetch("modootoday", {}).merge(merged["modootoday"])), merged
      run_guarded(d, REPO, "Restore _config.yml")
      assert_equal before, File.binread("#{d}/_config.yml")
    end
  end

  def test_a_fork_or_a_generated_repository_skips_the_overlay
    Dir.mktmpdir do |d|
      FileUtils.cp_r("#{tree}/jekyll4/tiny/.", d)
      before = File.binread("#{d}/_config.yml")
      %w[someone/tiny-starter Owner/my-site owner/tiny-starter].each do |repo|
        refute run_guarded(d, repo, "Layer the demo config"), repo
        assert_equal before, File.binread("#{d}/_config.yml"), repo
      end
    end
  end

  private

  # Runs one named step's script in dir when its if: holds for GITHUB_REPOSITORY = repo; true when it ran.
  def run_guarded(dir, repo, name)
    step = steps("github-pages").find { |s| s["name"] == name }
    want = step["if"][/\Agithub\.repository == '([^']+)'\z/, 1] or flunk("#{name}: unexpected if: #{step["if"]}")
    return false unless want == repo
    env = { "RUNNER_TEMP" => File.join(dir, ".runner"), "PATH" => "#{RbConfig::CONFIG["bindir"]}:#{ENV.fetch("PATH")}" }
    FileUtils.mkdir_p(env["RUNNER_TEMP"])
    assert system(env, "bash", "-e", "-c", step["run"], chdir: dir), "#{name} failed"
    true
  end
end
