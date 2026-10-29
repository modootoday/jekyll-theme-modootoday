# frozen_string_literal: true

require "open3"

module Modootoday
  module Check
    # --gh: render each page with `gh api markdown` (needs gh auth and network).
    module GhRender
      module_function

      def call(ctx)
        return unless ctx.option?("--gh")
        ctx.mds.each do |f|
          out, st = Open3.capture2("gh", "api", "markdown", "-f", "mode=gfm", "-f", "text=#{Markdown.body(File.read(f))}")
          next ctx.errs << "#{ctx.rel(f)}: gh api failed" unless st.success?
          ctx.errs << "#{ctx.rel(f)}: GitHub shows ': ' definition marker" if out =~ /<p>: /
        end
      end
    end
  end
end
