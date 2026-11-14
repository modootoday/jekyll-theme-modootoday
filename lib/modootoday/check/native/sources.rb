# frozen_string_literal: true

module Modootoday
  module Check
    # Rules about plain Jekyll conventions (layout names, collections), read from every source file with front matter:
    # Markdown under any extension Jekyll converts, and HTML, posts and collection documents included.
    module Native
      GLOB = "**/*.{md,markdown,mkd,mkdn,mdown,html}"

      module_function

      # [[file, front matter]] for the site's source files that start with front matter, once per run.
      def pages(ctx)
        (@pages ||= {})[ctx.object_id] ||= begin
          excl = Array(ctx.site_cfg["exclude"]).map { |e| e.to_s.chomp("/") }
          Dir.glob("#{ctx.src}/#{GLOB}").sort.filter_map do |f|
            next if ctx.skipped?(f) || ctx.unread?(f) || excl.any? { |e| ctx.rel(f) == e || ctx.rel(f).start_with?("#{e}/") }
            text = File.read(f, 4096)
            next unless text&.start_with?("---\n", "---\r\n")
            fm = (Markdown.fm(File.read(f)) rescue nil)
            [f, fm] if fm.is_a?(Hash)
          end
        end
      end
    end
  end
end
