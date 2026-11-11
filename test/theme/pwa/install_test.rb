# frozen_string_literal: true
# The c: install section: the section text, a hidden Install button and the hint, with its own sheet; pwa/install.js
# loads only with the PWA on and only on pages with the section, after register.js, which keeps an early offer for it.
require "minitest/autorun"
require_relative "../../support/pwa_site"

class PwaInstallTest < Minitest::Test
  PAGE = "---\ntitle: Get the app\nsections: [{c: install, name: app}]\n---\n# Get the app\n\n## Install\n\nRead the guides offline.\n"

  def self.site(key, config, **opts) = ((@sites ||= {})[key] ||= PwaSite.build(config, files: { "app.md" => PAGE }, **opts))

  def on = self.class.site(:on, "baseurl: /docs\nmodootoday: {pwa: {enabled: true}}\n")
  def off = self.class.site(:off, "lang: ko\nmodootoday: {favicon: brand}\n", stub: false)
  def html(site, name = "app/index.html") = File.read(File.join(site, name))

  def test_markup_is_the_text_a_hidden_button_and_the_hint
    h = html(on)
    assert_match(%r{<section class="mt-section mt-c-install" data-section="app" data-c="install">\s*<h2 id="install">Install</h2>\s*<p>Read the guides offline.</p>\s*<button type="button" class="mt-install" hidden>Install</button>\s*<p class="mt-install-hint">Your browser can also install this site from its menu or share sheet.</p>\s*</section>}, h)
    assert_includes html(off), '<button type="button" class="mt-install" hidden>설치</button>'
  end

  def test_sheet_on_section_pages_and_module_only_with_the_pwa
    assert_includes html(on), 'href="/docs/assets/css/modootoday/showcase/install.css?v='
    assert_match(%r{pwa/register\.js\?v=[^"]+"></script>\s*<script type="module" src="/docs/assets/js/modootoday/pwa/install\.js\?v=}, html(on))
    refute_includes html(on, "index.html"), "install.js"
    refute_includes html(on, "index.html"), "install.css"
    assert_includes html(off), "showcase/install.css"
    refute_includes html(off), "install.js"
  end

  def test_the_sheet_has_the_button_hint_and_installed_app_rules
    css = File.read(File.join(on, "assets/css/modootoday/showcase/install.css"))
    assert_includes css, ".mt-install[hidden]"
    assert_includes css, ".mt-install-hint"
    assert_match(/@media \(display-mode: ?standalone\), ?\(display-mode: ?minimal-ui\)/, css)
  end
end
