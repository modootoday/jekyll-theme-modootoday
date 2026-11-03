# frozen_string_literal: true

module Modootoday
  module Check
    module Config
      Schema.register(Key.new(name: "languages", type: :list, pattern: /\A[a-z]{2,3}(-[A-Za-z0-9]+)*\z/,
                              message: "must be a list of language codes such as [en, ko]"))

      # The languages that must translate every default-language page (modootoday-check --i18n-pages).
      in_languages = lambda do |ctx, path, list|
        langs = Array(ctx.mtc["languages"]).map(&:to_s)
        (list.map(&:to_s) - langs).each { |l| ctx.errs << "_config.yml: #{path}: '#{l}' is not in modootoday.languages" }
      end
      Schema.register(Key.new(name: "full_languages", type: :list, message: "must be a list of codes from modootoday.languages", check: in_languages))
    end
  end
end
