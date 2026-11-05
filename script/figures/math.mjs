// Renders the static math that modootoday-check SRC --math lists into its _data/math files with KaTeX, no browser.
// Usage: node script/figures/math.mjs SRC [LIST.json] [--output=mathml|htmlAndMathml|html]   (stdin without LIST.json)
// mathml (the default) needs no stylesheet, font or style attribute; the other outputs need KaTeX's CSS (see the recipe).
import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { pathToFileURL } from "node:url";
import { digest } from "./digest.mjs";

export const OUTPUTS = ["mathml", "htmlAndMathml", "html"];

const MATH = /<math\b[\s\S]*<\/math>/;

// KaTeX wraps MathML in span.katex; the page needs only the <math> element. Other outputs keep KaTeX's markup.
export function entryHtml(rendered, output) {
  if (output !== "mathml") {
    return rendered;
  }
  const math = rendered.match(MATH);
  if (!math) {
    throw new Error("KaTeX returned no <math> element");
  }
  return math[0];
}

// A JSON string is a valid YAML double-quoted scalar, so the file needs no YAML library.
export function toYaml(entries) {
  if (entries.length === 0) {
    return "[]\n";
  }
  const items = entries.map((e) => `- src: ${JSON.stringify(e.src)}\n  html: ${JSON.stringify(e.html)}`);
  return `${items.join("\n")}\n`;
}

export function renderRecord(katex, record, output = "mathml") {
  if (!OUTPUTS.includes(output)) {
    throw new Error(`unknown output ${output} (${OUTPUTS.join(", ")})`);
  }
  return record.blocks.map((block) => {
    if (digest(block.tex) !== block.digest) {
      throw new Error(`${record.page}:${block.line}: the block digest differs from the list; run modootoday-check --math again`);
    }
    const options = { displayMode: true, output, throwOnError: true };
    try {
      return { src: block.digest, html: entryHtml(katex.renderToString(block.tex, options), output) };
    } catch (e) {
      throw new Error(`${record.page}:${block.line}: ${e.message}`);
    }
  });
}

export function writeRecord(src, record, entries) {
  const path = join(src, record.file);
  mkdirSync(dirname(path), { recursive: true });
  const text = path.endsWith(".json") ? `${JSON.stringify(entries, null, 2)}\n` : toYaml(entries);
  writeFileSync(path, text);
}

async function main(argv) {
  const output = argv.find((a) => a.startsWith("--output="))?.slice("--output=".length) ?? "mathml";
  const [src, list] = argv.filter((a) => !a.startsWith("--"));
  if (!src) {
    console.error("usage: node script/figures/math.mjs SRC [LIST.json] [--output=mathml|htmlAndMathml|html]");
    return 2;
  }
  const records = JSON.parse(readFileSync(list ?? 0, "utf8"));
  if (records.length === 0) {
    console.log("math: nothing to render");
    return 0;
  }
  const { default: katex } = await import("katex");
  for (const record of records) {
    writeRecord(src, record, renderRecord(katex, record, output));
    console.log(`${record.file} (${record.page}, ${record.blocks.length} blocks, KaTeX ${katex.version})`);
  }
  console.log(`math: rendered ${records.length} files; commit them`);
  return 0;
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  process.exitCode = await main(process.argv.slice(2));
}
