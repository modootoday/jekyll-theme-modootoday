# frozen_string_literal: true
# Translation style lint (dev-only), driven by i18n/glossary.yml. Run by script/i18n-build --check.
#   catalogs  every i18n/<code>.yml: same keys as en.yml, same [n]/[total]/[section] and %{x}
#             placeholders, no empty values, no leading/trailing spaces, no trailing whitespace on lines
#   prose     ko/ja docs, READMEs, example pages and posts (code, inline code, URLs and Liquid removed):
#             glossary `avoid` terms, calques, register (ko docs 합니다체 and ko UI 해요체; ja です・ます),
#             and untranslated English sentences. Pages with `noindex: true` are samples and skip register.
require "yaml"

module I18nLint
  HAEYO = /[가-힣](?<![세시])요[.!](?=\s|$|["”)*_])/ # 해요체 statement (하세요/하시요 imperatives are fine)
  HANDA = /[가-힣](?<![니])다\.(?=\s|$)/ # 한다체 statement in 합니다체 docs
  HAMNIDA = /[습읍입니]니다[.!]?\s*\z|니다\.\s*\z/ # 합니다체 sentence in a ko UI string
  JA_PLAIN = /(?:である|だ|ない|(?<![まで])(?:する|した))。/
  EN_SENTENCE = /(?:\b[A-Za-z][a-z'’-]*\b[ ,]+){5,}[A-Za-z][a-z'’-]*[.:!?]/
  PH = /\[(?:n|total|section)\]|%\{\w+\}/

  module_function

  def leaves(h, pre = nil) = h.is_a?(Hash) ? h.flat_map { |k, v| leaves(v, [pre, k].compact.join(".")) } : [[pre, h.to_s]]

  def catalogs(root)
    errs = []
    reg = leaves(YAML.safe_load(File.read("#{root}/i18n/en.yml", encoding: "UTF-8"))).to_h
    YAML.safe_load(File.read("#{root}/i18n/languages.yml", encoding: "UTF-8")).map { |l| l["code"] }.each do |code|
      f = "i18n/#{code}.yml"
      src = File.read("#{root}/#{f}", encoding: "UTF-8")
      src.each_line.with_index(1) { |l, i| errs << "#{f}:#{i}: trailing whitespace" if l.match?(/[ \t]+\n?\z/) && l.strip != "" }
      h = leaves(YAML.safe_load(src)).to_h
      (reg.keys - h.keys).each { |k| errs << "#{f}: missing key #{k}" }
      (h.keys - reg.keys).each { |k| errs << "#{f}: unknown key #{k}" }
      h.each do |k, v|
        next unless reg.key?(k)
        errs << "#{f}: #{k} is empty" if v.strip.empty?
        errs << "#{f}: #{k} has leading/trailing spaces" if v != v.strip
        errs << "#{f}: #{k} placeholders #{v.scan(PH).sort} differ from English #{reg[k].scan(PH).sort}" unless v.scan(PH).sort == reg[k].scan(PH).sort
        errs << "#{f}: #{k} uses 합니다체; interface sentences use 해요체" if code == "ko" && v.match?(HAMNIDA)
      end
    end
    errs
  end

  # Prose with code, inline code, URLs, Liquid, HTML tags and front matter keys removed; [line, text] pairs.
  def prose(src)
    out, fence, fm = [], nil, src.start_with?("---\n")
    src.each_line.with_index(1) do |l, i|
      if fm
        fm = false if i > 1 && l.start_with?("---")
        out << [i, l.sub(/\A\s*[\w-]+:\s*/, "")] if l.match?(/\A(?:title|description|deck|nav_title):/)
        next
      end
      if (m = l.match(/\A\s*(```+|~~~+)[^`]*\z/))
        fence = fence ? (m[1].start_with?(fence) ? nil : fence) : m[1]
        next
      end
      next if fence || l.match?(/\A {4,}\S/)

      t = l.gsub(/`[^`]*`/, " ").gsub(/\{[{%].*?[%}]\}/, " ").gsub(%r{\]\([^)]*\)|https?://\S+|<[^>]+>}, " ")
      out << [i, t]
    end
    out
  end

  def sample?(src) = src[/\A---\n.*?\n---/m].to_s.match?(/^noindex: true$/)

  def file(path, rel, lang, gl, ui: false)
    errs = []
    src = File.read(path, encoding: "UTF-8")
    terms = gl["terms"].flat_map { |t| (t.dig("avoid", lang) || []).map { |a| [a, t[lang], /#{Regexp.escape(a)}(?!ー)/] } }
    calques = (gl.dig("calques", lang) || []).map { |c| [Regexp.new(c["re"]), c] }
    lines = path.end_with?(".yml") ? src.each_line.with_index(1).map { |l, i| [i, l.sub(/\A\s*[\w-]+:\s*/, "")] } : prose(src)
    lines.each do |i, t|
      terms.each { |bad, good, re| errs << "#{rel}:#{i}: '#{bad}' → use '#{good}' (i18n/glossary.yml)" if t.match?(re) }
      calques.each { |re, c| errs << "#{rel}:#{i}: calque /#{c['re']}/ (#{c['why']}) → #{c['use']}" if t.match?(re) }
      next if ui || sample?(src)

      if lang == "ko"
        errs << "#{rel}:#{i}: 해요체 sentence; docs use 합니다체" if t.match?(HAEYO)
        errs << "#{rel}:#{i}: 한다체 sentence; docs use 합니다체" if t.match?(HANDA)
      elsif lang == "ja"
        errs << "#{rel}:#{i}: 常体 sentence; docs use です・ます" if t.match?(JA_PLAIN) && !t.lstrip.start_with?("|")
      end
      cjk = t.match?(/[\p{Hangul}\p{Hiragana}\p{Katakana}\p{Han}]/)
      errs << "#{rel}:#{i}: untranslated English sentence" if !cjk && t.match?(EN_SENTENCE) && !t.lstrip.start_with?("|", "<!--")
    end
    errs
  end

  def targets(root, lang)
    globs = ["docs/#{lang}/**/*.md", "example/#{lang}/**/*.md", "docs/_posts/*-#{lang}.md", "README.#{lang}.md"]
    globs.flat_map { |g| Dir.glob(g, base: root) }.uniq.sort.reject { |r| r.end_with?("guides/translation.md") } # the rules page quotes the bad forms
  end

  def run(root)
    gl = YAML.safe_load(File.read("#{root}/i18n/glossary.yml", encoding: "UTF-8"))
    errs = catalogs(root)
    %w[ko ja].each do |lang|
      targets(root, lang).each { |r| errs.concat(file("#{root}/#{r}", r, lang, gl)) }
      ["i18n/#{lang}.yml", "docs/_data/i18n/#{lang}.yml", "example/_data/i18n/#{lang}.yml"].each do |r|
        errs.concat(file("#{root}/#{r}", r, lang, gl, ui: true)) if File.file?("#{root}/#{r}")
      end
    end
    errs
  end
end
