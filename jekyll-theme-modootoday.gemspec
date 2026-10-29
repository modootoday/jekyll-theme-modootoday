# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "jekyll-theme-modootoday"
  spec.version       = "0.5.0"
  spec.authors       = ["modootoday"]
  spec.summary       = "A Jekyll theme that keeps page bodies in plain GitHub Markdown and styles them with layouts, includes and CSS."
  spec.description   = "GitHub alerts, status badges, sectioned pages, install tabs and agent-readable Markdown twins for Jekyll and GitHub Pages, plus a checker (modootoday-check)."
  spec.homepage      = "https://github.com/modootoday/jekyll-theme-modootoday"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.2" # oldest Ruby in CI; sass-embedded needs 3.2; exe uses endless methods

  spec.metadata = {
    "source_code_uri" => spec.homepage,
    "changelog_uri" => "#{spec.homepage}/blob/main/CHANGELOG.md",
    "bug_tracker_uri" => "#{spec.homepage}/issues",
    "plugin_type" => "theme",
    "rubygems_mfa_required" => "true"
  }

  # Ship only runtime theme files (jekyll new-theme / minima convention):
  # tracked files under the theme dirs + top-level docs. test/, example/,
  # gemfiles/, CI and JS tooling stay in the repo but out of the gem.
  runtime = %r{\A(?:_layouts|_includes|_sass|assets|exe|lib)/|\A(?:LICENSE|README(?:\.ko)?\.md|RULES\.md|CHANGELOG\.md)\z}
  tracked = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL, &:read).to_s.split("\x0")
  tracked = Dir.glob("**/*", File::FNM_DOTMATCH, base: __dir__) if tracked.empty?
  spec.files = tracked.grep(runtime).select { |f| File.file?(File.join(__dir__, f)) }.sort
  spec.bindir        = "exe"
  spec.executables   = ["modootoday-check"]

  spec.add_runtime_dependency "jekyll", ">= 3.9", "< 5.0"
end
