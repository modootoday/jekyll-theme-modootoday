// jsdom tests for assets/js/modootoday/data/chart.js with a fake Chart: what it draws, how it folds the table, and when
// it leaves the table alone. Computed styles are stubbed (jsdom does not resolve custom properties). Run: npm test
const test = require("node:test");
const assert = require("node:assert");
const { JSDOM } = require("jsdom");
const { run } = require("../support/module.js");

const TABLE = '<div class="mt-table"><table><thead><tr><th>Month</th><th>Docs</th><th>Blog</th></tr></thead>' +
  "<tbody><tr><th scope=row>Jan</th><td>1,200</td><td>640</td></tr><tr><th scope=row>Feb</th><td>1,350</td><td>700</td></tr></tbody></table></div>";
const figure = (type, opts = "", caption = "<figcaption>Visits</figcaption>") =>
  `<figure class="mt-chart" data-type="${type}"${opts ? ` data-opts="${opts}"` : ""}><div class="mt-chart-canvas" hidden></div>` +
  `<div class="mt-chart-data" data-label="Chart data">${TABLE}</div>${caption}</figure>`;

let hooks = {};
globalThis.getComputedStyle = () => ({ direction: "ltr", getPropertyValue: (n) => hooks[n] || "" });
const scheme = (prefix) => {
  hooks = { "--mt-chart-sg": `${prefix}-grid`, "--mt-chart-st": `${prefix}-text` };
  for (let i = 1; i <= 8; i++) {
    hooks[`--mt-chart-s${i}`] = i == 1 ? "#2563eb" : `${prefix}-${i}`;
  }
};

async function page(body, { chart = true, queries = [], observer } = {}) {
  scheme("light");
  const w = new JSDOM(`<!doctype html><html lang="en"><body>${body}</body></html>`).window;
  w.IntersectionObserver = observer;
  const made = [];
  if (chart) {
    w.Chart = function Chart(canvas, config) {
      Object.assign(this, { canvas, config, destroyed: false });
      made.push(this);
    };
    w.Chart.prototype.destroy = function destroy() {
      this.destroyed = true;
    };
  }
  w.matchMedia = (q) => ({ matches: queries.includes(q) });
  await run("data/chart.js", w);
  return { doc: w.document, made };
}

test("draws a bar chart from the table, named by the caption, with the table folded into details", async () => {
  const { doc, made } = await page(figure("bar", "stacked horizontal"));
  assert.strictEqual(made.length, 1);
  const { type, data, options } = made[0].config;
  assert.strictEqual(type, "bar");
  assert.deepStrictEqual(data.labels, ["Jan", "Feb"]);
  assert.deepStrictEqual(data.datasets.map((d) => [d.label, d.data, d.backgroundColor]), [["Docs", [1200, 1350], "#2563eb"], ["Blog", [640, 700], "light-2"]]);
  assert.deepStrictEqual([options.indexAxis, options.scales.x.stacked, options.scales.y.grid.color, options.scales.x.ticks.color], ["y", true, "light-grid", "light-text"]);
  assert.strictEqual(options.animation, undefined);
  const canvas = doc.querySelector(".mt-chart-canvas canvas");
  assert.strictEqual(made[0].canvas, canvas);
  assert.deepStrictEqual([canvas.getAttribute("role"), canvas.getAttribute("aria-label"), canvas.parentElement.hidden], ["img", "Visits", false]);
  const details = doc.querySelector(".mt-chart-data > details");
  assert.deepStrictEqual([details.open, details.querySelector("summary").textContent, !!details.querySelector(".mt-table > table")], [false, "Chart data", true]);
  assert.strictEqual(details.querySelector("summary").getAttribute("aria-label"), "Chart data, Visits");
  assert.strictEqual(options.plugins.legend.labels.usePointStyle, undefined, "bar legends keep their filled box");
});

test("each Chart data disclosure is named after its chart, numbered when two charts share a name", async () => {
  const { doc } = await page(figure("bar") + figure("line", "", "<figcaption>Sales</figcaption>") + figure("pie"));
  assert.deepStrictEqual([...doc.querySelectorAll("summary")].map((s) => s.getAttribute("aria-label")),
    ["Chart data, Visits 1", "Chart data, Sales", "Chart data, Visits 2"]);
});

test("a line chart's legend draws each key as a stroke in the series dash", async () => {
  const { made } = await page(figure("line") + figure("area"));
  for (const chart of made) {
    const { usePointStyle, pointStyle, generateLabels } = chart.config.options.plugins.legend.labels;
    assert.deepStrictEqual([usePointStyle, pointStyle], [true, "line"]);
    class Fake {
      static defaults = { plugins: { legend: { labels: { generateLabels: () => [{ datasetIndex: 0, lineWidth: 1 }, { datasetIndex: 1, lineWidth: 1 }] } } } };
    }
    assert.deepStrictEqual(generateLabels(new Fake()).map((k) => [k.lineDash, k.lineWidth]), [[[], 2], [[6, 3], 2]], "the point style drops the series dash");
  }
});

test("line, area and pie charts; without a caption the series name the canvas", async () => {
  const { doc, made } = await page(figure("line", "", "") + figure("area") + figure("pie"));
  assert.deepStrictEqual(made.map((c) => c.config.type), ["line", "line", "pie"]);
  assert.deepStrictEqual(made[0].config.data.datasets.map((d) => d.borderDash), [[], [6, 3]]);
  assert.deepStrictEqual(made[1].config.data.datasets.map((d) => [d.fill, d.backgroundColor]), [[true, "#2563eb33"], [true, "light-2"]]);
  assert.deepStrictEqual(made[2].config.data.datasets[0].backgroundColor, ["#2563eb", "light-2"]);
  assert.deepStrictEqual(made[2].config.options.scales, {});
  assert.strictEqual(doc.querySelector("canvas").getAttribute("aria-label"), "Docs, Blog");
});

test("reduced motion turns the animation off", async () => {
  const { made } = await page(figure("bar"), { queries: ["(prefers-reduced-motion: reduce)"] });
  assert.strictEqual(made[0].config.options.animation, false);
});

test("without Chart.js, or under forced colours, the table stays the chart", async () => {
  for (const opts of [{ chart: false }, { queries: ["(forced-colors: active)"] }]) {
    const { doc, made } = await page(figure("bar"), opts);
    assert.strictEqual(made.length, 0);
    assert.strictEqual(doc.querySelector(".mt-chart-canvas").hidden, true);
    assert.strictEqual(doc.querySelector("details"), null);
    assert.ok(doc.querySelector(".mt-chart-data > .mt-table > table"));
  }
});

test("a scheme change redraws with the new colours and no animation", async () => {
  const { made } = await page(figure("bar"));
  scheme("dark");
  globalThis.document.documentElement.dataset.theme = "dark";
  globalThis.document.dispatchEvent(new globalThis.document.defaultView.Event("mt:themechange"));
  delete globalThis.document.documentElement.dataset.theme;
  assert.strictEqual(made.length, 2);
  assert.strictEqual(made[0].destroyed, true);
  assert.deepStrictEqual([made[1].config.data.datasets[1].backgroundColor, made[1].config.options.animation], ["dark-2", false]);
});

test("with an IntersectionObserver a chart is drawn only once its box nears the viewport", async () => {
  let seen;
  class Observer {
    constructor(cb, opts) {
      seen = { cb, opts, boxes: [], dropped: [] };
    }
    observe(el) {
      seen.boxes.push(el);
    }
    unobserve(el) {
      seen.dropped.push(el);
    }
  }
  const { doc, made } = await page(figure("bar") + figure("line"), { observer: Observer });
  assert.strictEqual(made.length, 0);
  assert.strictEqual(seen.opts.rootMargin, "200px");
  assert.ok(doc.querySelector("details"), "the table folds before the chart is drawn");
  seen.cb([{ target: seen.boxes[1], isIntersecting: true }, { target: seen.boxes[0], isIntersecting: false }]);
  assert.deepStrictEqual(made.map((c) => c.config.type), ["line"]);
  assert.deepStrictEqual(seen.dropped, [seen.boxes[1]]);
});
