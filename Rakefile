# frozen_string_literal: true
require "rake/testtask"
require "bundler/gem_tasks"
require "tmpdir"
Rake::TestTask.new(:test) { |t| t.test_files = FileList["test/**/*_test.rb"]; t.warning = false }
task default: %i[test starters:build]
desc "Regenerate _includes/modootoday/i18n*, t.html and docs/_data/languages.yml from i18n/*.yml"
task(:i18n) { ruby "script/i18n-build" }
namespace(:i18n) { desc "Fail when generated i18n includes are stale"; task(:check) { ruby "script/i18n-build", "--check" } }

# Starter sites (example/starters.yml): rendered into pkg/starters/<stack>/<name>/.
namespace :starters do
  starters = lambda do
    require_relative "script/starters/render"
    theme = Starters::Theme.new(__dir__)
    Starters::Render.new(Starters::Manifest.new(File.join(__dir__, "example/starters.yml"), theme), theme)
  end

  desc "Render every starter for each of its stacks into DIR (default pkg/starters)"
  task(:render, [:dir]) { |_, a| puts "rendered #{starters.call.all(a[:dir] || "pkg/starters")}" }

  desc "Fail when DIR (default pkg/starters) differs from a fresh render"
  task(:check, [:dir]) do |_, a|
    drift = starters.call.drift(a[:dir] || "pkg/starters")
    abort((["starters: DIR differs from a fresh render (run rake starters:render):"] + drift).join("\n  ")) unless drift.empty?
    puts "starters: no drift"
  end

  desc "Build each starter (or NAME) on the Jekyll of this bundle and run modootoday-check with its manifest flags"
  task(:build, [:name]) do |_, a|
    r = starters.call
    stack = Gem.loaded_specs.key?("github-pages") ? "github-pages" : "jekyll4"
    r.manifest.starters.select { |s| a[:name].nil? || s.name == a[:name] }.each do |s|
      Dir.mktmpdir do |d|
        # The gem stack's tree builds with the theme from this checkout; the classic one would fetch a release.
        r.one(s, "jekyll4", "#{d}/src")
        sh "bundle", "exec", "jekyll", "build", "-q", "-s", "#{d}/src", "-d", "#{d}/site"
        sh RbConfig.ruby, "exe/modootoday-check", "#{d}/src", "#{d}/site", *Starters::Site.new(s, stack, r.theme).check_flags.split
      end
    end
  end

  desc "Build each starter (or NAME) with its _config.demo.yml at its Pages base path into OUT/<name>/ (default pkg/demo), " \
       "check it and its qa: pages, and write OUT/<name>.json for test/system/showcase.mjs"
  task(:demo, [:name, :out]) do |_, a|
    require "json"
    r = starters.call
    out = File.expand_path(a[:out] || "pkg/demo")
    stack = Gem.loaded_specs.key?("github-pages") ? "github-pages" : "jekyll4"
    r.manifest.starters.select { |s| a[:name].to_s.empty? || s.name == a[:name] }.each do |s|
      Dir.mktmpdir do |d|
        site = File.join(out, s.name)
        rm_rf site
        r.one(s, "jekyll4", "#{d}/src")
        sh "bundle", "exec", "jekyll", "build", "-q", "-s", "#{d}/src", "-d", site, "--baseurl", s.baseurl,
           "--config", "#{d}/src/_config.yml,#{d}/src/_config.demo.yml"
        sh RbConfig.ruby, "exe/modootoday-check", "#{d}/src", site, *Starters::Site.new(s, stack, r.theme).check_flags.split
        missing = s.qa.reject { |p| File.file?(File.join(site, p.empty? || p.end_with?("/") ? "#{p}index.html" : p)) }
        abort("starters: #{s.name}: qa: pages the demo build lacks: #{missing.join(", ")}") unless missing.empty?
        File.write(File.join(out, "#{s.name}.json"), JSON.generate({ "name" => s.name, "base" => s.baseurl, "qa" => s.qa }))
      end
    end
  end

  desc "Print each starter repository's description, website and topics as JSON (the maintainer's repository settings)"
  task(:repos) do
    require "json"
    puts JSON.pretty_generate(starters.call.manifest.starters.map do |s|
      { "repo" => s.repo, "description" => s.description, "homepage" => s.demo_url, "topics" => s.topics, "template_url" => s.generate_url }
    end)
  end
end
