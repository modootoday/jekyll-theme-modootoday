# frozen_string_literal: true

# modootoday-stubs (Ruby stdlib only): writes the front-matter-only stub pages that classic GitHub Pages needs for
# twins, URL aliases, record pages and the PWA entry files. It is apart from modootoday-check so the checker never writes into a site.
require "yaml"
require "date"
require "json"
require "fileutils"
require_relative "markdown"
require_relative "stubs/page"
require_relative "stubs/source"
require_relative "stubs/twins"
require_relative "stubs/aliases"
require_relative "stubs/records"
require_relative "stubs/pwa"
require_relative "stubs/plan"
require_relative "stubs/writer"
require_relative "stubs/report"
require_relative "stubs/cli"

module Modootoday
  module Stubs
    GENERATORS = { twins: Twins, aliases: Aliases, records: Records, pwa: Pwa }.freeze
  end
end
