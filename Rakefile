# frozen_string_literal: true
require "rake/testtask"
require "bundler/gem_tasks"
Rake::TestTask.new(:test) { |t| t.test_files = FileList["test/**/*_test.rb"]; t.warning = false }
desc "Build the example site and run the checker"
task :example do
  sh "bundle exec jekyll build -q -s example -d example/_site"
  sh "ruby exe/modootoday-check example example/_site --twins"
end
task default: %i[test example]
desc "Regenerate _includes/modootoday/i18n* and t.html from i18n/*.yml"
task(:i18n) { ruby "script/i18n-build" }
namespace(:i18n) { desc "Fail when generated i18n includes are stale"; task(:check) { ruby "script/i18n-build", "--check" } }
