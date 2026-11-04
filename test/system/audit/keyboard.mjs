// Keyboard flows: skip link, a visible focus ring on every Tab stop, the language menu, the header menu sheet, tabs (LTR and RTL),
// search shortcuts and result arrows, focusable scrolling code blocks. Chromium, desktop and 360px.
import { tabWalk, skipLink, tocRing, cardRing } from "./keyboard/focus.mjs";
import { langMenu, navSheet, tabsKeys } from "./keyboard/menus.mjs";
import { search } from "./keyboard/search.mjs";
import { scrollRegions } from "./keyboard/scroll-regions.mjs";

export async function checkKeyboard(browser, origin, fails) {
  const ctx = await browser.newContext({ viewport: { width: 1024, height: 900 } });
  const page = await ctx.newPage();
  const before = fails.length;
  for (const p of ["", "components/kitchen-sink/", "ko/guides/install/"]) await tabWalk(page, origin + p, fails);
  await skipLink(page, origin + "guides/install/", fails);
  await langMenu(page, origin + "guides/install/", fails);
  await navSheet(page, origin + "guides/install/", fails);
  await tocRing(page, origin + "guides/configuration/", fails);
  await cardRing(page, origin + "components/kitchen-sink/", fails);
  await tabsKeys(page, origin + "guides/install/", fails, false);
  await tabsKeys(page, origin + "components/kitchen-sink-rtl/", fails, true);
  await search(page, origin + "guides/install/", fails);
  await scrollRegions(page, origin + "components/kitchen-sink/", fails);
  await ctx.close();
  return { flows: 12, fails: fails.length - before };
}
