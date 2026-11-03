# frozen_string_literal: true

# The modootoday: keys of _config.yml. Load order is report order: keep it when adding a key.
require_relative "schema"
require_relative "validate"
require_relative "keys/twins"
require_relative "keys/color_scheme"
require_relative "keys/csp"
require_relative "keys/languages"
require_relative "keys/content"
require_relative "keys/search"
require_relative "keys/edit_url"
require_relative "keys/switches"
require_relative "keys/delivery"
require_relative "keys/chrome"
require_relative "keys/components"
require_relative "keys/tokens"
