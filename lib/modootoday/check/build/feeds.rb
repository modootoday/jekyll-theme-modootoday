# frozen_string_literal: true

module Modootoday
  module Check
    # Front matter feed: on a page names its Atom feed (meta/feed-url.html): false, or a site path to an .xml page that
    # exists in the build. The theme drops a feed it cannot find, so a wrong path would lose the link without a word.
    module Feeds
      module_function

      def call(ctx)
        ctx.mds.each do |f|
          fm = (Markdown.fm(File.read(f)) rescue nil)
          next unless fm.is_a?(Hash) && fm.key?("feed")
          problem = check(ctx.site, fm["feed"])
          ctx.errs << "#{ctx.rel(f)}: feed: #{problem}" if problem
        end
      end

      def check(site, feed)
        return if feed == false
        return "must be false or a site path to the page's Atom feed, such as /blog/feed.xml (got #{feed.inspect})" unless feed.is_a?(String) && feed.start_with?("/") && feed.end_with?(".xml")
        return if File.file?(File.join(site, feed))
        "#{feed} is not in the build: add a page with layout: feed at that permalink, or fix the path"
      end
    end
  end
end
