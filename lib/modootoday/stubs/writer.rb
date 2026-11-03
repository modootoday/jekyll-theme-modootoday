# frozen_string_literal: true

module Modootoday
  module Stubs
    # Applies a plan. Only changed files are touched, so a second run writes nothing.
    module Writer
      module_function

      def apply(source, changes)
        changes.each do |c|
          file = source.path(c.path)
          next File.delete(file) if c.content.nil?
          FileUtils.mkdir_p(File.dirname(file))
          File.binwrite(file, c.content)
        end
      end
    end
  end
end
