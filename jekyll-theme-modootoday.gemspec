# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "jekyll-theme-modootoday"
  spec.version       = "0.1.0"
  spec.authors       = ["modootoday"]
  spec.summary       = "A Jekyll theme that keeps page bodies in plain GitHub Markdown and styles them with layouts, includes and CSS."
  spec.description   = "GitHub alerts, status badges, sectioned pages, install tabs and agent-readable Markdown twins for Jekyll and GitHub Pages, plus a checker (modootoday-check)."
  spec.homepage      = "https://github.com/modootoday/jekyll-theme-modootoday"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.7"

  spec.metadata = {
    "source_code_uri" => spec.homepage,
    "changelog_uri" => "#{spec.homepage}/blob/main/CHANGELOG.md",
    "bug_tracker_uri" => "#{spec.homepage}/issues",
    "plugin_type" => "theme",
    "rubygems_mfa_required" => "true"
  }

  spec.files = Dir.glob("{_layouts,_includes,_sass,assets,exe}/**/*", File::FNM_DOTMATCH).select { |f| File.file?(f) } +
               %w[LICENSE README.md README.ko.md RULES.md CHANGELOG.md]
  spec.bindir        = "exe"
  spec.executables   = ["modootoday-check"]

  spec.add_runtime_dependency "jekyll", ">= 3.9", "< 5.0"
end
