# frozen_string_literal: true

module Modootoday
  module Check
    module Config
      EDIT_URL = %r{\Ahttps?://\S+/\z}
      # auto, build_link and feedback.issues: auto read site.github, which GitHub Pages (or the jekyll-github-metadata
      # plugin) provides; a github: map in _config.yml stands in for it elsewhere. Without either the link is left out.
      GITHUB_SOURCE = lambda do |ctx, path, v|
        next unless v == "auto" || v == true
        cfg = ctx.site_cfg
        next if ctx.option?("--github-pages") || cfg["github"].is_a?(Hash) || Array(cfg["plugins"]).include?("jekyll-github-metadata")
        ctx.warns << "_config.yml: #{path}: #{v.inspect} reads site.github, which this build may not have: build on GitHub Pages, " \
                     "add the jekyll-github-metadata plugin, or set a github: map (repository_url, source: {branch, path}, " \
                     "build_revision); without it the link is left out"
      end
      edit_url = lambda do |ctx, path, v|
        next ctx.errs << "_config.yml: #{path} must be auto or an http(s) URL ending in / (page.path is appended)" unless v == "auto" || v.to_s.match?(EDIT_URL)
        GITHUB_SOURCE.call(ctx, path, v)
      end
      Schema.register(Key.new(name: "edit_url", type: :any, check: edit_url))
      Schema.register(Key.new(name: "build_link", type: :bool, check: GITHUB_SOURCE))
    end
  end
end
