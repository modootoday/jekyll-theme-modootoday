# frozen_string_literal: true
# Shared base for tests that run exe/modootoday-check on a throwaway SRC and SITE.
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "open3"
require "rbconfig"

class CheckerCase < Minitest::Test
  CHECK = File.expand_path("../../exe/modootoday-check", __dir__)
  ROOT = File.expand_path("../..", __dir__)

  # The checker runs outside the parent bundle (as users run it); never leak bundler env into it.
  CLEAN_ENV = { "BUNDLE_GEMFILE" => nil, "RUBYOPT" => nil, "BUNDLER_SETUP" => nil, "BUNDLER_VERSION" => nil }.freeze

  def setup
    @dir = Dir.mktmpdir
    @src = File.join(@dir, "src")
    @site = File.join(@dir, "_site")
    FileUtils.mkdir_p([@src, @site])
  end

  def teardown = FileUtils.rm_rf(@dir)

  def page(name, text) = write(File.join(@src, name), text)
  def out(name, text) = write(File.join(@site, name), text)

  def write(path, text)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, text)
  end

  def check(*flags)
    o, e, st = Open3.capture3(CLEAN_ENV, RbConfig.ruby, CHECK, @src, @site, *flags)
    [o + e, st.exitstatus]
  end
end
