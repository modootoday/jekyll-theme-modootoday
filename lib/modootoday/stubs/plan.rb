# frozen_string_literal: true

module Modootoday
  module Stubs
    # One planned file: path relative to SRC, wanted content (nil = delete) and why.
    Change = Struct.new(:path, :content, :reason) do
      def action = content.nil? ? "delete" : (reason == "missing" ? "create" : "update")
    end

    # What the chosen kinds want on disk, minus what is already there byte for byte.
    class Plan
      attr_reader :kinds

      def initialize(source, kinds, prune: true)
        @s, @kinds, @prune = source, kinds, prune
      end

      def changes
        @changes ||= begin
          gens = kinds.map { |k| GENERATORS.fetch(k).new(@s) }
          wanted = gens.map(&:wanted)
          clash = wanted.flat_map(&:keys).tally.select { |_, n| n > 1 }.keys
          raise DataError, "#{clash.first}: wanted by two stub kinds (rename the page)" unless clash.empty?
          writes = wanted.reduce({}, :merge).filter_map { |path, body| change(path, body) }
          gone = @prune ? gens.flat_map(&:orphans).uniq.map { |path| Change.new(path, nil, "orphan") } : []
          (writes + gone).sort_by(&:path)
        end
      end

      def empty? = changes.empty?

      private

      def change(path, body)
        file = @s.path(path)
        return Change.new(path, body, "missing") unless File.exist?(file)
        Change.new(path, body, "stale") unless File.binread(file) == body
      end
    end
  end
end
