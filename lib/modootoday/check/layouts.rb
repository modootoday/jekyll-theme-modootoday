# frozen_string_literal: true

require "time"
require_relative "layouts/shape"
require_relative "layouts/shells"
require_relative "layouts/directory"
require_relative "layouts/detail"
require_relative "layouts/marketing"
require_relative "layouts/docs_extra"

module Modootoday
  module Check
    # Front matter contracts of the theme layouts: each layout name maps to the check of the keys it reads
    # (lib/modootoday/check/layouts/). Pages with other layouts are left alone.
    module Layouts
      def self.contracts
        @contracts ||= {
          "error" => Shells.method(:error), "redirect" => Shells.method(:redirect), "home" => Shells.method(:home),
        }.merge(Directory::LAYOUTS.to_h { |l| [l, Directory.method(:call)] })
          .merge(Detail::LAYOUTS.to_h { |l| [l, Detail.method(:call)] })
          .merge(Marketing::LAYOUTS.to_h { |l| [l, Marketing.method(:call)] })
          .merge(DocsExtra::LAYOUTS.to_h { |l| [l, DocsExtra.method(:call)] })
      end

      def self.register(names, check) = names.each { |n| contracts[n] = check }

      def self.call(ctx)
        ctx.mds.each do |f|
          fm = Markdown.fm(File.read(f))
          check = contracts[fm["layout"]]
          check&.call(ctx.errs, "#{ctx.rel(f)}: layout #{fm['layout']}", fm, ctx)
        end
        Shells.fallback(ctx.errs, ctx.mtc.is_a?(Hash) && ctx.mtc["search"].is_a?(Hash) ? ctx.mtc["search"]["fallback"] : nil)
      end
    end
  end
end
