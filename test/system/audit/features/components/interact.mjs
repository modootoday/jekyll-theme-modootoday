// The interactive parts of the component examples on one page: each check drives the first instance with the mouse and
// reports what did not respond. A part the page does not have is skipped (null).
// The first shown instance: an earlier check may have hidden others (the first tab's panel).
const first = async (page, sel) => ((await page.locator(`${sel}:visible`).count()) ? page.locator(`${sel}:visible`).first() : null);

async function tabs(page) {
  const tab = await first(page, "main [role=tablist] [role=tab]:nth-child(2)");
  if (!tab) return null;
  await tab.click();
  return tab.evaluate((t) => {
    const panel = document.getElementById(t.getAttribute("aria-controls"));
    return t.getAttribute("aria-selected") === "true" && panel && panel.checkVisibility() ? "" : "the second tab does not show its panel";
  });
}

async function accordion(page) {
  const b = await first(page, "main [data-c=accordion] > h3 button[aria-expanded]");
  if (!b) return null;
  const was = await b.getAttribute("aria-expanded");
  await b.click();
  const panel = await b.evaluate((e) => document.getElementById(e.getAttribute("aria-controls"))?.checkVisibility());
  return (await b.getAttribute("aria-expanded")) !== was && panel === (was !== "true") ? "" : "the accordion does not open its panel";
}

async function disclose(page, sel, what) {
  const s = await first(page, sel);
  if (!s) return null;
  const was = await s.evaluate((e) => e.closest("details").open);
  await s.click();
  const now = await s.evaluate((e) => e.closest("details").open);
  return now !== was ? "" : `${what} does not open or close`;
}

async function copy(page) {
  const b = await first(page, "main .mt-code-copy");
  if (!b) return null;
  await b.click();
  await page.waitForTimeout(200);
  return page.evaluate(() => ([...document.querySelectorAll("[role=status]")].some((s) => s.textContent.trim()) ? "" : "the copy button says nothing"));
}

async function toggle(page) {
  const t = await first(page, ".mt-theme-toggle");
  if (!t || !(await t.isVisible())) return null;
  const bg = () => page.evaluate(() => getComputedStyle(document.body).backgroundColor);
  const before = await bg();
  await t.click();
  await page.waitForTimeout(300);
  const after = await bg();
  await t.click();
  return after !== before ? "" : "the theme toggle does not change the scheme";
}

async function widget(page) {
  const b = await first(page, "main .mt-widget > :not(.mt-widget-fallback) button");
  if (!b) return (await first(page, "main .mt-widget")) ? "the widget drew no control" : null;
  const read = () => page.locator("main .mt-widget").first().innerText();
  const before = await read();
  await b.click();
  return (await read()) !== before ? "" : "the widget does not respond to its button";
}

async function filter(page) {
  const box = await first(page, "main [data-mt-filter] .mt-filter input");
  if (!box || !(await box.isVisible())) return null;
  const count = () => page.evaluate(() => {
    const root = document.querySelector("main [data-mt-filter]");
    return [...root.querySelectorAll(":scope > ul > li, :scope > ol > li, :scope tbody > tr")].filter((e) => !e.hidden).length;
  });
  const before = await count();
  await box.fill("zzzzqqq");
  await page.waitForTimeout(300);
  const after = await count();
  await box.fill("");
  return after < before ? "" : "the filter hides nothing";
}

export async function interactExamples(page) {
  const out = {};
  const checks = {
    tabs, accordion, copy, toggle, widget, filter,
    details: (p) => disclose(p, "main details.mt-details > summary", "a details block"),
    chartTable: (p) => disclose(p, "main figure.mt-chart .mt-chart-data summary", "the chart data table"),
    gallery: async (p) => {
      const a = await first(p, "main a.mt-gallery-thumb");
      if (!a) return null;
      await a.click();
      await p.waitForTimeout(300);
      const open = await p.evaluate(() => [...document.querySelectorAll(".mt-lightbox")].some((l) => l.checkVisibility()));
      await p.keyboard.press("Escape");
      await p.evaluate(() => history.replaceState(null, "", location.pathname));
      return open ? "" : "the gallery thumbnail opens no lightbox";
    },
  };
  for (const [name, fn] of Object.entries(checks)) {
    try {
      const r = await fn(page);
      if (r !== null) out[name] = r;
    } catch (e) {
      out[name] = `error: ${String(e.message || e).split("\n").filter((l) => /intercepts|not visible|Timeout|detached/.test(l)).slice(0, 2).join(" / ").slice(0, 200)}`;
    }
  }
  return out;
}
