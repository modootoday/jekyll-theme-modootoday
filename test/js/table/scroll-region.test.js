// jsdom tests for assets/js/modootoday/content/scroll-region.js: scroll regions on overflowing code and table wrappers. Run: npm test
const test = require("node:test");
const assert = require("node:assert");
const { JSDOM } = require("jsdom");
const { run: load, load: importModule } = require("../support/module.js");

const HEAD = "<thead><tr><th>Key</th><th>Type</th><th>Default</th><th>Description</th></tr></thead>";
const BODY = "<tbody><tr><td><code>badges</code></td><td>boolean</td><td>true</td><td>Status badges</td></tr></tbody>";

// jsdom has no layout, so widths are set per element: data-w is scrollWidth, clientWidth is 100.
async function run(body) {
  const w = new JSDOM(`<!doctype html><html data-mt-table="표" data-mt-code="코드"><body><main class="mt-main">${body}</main></body></html>`,
    { runScripts: "outside-only" }).window;
  for (const el of w.document.querySelectorAll("[data-w]")) {
    Object.defineProperty(el, "scrollWidth", { value: +el.dataset.w });
    Object.defineProperty(el, "clientWidth", { value: 100 });
  }
  await load("content/scroll-region.js", w);
  return w.document;
}

test("an overflowing table wrapper becomes a labelled focusable region; a fitting one stays plain", async () => {
  const d = await run(`<div class="mt-table" id="wide" data-w="300"><table>${HEAD}${BODY}</table></div>` +
    `<div class="mt-table" id="fits" data-w="100"><table>${HEAD}${BODY}</table></div>`);
  const wide = d.getElementById("wide");
  assert.deepStrictEqual([wide.tabIndex, wide.getAttribute("role"), wide.getAttribute("aria-label")], [0, "region", "표 1"], "numbered among all tables, so the name holds at every width");
  assert.strictEqual(d.getElementById("fits").hasAttribute("role"), false);
  assert.strictEqual(d.querySelector("table").hasAttribute("tabindex"), false, "the table itself is not the region");
});

test("an overflowing code block is labelled with the code string", async () => {
  const d = await run('<pre data-w="300"><code>x</code></pre>');
  assert.strictEqual(d.querySelector("pre").getAttribute("aria-label"), "코드");
});

// Rouge markup: div.language-<lang> > div.highlight > pre; file: titles add div.mt-code > p.mt-code-title.
const code = (lang, id) => `<div class="language-${lang} highlighter-rouge"><div class="highlight"><pre id="${id}" data-w="300"><code>x</code></pre></div></div>`;

test("every overflowing region gets its own name: title, caption or language, else the heading, then an ordinal", async () => {
  const d = await run(`${code("yaml", "c1")}<h2>Install</h2>${code("yaml", "c2")}${code("yaml", "c3")}${code("plaintext", "c4")}` +
    `<div class="mt-code"><p class="mt-code-title"><span class="mt-sr-only">파일: </span>_config.yml</p>${code("yaml", "c5")}</div>` +
    `<h3>Keys</h3><div class="mt-table" id="t1" data-w="300"><table><caption>Settings</caption>${HEAD}${BODY}</table></div>` +
    `<div class="mt-table" id="t2" data-w="300"><table>${HEAD}${BODY}</table></div>` +
    `<figure class="mt-chart"><div class="mt-table" id="t3" data-w="300"><table>${HEAD}${BODY}</table></div><figcaption>Visits</figcaption></figure>`);
  const label = (id) => d.getElementById(id).getAttribute("aria-label");
  assert.deepStrictEqual(["c1", "c2", "c3", "c4", "c5", "t1", "t2", "t3"].map(label),
    ["코드, yaml 1", "코드, yaml 2", "코드, yaml 3", "코드, Install", "코드, _config.yml", "표, Settings", "표, Keys", "표, Visits"]);
  const all = [...d.querySelectorAll("[role=region]")].map((e) => e.getAttribute("aria-label"));
  assert.strictEqual(new Set(all).size, all.length, "names repeat");
});

test("the name patterns come from the page language", async () => {
  const w = new JSDOM(`<!doctype html><html data-mt-code="コード" data-mt-region-named="[label]（[name]）" data-mt-region-nth="[name] [n]"><body><main class="mt-main">` +
    `<h2>例</h2>${code("ruby", "a")}${code("ruby", "b")}<pre id="c"><code>x</code></pre></main></body></html>`).window;
  const { names } = await importModule("content/scroll-region.js");
  const n = names(w.document, w.document.documentElement.dataset);
  assert.deepStrictEqual(["a", "b", "c"].map((id) => n.get(w.document.getElementById(id))), ["コード（ruby） 1", "コード（ruby） 2", "コード（例）"]);
});
