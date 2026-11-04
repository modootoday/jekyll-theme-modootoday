# frozen_string_literal: true
# Rows of _includes/modootoday/assets/registry.html as tests read them: the rows Liquid links (_mta_rows) and the files
# the layouts link themselves (_mta_fixed), in file order. test/system/audit/budgets/registry.mjs reads the same format.
module AssetRegistry
  ROOT = File.expand_path("../..", __dir__)
  FILE = File.join(ROOT, "_includes/modootoday/assets/registry.html")
  Row = Struct.new(:name, :kind, :path, :triggers, :parts, :cap, :deps, :fixed) do
    # The source of the built file: a .scss beside the .css path, or the .js itself.
    def source = File.join(ROOT, path.delete_prefix("/").sub(/\.css\z/, ".scss"))
  end

  module_function

  def rows(capture = nil)
    text = File.read(FILE)
    %w[_mta_rows _mta_fixed].select { |c| capture.nil? || capture == c }.flat_map do |c|
      text[/capture #{c} -%}\n(.*?)\{%- endcapture/m, 1].to_s.lines.map { |l| row(l.chomp, c == "_mta_fixed") }
    end
  end

  def row(line, fixed)
    name, kind, path, triggers, parts, cap, deps = line.split("|", -1)
    Row.new(name, kind, path, triggers.to_s.split("^"), parts.to_s.split, cap.to_s.empty? ? nil : Integer(cap, 10), deps.to_s.split, fixed)
  end
end
