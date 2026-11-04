// Rows of the asset registry, _includes/modootoday/assets/registry.html, the owner of every theme CSS and JS file and
// its cap: name|kind|path|triggers|parts|cap|deps, the linked rows (_mta_rows) then the fixed ones (_mta_fixed).
// test/support/asset_registry.rb reads the same format.
import fs from "node:fs";
import { fileURLToPath } from "node:url";

export const REGISTRY = fileURLToPath(new URL("../../../_includes/modootoday/assets/registry.html", import.meta.url));

const CAPTURES = ["_mta_rows", "_mta_fixed"];

const row = (line, fixed) => {
  const [name, kind, path, triggers = "", parts = "", cap = "", deps = ""] = line.split("|");
  return {
    name,
    kind,
    path,
    // assets/-relative, as pageAssets() names a loaded file
    file: path.replace(/^\/assets\//, ""),
    triggers: triggers.split("^").filter(Boolean),
    parts: parts.split(/\s+/).filter(Boolean),
    cap: cap === "" ? null : Number(cap),
    deps: deps.split(/\s+/).filter(Boolean),
    fixed,
  };
};

export function parseRegistry(text) {
  return CAPTURES.flatMap((c) => {
    const m = text.match(new RegExp(`capture ${c} -%}\\n([\\s\\S]*?)\\{%- endcapture`));
    if (!m) {
      return [];
    }
    return m[1].split("\n").filter(Boolean).map((l) => row(l, c === "_mta_fixed"));
  });
}

export const readRegistry = (file = REGISTRY) => parseRegistry(fs.readFileSync(file, "utf8"));
