// A deploy at /a: v1 controls the page, v2 (same theme files, another build) takes its place behind it. The browser
// finds the new sw.js, the new worker fills the v2 pages cache, and once v1 has no page left v2 controls the next one:
// the v1 pages cache is gone and the assets cache, whose name follows the theme files, is the same one.
import { clean, constants, controlled, cachesOf, until, update } from "./session.mjs";

const hasCache = (name) => caches.has(name);

export async function checkUpdate(ctx, srv, dirs, fails) {
  const fail = (m) => fails.push(`pwa update: ${m}`);
  const a = srv.url("/a");
  const v1 = constants(dirs.v1);
  const v2 = constants(dirs.v2);
  const pages = (c) => `mt:${c.scope}:pages:${c.build}`;
  const assets = (c) => `mt:${c.scope}:assets:${c.assets}`;
  if (v1.build === v2.build || v1.assets !== v2.assets) {
    fail(`the fixture builds need another build and the same assets (v1 ${v1.build} ${v1.assets}, v2 ${v2.build} ${v2.assets})`);
    return {};
  }
  const rows = {};
  srv.set("/a", dirs.v1);
  const page = await ctx.newPage();
  try {
    await clean(page, srv.root);
    await page.goto(a);
    await controlled(page);
    await until(page, "v1 caches", hasCache, pages(v1));
    rows.before = Object.keys(await cachesOf(page, "mt:/a/:"));
    srv.set("/a", dirs.v2);
    await update(page);
    await until(page, "v2 worker installed with its pages cache", hasCache, pages(v2));
    rows.waiting = await page.evaluate(async () => {
      const reg = await navigator.serviceWorker.getRegistration();
      return { installing: !!reg.installing, waiting: !!reg.waiting, active: reg.active && reg.active.state };
    });
    // A page outside the scope leaves v1 with no client, so v2 activates; the check reads the registration from there.
    await page.goto(`${srv.root}/__clean`);
    await until(page, "v2 activated once v1 had no page", async (scope) => {
      const reg = await navigator.serviceWorker.getRegistration(scope);
      return reg && !reg.waiting && !reg.installing && reg.active && reg.active.state == "activated";
    }, a);
    await page.goto(a);
    await controlled(page);
    await until(page, "v1 pages cache deleted on activate", async (name) => !(await caches.has(name)), pages(v1));
    rows.after = Object.keys(await cachesOf(page, "mt:/a/:"));
    if (!rows.after.includes(pages(v2))) {
      fail(`after the swap the caches are ${rows.after.join(", ")}, without ${pages(v2)}`);
    }
    if (!rows.before.includes(assets(v1)) || !rows.after.includes(assets(v2))) {
      fail(`the assets cache ${assets(v1)} did not carry over (${rows.before.join(", ")} -> ${rows.after.join(", ")})`);
    }
  } finally {
    srv.set("/a", dirs.v1);
    await page.close();
  }
  return rows;
}
