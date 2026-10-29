# frozen_string_literal: true
require "rake/testtask"
require "bundler/gem_tasks"
Rake::TestTask.new(:test) { |t| t.test_files = FileList["test/*_test.rb"]; t.warning = false }
desc "Build the example site and run the checker"
task :example do
  sh "bundle exec jekyll build -q -s example -d example/_site"
  sh "ruby exe/modootoday-check example example/_site --twins"
end
task default: %i[test example]
