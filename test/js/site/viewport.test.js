// Tests for test/system/site/viewport.mjs: a read after settle sees what scroll-region.js marks for the new width. Run: npm test
const test = require("node:test");
const assert = require("node:assert");
const fs = require("node:fs");
const path = require("node:path");
const { pathToFileURL } = require("node:url");
const { JSDOM } = require("jsdom");
const { run } = require("../support/module.js");

const SYSTEM = path.join(__dirname, "../../system");

// A browser delivers ResizeObserver entries in the rendering update after a resize, never during the resize itself.
function browser(body) {
  const w = new JSDOM(`<!doctype html><html data-mt-code="Code"><body><main class="mt-main">${body}</main></body></html>`,
    { runScripts: "outside-only", pretendToBeVisual: true }).window;
  const observed = [];
  w.ResizeObserver = class {
    constructor(cb) {
      this.cb = cb;
    }
    observe(el) {
      observed.push([this, el]);
      w.requestAnimationFrame(() => this.cb([{ target: el }]));
    }
  };
  let width = 1440;
  Object.defineProperty(w, "innerWidth", { get: () => width });
  const page = {
    setViewportSize: async (size) => {
      width = size.width;
      observed.forEach(([ro, el]) => w.requestAnimationFrame(() => ro.cb([{ target: el }])));
    },
    waitForFunction: async (fn, arg) => assert.ok(w.eval(`(${fn})(${JSON.stringify(arg)})`)),
    evaluate: (fn) => w.eval(`(${fn})()`),
  };
  return { w, page };
}

test("a region that overflows again after it fit is a labelled tab stop once the audit settles", async () => {
  const { settle } = await import(pathToFileURL(path.join(SYSTEM, "site/viewport.mjs")).href);
  const { w, page } = browser('<h2>Stubs</h2><pre class="highlight" tabindex="0" id="p"><code>x</code></pre>');
  const pre = w.document.getElementById("p");
  let scroll = 120;
  Object.defineProperty(pre, "scrollWidth", { get: () => scroll });
  Object.defineProperty(pre, "clientWidth", { value: 100 });
  await run("content/scroll-region.js", w);
  await settle(page, 1440);
  assert.deepStrictEqual([pre.tabIndex, pre.getAttribute("aria-label")], [0, "Code, Stubs"]);
  scroll = 100;
  await page.setViewportSize({ width: 1440, height: 900 });
  await settle(page, 1440);
  assert.strictEqual(pre.hasAttribute("tabindex"), false, "a fitting block is no tab stop");
  scroll = 120;
  await page.setViewportSize({ width: 1024, height: 900 });
  assert.strictEqual(pre.hasAttribute("tabindex"), false, "until the next rendering update the overflow is unmarked");
  await settle(page, 1024);
  assert.deepStrictEqual([pre.tabIndex, pre.getAttribute("role"), pre.getAttribute("aria-label")], [0, "region", "Code, Stubs"]);
});

test("the docs audit settles the restored width before axe reads the page", () => {
  const src = fs.readFileSync(path.join(SYSTEM, "audit/pages.mjs"), "utf8");
  const axe = src.indexOf("new AxeBuilder");
  assert.ok(axe > 0);
  assert.ok(src.lastIndexOf("await settle(page, 1024)", axe) > src.lastIndexOf("setViewportSize", axe), "axe runs before the last resize settles");
});
