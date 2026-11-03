# frozen_string_literal: true

require "digest"

module Modootoday
  module Check
    # --byte-exact=DIR[,DIR]: files under these source folders are published byte for byte (an API, downloads). Each file
    # in SITE must have the source's sha256. A folder Jekyll reads as data or skips, or a file it would convert, is an error.
    module ByteExact
      OPTION = "--byte-exact="
      CONVERTED = /\.(md|markdown|mkdown|mkdn|mkd|textile|scss|sass|coffee)\z/
      SKIPPED = /\A[._#~]|~\z/

      module_function

      def call(ctx)
        arg = ctx.argv.find { |a| a.start_with?(OPTION) }
        return unless arg
        dirs = arg.delete_prefix(OPTION).split(",").map { |d| d.delete_prefix("/").chomp("/") }
        return ctx.errs << "#{OPTION}: name at least one folder of SRC" if dirs.empty? || dirs.any?(&:empty?)
        dirs.each { |d| dir(ctx, d) }
      end

      def dir(ctx, d)
        return ctx.errs << "#{OPTION}#{d}: not a folder in #{ctx.src}" unless File.directory?("#{ctx.src}/#{d}")
        return ctx.errs << "#{OPTION}#{d}: Jekyll does not publish folders whose name starts with _ or . (unless include: lists them)" if skipped?(ctx, d)
        return ctx.errs << "#{OPTION}#{d}: excluded in _config.yml (exclude: #{excluded_by(ctx, d)})" if excluded_by(ctx, d)
        files = Dir.glob("**/*", File::FNM_DOTMATCH, base: "#{ctx.src}/#{d}").reject { |r| r.end_with?(".") || File.directory?("#{ctx.src}/#{d}/#{r}") }
        return ctx.warns << "#{OPTION}#{d}: no files" if files.empty?
        files.sort.each { |r| file(ctx, "#{d}/#{r}") }
      end

      def file(ctx, rel)
        src = "#{ctx.src}/#{rel}"
        return ctx.errs << "#{rel}: not published (Jekyll skips names starting with . _ # ~ unless include: lists them)" if skipped?(ctx, rel)
        return ctx.errs << "#{rel}: has front matter, so Jekyll renders it instead of copying it" if File.binread(src, 8).to_s.match?(/\A---[ \t]*\r?\n/)
        return ctx.errs << "#{rel}: Jekyll converts this file type (GitHub Pages renders Markdown without front matter too)" if rel.match?(CONVERTED)
        out = "#{ctx.site}/#{rel}"
        return ctx.errs << "#{rel}: missing from the build (#{out})" unless File.file?(out)
        ctx.errs << "#{rel}: the built file differs from the source (sha256 #{sha(out)[0, 12]} != #{sha(src)[0, 12]})" unless sha(out) == sha(src)
      end

      def excluded_by(ctx, d)
        Array(ctx.site_cfg["exclude"]).map { |e| e.to_s.chomp("/") }.find { |e| d == e || d.start_with?("#{e}/") || File.fnmatch?(e, d, File::FNM_PATHNAME) }
      end

      def skipped?(ctx, rel)
        inc = Array(ctx.site_cfg["include"]).map(&:to_s)
        rel.split("/").any? { |s| s.match?(SKIPPED) && !inc.include?(s) }
      end

      def sha(path) = Digest::SHA256.file(path).hexdigest
    end
  end
end
