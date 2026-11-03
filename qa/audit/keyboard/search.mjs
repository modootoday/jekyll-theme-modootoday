// Search shortcuts: / and Ctrl+K focus the field, arrows reach the results, Esc returns and clears.
export async function search(page, url, fails) {
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
