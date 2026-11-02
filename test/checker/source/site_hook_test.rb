# frozen_string_literal: true
# The site's token hook _sass/modootoday/_site.scss (lib/modootoday/check/source/site_hook.rb). Run: bundle exec rake test
require_relative "../checker_case"

class CheckSiteHookTest < CheckerCase
  HOOK = "_sass/modootoday/_site.scss"

  def test_the_three_maps_with_theme_tokens_pass
    page HOOK, "// brand\n/* block\ncomment */\n$mt-overrides-base: (font-heading: (\"Fraunces\", var(--mt-font-sans)), heading-weight: 600);\n" \
               "$mt-overrides: (\n  primary: #0f766e, // teal\n  link: #0f766e, link-hover: #115e59\n);\n$mt-overrides-dark: ();\n"
    o, code = check("--strict")
    assert_equal 0, code, o
  end

  def test_other_statements_and_unknown_tokens_fail
    page HOOK, "$mt-overrides: (primray: #0f766e, link: #0f766e);\n\n$brand: #123456;\n@import \"brand\";\n" \
               "$mt-overrides-base: (primary: #000);\n.x { color: red; }\n"
    o, code = check
    assert_equal 1, code
    assert_includes o, "#{HOOK}:1: $mt-overrides: unknown token primray"
    refute_includes o, "unknown token link"
    assert_includes o, "#{HOOK}:3: only $mt-overrides-base, $mt-overrides and $mt-overrides-dark maps belong here"
    assert_includes o, "#{HOOK}:4: only $mt-overrides-base"
    assert_includes o, "#{HOOK}:5: $mt-overrides-base: unknown token primary"
    assert_match(/#{Regexp.escape(HOOK)}:6: only/, o)
  end

  def test_other_sass_files_are_not_hooks
    page "_sass/site/_site.scss", "$brand: #123456;\n"
    assert_equal 0, check[1]
  end
end
