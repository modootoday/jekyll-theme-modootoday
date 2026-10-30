# frozen_string_literal: true
# Check::Renderers on hand-written settings and built pages (fake URLs; nothing is fetched).
require "minitest/autorun"
require_relative "../../lib/modootoday/check"

class RenderersCheckTest < Minitest::Test
  R = Modootoday::Check::Renderers
  Ctx = Struct.new(:errs, :warns, :mtc)
  URL = "https://cdn.example.test/mermaid@11.4.1/dist/mermaid.min.js"
  SRI = "sha384-AAAAbbbbCCCCdddd0123456789+/AAAAbbbbCCCCdddd0123456789+/AAAAbbbbCC"

  def settings(mtc, warns: false)
    ctx = Ctx.new([], [], mtc)
    R.settings(ctx)
    warns ? ctx.warns : ctx.errs
  end

  def page(html, mtc)
    ctx = Ctx.new([], [], mtc)
    R.page(ctx, "p.html", html, R.allowed(mtc))
    ctx.errs
  end

  def mm(**o) = { "mermaid" => { "enabled" => true, "src" => URL, "integrity" => SRI }.merge(o.transform_keys(&:to_s)) }

  def test_valid_settings
    assert_empty settings(mm)
    assert_empty settings(mm(src: "/assets/mermaid/mermaid.min.js", integrity: nil))
    assert_empty settings({ "mermaid" => { "enabled" => false } })
    assert_empty settings({})
  end

  def test_settings_errors
    {
      mm(integrity: nil) => "integrity (an SRI hash such as sha384-…) is required",
      mm(src: nil) => "modootoday.mermaid.src is required",
      mm(src: "https://cdn.example.test/mermaid/dist/mermaid.min.js") => "pin an exact version",
      mm(src: "https://cdn.example.test/mermaid@latest/dist/mermaid.min.js") => "pin an exact version",
      mm(src: "http://cdn.example.test/mermaid@11.4.1/mermaid.min.js") => "use https://",
      mm(src: "assets/mermaid.js", integrity: nil) => "must be an https URL or a site path",
      mm(integrity: "md5-abc") => "not an SRI hash",
      mm(theme: "blue") => "theme must be",
      mm(enabled: "yes") => "enabled must be true or false",
      mm(cdn: 1) => "unknown key 'cdn'",
      { "mermaid" => true } => "must be a map",
    }.each { |cfg, msg| assert(settings(cfg).any? { |e| e.include?(msg) }, "#{msg}: #{settings(cfg)}") }
  end

  def test_built_pages
    tag = %(<script src="#{URL}" integrity="#{SRI}" crossorigin="anonymous" defer></script>)
    assert_empty page(tag, mm)
    assert_empty page(%(<script src="/assets/js/modootoday-mermaid.js" defer></script><link rel="canonical" href="https://e.org/">), {})
    {
      [tag, {}] => "is not a declared renderer URL",
      [tag, mm(enabled: false)] => "is not a declared renderer URL",
      [%(<script src="https://other.example.test/x@1.0.0/x.js" integrity="#{SRI}" crossorigin="anonymous"></script>), mm] => "is not a declared renderer URL",
      [%(<link rel="stylesheet" href="https://other.example.test/x.css">), mm] => "external stylesheet",
      [%(<script src="#{URL}" crossorigin="anonymous"></script>), mm] => "without integrity",
      [%(<script src="#{URL}" integrity="sha384-zzz" crossorigin="anonymous"></script>), mm] => "integrity differs",
      [%(<script src="#{URL}" integrity="#{SRI}"></script>), mm] => "without crossorigin",
    }.each { |(html, cfg), msg| assert(page(html, cfg).any? { |e| e.include?(msg) }, "#{msg}: #{page(html, cfg)}") }
  end

  K = "https://cdn.example.test/katex@0.16.11/dist/"
  def mx(**o)
    { "math" => { "enabled" => true, "engine" => "katex", "src" => "#{K}katex.min.js", "css" => "#{K}katex.min.css", "integrity" => { "js" => SRI, "css" => SRI },
                  "auto_render_src" => "#{K}contrib/auto-render.min.js", "auto_render_integrity" => SRI }.merge(o.transform_keys(&:to_s)) }
  end

  def test_math_settings
    assert_empty settings(mx)
    assert_empty settings(mx(src: "/assets/katex/katex.min.js", css: "/assets/katex/katex.min.css", integrity: nil, auto_render_src: "/assets/katex/auto-render.min.js", auto_render_integrity: nil))
    assert_empty settings({ "math" => { "enabled" => false } })
    {
      mx(integrity: { "js" => SRI }) => "integrity.css (an SRI hash such as sha384-…) is required",
      mx(integrity: nil) => "integrity.js (an SRI hash such as sha384-…) is required",
      mx(auto_render_integrity: nil) => "auto_render_integrity (an SRI hash such as sha384-…) is required",
      mx(css: nil) => "modootoday.math.css is required",
      mx(src: "https://cdn.example.test/katex/dist/katex.min.js") => "pin an exact version",
      mx(engine: "mathjax") => "engine must be katex",
      mx(inline: "yes") => "inline must be true or false",
      mx(integrity: "sha384-x") => "integrity must be a map",
      mx(macros: 1) => "unknown key 'macros'",
    }.each { |cfg, msg| assert(settings(cfg).any? { |e| e.include?(msg) }, "#{msg}: #{settings(cfg)}") }
    assert_empty settings(mx, warns: true)
    no_ar = mx; no_ar["math"].delete("auto_render_src"); no_ar["math"].delete("auto_render_integrity")
    assert(settings(no_ar, warns: true).any? { |x| x.include?("only ```math fences render") })
  end

  def test_math_built_pages
    ok = %(<link rel="stylesheet" href="#{K}katex.min.css" integrity="#{SRI}" crossorigin="anonymous"><script src="#{K}katex.min.js" integrity="#{SRI}" crossorigin="anonymous" defer></script>)
    assert_empty page(ok, mx)
    refute_empty page(ok, mx(enabled: false))
    assert(page(%(<link rel="stylesheet" href="#{K}katex.min.css">), mx).any? { |e| e.include?("without integrity") })
  end

  def test_inline_dollar
    {
      "Energy $E=mc^2$ here.\n" => 1, "a\nSet $a$.\n" => 2,
      "Price $5 and $10.\n" => nil, "`$x$` in code\n" => nil, "$$x$$ is kramdown inline math\n" => nil,
      "```sh\necho $HOME$\n```\n" => nil, "    $a$ indented code\n" => nil, "a $ b $ c\n" => nil,
    }.each { |text, n| n ? assert_equal(n, R.inline_dollar(text), text) : assert_nil(R.inline_dollar(text), text) }
  end
end
