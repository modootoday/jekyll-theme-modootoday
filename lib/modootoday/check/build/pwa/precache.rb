# frozen_string_literal: true

module Modootoday
  module Check
    module Pwa
      # What the worker precaches: every URL is in the build (the worker skips a missing one, so offline reading silently
      # lacks it), and the total stays small for a first visit. Front matter pwa: takes only precache.
      module Precache
        LIMIT = 1024 * 1024

        module_function

        def call(ctx)
          c = Worker.settings(ctx)
          return unless c
          f = File.join(ctx.site, Stubs::Pwa::WORKER)
          base = c["scope"].to_s.chomp("/")
          offline = c["offline"].to_h.values
          total = Array(c["precache"]).sum do |url|
            file = Worker.file(ctx, base, url)
            next File.size(file) if File.file?(file)
            ctx.errs << "#{f}: precache URL #{url} is not in the build" unless offline.include?(url)
            0
          end
          ctx.warns << "#{f}: the precache list is #{total} bytes; every first visit downloads it, so keep it under 1 MiB" if total > LIMIT
        end

        def front_matter(ctx)
          ctx.mds.each do |f|
            fm = begin Markdown.fm(File.read(f)) rescue nil end
            next unless fm.is_a?(Hash) && fm.key?("pwa") && fm["pwa"] != "precache"
            ctx.errs << "#{ctx.rel(f)}: pwa: takes only precache (the worker keeps the page for offline reading)"
          end
        end
      end
    end
  end
end
