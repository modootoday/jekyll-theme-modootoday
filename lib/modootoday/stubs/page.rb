# frozen_string_literal: true

module Modootoday
  module Stubs
    # One Markdown page with front matter: its path relative to the site source, its front matter and its URL.
    # The one owner of a page's URL for modootoday-stubs, modootoday-check --aliases and script/docs.
    Page = Struct.new(:rel, :fm) do
      def url
        return fm["permalink"] if fm["permalink"].to_s.end_with?("/")
        "/#{rel.delete_suffix(".md").delete_suffix("index")}".sub(%r{([^/])\z}, '\1/')
      end

      def name = File.basename(rel)
      def directory_url? = fm["permalink"].nil? || fm["permalink"].to_s.end_with?("/")
    end
  end
end
