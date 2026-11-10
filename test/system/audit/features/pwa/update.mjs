// A deploy at /a: v1 controls the page, v2 (same theme files, another build) takes its place behind it. The browser
// finds the new sw.js and the new worker installs; once v1 has no page left v2 controls the next one, and the caches,
// whose names follow the theme files, are the same ones, with the page the reader visited still kept.
import { clean, constants, controlled, cachesOf, kept, until, update } from "./session.mjs";

export async function checkUpdate(ctx, srv, dirs, fails) {
  const fail = (m) => fails.push(`pwa update: ${m}`);
  const a = srv.url("/a");
  const v1 = constants(dirs.v1);
  const v2 = constants(dirs.v2);
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
    await page.goto(`${a}guide/`);
    await kept(page, "mt:/a/:pages:", `${a}guide/`);
    rows.before = Object.keys(await cachesOf(page, "mt:/a/:"));
    srv.set("/a", dirs.v2);
    await update(page);
    rows.waiting = await until(page, "v2 worker installed", async () => {
      const reg = await navigator.serviceWorker.getRegistration();
      return reg.waiting ? reg.waiting.state : null;
    });
    // A page outside the scope leaves v1 with no client, so v2 activates; the check reads the registration from there.
    await page.goto(`${srv.root}/__clean`);
    await until(page, "v2 activated once v1 had no page", async (scope) => {
      const reg = await navigator.serviceWorker.getRegistration(scope);
      return reg && !reg.waiting && !reg.installing && reg.active && reg.active.state == "activated";
    }, a);
    await page.goto(a);
    await controlled(page);
    rows.after = Object.keys(await cachesOf(page, "mt:/a/:"));
    const versioned = (names) => names.filter((n) => !n.endsWith(":media")).join();
    if (versioned(rows.after) !== versioned(rows.before)) {
      fail(`a deploy with the same theme files changed the caches (${rows.before.join(", ")} -> ${rows.after.join(", ")})`);
    }
    await kept(page, "mt:/a/:pages:", `${a}guide/`);
  } finally {
    srv.set("/a", dirs.v1);
    await page.close();
  }
  return rows;
}
