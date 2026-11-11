# frozen_string_literal: true

require "json"

module Modootoday
  module Check
    module Pwa
      # The built manifest.webmanifest: a JSON object with the fields browsers need to install the site, start_url and id
      # inside the scope, and icons and screenshots that are PNG files in SITE of the size they state (read from the IHDR
      # chunk); a shortcut opens a page of the build.
      module Manifest
        REQUIRED = %w[id name short_name start_url scope display icons].freeze
        PNG = "\x89PNG\r\n\x1a\n".b

        module_function

        def call(ctx)
          f = File.join(ctx.site, Stubs::Pwa::MANIFEST)
          return ctx.errs << "#{f}: missing (#{HINT}, then build)" unless File.file?(f)
          m = JSON.parse(File.read(f))
          return ctx.errs << "#{f}: must be a JSON object" unless m.is_a?(Hash)
          missing = REQUIRED - m.keys
          return ctx.errs << "#{f}: missing #{missing.join(', ')}" unless missing.empty?
          scope = m["scope"].to_s
          %w[start_url id].each { |k| ctx.errs << "#{f}: #{k} #{m[k].inspect} is outside the scope #{scope}" unless m[k].to_s.start_with?(scope) }
          icons(ctx, f, m["icons"], scope.chomp("/"))
          Array(m["screenshots"]).each { |i| image(ctx, f, "screenshot", i, scope.chomp("/")) }
          Array(m["shortcuts"]).each { |s| shortcut(ctx, f, s.is_a?(Hash) ? s["url"].to_s : "", scope) }
        rescue JSON::ParserError => e
          ctx.errs << "#{f}: not JSON (#{e.message.lines.first.strip})"
        end

        # Icon URLs carry the baseurl, which the built SITE folder does not.
        def icons(ctx, f, icons, base)
          return ctx.errs << "#{f}: icons must be a list" unless icons.is_a?(Array) && !icons.empty?
          icons.each { |i| image(ctx, f, "icon", i, base) }
        end

        def image(ctx, f, kind, i, base)
          src = i.is_a?(Hash) ? i["src"].to_s : ""
          file = File.join(ctx.site, src.delete_prefix(base).split("?").first.to_s)
          return ctx.errs << "#{f}: #{kind} #{src.inspect} is not in the build" unless src.start_with?("#{base}/") && File.file?(file)
          size = png_size(file)
          return ctx.errs << "#{f}: #{kind} #{src} is not a PNG file" unless size
          ctx.errs << "#{f}: #{kind} #{src} is #{size.join('x')}, not #{i['sizes']}" unless i["sizes"] == size.join("x")
        end

        def shortcut(ctx, f, url, scope)
          return ctx.errs << "#{f}: shortcut #{url.inspect} is outside the scope #{scope}" unless url.start_with?(scope)
          ctx.errs << "#{f}: shortcut #{url} is not in the build" unless File.file?(Worker.file(ctx, scope.chomp("/"), url))
        end

        def png_size(file)
          head = File.binread(file, 24)
          return unless head && head.size == 24 && head.start_with?(PNG) && head[12, 4] == "IHDR"
          head[16, 8].unpack("NN")
        end
      end
    end
  end
end
