// Deploys at /a while a page stays open. v1 to v2 changes only the build: the new worker takes over by itself, with no
// notice and no reload, and the caches and the visited page stay. v2 to next changes the theme files: the new worker
// waits and the notice shows without taking focus; Escape closes it, and its Reload hands over to the new worker.
import AxeBuilder from "@axe-core/playwright";
import { clean, constants, controlled, cachesOf, kept, until, update } from "./session.mjs";

const TAGS = ["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"];
const notice = () => {
  const box = document.querySelector(".mt-toast");
  return box && box.querySelector("button") && { role: box.getAttribute("role"), text: box.textContent, focus: document.activeElement.tagName };
};
const empty = () => !document.querySelector(".mt-toast button");
const versioned = (names) => names.filter((n) => !n.endsWith(":media")).join();

export async function checkUpdate(ctx, srv, dirs, fails) {
  const fail = (m) => fails.push(`pwa update: ${m}`);
  const a = srv.url("/a");
  const [v1, v2, next] = [dirs.v1, dirs.v2, dirs.next].map(constants);
  if (v1.build === v2.build || v1.assets !== v2.assets || next.assets === v2.assets) {
    fail(`the fixture builds need v2 with another build and next with other assets (${[v1, v2, next].map((c) => `${c.build} ${c.assets}`).join(", ")})`);
    return {};
  }
  const rows = {};
  srv.set("/a", dirs.v1);
  const page = await ctx.newPage();
  const mark = () => page.evaluate(() => {
    window.mtMark = true;
    navigator.serviceWorker.addEventListener("controllerchange", () => {
      window.mtSwaps = (window.mtSwaps || 0) + 1;
    });
  });
  try {
    await clean(page, srv.root);
    await page.goto(a);
    await controlled(page);
    await page.goto(`${a}guide/`);
    await kept(page, "mt:/a/:pages:", `${a}guide/`);
    rows.before = Object.keys(await cachesOf(page, "mt:/a/:"));
    await mark();
    srv.set("/a", dirs.v2);
    await update(page);
    await until(page, "v2 took over the open page by itself", () => window.mtSwaps >= 1);
    rows.silent = await page.evaluate(() => ({ mark: window.mtMark === true, notice: !!document.querySelector(".mt-toast") }));
    if (!rows.silent.mark || rows.silent.notice) {
      fail(`a deploy of pages alone ${rows.silent.mark ? "" : "reloaded the page"}${rows.silent.notice ? " showed the notice" : ""}`);
    }
    await page.goto(a);
    await controlled(page);
    rows.after = Object.keys(await cachesOf(page, "mt:/a/:"));
    if (versioned(rows.after) !== versioned(rows.before)) {
      fail(`a deploy with the same theme files changed the caches (${rows.before.join(", ")} -> ${rows.after.join(", ")})`);
    }
    await kept(page, "mt:/a/:pages:", `${a}guide/`);

    await mark();
    srv.set("/a", dirs.next);
    await update(page);
    rows.notice = await until(page, "the update notice for new theme files", notice);
    if (rows.notice.role !== "status" || rows.notice.focus !== "BODY") {
      fail(`the notice is role ${rows.notice.role} and focus moved to ${rows.notice.focus}`);
    }
    const axe = await new AxeBuilder({ page }).include(".mt-toast").withTags(TAGS).analyze();
    rows.axe = axe.violations.map((v) => v.id);
    if (rows.axe.length) {
      fail(`axe on the notice: ${rows.axe.join(", ")}`);
    }
    await page.keyboard.press("Escape");
    await until(page, "Escape closed the notice", empty);
    if (!(await page.evaluate(() => window.mtMark === true))) {
      fail("the page reloaded by itself while a worker waited");
    }
    await page.reload();
    await until(page, "the notice again on the next page while the worker waits", notice);
    await mark();
    await page.locator(".mt-toast button").first().click();
    await until(page, "Reload handed over and reloaded the page once", async (want) => {
      const reg = await navigator.serviceWorker.getRegistration();
      const css = [...document.querySelectorAll("link[rel=stylesheet]")].map((l) => l.href);
      return !window.mtMark && document.readyState == "complete" && reg && !reg.waiting && navigator.serviceWorker.controller && css.some((h) => h.endsWith(want));
    }, `?v=${next.assets}`);
    rows.swapped = Object.keys(await cachesOf(page, "mt:/a/:"));
    if (rows.swapped.some((n) => n.endsWith(`:${v2.assets}`)) || !rows.swapped.includes(`mt:/a/:assets:${next.assets}`)) {
      fail(`after Reload the caches are ${rows.swapped.join(", ")}`);
    }
  } finally {
    srv.set("/a", dirs.v1);
    await page.close();
  }
  return rows;
}
