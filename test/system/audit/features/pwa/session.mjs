// The steps the PWA flows share. A flow may run in a long-lived browser context (a remote session's default one), so it
// starts by removing every worker and mt: cache, and it waits for each completion state instead of a fixed time: a
// remote browser's latency hides races that a local one shows.
import fs from "node:fs";
import path from "node:path";

// The constants a build's sw.js gives the worker (scope, build, assets, precache, offline).
export const constants = (dir) => JSON.parse(fs.readFileSync(path.join(dir, "sw.js"), "utf8").match(/^self\.MT_PWA = (\{.*\});$/m)[1]);

// The workers and mt: caches the page sees, printed with a timeout so a CI failure says where the flow stopped.
const state = (page) => page.evaluate(async () => {
  const at = (w) => w && `${w.state} ${new URL(w.scriptURL).pathname}`;
  const regs = await navigator.serviceWorker.getRegistrations();
  return {
    controller: at(navigator.serviceWorker.controller),
    regs: regs.map((r) => ({ scope: r.scope, installing: at(r.installing), waiting: at(r.waiting), active: at(r.active) })),
    caches: (await caches.keys()).filter((n) => n.startsWith("mt:")),
    swaps: window.mtSwaps,
    toast: document.querySelector(".mt-toast")?.textContent,
  };
});

// Polls fn in the page until it returns a truthy value. A worker that reloads the page destroys the context mid-call,
// which counts as not yet.
export async function until(page, what, fn, arg, timeout = 20000) {
  const end = Date.now() + timeout;
  let last;
  for (;;) {
    try {
      last = await page.evaluate(fn, arg);
      if (last) {
        return last;
      }
    } catch (e) {
      last = e.message.split("\n")[0];
    }
    if (Date.now() > end) {
      const now = await state(page).catch((e) => e.message.split("\n")[0]);
      throw new Error(`${what}: not reached in ${timeout} ms (last: ${JSON.stringify(last)}; state: ${JSON.stringify(now)})`);
    }
    await page.waitForTimeout(150);
  }
}

// A page of the origin that no worker registers from (the server answers 404), so nothing comes back while cleaning.
export async function clean(page, root) {
  await page.goto(`${root}/__clean`);
  await page.evaluate(async () => {
    for (const reg of await navigator.serviceWorker.getRegistrations()) {
      await reg.unregister();
    }
    for (const name of await caches.keys()) {
      if (name.startsWith("mt:")) {
        await caches.delete(name);
      }
    }
  });
  await page.goto("about:blank");
}

// After a visit: the page's worker is activated and controls the page (clients.claim on activate).
export const controlled = (page) => until(page, "worker controls the page", async () => {
  const reg = await navigator.serviceWorker.getRegistration();
  const on = reg && reg.active && reg.active.state == "activated" && navigator.serviceWorker.controller;
  return on ? { scope: reg.scope, script: reg.active.scriptURL } : null;
});

// Cache name => sorted URLs, for the names that start with prefix.
export const cachesOf = (page, prefix) => page.evaluate(async (p) => {
  const out = {};
  for (const name of (await caches.keys()).filter((n) => n.startsWith(p)).sort()) {
    out[name] = (await (await caches.open(name)).keys()).map((r) => r.url).sort();
  }
  return out;
}, prefix);

// Waits until a cache whose name starts with prefix holds url (the worker stores a page after answering with it).
export const kept = (page, prefix, url) => until(page, `${url} kept in ${prefix}*`, async ([p, u]) => {
  for (const name of (await caches.keys()).filter((n) => n.startsWith(p))) {
    if (await (await caches.open(name)).match(u)) {
      return name;
    }
  }
  return null;
}, [prefix, url]);

export const scopes = (page) => page.evaluate(async () => (await navigator.serviceWorker.getRegistrations()).map((r) => r.scope).sort());

// Asks the browser to look for a new sw.js now instead of on its own schedule.
export const update = (page) => page.evaluate(async () => {
  const reg = await navigator.serviceWorker.getRegistration();
  await reg.update().catch(() => {});
});

export const violations = (page) => page.evaluate(() => window.mtCspViolations || []);

// Registered before page scripts run (a cached page served offline runs it too).
export const watch = () => {
  window.mtCspViolations = [];
  document.addEventListener("securitypolicyviolation", (e) => window.mtCspViolations.push(`${e.effectiveDirective} ${e.blockedURI || "inline"}`));
};
