// Menus and tabs: the language menu, the header menu sheet at 360px and tab arrows (LTR and RTL).
export async function langMenu(page, url, fails) {
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

export async function navSheet(page, url, fails) {
  await page.setViewportSize({ width: 360, height: 800 });
  await page.goto(url, { waitUntil: "networkidle" });
  const s = page.locator("details.mt-nav-sheet > summary");
  if (!(await s.count())) {
    fails.push(`keyboard: no menu sheet button in the header at 360px ${url}`);
    await page.setViewportSize({ width: 1024, height: 900 });
    return;
  }
  await s.focus();
  await page.keyboard.press("Enter");
  await page.keyboard.press("ArrowDown");
  const inSheet = await page.evaluate(() => !!document.activeElement.closest("details.mt-nav-sheet ul") && document.activeElement.getBoundingClientRect().height > 0);
  await page.keyboard.press("Escape");
  const back = await page.evaluate(() => !document.querySelector("details.mt-nav-sheet").open && document.activeElement.matches("details.mt-nav-sheet > summary"));
  if (!inSheet) fails.push(`keyboard: ArrowDown does not reach a visible link in the menu sheet at 360px ${url}`);
  if (!back) fails.push(`keyboard: Esc does not close the menu sheet and return focus ${url}`);
  await page.setViewportSize({ width: 1024, height: 900 });
}

export async function tabsKeys(page, url, fails, rtl) {
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
