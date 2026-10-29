// Keyboard flows: skip link, a visible focus ring on every Tab stop, the language menu, tabs (LTR and RTL),
// search shortcuts and result arrows, focusable scrolling code blocks. Chromium, desktop and 360px.
const ring = () => {
  const e = document.activeElement; if (!e || e === document.body) return null;
  const s = getComputedStyle(e), r = e.getBoundingClientRect();
  const visible = (s.outlineStyle !== "none" && parseFloat(s.outlineWidth) >= 2) || (s.boxShadow !== "none" && s.boxShadow !== "");
  return { tag: e.tagName + (e.className ? "." + String(e.className).split(" ")[0] : ""), visible, inView: r.width > 0 && r.height > 0 };
};

async function tabWalk(page, url, fails, max = 80) {
  await page.goto(url, { waitUntil: "networkidle" });
  await page.keyboard.press("Tab");
  const first = await page.evaluate(() => document.activeElement.className);
  if (first !== "mt-skip") fails.push(`keyboard: first Tab stop is .${first}, not the skip link, ${url}`);
  const seen = new Set();
  for (let i = 0; i < max; i++) {
    const r = await page.evaluate(ring);
    if (!r) break;
    if (!r.visible && !seen.has(r.tag)) { seen.add(r.tag); fails.push(`keyboard: no visible focus ring on ${r.tag} ${url}`); }
    await page.keyboard.press("Tab");
  }
}

async function skipLink(page, url, fails) {
  await page.goto(url, { waitUntil: "networkidle" });
  await page.keyboard.press("Tab");
  const shown = await page.evaluate(() => document.activeElement.getBoundingClientRect().left >= 0);
  await page.keyboard.press("Enter");
  const id = await page.evaluate(() => document.activeElement.id);
  if (!shown) fails.push(`keyboard: skip link not on screen when focused ${url}`);
  if (id !== "mt-main") fails.push(`keyboard: skip link does not move focus to main (${id}) ${url}`);
}

async function langMenu(page, url, fails) {
  await page.goto(url, { waitUntil: "networkidle" });
  const s = page.locator("details.mt-lang > summary");
  if (!(await s.count())) return;
  await s.focus(); await page.keyboard.press("Enter"); await page.keyboard.press("ArrowDown");
  const inMenu = await page.evaluate(() => !!document.activeElement.closest("details.mt-lang ul"));
  await page.keyboard.press("Escape");
  const back = await page.evaluate(() => { const d = document.querySelector("details.mt-lang"); return !d.open && document.activeElement === d.querySelector("summary"); });
  if (!inMenu) fails.push(`keyboard: ArrowDown does not enter the language menu ${url}`);
  if (!back) fails.push(`keyboard: Esc does not close the language menu and return focus ${url}`);
}

async function tabsKeys(page, url, fails, rtl) {
  await page.goto(url, { waitUntil: "networkidle" });
  const tabs = page.locator('[role="tablist"]').first().locator('[role="tab"]');
  if ((await tabs.count()) < 2) return;
  await tabs.first().focus();
  await page.keyboard.press(rtl ? "ArrowLeft" : "ArrowRight");
  const sel = await tabs.nth(1).getAttribute("aria-selected"), foc = await tabs.nth(1).evaluate((e) => e === document.activeElement);
  await page.keyboard.press("Home");
  const home = await tabs.first().getAttribute("aria-selected");
  const roving = await page.evaluate(() => [...document.querySelector('[role="tablist"]').children].filter((t) => t.tabIndex === 0).length);
  if (sel !== "true" || !foc) fails.push(`keyboard: ${rtl ? "ArrowLeft (RTL)" : "ArrowRight"} does not move to the next tab ${url}`);
  if (home !== "true") fails.push(`keyboard: Home does not select the first tab ${url}`);
  if (roving !== 1) fails.push(`keyboard: tablist has ${roving} tab stops, want 1 (roving tabindex) ${url}`);
}

async function search(page, url, fails) {
  await page.goto(url, { waitUntil: "networkidle" });
  if (!(await page.locator(".mt-search input").count())) return;
  await page.locator("body").press("/");
  if (!(await page.evaluate(() => document.activeElement.matches(".mt-search input")))) { fails.push(`keyboard: "/" does not focus search ${url}`); return; }
  await page.keyboard.type("install");
  await page.waitForSelector(".mt-search-results a", { timeout: 5000 }).catch(() => {});
  await page.keyboard.press("ArrowDown");
  const onLink = await page.evaluate(() => !!document.activeElement.closest(".mt-search-results"));
  await page.keyboard.press("Escape");
  const back = await page.evaluate(() => document.activeElement.matches(".mt-search input"));
  await page.keyboard.press("Escape");
  const cleared = await page.evaluate(() => document.querySelector(".mt-search input").value === "");
  if (!onLink) fails.push(`keyboard: ArrowDown does not reach search results ${url}`);
  if (!back || !cleared) fails.push(`keyboard: Esc does not return to and clear search ${url}`);
  await page.keyboard.press("Tab"); await page.keyboard.press("Control+k");
  if (!(await page.evaluate(() => document.activeElement.matches(".mt-search input")))) fails.push(`keyboard: Ctrl+K does not focus search ${url}`);
}

async function scrollRegions(page, url, fails) {
  await page.setViewportSize({ width: 360, height: 800 });
  await page.goto(url, { waitUntil: "networkidle" });
  const bad = await page.evaluate(() => [...document.querySelectorAll(".mt-main pre, .mt-main table")]
    .filter((e) => e.scrollWidth > e.clientWidth + 1 && !(e.tabIndex === 0 && e.getAttribute("aria-label"))).length);
  if (bad) fails.push(`keyboard: ${bad} scrolling code blocks/tables are not focusable labelled regions at 360px ${url}`);
  await page.setViewportSize({ width: 1024, height: 900 });
}

export async function checkKeyboard(browser, origin, fails) {
  const ctx = await browser.newContext({ viewport: { width: 1024, height: 900 } });
  const page = await ctx.newPage();
  const before = fails.length;
  for (const p of ["", "components/kitchen-sink/", "ko/install/"]) await tabWalk(page, origin + p, fails);
  await skipLink(page, origin + "install/", fails);
  await langMenu(page, origin + "install/", fails);
  await tabsKeys(page, origin + "install/", fails, false);
  await tabsKeys(page, origin + "components/kitchen-sink-rtl/", fails, true);
  await search(page, origin + "install/", fails);
  await scrollRegions(page, origin + "components/kitchen-sink/", fails);
  await ctx.close();
  return { flows: 9, fails: fails.length - before };
}
