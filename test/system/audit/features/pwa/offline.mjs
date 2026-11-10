// Offline reading on the v1 build at /a: the worker registers with the site's scope; with every socket cut a visited
// page comes from the cache, an unvisited one gets the offline page with the kept pages listed, a Korean path gets the
// Korean offline page, and no page breaks the strict CSP. smoke (the WebKit run) stops after the first offline page.
import { clean, controlled, kept, until, violations } from "./session.mjs";

const offlinePage = () => {
  const box = document.querySelector("[data-mt-offline]");
  return box && { lang: document.documentElement.lang, h1: document.querySelector("h1").textContent };
};

// offline.js fills the list after reading the caches, so the check waits for it to show.
const listed = () => {
  const box = document.querySelector("[data-mt-offline]");
  return box && !box.hidden && [...box.querySelectorAll("a")].map((a) => a.href);
};

export async function checkOffline(ctx, srv, dirs, fails, { smoke = false } = {}) {
  const fail = (m) => fails.push(`pwa offline: ${m}`);
  const a = srv.url("/a");
  const rows = { violations: [] };
  srv.set("/a", dirs.v1);
  const page = await ctx.newPage();
  const note = async () => rows.violations.push(...(await violations(page)));
  try {
    await clean(page, srv.root);
    await page.goto(a);
    rows.registration = await controlled(page);
    if (rows.registration.scope !== a) {
      fail(`scope ${rows.registration.scope}, not ${a}`);
    }
    await page.goto(`${a}guide/`);
    rows.kept = await kept(page, "mt:/a/:pages:", `${a}guide/`);
    await note();
    await srv.offline(true);
    await page.goto(`${a}guide/`);
    rows.visited = await page.title();
    if (!rows.visited.startsWith("Guide")) {
      fail(`a visited page offline shows "${rows.visited}", not its kept copy`);
    }
    await note();
    await page.goto(`${a}not-kept/`);
    rows.unvisited = await until(page, "offline page for an unvisited page", offlinePage);
    if (rows.unvisited.lang !== "en") {
      fail(`the offline page for /a/not-kept/ is lang ${rows.unvisited.lang}`);
    }
    if (smoke) {
      return rows;
    }
    rows.list = await until(page, "kept pages listed on the offline page", listed);
    if (!rows.list.includes(`${a}guide/`)) {
      fail(`the offline page lists ${rows.list.join(", ")} without the visited guide`);
    }
    await note();
    await page.goto(`${a}ko/guide/`);
    rows.ko = await until(page, "Korean offline page", offlinePage);
    if (rows.ko.lang !== "ko") {
      fail(`/a/ko/guide/ offline shows the ${rows.ko.lang} offline page`);
    }
    await note();
    rows.violations.forEach((v) => fail(`CSP violation ${v}`));
  } finally {
    await srv.offline(false);
    await page.close();
  }
  return rows;
}
