# frozen_string_literal: true
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require_relative "../../script/starters/render"

class StarterRenderTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  THEME = Starters::Theme.new(ROOT)
  MANIFEST = Starters::Manifest.new(File.join(ROOT, "test/fixtures/starters/starters.yml"), THEME)

  def render = @render ||= Starters::Render.new(MANIFEST, THEME)
  def tree(dir) = Starters::Render.files(dir).to_h { |f| [f, File.binread(File.join(dir, f))] }
  def read(dir, stack, f) = File.read(File.join(dir, stack, "tiny", f))

  def test_two_renders_are_byte_identical
    Dir.mktmpdir do |d|
      a = tree(render.all("#{d}/a"))
      b = tree(render.all("#{d}/b"))
      assert_equal a, b
      assert_includes a.keys, "github-pages/tiny/.github/workflows/pages.yml"
      assert_includes a.keys, "jekyll4/tiny/ko/index.md.txt"
    end
  end

  def test_classic_stack_pins_remote_theme_to_the_gemspec_version
    Dir.mktmpdir do |d|
      render.all(d)
      cfg = read(d, "github-pages", "_config.yml")
      assert_includes cfg, "remote_theme: #{THEME.repo}@v#{THEME.version}\nplugins: [jekyll-remote-theme]\n"
      refute_match(/^theme:/, cfg)
      assert_equal File.read(File.join(ROOT, "test/fixtures/starters/tiny/_config.yml")), read(d, "jekyll4", "_config.yml")
      assert_includes read(d, "github-pages", ".github/workflows/pages.yml"), "  modootoday-check . _site --twins\n"
      assert_includes read(d, "jekyll4", ".github/workflows/pages.yml"), "bundle exec modootoday-check . _site --twins\n"
      assert_includes read(d, "github-pages", "README.md"), "modootoday-check . _site --twins --github-pages\n"
    end
  end

  def test_gemfile_lines_come_from_the_stack_bundle
    Dir.mktmpdir do |d|
      render.all(d)
      %w[github-pages jekyll4].each do |stack|
        gems = read(d, stack, "Gemfile").lines(chomp: true).grep(/\Agem /)
        want = File.readlines(File.join(ROOT, "gemfiles/#{stack}.gemfile"), chomp: true).grep(/\Agem /).reject { |l| l.match?(/"(minitest|rake)"/) }
        assert_equal [%(gem "jekyll-theme-modootoday", "#{THEME.version}"), *want], gems, stack
      end
    end
  end

  def test_stubs_readme_tables_and_no_copied_catalogs
    Dir.mktmpdir do |d|
      render.all(d)
      assert_equal "---\nlayout: twin\ntwin_of: index.md\npermalink: /ko/index.md\n---\n", read(d, "jekyll4", "ko/index.md.txt")
      assert_empty Dir.glob("*/tiny/_data/**/*", base: d), "the theme ships en and ko; the render copies no catalog"
      readme = read(d, "github-pages", "README.md")
      THEME.commands.each_value { |table| assert_includes readme, table }
      assert_includes readme, "modootoday-stubs . --twins --write"
      assert_includes readme, "one folder per language with the same page names: `ko/`."
    end
  end

  def test_drift_names_every_changed_missing_and_extra_file
    Dir.mktmpdir do |d|
      render.all(d)
      assert_empty render.drift(d)
      File.write("#{d}/jekyll4/tiny/index.md", "edited\n")
      File.delete("#{d}/github-pages/tiny/Gemfile")
      File.write("#{d}/jekyll4/tiny/extra.md", "x\n")
      FileUtils.mkdir_p("#{d}/jekyll4/tiny/_site")
      File.write("#{d}/jekyll4/tiny/_site/index.html", "build output is ignored\n")
      assert_equal ["github-pages/tiny/Gemfile: missing", "jekyll4/tiny/extra.md: not rendered", "jekyll4/tiny/index.md: differs"], render.drift(d).sort
    end
  end
end
