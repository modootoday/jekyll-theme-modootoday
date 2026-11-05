// script/figures/diagrams.mjs without a browser: the root attributes of a rendered SVG, the fixed id, the pinned
// Mermaid file and the guard against a list from another digest rule. Run: npm test
const test = require("node:test");
const assert = require("node:assert");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");

const SCRIPT = path.join(__dirname, "../../../script/figures/diagrams.mjs");
const SRC = "sha256-79eaf605a9a879820b538b7f10f67e7232e315b3cabe2d8188e56c3aa675b433";
const RENDERED = '<svg id="mt-79eaf605a9a8" width="100%" xmlns="http://www.w3.org/2000/svg" style="max-width: 817.5px;" viewBox="0 0 817.515625 62.5" role="graphics-document document"><style>#mt-79eaf605a9a8{fill:#333;}</style><g/></svg>';

test("finish sizes the root from the viewBox and records the digest", async () => {
  const { finish } = await import(SCRIPT);
  const out = finish(RENDERED, SRC);
  const root = out.match(/<svg\b[^>]*>/)[0];
  assert.strictEqual(root, `<svg id="mt-79eaf605a9a8" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 817.515625 62.5" role="graphics-document document" width="818" height="63" data-mt-src="${SRC}">`);
  assert.ok(out.endsWith("<g/></svg>\n"));
  assert.ok(out.includes("<style>#mt-79eaf605a9a8{fill:#333;}</style>"));
  assert.strictEqual(finish(out, SRC), out);
});

test("finish refuses output without an svg root or a viewBox", async () => {
  const { finish } = await import(SCRIPT);
  assert.throws(() => finish("<div></div>", SRC), /no <svg> element/);
  assert.throws(() => finish('<svg width="10"></svg>', SRC), /no viewBox/);
});

test("the id comes from the digest and Mermaid is pinned with its hash", async () => {
  const { svgId, MERMAID, THEMES } = await import(SCRIPT);
  assert.strictEqual(svgId(SRC), "mt-79eaf605a9a8");
  assert.match(MERMAID.src, /^https:\/\/cdn\.jsdelivr\.net\/npm\/mermaid@\d+\.\d+\.\d+\/dist\/mermaid\.min\.js$/);
  assert.match(MERMAID.integrity, /^sha384-[A-Za-z0-9+/]{64}$/);
  assert.deepStrictEqual(THEMES, ["default", "dark"]);
});

test("a list whose digest does not match its fence is refused before writing", async () => {
  const { renderAll } = await import(SCRIPT);
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "mt-diagrams-"));
  const page = {
    setContent: async () => {},
    evaluate: async () => true,
  };
  const browser = { newContext: async () => ({ newPage: async () => page, close: async () => {} }) };
  const job = { page: "a.md", name: "flow", fence: "flowchart LR", digest: SRC, files: { default: "flow.svg" } };
  await assert.rejects(renderAll(browser, [job], dir, () => {}), /a\.md: flow: the fence digest differs/);
  assert.deepStrictEqual(fs.readdirSync(dir), []);
  fs.rmSync(dir, { recursive: true });
});

test("rendered files land at the listed paths", async () => {
  const { renderAll } = await import(SCRIPT);
  const { digest } = await import(path.join(__dirname, "../../../script/figures/digest.mjs"));
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "mt-diagrams-"));
  const fence = "flowchart LR\n  a --> b";
  const themes = [];
  const page = {
    setContent: async () => {},
    evaluate: async (fn, arg) => {
      if (!arg) {
        return true;
      }
      themes.push(arg.theme);
      return RENDERED.replace("mt-79eaf605a9a8", arg.id);
    },
  };
  const browser = { newContext: async () => ({ newPage: async () => page, close: async () => {} }) };
  const job = { page: "a.md", name: "x/flow", fence, digest: digest(fence), files: { default: "d/x/flow.svg", dark: "d/x/flow.dark.svg" } };
  await renderAll(browser, [job], dir, () => {});
  assert.deepStrictEqual(themes, ["default", "dark"]);
  const light = fs.readFileSync(path.join(dir, "d/x/flow.svg"), "utf8");
  assert.ok(light.includes(`data-mt-src="${job.digest}"`));
  assert.ok(light.startsWith(`<svg id="mt-${job.digest.slice(7, 19)}"`));
  assert.ok(fs.existsSync(path.join(dir, "d/x/flow.dark.svg")));
  fs.rmSync(dir, { recursive: true });
});
