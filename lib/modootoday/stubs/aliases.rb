# frozen_string_literal: true

module Modootoday
  module Stubs
    # URL aliases (RULES.md 5a) that modootoday.aliases turns on, for each page with a directory URL other than /:
    # md: <name>.flat.md.txt, the twin again at /<page>.md; html: <name>.html.md.txt, a redirect at /<page>.html.
    class Aliases
      SUFFIX = { "md" => ".flat.md.txt", "html" => ".html.md.txt" }.freeze

      def self.stub?(rel) = SUFFIX.values.any? { |s| rel.end_with?(s) }

      def initialize(source)
        @s = source
        mt = source.modootoday
        cfg = mt["aliases"]
        raise ConfigError, "--aliases: set modootoday.aliases: {md: true, html: true} (or one of them) in _config.yml" unless cfg.is_a?(Hash) && cfg.values.include?(true)
        @kinds = SUFFIX.keys.select { |k| cfg[k] == true }
        raise ConfigError, "modootoday.aliases.md: not with twins: source (a page without front matter is already served at /<page>.md)" if @kinds.include?("md") && mt["twins"] == "source"
      end

      def wanted
        @wanted ||= begin
          seen = {}
          pages.each_with_object({}) do |p, out|
            @kinds.each do |k|
              next if k == "md" && p.fm["twin"] == false
              url = "#{@s.url!(p, p.url).chomp("/")}.#{k}"
              conflict!(p, url, seen)
              out["#{p.rel.delete_suffix(".md")}#{SUFFIX[k]}"] = body(k, p, url)
            end
          end
        end
      end

      # Alias stubs that no page wants any more: page gone, alias kind off or page no longer eligible.
      def orphans = @s.files("**/*{#{SUFFIX.values.join(",")}}").uniq.reject { |r| wanted.key?(r) }

      private

      def pages
        @s.pages.reject do |p|
          p.name == "README.md" || !p.directory_url? || p.url == "/" || p.fm["layout"] == "redirect"
        end
      end

      def body(kind, page, url)
        return "---\nlayout: twin\ntwin_of: #{page.name}\npermalink: #{url}\n---\n" if kind == "md"
        "---\nlayout: redirect\nredirect_to: #{page.url}\npermalink: #{url}\nsitemap: false\n---\n"
      end

      # Two pages cannot share an alias URL, and an alias cannot take the path of a file Jekyll already outputs.
      def conflict!(page, url, seen)
        raise DataError, "#{page.rel}: alias #{url} is also the alias of #{seen[url]}" if seen.key?(url)
        seen[url] = page.rel
        file = url.delete_prefix("/")
        return if file == page.rel || !File.exist?(@s.path(file))
        raise DataError, "#{page.rel}: alias #{url} would overwrite #{file}"
      end
    end
  end
end
