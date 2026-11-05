// Draws each figure.mt-chart table with the site's Chart.js (loaded first by render/chart.html) and folds the table
// into a details element. Without Chart.js, or under forced colours, the table stays the chart.
import { tableData } from "./chart-table.js";
import { onThemeChange } from "../theme/current.js";

const DASH = [[], [6, 3], [2, 2], [8, 3, 2, 3]];

// Colours are the hooks chart.css resolves on the figure for the current scheme; area fills a #rrggbb hook at 20%.
export function chartConfig(fig, data, still) {
  const cs = getComputedStyle(fig);
  const hook = (n) => cs.getPropertyValue(`--mt-chart-s${n}`).trim();
  const color = (i) => hook((i % 8) + 1);
  const type = fig.dataset.type;
  const opts = fig.dataset.opts || "";
  const round = /pie|doughnut/.test(type);
  const rtl = cs.direction == "rtl";
  const datasets = data.series.map((s, i) => ({
    label: s.name,
    data: s.values,
    borderColor: color(i),
    backgroundColor: round ? data.labels.map((_, j) => color(j)) : type == "area" ? color(i).replace(/^#\w{6}$/, "$&33") : color(i),
    borderWidth: round ? 0 : 2,
    fill: type == "area",
    borderDash: DASH[i % 4],
  }));
  const ticks = { color: hook("t") };
  const grid = { color: hook("g") };
  const axis = { stacked: opts.includes("stacked"), grid, border: grid, ticks };
  const options = { maintainAspectRatio: false, indexAxis: opts.includes("horizontal") ? "y" : "x", plugins: { legend: { rtl, labels: ticks }, tooltip: { rtl } } };
  options.scales = round ? {} : { x: axis, y: { ...axis } };
  if (still) {
    options.animation = false;
  }
  return { type: round || type == "bar" ? type : "line", data: { labels: data.labels, datasets }, options };
}

export function init(root) {
  const doc = root.ownerDocument || root;
  const win = doc.defaultView || {};
  const query = (q) => win.matchMedia && win.matchMedia(q).matches;
  if (typeof win.Chart != "function" || query("(forced-colors: active)")) {
    return;
  }
  const drawn = [];
  for (const fig of root.querySelectorAll("figure.mt-chart")) {
    const box = fig.querySelector(".mt-chart-canvas");
    const holder = fig.querySelector(".mt-chart-data");
    const table = holder && holder.querySelector("table");
    const data = table && tableData(table);
    if (!box || !data || !data.series.length) {
      continue;
    }
    const canvas = doc.createElement("canvas");
    const cap = fig.querySelector("figcaption");
    canvas.setAttribute("role", "img");
    canvas.setAttribute("aria-label", cap ? cap.textContent.trim() : data.series.map((s) => s.name).join(", "));
    box.append(canvas);
    box.hidden = false;
    const details = doc.createElement("details");
    details.append(doc.createElement("summary"), ...holder.childNodes);
    details.firstChild.textContent = holder.dataset.label;
    holder.append(details);
    const draw = (still) => new win.Chart(canvas, chartConfig(fig, data, still || query("(prefers-reduced-motion: reduce)")));
    drawn.push({ draw, chart: draw() });
  }
  onThemeChange(() => drawn.forEach((d) => {
    d.chart.destroy();
    d.chart = d.draw(true);
  }));
}

init(document);
