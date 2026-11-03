# frozen_string_literal: true
# Rouge token classes to --mt-code-* tokens (_sass/modootoday/base/_code.scss), the default colour of each class
# against the five tokens it used before, and the code presets (tokens/_code-presets.scss).
require "minitest/autorun"

class CodeTokensTest < Minitest::Test
  SEMANTIC_REF = /\Avar\(--mt-(?!p-)([\w-]+)\)\z/
  SASS = File.expand_path("../../../_sass/modootoday", __dir__)
  TABLE = {
    "comment" => %w[c c1 cm cs cp cd], "keyword" => %w[k kd kn kp kr kt kc ow], "tag" => %w[nt],
    "string" => %w[s s1 s2 sb sc sd se sh si sx sr ss], "number" => %w[m mi mf mh mo il], "constant" => %w[no bp py],
    "variable" => %w[vc vg vi], "attribute" => %w[na], "function" => %w[nf fm nn nb nd ne], "type" => %w[nc],
    "operator" => %w[o], "deleted" => %w[gd err], "inserted" => %w[gi]
  }.freeze
  # The token each class read before the finer tokens; .o had no rule and inherited the text colour.
  BEFORE = {
    "comment" => "code-comment", "keyword" => "code-keyword", "tag" => "code-keyword", "string" => "code-string",
    "number" => "code-constant", "constant" => "code-constant", "variable" => "code-constant", "attribute" => "code-constant",
    "function" => "code-function", "type" => "code-function", "operator" => "currentColor", "deleted" => "caution", "inserted" => "tip"
  }.freeze

  def rules
    File.read(File.join(SASS, "base/_code.scss")).scan(/^\s*\.highlight (?::is\(([^)]*)\)|\.(\w+))[^{]*\{ color: mt\(code-([\w-]+)\)/)
        .to_h { |list, one, token| [token, list ? list.delete(".").split(/,\s*/) : [one]] }
  end

  def sem = (@sem ||= File.read(File.join(SASS, "tokens/_semantic.scss")))

  # name: value pairs of one Sass map, split on top-level commas
  def sass_map(src, name)
    body = src[/\$#{name}:\s*\((.*?)\n\)/m, 1].gsub(%r{//[^\n]*}, "")
    parts, cur, depth = [], +"", 0
    body.each_char do |c|
      depth += { "(" => 1, ")" => -1 }.fetch(c, 0)
      next cur << c unless c == "," && depth.zero?
      parts << cur
      cur = +""
    end
    (parts << cur).reject { _1.strip.empty? }.to_h { |p| p.split(":", 2).map(&:strip) }
  end

  def resolve(map, v)
    v = v.to_s
    while (m = v.match(SEMANTIC_REF)) && map.key?(m[1]) do v = map[m[1]] end
    v
  end

  def test_every_rouge_class_maps_to_one_code_token
    assert_equal TABLE, rules
  end

  def test_default_colours_match_the_tokens_used_before
    %w[mt-light mt-dark].each do |name|
      map = sass_map(sem, name)
      TABLE.each_key do |token|
        before = BEFORE[token] == "currentColor" ? "currentColor" : resolve(map, map.fetch(BEFORE[token]))
        assert_equal before, resolve(map, map.fetch("code-#{token}")), "#{name} #{token}"
      end
      assert_equal "var(--mt-muted)", map["code-background"], "#{name} code block background"
    end
  end

  def test_presets_set_every_code_token_in_both_schemes
    code = sass_map(sem, "mt-light").keys.grep(/\Acode-/).sort
    presets = File.read(File.join(SASS, "tokens/_code-presets.scss"))
    %w[light dark].each do |s|
      body = presets[/\$mt-code-github-#{s}:\s*\((.*?)\n\);/m, 1] or flunk("$mt-code-github-#{s} missing")
      keys = body.scan(/([\w-]+):\s*#\h{6}/).flatten.sort
      assert_equal code, keys, "github #{s}"
    end
    assert_equal sass_map(sem, "mt-light").keys.sort, sass_map(sem, "mt-dark").keys.sort
  end
end
