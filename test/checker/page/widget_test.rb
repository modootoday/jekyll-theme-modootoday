# frozen_string_literal: true
# Widgets (page/widget.rb, the element rules of config/keys/serving/delivery.rb): the w01-widget fixtures, widget_props,
# c: widget sections, and the element names a modootoday.scripts entry may define. Run: bundle exec rake test
require_relative "../checker_case"

class CheckWidgetTest < CheckerCase
  FIX = File.expand_path("../../fixtures/md", __dir__)
  CONFIG = "modootoday:\n  scripts:\n    counter: {src: /assets/js/x-counter.js, element: x-counter}\n"

  def fixture(name, fm = "") = page("#{name}.md", "---\n#{fm}---\n#{File.read(File.join(FIX, "#{name}.md"))}")

  def test_fixtures
    page "_config.yml", CONFIG
    fixture "w01-widget-ok"
    fixture "w01-widget-unregistered"
    fixture "w01-widget-props", "widget_props: {x-counter: {start: 3, label: Count, steps: [1, 2]}, x-other: {a: 1}}\n"
    o, code = check
    assert_equal 1, code, o
    assert_includes o, "w01-widget-unregistered.md: `widget:x-missing`: no modootoday.scripts entry has element: x-missing, so it stays a code span"
    assert_includes o, "w01-widget-props.md: widget_props.x-counter: steps must be a plain value (text, a number, true or false)"
    assert_includes o, "w01-widget-props.md: widget_props.x-other: no modootoday.scripts entry has element: x-other"
    refute_match(/w01-widget-ok/, o)
  end

  def test_sections
    page "_config.yml", CONFIG
    secs = "[{c: widget, name: a, widget: x-counter, props: {start: 2}}, {c: widget, name: b, widget: x-gone}, {c: widget, name: c}, " \
           "{c: widget, name: d, widget: x-counter, props: [1]}, {c: widget, name: e, widget: x-counter}]"
    page "a.md", "---\nsections: #{secs}\n---\n# A\n\n## A\n\nLead.\n\n## B\n\nLead.\n\n## C\n\nLead.\n\n## D\n\nLead.\n\n## E\n\n- only a list\n"
    o, code = check
    assert_equal 1, code, o
    assert_includes o, "a.md: sections[1] widget: widget: x-gone is not the element: of any modootoday.scripts entry"
    assert_includes o, "a.md: sections[2] widget: needs widget: <element> (the element: of a modootoday.scripts entry)"
    assert_includes o, "a.md: sections[3] widget.props must be a map of names to plain values"
    assert_includes o, "a.md: sections[4] widget: needs a paragraph after the heading, the text shown until the widget runs"
    refute_includes o, "sections[0]"
  end

  def test_element_names
    page "_config.yml", "modootoday:\n  scripts:\n    a: {src: /a.js, element: mt-counter}\n    b: {src: /b.js, element: x-dup}\n" \
                        "    c: {src: /c.js, element: x-dup}\n    d: {src: /d.js, element: font-face}\n"
    o, code = check
    assert_equal 1, code, o
    assert_includes o, "modootoday.scripts[a].element: the mt- prefix is the theme's (got mt-counter)"
    assert_includes o, "modootoday.scripts: element x-dup is named by more than one entry"
    assert_includes o, "modootoday.scripts[d].element must be a custom element name with a hyphen"
  end
end
