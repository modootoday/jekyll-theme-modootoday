# frozen_string_literal: true
# Shared base for tests that run exe/modootoday-stubs on a throwaway site source.
require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "open3"
require "rbconfig"
require "json"

class StubsCase < Minitest::Test
  STUBS = File.expand_path("../../exe/modootoday-stubs", __dir__)
  CLEAN_ENV = { "BUNDLE_GEMFILE" => nil, "RUBYOPT" => nil, "BUNDLER_SETUP" => nil, "BUNDLER_VERSION" => nil }.freeze

  def setup
    @src = Dir.mktmpdir
    file "_config.yml", "title: T\n"
  end

  def teardown = FileUtils.rm_rf(@src)

  def file(name, text)
    path = File.join(@src, name)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, text)
  end

  def read(name) = File.read(File.join(@src, name))
  def exist?(name) = File.exist?(File.join(@src, name))
  def config(yaml) = file("_config.yml", "title: T\n#{yaml}")

  def stubs(*args)
    o, e, st = Open3.capture3(CLEAN_ENV, RbConfig.ruby, STUBS, @src, *args)
    [o, e, st.exitstatus]
  end

  def plan(*args) = JSON.parse(stubs(*args, "--json")[0])["changes"].to_h { |c| [c["path"], c["action"]] }
end
