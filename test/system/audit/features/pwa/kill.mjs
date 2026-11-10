// The kill switch at /a: v1 controls the page, then the deploy of enabled: kill. The browser finds the new sw.js, which
// deletes this scope's caches, unregisters and reloads the open page; the next visit has no worker and no manifest link.
import { clean, controlled, cachesOf, scopes, until, update } from "./session.mjs";

export async function checkKill(ctx, srv, dirs, fails) {
  const fail = (m) => fails.push(`pwa kill: ${m}`);
  const a = srv.url("/a");
  const rows = {};
  srv.set("/a", dirs.v1);
  const page = await ctx.newPage();
  try {
    await clean(page, srv.root);
    await page.goto(a);
    await controlled(page);
    rows.before = Object.keys(await cachesOf(page, "mt:/a/:"));
    if (!rows.before.length) {
      fail("v1 kept no cache, so the kill proves nothing");
    }
    await page.evaluate(() => {
      window.mtBeforeKill = true;
    });
    srv.set("/a", dirs.kill);
    await update(page);
    rows.gone = await until(page, "registration and mt:/a/: caches gone", async (scope) => {
      const regs = (await navigator.serviceWorker.getRegistrations()).filter((r) => r.scope == scope);
      const left = (await caches.keys()).filter((n) => n.startsWith("mt:/a/:"));
      return !regs.length && !left.length && document.readyState == "complete";
    }, a);
    rows.reloaded = await until(page, "the open page reloaded by the worker", () => !window.mtBeforeKill && document.readyState == "complete");
    await page.goto(a);
    rows.after = await page.evaluate(async () => ({
      controller: !!navigator.serviceWorker.controller,
      manifest: !!document.querySelector("link[rel=manifest]"),
      caches: (await caches.keys()).filter((n) => n.startsWith("mt:/a/:")),
    }));
    rows.scopes = await scopes(page);
    if (rows.after.controller || rows.after.manifest || rows.after.caches.length || rows.scopes.includes(a)) {
      fail(`after the kill deploy: ${JSON.stringify({ ...rows.after, scopes: rows.scopes })}`);
    }
  } finally {
    srv.set("/a", dirs.v1);
    await page.close();
  }
  return rows;
}
