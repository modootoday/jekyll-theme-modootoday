# frozen_string_literal: true
# The starter sites of example/starters.yml as tests build them: rendered once per run for the jekyll4 stack, so
# the theme comes from this checkout and the stubs and record pages are in place. Treat the tree as read-only.
require "tmpdir"
require "fileutils"
require "minitest"
require_relative "../../script/starters/render"

module Starters
  module Sources
    ROOT = File.expand_path("../..", __dir__)

    module_function

    def render
      @render ||= begin
        theme = Theme.new(ROOT)
        Render.new(Manifest.new(File.join(ROOT, "example/starters.yml"), theme), theme)
      end
    end

    def path(name)
      (@paths ||= {})[name] ||= begin
        dir = Dir.mktmpdir("starter-")
        Minitest.after_run { FileUtils.rm_rf(dir) }
        render.one(render.manifest.fetch(name), "jekyll4", File.join(dir, name))
      end
    end
  end
end
