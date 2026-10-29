# frozen_string_literal: true

module Modootoday
  module Check
    # 4b. Registered parts exist in the built HTML of the pages that use the component (needs
    # Nokogiri; skipped without it). Attributes that component scripts add at runtime (role=, aria-*)
    # are checked after scripts run by docs QA.
    module BuiltParts
      RUNTIME_PART = /\[(role|aria-)/

      module_function

      def nokogiri?
        require "nokogiri"
        true
      rescue LoadError
        false
      end

      def call(ctx)
        return unless ctx.comps.is_a?(Hash) && nokogiri?
        docs = {}
        ctx.part_uses.each do |c, pages|
          secs = pages.uniq.flat_map do |pg|
            r = pg.delete_suffix(".md")
            cand = File.basename(r) == "index" ? ["#{ctx.site}/#{r}.html"] : ["#{ctx.site}/#{r}.html", "#{ctx.site}/#{r}/index.html"]
            h = cand.find { |x| File.exist?(x) }
            h ? (docs[h] ||= Nokogiri::HTML(File.read(h))).css(%(section[data-c="#{c}"])).to_a : []
          end
          next if secs.empty? # page not built under its source path (custom permalink): nothing to compare
          ctx.comps[c]["parts"].each do |sel|
            next unless sel.is_a?(String) && !sel.match?(RUNTIME_PART)
            found = secs.any? { |sec| (sec.matches?(sel) rescue false) || !(sec.css(sel) rescue []).empty? }
            ctx.errs << "_data/components.yml: #{c}.parts: '#{sel}' not found in the built HTML of #{pages.uniq.sort.join(', ')}" unless found
          end
        end
      end
    end
  end
end
