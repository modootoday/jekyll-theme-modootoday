// The "On this page" mark (structure/toc-spy.js) on a long guide under the strict CSP: nothing marked at the top, the
// heading brought to the activation line marked (its h2 in the column, itself in the mobile list), the last heading in
// view at the page end, a followed link at once, one mark per list, no CSP violation and axe clean with a mark shown.
import AxeBuilder from "@axe-core/playwright";

export const TOC_PAGE = "guides/customize/";

const watch = () => {
  window.mtCspViolations = [];
  document.addEventListener("securitypolicyviolation", (e) => window.mtCspViolations.push(`${e.effectiveDirective} ${e.blockedURI || "inline"}`));
};

const marks = () => ({
  column: [...document.querySelectorAll(".mt-doc-aside .mt-toc a[aria-current]")].map((a) => a.getAttribute("href").slice(1)),
  mobile: [...document.querySelectorAll(".mt-toc-mobile a[aria-current]")].map((a) => a.getAttribute("href").slice(1)),
  value: [...new Set([...document.querySelectorAll(".mt-toc a[aria-current], .mt-toc-mobile a[aria-current]")].map((a) => a.getAttribute("aria-current")))],
});

// Scrolls the heading listed at index i to just past the line (header bottom plus 1rem); returns its id and its h2's.
const toLine = (i) => {
  const links = [...document.querySelectorAll(".mt-toc-mobile li > a")];
  const h = document.getElementById(links[i].getAttribute("href").slice(1));
  const line = document.querySelector(".mt-header").getBoundingClientRect().bottom + 16;
  window.scrollTo(0, window.scrollY + h.getBoundingClientRect().top - line + 4);
  const h2 = links.slice(0, i + 1).filter((a) => a.parentNode.classList.contains("mt-toc-h2")).pop();
  return { id: h.id, h2: h2.getAttribute("href").slice(1), n: links.length };
};

const lastInView = () => {
  window.scrollTo(0, document.documentElement.scrollHeight);
  const ids = [...document.querySelectorAll(".mt-toc-mobile li > a")].map((a) => a.getAttribute("href").slice(1));
  return ids.filter((id) => document.getElementById(id).getBoundingClientRect().top < window.innerHeight).pop();
};

// origin: a server that sends the strict CSP header (config.mjs CSP). Returns the rows it measured.
export async function checkToc(browser, origin, fails) {
  const fail = (m) => fails.push(`toc /${TOC_PAGE}: ${m}`);
  const ctx = await browser.newContext({ viewport: { width: 1440, height: 900 } });
  await ctx.addInitScript(watch);
  const page = await ctx.newPage();
  const settle = () => page.waitForTimeout(400);
  const rows = {};
  try {
    await page.goto(origin + TOC_PAGE, { waitUntil: "networkidle" });
    await settle();
    rows.top = await page.evaluate(marks);
    if (rows.top.column.length || rows.top.mobile.length) fail(`marked at the top of the page: ${JSON.stringify(rows.top)}`);
    const n = await page.evaluate(() => document.querySelectorAll(".mt-toc-mobile li > a").length);
    if (n < 4) fail(`only ${n} headings listed; the check needs a long guide`);
    for (const i of [1, Math.min(3, n - 2)]) {
      const want = await page.evaluate(toLine, i);
      await settle();
      const got = await page.evaluate(marks);
      rows[`line${i}`] = { want, got };
      if (got.mobile.join() !== want.id || got.column.join() !== want.h2) fail(`heading ${want.id} at the line: marked ${JSON.stringify(got)}`);
    }
    const last = await page.evaluate(lastInView);
    await settle();
    rows.end = { want: last, got: await page.evaluate(marks) };
    if (rows.end.got.mobile.join() !== last) fail(`page end: marked ${JSON.stringify(rows.end.got)}, want ${last}`);
    await page.evaluate(() => window.scrollTo(0, 0));
    const link = page.locator(".mt-doc-aside .mt-toc .mt-toc-h2 a").last();
    const href = await link.getAttribute("href");
    await link.click();
    await settle();
    rows.followed = await page.evaluate(marks);
    if (rows.followed.column.join() !== href.slice(1)) fail(`followed ${href}: marked ${JSON.stringify(rows.followed)}`);
    if (rows.followed.value.join() !== "location") fail(`aria-current values ${rows.followed.value}`);
    const axe = await new AxeBuilder({ page }).withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"]).analyze();
    rows.axe = axe.violations.map((v) => v.id);
    rows.axe.forEach((id) => fail(`axe ${id} with a section marked`));
    rows.violations = await page.evaluate(() => window.mtCspViolations);
    rows.violations.forEach((v) => fail(`CSP violation ${v}`));
  } finally {
    await ctx.close();
  }
  return rows;
}
