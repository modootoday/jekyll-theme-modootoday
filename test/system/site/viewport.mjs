// A new viewport reaches the scripts only in the next rendering update: matchMedia listeners (table-stack.js) first,
// ResizeObserver callbacks (scroll-region.js) after its layout. A read before it forces a layout they have not seen, so
// wait for the width, then for the frame after that update.
export async function settle(page, width) {
  await page.waitForFunction((w) => window.innerWidth === w, width);
  await page.evaluate(() => new Promise((done) => requestAnimationFrame(() => requestAnimationFrame(done))));
}
