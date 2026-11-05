# frozen_string_literal: true
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require_relative "../../script/starters/render"

class StarterManifestTest < Minitest::Test
  ROOT = File.expand_path("../..", __dir__)
  THEME = Starters::Theme.new(ROOT)
  CONFIG = "title: S\nlang: en\ntheme: jekyll-theme-modootoday\nexclude: [README.md]\n"

  DEMO = { "docs_url" => "https://docs.example.com/" }.freeze

  def site(entries, files = { "s/_config.yml" => CONFIG }, demo: DEMO)
    @dir = Dir.mktmpdir
    files.each { |f, t| FileUtils.mkdir_p(File.dirname("#{@dir}/#{f}")); File.write("#{@dir}/#{f}", t) }
    File.write("#{@dir}/starters.yml", { "demo" => demo, "starters" => entries }.compact.to_yaml)
    Starters::Manifest.new("#{@dir}/starters.yml", THEME)
  end

  def teardown = @dir && FileUtils.rm_rf(@dir)
  def entry(**over) = { "name" => "s", "repo" => "o/s", "description" => "An S starter", "languages" => ["en"], "stacks" => ["jekyll4"],
                        "qa" => ["", "a/"] }.merge(over.transform_keys(&:to_s))
  def refused(msg, entries, files = { "s/_config.yml" => CONFIG }) = assert_match(msg, assert_raises(Starters::ManifestError) { site(entries, files) }.message)

  def test_demo_addresses_derive_from_the_repo
    s = site([entry(repo: "Org/s-starter", showcase: { "style" => "pill" })]).fetch("s")
    assert_equal "https://org.github.io/s-starter/", s.demo_url
    assert_equal "https://github.com/Org/s-starter/generate", s.generate_url
    assert_equal "/s-starter", s.baseurl
    assert_equal ["pill", "https://docs.example.com/"], [s.style, s.docs_url]
    assert_equal %w[jekyll jekyll-theme github-pages starter-template s], s.topics
    assert_equal "bar", site([entry]).fetch("s").style
  end

  def test_demo_fields_are_checked
    assert_match(/demo: \{docs_url:\}/, assert_raises(Starters::ManifestError) { site([entry], demo: nil) }.message)
    assert_match(/demo: \{docs_url:\}/, assert_raises(Starters::ManifestError) { site([entry], demo: { "docs_url" => "http://x.test/" }) }.message)
    refused(/description: one line/, [entry(description: "two\nlines")])
    refused(/description: one line/, [entry(description: nil)])
    refused(/showcase.style: bar or pill/, [entry(showcase: { "style" => "banner" })])
    refused(/showcase: a map with style/, [entry(showcase: { "colour" => "red" })])
    refused(/qa: name at least two pages/, [entry(qa: [""])])
    refused(%r{qa: /abs/: a page path}, [entry(qa: ["", "/abs/"])])
  end

  def test_languages_and_stacks_are_the_theme_lists
    assert_equal %w[github-pages jekyll4], THEME.stacks
    refused(/languages: unknown xx/, [entry(languages: %w[en xx])])
    refused(/stacks: unknown jekyll39/, [entry(stacks: %w[jekyll39])])
    refused(/languages: name at least one/, [entry(languages: [])])
  end

  def test_names_folders_and_repos
    refused(/listed twice/, [entry, entry])
    refused(/no _config.yml/, [entry(name: "missing")])
    refused(/repo: owner\/name/, [entry(repo: "nope")])
    refused(/name "Bad"/, [entry(name: "Bad")])
    refused(/is a map of/, [entry(extra: 1)])
  end

  def test_source_must_leave_rendered_files_to_the_renderer
    m = site([entry], { "s/_config.yml" => CONFIG, "s/Gemfile" => "source x\n" })
    e = assert_raises(Starters::ManifestError) { Starters::Render.new(m, THEME).one(m.fetch("s"), "jekyll4", "#{@dir}/out") }
    assert_match(/Gemfile are rendered/, e.message)
    m = site([entry], { "s/_config.yml" => CONFIG.sub("theme: jekyll-theme-modootoday\n", "") })
    assert_raises(Starters::ManifestError) { Starters::Render.new(m, THEME).one(m.fetch("s"), "jekyll4", "#{@dir}/out") }
    m = site([entry], { "s/_config.yml" => CONFIG.sub("exclude: [README.md]\n", "") })
    assert_raises(Starters::ManifestError) { Starters::Render.new(m, THEME).one(m.fetch("s"), "jekyll4", "#{@dir}/out") }
  end
end
