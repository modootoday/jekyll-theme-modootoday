# frozen_string_literal: true

module Modootoday
  module Check
    # 5b/5c. Site sources: Sass portability on GitHub Pages (Ruby Sass 3.7: @use/@forward pass
    # through silently, @supports selector() is a syntax error) and deprecated md-* aliases.
    module Stylesheets
      SASS_BAD = [[/^\s*@(use|forward)\b/, "@use/@forward (Ruby Sass on GitHub Pages copies it into the CSS untouched); use @import"],
                  [/@supports\s+(not\s+)?selector\(/, "@supports selector() (Ruby Sass syntax error on GitHub Pages)"]].freeze
      MD_ALIAS = /(class=["'][^"']*(?<![\w-])md-[a-z]|var\(\s*--md-[a-z])/
      DEPRECATED = "md-* alias is deprecated (removed in 2.0); use the --mt-*/mt-* name"

      module_function

      def call(ctx)
        sass(ctx)
        markup(ctx)
      end

      def sass(ctx)
        src = ctx.src
        Dir.glob(["#{src}/_sass/**/*.scss", "#{src}/assets/**/*.scss"]).reject { |f| ctx.skipped?(f) }.sort.each do |f|
          File.read(f).gsub(%r{/\*.*?\*/}m) { |c| "\n" * c.count("\n") }.each_line.with_index(1) do |l, n|
            l = l.sub(%r{//.*}, "")
            SASS_BAD.each { |re, why| ctx.errs << "#{ctx.rel(f)}:#{n}: #{why}" if l =~ re }
            # the theme's own partials keep the aliases until 2.0
            ctx.warns << "#{ctx.rel(f)}:#{n}: #{DEPRECATED}" if f !~ %r{/_sass/modootoday(/|\.scss\z)} && l =~ /(--md-[a-z]|\.md-[a-z])/
          end
        end
      end

      # md-* aliases in the site's own markup and CSS (classes and var(--md-*)); code is ignored
      def markup(ctx)
        src = ctx.src
        files = Dir.glob(["#{src}/_includes/**/*.html", "#{src}/_layouts/**/*.html", "#{src}/assets/**/*.css"]) +
                Dir.glob(["#{src}/**/*.md", "#{src}/**/*.html"]).reject { |f| ctx.skipped?(f) }
        files.uniq.reject { |f| f.delete_prefix(src) =~ %r{(^|/)(_site|vendor|node_modules)/} }.sort.each do |f|
          t = File.read(f)
          t = Markdown.strip_comments(f.end_with?(".md") ? Markdown.strip_code(t) : t)
          t.each_line.with_index(1) { |l, n| ctx.warns << "#{ctx.rel(f)}:#{n}: #{DEPRECATED}" if l =~ MD_ALIAS }
        end
      end
    end
  end
end
