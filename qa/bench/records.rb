#!/usr/bin/env ruby
# frozen_string_literal: true

# Records benchmark: builds the synthetic records site (fixture.rb) with the classic GitHub Pages builder image and reports
# build time and peak memory per record count. Fails when a build fails or takes longer than --limit seconds.
# Usage: ruby qa/bench/records.rb [--records 250,1000] [--where] [--limit 300] [--work DIR] [--image IMAGE]
require "optparse"
require "tmpdir"
require "rbconfig"
require_relative "fixture"

opts = { records: [250, 1000], where: false, limit: 300.0, work: File.join(Dir.tmpdir, "mt-bench"),
         image: "ghcr.io/actions/jekyll-build-pages:v1.0.13" }
OptionParser.new do |o|
  o.on("--records LIST", Array) { |v| opts[:records] = v.map { |n| Integer(n) } }
  o.on("--where", "drop record_index from the stubs (every page scans the records)") { opts[:where] = true }
  o.on("--limit SECONDS", Float) { |v| opts[:limit] = v }
  o.on("--work DIR") { |v| opts[:work] = File.expand_path(v) }
  o.on("--image IMAGE") { |v| opts[:image] = v }
end.parse!

# Peak resident memory of the Jekyll process, written when it exits (RUBYOPT loads this into the builder).
HWM = 'at_exit { File.write("/out/.bench-hwm", File.read("/proc/self/status")[/VmHWM:\s+(\d+)/, 1].to_s) }'

def build(opts, src, out)
  FileUtils.rm_rf(out)
  FileUtils.mkdir_p(out)
  File.write("#{src}/.bench-hwm.rb", HWM)
  system("chmod", "-R", "a+rX", src, exception: true)
  File.chmod(0o777, out)
  cmd = ["docker", "run", "--rm", "--memory", "3g", "--cpus", "2", "--user", "#{Process.uid}:#{Process.gid}", "-e", "HOME=/tmp",
         "-e", "JEKYLL_ENV=production", "-e", "PAGES_REPO_NWO=example/bench", "-e", "RUBYOPT=-r/src/.bench-hwm.rb",
         "-v", "#{src}:/src", "-v", "#{out}:/out", "-w", "/usr/local/bundle", "--entrypoint", "/usr/local/bundle/bin/github-pages",
         opts[:image], "build", "--source", "/src", "--destination", "/out"]
  t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  log = IO.popen(cmd, err: %i[child out], &:read)
  wall = Process.clock_gettime(Process::CLOCK_MONOTONIC) - t0
  hwm = File.exist?("#{out}/.bench-hwm") ? File.read("#{out}/.bench-hwm").to_i / 1024 : nil
  { ok: $?.success?, wall: wall, jekyll: log[/done in ([\d.]+) seconds/, 1]&.to_f, mib: hwm, log: log }
end

rows = opts[:records].map do |n|
  src = Bench::Fixture.write(File.join(opts[:work], "src-#{n}"), n, where: opts[:where])
  r = build(opts, src, File.join(opts[:work], "out-#{n}"))
  pages = Dir.glob(File.join(opts[:work], "out-#{n}", "skills", "*", "index.html")).size
  warn r[:log].lines.last(20).join unless r[:ok]
  r.merge(records: n, pages: pages)
end

lookup = opts[:where] ? "where (no record_index)" : "record_index"
table = ["| Records | Lookup | Record pages | Jekyll (s) | Wall (s) | Peak RSS (MiB) | Per page (ms) |", "|---:|---|---:|---:|---:|---:|---:|"]
rows.each do |r|
  per = r[:jekyll] ? format("%.1f", r[:jekyll] * 1000 / [r[:records], 1].max) : "-"
  table << format("| %d | %s | %d | %s | %.1f | %s | %s |", r[:records], lookup, r[:pages], r[:jekyll] || "failed", r[:wall], r[:mib] || "-", per)
end
puts table
File.write(ENV["GITHUB_STEP_SUMMARY"], "### Records benchmark (limit #{opts[:limit].round} s)\n\n#{table.join("\n")}\n", mode: "a") if ENV["GITHUB_STEP_SUMMARY"]
bad = rows.reject { |r| r[:ok] && r[:pages] == r[:records] && r[:jekyll] && r[:jekyll] <= opts[:limit] }
bad.each { |r| warn "records benchmark: #{r[:records]} records: #{r[:ok] ? "#{r[:jekyll] || "?"} s > #{opts[:limit]} s or #{r[:pages]} pages" : "build failed"}" }
exit(bad.empty? ? 0 : 1)
