// Docs demo for script: and poster: on a hero: three dots circle a centre in an SVG drawn over the poster, no library.
// Under reduced motion it draws nothing, so the poster stays. data-turn on the stage: seconds per turn.
import { readConfig } from "../modootoday/dom/config.js";
import { currentTheme, onThemeChange } from "../modootoday/theme/current.js";

const NS = "http://www.w3.org/2000/svg";

const draw = (parent, name, attrs) => {
  const el = document.createElementNS(NS, name);
  for (const [key, value] of Object.entries(attrs)) {
    el.setAttribute(key, value);
  }
  parent.append(el);
  return el;
};

if (!matchMedia("(prefers-reduced-motion: reduce)").matches) {
  for (const stage of document.querySelectorAll('[data-mt-script="orbit"] .mt-visual-stage')) {
    const { turn } = readConfig(stage, { turn: 12 });
    const svg = draw(stage, "svg", { viewBox: "0 0 200 200", "aria-hidden": "true", focusable: "false" });
    const fill = draw(draw(svg, "defs", {}), "linearGradient", { id: "orbit-sky", x1: 0, y1: 0, x2: 1, y2: 1 });
    draw(fill, "stop", { offset: 0, "stop-color": "#312e81" });
    draw(fill, "stop", { offset: 1, "stop-color": "#0f766e" });
    draw(svg, "rect", { width: 200, height: 200, fill: "url(#orbit-sky)" });
    draw(svg, "circle", { class: "orbit-ring", cx: 100, cy: 100, r: 70 });
    draw(svg, "circle", { class: "orbit-core", cx: 100, cy: 100, r: 14 });
    const ring = draw(svg, "g", { class: "orbit-dots" });
    for (const deg of [0, 120, 240]) {
      const rad = (deg * Math.PI) / 180;
      draw(ring, "circle", { cx: 100 + 70 * Math.cos(rad), cy: 100 + 70 * Math.sin(rad), r: 9 });
    }
    ring.animate([{ transform: "rotate(0turn)" }, { transform: "rotate(1turn)" }], { duration: turn * 1000, iterations: Infinity });
    svg.dataset.scheme = currentTheme();
    onThemeChange((theme) => {
      svg.dataset.scheme = theme;
    });
    stage.closest("[data-mt-script]").dataset.mtReady = "";
  }
}
