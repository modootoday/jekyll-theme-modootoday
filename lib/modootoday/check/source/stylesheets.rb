# frozen_string_literal: true

module Modootoday
  module Check
    # 5b/5c. Site sources: Sass portability on GitHub Pages (Ruby Sass 3.7: @use/@forward pass
    # through silently, @supports selector() is a syntax error).
    module Stylesheets
      SASS_BAD = [[/^\s*@(use|forward)\b/, "@use/@forward (Ruby Sass on GitHub Pages copies it into the CSS untouched); use @import"],
                  [/@supports\s+(not\s+)?selector\(/, "@supports selector() (Ruby Sass syntax error on GitHub Pages)"]].freeze

      module_function

      def call(ctx)
        sass(ctx)
      end

      def sass(ctx)
        src = ctx.src
        Dir.glob(["#{src}/_sass/**/*.scss", "#{src}/assets/**/*.scss"]).reject { |f| ctx.skipped?(f) }.sort.each do |f|
          File.read(f).gsub(%r{/\*.*?\*/}m) { |c| "\n" * c.count("\n") }.each_line.with_index(1) do |l, n|
            l = l.sub(%r{//.*}, "")
            SASS_BAD.each { |re, why| ctx.errs << "#{ctx.rel(f)}:#{n}: #{why}" if l =~ re }
          end
        end
      end
    end
  end
end
