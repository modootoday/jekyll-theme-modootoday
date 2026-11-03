# frozen_string_literal: true

require "digest"

module Modootoday
  module I18n
    # source_rev: which revision of its source a translation was made from. The one owner of the hash, which
    # script/docs-index writes and modootoday-check --i18n-pages compares. Line endings, the generated page lists
    # and front matter other than the translated fields do not count as a change.
    module SourceRev
      FIELDS = %w[title description nav_title].freeze
      PATTERN = /\Asha256:\h{12}\z/

      module_function

      def of(text)
        t = text.gsub("\r\n", "\n")
        fm = Markdown.fm(t)
        fm = {} unless fm.is_a?(Hash)
        head = FIELDS.filter_map { |k| "#{k}: #{fm[k]}\n" if fm.key?(k) }.join
        body = Markdown.strip_index_lists(Markdown.body(t))
        "sha256:#{Digest::SHA256.hexdigest("#{head}\n#{body}")[0, 12]}"
      end
    end
  end
end
