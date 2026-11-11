// The docs site with the PWA on, under the strict CSP: the manifest as Chromium reads it, installable apart from the error a
// private context always reports, the worker controlling the page with the site's scope, caches only under that scope, the
// install section's hint shown and its button hidden, and the precache total against its guide target (a warning).
import fs from "node:fs";
import path from "node:path";
import { cachesOf, constants, controlled } from "./session.mjs";

export const DOCS_PAGE = "layouts/demo/csp/"; // the strict CSP demo, which holds an install section
export const PRECACHE_GUIDE = 150 * 1024;
const PRIVATE = "in-incognito";

// Raw bytes of what the worker saves at install, read from the build: each URL without its base path and query, a folder
// as its index.html. A URL with no file fails, as modootoday-check does.
export function precacheBytes(site, base, fail) {
  let sum = 0;
  for (const url of constants(site).precache) {
    const rel = decodeURI(url.split("?")[0]).slice(base.length);
    const file = path.join(site, rel.endsWith("/") ? `${rel}index.html` : rel);
    if (!fs.existsSync(file)) {
      fail(`precache ${url}: not in the build`);
      continue;
    }
    sum += fs.statSync(file).size;
  }
  return sum;
}

const install = () => ({
  button: document.querySelector("button.mt-install")?.hidden,
  hint: !!document.querySelector(".mt-install-hint"),
});

// origin: the docs build served at its base path with the strict CSP header. Returns the rows it measured.
export async function checkDocsPwa(browser, origin, site, fails, warns) {
  const fail = (m) => fails.push(`pwa docs /${DOCS_PAGE}: ${m}`);
  const scope = new URL(origin).pathname;
  const ctx = await browser.newContext();
  const page = await ctx.newPage();
  const rows = {};
  try {
    await page.goto(origin + DOCS_PAGE, { waitUntil: "load" });
    rows.worker = await controlled(page);
    if (new URL(rows.worker.scope).pathname !== scope) {
      fail(`worker scope ${rows.worker.scope}, not ${scope}`);
    }
    const cdp = await ctx.newCDPSession(page);
    const manifest = await cdp.send("Page.getAppManifest");
    rows.manifest = manifest.errors.map((e) => e.message);
    if (!manifest.url || rows.manifest.length) {
      fail(`manifest ${manifest.url || "not linked"}: ${rows.manifest.join("; ")}`);
    }
    const { installabilityErrors } = await cdp.send("Page.getInstallabilityErrors");
    rows.installability = installabilityErrors.map((e) => e.errorId).filter((id) => id !== PRIVATE);
    if (rows.installability.length) {
      fail(`not installable: ${rows.installability.join(", ")}`);
    }
    await cdp.detach();
    rows.caches = Object.keys(await cachesOf(page, "mt:"));
    const stray = rows.caches.filter((n) => !n.startsWith(`mt:${scope}:`));
    if (!rows.caches.length || stray.length) {
      fail(`caches ${JSON.stringify(rows.caches)}: expected names under mt:${scope}:`);
    }
    rows.install = await page.evaluate(install);
    if (rows.install.button !== true || !rows.install.hint) {
      fail(`install section: ${JSON.stringify(rows.install)}; expected the hint and a hidden button`);
    }
  } finally {
    await ctx.close();
  }
  rows.precache = precacheBytes(site, scope.replace(/\/$/, ""), fail);
  if (rows.precache > PRECACHE_GUIDE) {
    warns.push(`pwa docs: the precache list is ${rows.precache} B, over the ${PRECACHE_GUIDE} B guide target`);
  }
  return rows;
}
