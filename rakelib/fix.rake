# frozen_string_literal: true

require "digest"
require "open3"

# Generators fix, checks verify (adr:modootoday/20261109225836): CI keeps each generator's --check form.
FIX_GENERATORS = [
  %w[script/docs-index], %w[script/readme-commands], %w[script/i18n-build], %w[script/version-include], %w[script/changelog]
].freeze

desc "Run every generator in write mode (docs index, README commands, i18n, version include, CHANGELOG [Unreleased]) " \
     "and print the files that changed; translation stamps stay deliberate (script/docs-index --stamp)"
task :fix do
  root = File.expand_path("..", __dir__)
  snapshot = lambda do
    files = Open3.capture2("git", "-C", root, "ls-files", "-z", "-c", "-o", "--exclude-standard").first.split("\0")
    files.to_h { |f| [f, File.file?(File.join(root, f)) ? Digest::SHA256.file(File.join(root, f)).hexdigest : nil] }
  end
  before = snapshot.call
  failed = FIX_GENERATORS.reject { |args| system(RbConfig.ruby, *args.map { |a| File.join(root, a) }, chdir: root) }
  after = snapshot.call
  changed = (before.keys | after.keys).reject { |f| before[f] == after[f] }.sort
  puts changed.empty? ? "fix: nothing changed" : (["fix: changed (review and commit these):"] + changed).join("\n  ")
  abort "fix: failed: #{failed.map(&:first).join(", ")}" unless failed.empty?
end
