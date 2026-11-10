// Sites sharing one origin, as project sites share <user>.github.io with the user site: v1 at /b, then at /a, then at the
// root. Each activation, and then the kill deploy at /a, leaves the other scopes' registrations and caches as they were
// (cache names carry the scope, and "mt:/:" must not reach "mt:/a/:").
import { cachesOf, clean, controlled, kept, scopes, until, update } from "./session.mjs";

const same = (x, y) => JSON.stringify(x) === JSON.stringify(y);
// Cache names only, and only their loss: a worker deletes whole caches, and a first visit's warm-up may still add one.
const stays = (before, now) => before.every((n) => now.includes(n));
const names = async (page, prefix) => Object.keys(await cachesOf(page, prefix));

export async function checkScope(ctx, srv, dirs, fails) {
  const fail = (m) => fails.push(`pwa scope: ${m}`);
  const [a, b, root] = [srv.url("/a"), srv.url("/b"), srv.url("")];
  const rows = {};
  srv.set("/a", dirs.v1);
  srv.set("/b", dirs.b);
  srv.set("", dirs.root);
  const page = await ctx.newPage();
  try {
    await clean(page, srv.root);
    await page.goto(b);
    await controlled(page);
    await page.goto(`${b}guide/`);
    await kept(page, "mt:/b/:pages:", `${b}guide/`);
    rows.b = await names(page, "mt:/b/:");
    await page.goto(a);
    rows.a = (await controlled(page)).scope;
    if (!stays(rows.b, await names(page, "mt:/b/:"))) {
      fail("activating /a changed the /b caches");
    }
    await page.goto(root);
    rows.root = (await controlled(page)).scope;
    rows.rootCaches = await names(page, "mt:/:");
    if (!stays(rows.b, await names(page, "mt:/b/:")) || !(await names(page, "mt:/a/:")).length) {
      fail("activating the root scope changed the /a or /b caches");
    }
    srv.set("/a", dirs.kill);
    await page.goto(a);
    await update(page);
    await until(page, "/a unregistered and its caches gone", async (scope) => {
      const regs = (await navigator.serviceWorker.getRegistrations()).filter((r) => r.scope == scope);
      return !regs.length && !(await caches.keys()).some((n) => n.startsWith("mt:/a/:"));
    }, a);
    rows.scopes = await scopes(page);
    if (!same(rows.scopes, [`${srv.root}/`, b].sort())) {
      fail(`after the kill at /a the registrations are ${rows.scopes.join(", ")}`);
    }
    if (!stays(rows.b, await names(page, "mt:/b/:"))) {
      fail("the kill at /a changed the /b caches");
    }
    const rootLeft = await names(page, "mt:/:");
    if (!stays(rows.rootCaches, rootLeft)) {
      fail(`the kill at /a deleted root caches (${rows.rootCaches.join(", ")} -> ${rootLeft.join(", ")})`);
    }
  } finally {
    srv.set("/a", dirs.v1);
    await page.close();
  }
  return rows;
}
