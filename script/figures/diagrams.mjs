// Renders the static diagrams that modootoday-check SRC --diagrams lists into their light and dark SVG files.
// Usage: node script/figures/diagrams.mjs SRC [LIST.json] [--cdp=URL]   (the list comes from stdin without LIST.json)
// Without --cdp it launches Playwright's Chromium; with it, it drives a browser elsewhere (CDP_AUTHORIZATION: header).
import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { pathToFileURL } from "node:url";
import { digest } from "./digest.mjs";

// Mermaid runs in the browser from this exact file; the hash is the npm tarball's dist/mermaid.min.js.
export const MERMAID = {
  src: "https://cdn.jsdelivr.net/npm/mermaid@11.17.2/dist/mermaid.min.js",
  integrity: "sha384-EOXBFmc3gx5mb+vn0vPvvGqACToJD24hhacX5Yx+8NUUQrHIle/Qi5Bg9o3zKwW2",
};

// Mermaid themes per files key of the list: the light file uses default, the .dark.svg file dark.
export const THEMES = ["default", "dark"];

const ROOT_TAG = /<svg\b[^>]*>/;
const VIEWBOX = /\sviewBox="\s*[-\d.]+[\s,]+[-\d.]+[\s,]+([\d.]+)[\s,]+([\d.]+)\s*"/;

// The root element gets the viewBox size as width and height (no layout shift) and the fence digest.
export function finish(svg, src) {
  const root = svg.match(ROOT_TAG);
  if (!root) {
    throw new Error("Mermaid returned no <svg> element");
  }
  const box = root[0].match(VIEWBOX);
  if (!box) {
    throw new Error("the rendered <svg> has no viewBox");
  }
  const width = Math.ceil(Number(box[1]));
  const height = Math.ceil(Number(box[2]));
  const attrs = root[0]
    .slice(4, -1)
    .replace(/\s(?:width|height|style|data-mt-src)="[^"]*"/g, "");
  const tag = `<svg${attrs} width="${width}" height="${height}" data-mt-src="${src}">`;
  return `${svg.replace(ROOT_TAG, tag).trim()}\n`;
}

// The id is fixed per fence so the same fence gives the same file.
export function svgId(src) {
  const hex = src.slice("sha256-".length, "sha256-".length + 12);
  return `mt-${hex}`;
}

async function renderIn({ code, theme, id }) {
  const settings = { startOnLoad: false, theme, securityLevel: "strict", deterministicIds: true };
  settings.htmlLabels = false;
  settings.flowchart = { htmlLabels: false };
  window.mermaid.initialize(settings);
  const result = await window.mermaid.render(id, code);
  return result.svg;
}

export async function renderAll(browser, jobs, src, log = console.log) {
  const context = await browser.newContext();
  try {
    const page = await context.newPage();
    const script = `<script src="${MERMAID.src}" integrity="${MERMAID.integrity}" crossorigin="anonymous"></script>`;
    await page.setContent(`<!doctype html><meta charset="utf-8">${script}`, { waitUntil: "load" });
    const loaded = await page.evaluate(() => typeof window.mermaid === "object");
    if (!loaded) {
      throw new Error(`Mermaid did not load from ${MERMAID.src} (network or integrity)`);
    }
    for (const job of jobs) {
      await renderJob(page, job, src, log);
    }
  } finally {
    await context.close();
  }
}

async function renderJob(page, job, src, log) {
  if (digest(job.fence) !== job.digest) {
    throw new Error(`${job.page}: ${job.name}: the fence digest differs from the list; run modootoday-check --diagrams again`);
  }
  for (const [theme, file] of Object.entries(job.files)) {
    if (!THEMES.includes(theme)) {
      throw new Error(`${job.page}: ${job.name}: unknown Mermaid theme ${theme}`);
    }
    const svg = await page.evaluate(renderIn, { code: job.fence, theme, id: svgId(job.digest) });
    const path = join(src, file);
    mkdirSync(dirname(path), { recursive: true });
    writeFileSync(path, finish(svg, job.digest));
    log(`${file} (${job.page}, ${theme})`);
  }
}

async function browserFor(cdp) {
  const { chromium } = await import("playwright");
  if (!cdp) {
    return chromium.launch();
  }
  const auth = process.env.CDP_AUTHORIZATION;
  const headers = auth ? { Authorization: auth } : {};
  return chromium.connectOverCDP(cdp, { headers });
}

async function main(argv) {
  const cdp = argv.find((a) => a.startsWith("--cdp="))?.slice("--cdp=".length);
  const [src, list] = argv.filter((a) => !a.startsWith("--"));
  if (!src) {
    console.error("usage: node script/figures/diagrams.mjs SRC [LIST.json] [--cdp=URL]");
    return 2;
  }
  const jobs = JSON.parse(readFileSync(list ?? 0, "utf8"));
  if (jobs.length === 0) {
    console.log("diagrams: nothing to render");
    return 0;
  }
  const browser = await browserFor(cdp);
  try {
    await renderAll(browser, jobs, src);
  } finally {
    await browser.close();
  }
  console.log(`diagrams: rendered ${jobs.length}; commit the SVG files`);
  return 0;
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  process.exitCode = await main(process.argv.slice(2));
}
