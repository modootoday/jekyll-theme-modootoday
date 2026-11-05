// jsdom tests for assets/js/modootoday/data/chart-table.js: a chart's table as {labels, series}. Run: npm test
const test = require("node:test");
const assert = require("node:assert");
const { JSDOM } = require("jsdom");
const { load } = require("../support/module.js");

const table = (html) => new JSDOM(`<!doctype html><table>${html}</table>`).window.document.querySelector("table");

test("labels come from the first column and series from the header row", async () => {
  const { tableData } = await load("data/chart-table.js");
  const t = table("<thead><tr><th>Month</th><th>Visits</th><th>Share</th></tr></thead>" +
    "<tbody><tr><th scope=row>Jan</th><td>1,200</td><td>30%</td></tr><tr><td>Feb</td><td> 1500 </td><td>42.5 %</td></tr></tbody>");
  assert.deepStrictEqual(tableData(t), {
    labels: ["Jan", "Feb"],
    series: [{ name: "Visits", values: [1200, 1500] }, { name: "Share", values: [30, 42.5] }],
  });
});

test("a cell that is not a number, or is missing, is a gap", async () => {
  const { tableData } = await load("data/chart-table.js");
  const t = table("<thead><tr><td></td><th>A</th><th>B</th></tr></thead><tbody><tr><td>x</td><td>n/a</td></tr><tr><td>y</td><td></td><td>-3</td></tr></tbody>");
  assert.deepStrictEqual(tableData(t).series.map((s) => s.values), [[null, null], [null, -3]]);
});

test("an empty table has no labels and no series", async () => {
  const { tableData } = await load("data/chart-table.js");
  assert.deepStrictEqual(tableData(table("")), { labels: [], series: [] });
});
