# frozen_string_literal: true

# The modootoday: keys of _config.yml, grouped by feature (appearance/, pages/, serving/). Load order is report order:
# keep it when adding a key.
require_relative "schema"
require_relative "validate"
require_relative "keys/pages/twins"
require_relative "keys/appearance/color_scheme"
require_relative "keys/serving/csp"
require_relative "keys/pages/languages"
require_relative "keys/pages/content"
require_relative "keys/pages/search"
require_relative "keys/pages/edit_url"
require_relative "keys/appearance/switches"
require_relative "keys/serving/delivery"
require_relative "keys/appearance/chrome"
require_relative "keys/appearance/components"
require_relative "keys/appearance/tokens"
