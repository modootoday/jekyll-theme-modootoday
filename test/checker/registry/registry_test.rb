# frozen_string_literal: true
# _data/components.yml and _data/i18n (lib/modootoday/check/registry/): keys, slots, parts. Run: bundle exec rake test
require_relative "../checker_case"

class CheckRegistryTest < CheckerCase
  def test_i18n_translation_keys_follow_english
    page "a.md", "---\ntitle: A\n---\n# A\n"
    page "ko/a.md", "---\ntitle: A\n---\n# A\n"
    page "ko/b.md", "---\ntitle: B\n---\n# B\n"
    write File.join(@src, "_data/i18n/en.yml"), "skip: Skip\ntoc: {label: On this page}\nhero: {cta: Start}\n"
    write File.join(@src, "_data/i18n/ko.yml"), "skip: 건너뛰기\ntoc: {lable: 목차}\n"
    o, code = check
    assert_equal 1, code, o
    assert_includes o, "_data/i18n/ko.yml: key 'toc.lable' is not in _data/i18n/en.yml"
    assert_includes o, "missing key 'hero.cta' (falls back to en)"
    refute_includes o, "missing key 'toc.label'" # the theme ships ko toc.label
    assert_includes o, "ko/b.md: no en page at b.md"
    refute_includes o, "ko/a.md: no en page"
  end

  def test_components_registry
    write File.join(@src, "_data/components.yml"), "features: {params: {cols: {allowed: [2, 3], required: true}}}\ntabs: {i18n: [tabs.label, hero.cta]}\n"
    write File.join(@src, "_data/i18n/en.yml"), "callout: {}\n"
    page "a.md", "---\nsections: [{c: features, cols: 4}, {c: nope}]\n---\n## A\n## B\n"
    o, = check
    assert_match(/cols=4 not in/, o)
    assert_match(/unknown component 'nope'/, o)
    assert_match(/missing key 'hero.cta'/, o)
    refute_match(/missing key 'tabs.label'/, o) # the theme catalog has it
  end

  def test_slot_contract
    write File.join(@src, "_data/components.yml"),
          "features: {slots: {items: {min: 2, max: 3}, lead: {max: 0}}}\n" \
          "tabs: {slots: {panels: {min: 2}, code: {required: true}}}\n" \
          "cta: {slots: {actions: {required: true}, bogus: {}}}\n"
    page "ok.md", "---\nsections: [{c: features}, {c: tabs}, {c: cta}]\n---\n# T\n\n## F\n\n- **a** x\n- **b** y\n\n" \
                  "## Tabs\n\n### A\n\n```sh\n## not a heading\n```\n\n### B\n\n```sh\nb\n```\n\n## Next\n\n[Go](x/) [More](y/)\n"
    o, = check
    refute_match(/sections\[\d\]/, o)
    assert_match(/unknown slot 'bogus'/, o)
    page "bad.md", "---\nsections: [{c: features}, {c: tabs}, {c: cta}]\n---\n# T\n\n## F\n\nIntro.\n\n- one\n- two\n- three\n- four\n\n" \
                   "## Tabs\n\n### Only\n\n## Next\n\nNo links here.\n"
    o, code = check
    assert_equal 1, code
    assert_match(/bad.md: sections\[0\] features: slot 'items' has 4 item\(s\), allows at most 3/, o)
    assert_match(/bad.md: sections\[0\] features: slot 'lead' has 1 item\(s\), allows at most 0/, o)
    assert_match(/bad.md: sections\[1\] tabs: slot 'panels' has 1 item\(s\), needs at least 2/, o)
    assert_match(/bad.md: sections\[1\] tabs: slot 'code' has 0 item\(s\), needs at least 1/, o)
    assert_match(/bad.md: sections\[2\] cta: slot 'actions' has 0 item\(s\), needs at least 1/, o)
    refute_match(/ok.md: sections/, o)
  end

  def test_registry_keys_and_ranges
    write File.join(@src, "_data/components.yml"),
          "features: {slots: {items: {min: 3, max: 2}, lead: {required: yes, most: 1}}, colour: red}\n" \
          "cta: {slots: {actions: {min: -1}}, parts: oops}\n" \
          "steps: {slots: [{items: {min: 1}}]}\n"
    page "a.md", "---\n---\n# A\n"
    o, code = check
    assert_equal 1, code
    assert_match(/features: unknown key 'colour'/, o)
    assert_match(/features.slots.items: min 3 is greater than max 2/, o)
    assert_match(/features.slots.lead: unknown key 'most'/, o)
    assert_match(/cta.slots.actions.min must be a whole number/, o)
    assert_match(/cta.parts must be a list of CSS selectors/, o)
    assert_match(/steps.slots: a list of alternative forms needs at least 2 maps/, o)
  end

  def test_slot_alternatives
    write File.join(@src, "_data/components.yml"), "steps: {slots: [{items: {min: 2}}, {panels: {min: 2}}]}\n"
    page "ok.md", "---\nsections: [{c: steps}, {c: steps}]\n---\n# T\n\n## L\n\n1. a\n2. b\n\n## H\n\n### A\n\n### B\n"
    o, = check
    refute_match(/ok.md: sections/, o)
    page "bad.md", "---\nsections: [{c: steps}]\n---\n# T\n\n## L\n\n1. a\n"
    o, code = check
    assert_equal 1, code
    assert_match(/bad.md: sections\[0\] steps: matches none of 2 slot forms \(form 1: slot 'items' has 1 item\(s\), needs at least 2; form 2: slot 'panels' has 0/, o)
  end

  def test_parts_match_api_table
    write File.join(@src, "_data/components.yml"), "tabs: {parts: ['[role=tab]', 'h3 > button[aria-expanded]', .mt-gone]}\n"
    write File.join(@src, "api.md"), "---\n---\n# API\n\n## Component structure\n\n| C | Parts |\n|---|---|\n" \
                                     "| Tabs | `[role=tab]`, `h3 > button[aria-expanded]` |\n\n## Next\n\n`.mt-gone`\n"
    o, code = check
    assert_equal 1, code
    assert_match(/tabs.parts: '.mt-gone' is not in the Component structure table of api.md/, o)
    refute_match(/'\[role=tab\]' is not/, o)
  end
end
