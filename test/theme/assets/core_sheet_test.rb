# frozen_string_literal: true
# The core sheet, which every page links, holds only tokens, base element rules and the shell (adr:modootoday/20261104053143):
# rules at least 90% of measured pages use. A component goes to a module sheet; adding a partial here needs a new record.
require "minitest/autorun"

class CoreSheetTest < Minitest::Test
  ROOT = File.expand_path("../../..", __dir__)
  CORE_IMPORTS = %w[
    modootoday/site settings tools/functions tools/mixins
    tokens/primitive tokens/semantic tokens/scale registry/hooks tokens/code-presets tokens/merge tokens/emit tokens/fonts
    base/reset base/prose base/bidi base/interaction
    layout/shell modootoday/components/core/chrome/header layout/safe-area
  ].freeze
  CORE_COMPONENTS = %w[core/chrome/nav core/chrome/theme-toggle].freeze
  SHEET = "assets/css/modootoday.scss"

  def read(path) = File.read(File.join(ROOT, path))

  def test_core_imports_only_tokens_base_and_shell
    assert_equal CORE_IMPORTS, read("_sass/modootoday/_core.scss").scan(/@import "([^"]+)"/).flatten
  end

  def test_core_components_are_the_shell
    assert_equal CORE_COMPONENTS, read("_includes/modootoday/config.html")[/assign mt_core_partials = "([^"]+)"/, 1].split(",")
  end

  def test_core_sheet_adds_only_the_shell_access_part_in_split_mode
    split = read(SHEET).sub(/\{%- if mt\.css == "bundle" -%\}.*?\{%- endif -%\}/m, "")
    assert_equal %w[modootoday/core modootoday/access], split.scan(/@import "([^"{]+)"/).flatten
  end
end
