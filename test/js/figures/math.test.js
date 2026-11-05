// script/figures/math.mjs with the pinned KaTeX: MathML entries, the YAML the theme reads, the digest guard and
// writing a list record. Run: npm test
const test = require("node:test");
const assert = require("node:assert");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");

const SCRIPT = path.join(__dirname, "../../../script/figures/math.mjs");
const DIGEST = path.join(__dirname, "../../../script/figures/digest.mjs");

async function record(tex) {
  const { digest } = await import(DIGEST);
  return { key: "guide--a", file: "_data/math/guide--a.yml", page: "guide/a.md", blocks: [{ line: 5, tex, digest: digest(tex) }], reason: "missing" };
}

test("a block becomes one <math> element with its TeX as the annotation and no style", async () => {
  const { renderRecord } = await import(SCRIPT);
  const { default: katex } = await import("katex");
  const rec = await record("e^{i\\pi} + 1 = 0");
  const [entry] = renderRecord(katex, rec);
  assert.strictEqual(entry.src, rec.blocks[0].digest);
  assert.match(entry.html, /^<math xmlns="http:\/\/www\.w3\.org\/1998\/Math\/MathML" display="block">/);
  assert.match(entry.html, /<annotation encoding="application\/x-tex">e\^\{i\\pi\} \+ 1 = 0<\/annotation><\/semantics><\/math>$/);
  assert.doesNotMatch(entry.html, /style=|class=/);
});

test("KaTeX HTML output keeps KaTeX's markup and an unknown output is refused", async () => {
  const { renderRecord } = await import(SCRIPT);
  const { default: katex } = await import("katex");
  const rec = await record("x");
  assert.match(renderRecord(katex, rec, "htmlAndMathml")[0].html, /class="katex-html"/);
  assert.throws(() => renderRecord(katex, rec, "svg"), /unknown output svg/);
});

test("a list from another digest rule or bad TeX is refused with the page line", async () => {
  const { renderRecord } = await import(SCRIPT);
  const { default: katex } = await import("katex");
  const rec = await record("x");
  rec.blocks[0].digest = "sha256-0000";
  assert.throws(() => renderRecord(katex, rec), /guide\/a\.md:5: the block digest differs/);
  const bad = await record("\\frac{1}{");
  assert.throws(() => renderRecord(katex, bad), /guide\/a\.md:5: KaTeX parse error/);
});

test("the YAML file holds JSON-quoted scalars the theme and the checker read back", async () => {
  const { toYaml, writeRecord } = await import(SCRIPT);
  assert.strictEqual(toYaml([]), "[]\n");
  const html = '<math display="block"><mi>α</mi><mo>\'</mo><mtext>a\\b "c"</mtext></math>';
  assert.strictEqual(toYaml([{ src: "sha256-1", html }]), `- src: "sha256-1"\n  html: ${JSON.stringify(html)}\n`);
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "mt-math-"));
  try {
    writeRecord(dir, { file: "_data/math/a.yml" }, [{ src: "sha256-1", html }]);
    writeRecord(dir, { file: "_data/math/b.json" }, [{ src: "sha256-1", html }]);
    assert.ok(fs.readFileSync(path.join(dir, "_data/math/a.yml"), "utf8").startsWith('- src: "sha256-1"'));
    assert.deepStrictEqual(JSON.parse(fs.readFileSync(path.join(dir, "_data/math/b.json"), "utf8")), [{ src: "sha256-1", html }]);
  } finally {
    fs.rmSync(dir, { recursive: true, force: true });
  }
});
