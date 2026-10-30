# frozen_string_literal: true

# md-components v1 checker (Ruby stdlib only; Nokogiri optional). This file only assembles the parts;
# each rule group lives in check/<name>.rb and reports into one shared Context.
require "yaml"
require "date"
require_relative "check/markdown"
require_relative "check/context"
require_relative "check/registry"
require_relative "check/pages"
require_relative "check/i18n"
require_relative "check/built_parts"
require_relative "check/build_output"
require_relative "check/structured_data"
require_relative "check/stylesheets"
require_relative "check/site_config"
require_relative "check/blog"
require_relative "check/github_pages"
require_relative "check/layouts"
require_relative "check/twins"
require_relative "check/gh_render"
require_relative "check/renderers"
require_relative "check/cli"
