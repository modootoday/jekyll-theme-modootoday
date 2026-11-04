# frozen_string_literal: true
# css: split and css: bundle hold the same rules (adr:modootoday/20261104053143): the core sheet plus every module, context and
# section sheet of a split build, against the one core sheet of a bundle build, as a multiset of (at-rules, selector, block).
require "minitest/autorun"
require_relative "../support/layout_site"

class CssOrderTest < Minitest::Test
  include LayoutSite

  # One entry per selector of each rule, keyed by its enclosing at-rules and its declaration block.
  def rules(css)
    css = css.gsub(%r{/\*.*?\*/}m, "").gsub(/\s+/, " ")
    out = []
    stack = []
    buf = +""
    css.each_char do |ch|
      case ch
      when "{"
        stack << buf.strip
        buf = +""
      when "}"
        head = stack.pop
        if head && !head.start_with?("@")
          ctx = stack.select { |s| s.start_with?("@") && !s.start_with?("@keyframes") }.join(" ")
          head.split(/,(?![^(]*\))/).each { |sel| out << "#{ctx} #{sel.strip}{#{buf.strip.sub(/;\z/, "")}}" } unless stack.any? { |s| s.start_with?("@keyframes") }
        end
        buf = +""
      when ";"
        buf.strip.start_with?("@") && stack.empty? ? buf = +"" : buf << ch
      else
        buf << ch
      end
    end
    out.tally
  end

  def theme_css(site, bundle:)
    files = bundle ? ["#{site}/assets/css/modootoday.css"] : Dir.glob("#{site}/assets/css/modootoday{.css,/**/*.css}")
    files.sum("") { |f| "#{File.read(f)}\n" }
  end

  def test_split_and_bundle_hold_the_same_rules
    split = Dir.mktmpdir { |d| theme_css(build_site(d, {})[1], bundle: false) }
    bundle = Dir.mktmpdir { |d| theme_css(build_site(d, {}, config: "modootoday: {css: bundle}\n")[1], bundle: true) }
    a = rules(split)
    b = rules(bundle)
    refute_empty a
    diff = (a.keys | b.keys).reject { |k| a[k] == b[k] }.map { |k| "#{a[k].to_i}x split, #{b[k].to_i}x bundle: #{k[0, 160]}" }
    assert_empty diff, "a rule only one mode has, or a different number of times"
  end
end
