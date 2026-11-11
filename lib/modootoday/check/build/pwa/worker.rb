# frozen_string_literal: true

require "json"

module Modootoday
  module Check
    module Pwa
      # The built sw.js: rendered by the theme include at the baseurl root, the constants form with enabled: true and the
      # self-removing form with kill, with an offline page for each language prefix it names. A disabled site that keeps
      # the stub serves the self-removing worker, which is right for a while and then only clutter.
      module Worker
        CONSTANTS = /^self\.MT_PWA = (\{.*\});$/
        KILL = "self.registration.unregister()"

        module_function

        def call(ctx, mode)
          f = File.join(ctx.site, Stubs::Pwa::WORKER)
          return ctx.errs << "#{f}: missing (#{HINT}, then build)" unless File.file?(f)
          if mode == "kill"
            ctx.errs << "#{f}: not the theme's self-removing worker; keep the stub as modootoday-stubs writes it" unless File.read(f).include?(KILL)
            return
          end
          c = settings(ctx)
          return ctx.errs << "#{f}: not the theme's worker (no self.MT_PWA); keep the stub as modootoday-stubs writes it" unless c
          base = c["scope"].to_s.chomp("/")
          c["offline"].to_h.each_value do |url|
            ctx.errs << "#{f}: the offline page #{url} is not in the build (#{HINT}, then build)" unless File.file?(file(ctx, base, url))
          end
        end

        # The worker's constants, or nil when sw.js is missing or not the theme's.
        def settings(ctx)
          f = File.join(ctx.site, Stubs::Pwa::WORKER)
          m = File.file?(f) && File.read(f)[CONSTANTS, 1]
          m && JSON.parse(m)
        rescue JSON::ParserError
          nil
        end

        # The built file a site URL (with the baseurl, maybe a query) is served from.
        def file(ctx, base, url)
          path = url.to_s.split("?").first.to_s.delete_prefix(base)
          File.join(ctx.site, path.end_with?("/") ? "#{path}index.html" : path)
        end

        def leftover(ctx)
          f = File.join(*[ctx.src, Pwa.dir(ctx), Stubs::Pwa::WORKER].compact)
          return unless File.file?(f) && Stubs::Pwa.ours?(File.read(f))
          ctx.warns << "#{ctx.rel(f)}: modootoday.pwa is off, so it serves a self-removing worker; delete the PWA stubs a week after the last enabled deploy"
        end
      end
    end
  end
end
