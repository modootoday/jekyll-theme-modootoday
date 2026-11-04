// Code copy: the copy button never hides code for good. In a title bar it stays above the text; over the top-end corner
// of an untitled block, each line it overlaps ends clear of it once the block is scrolled to its end. At 360, 768, 1440px.
export const COPY_WIDTHS = [360, 768, 1440];
export function coveredBlocks() {
  const bad = [];
  for (const b of document.querySelectorAll(".mt-code-copy")) {
    const pre = b.parentElement.matches("pre") ? b.parentElement : b.parentElement.querySelector("pre");
    if (!pre || !b.offsetParent) {
      continue;
    }
    const cs = getComputedStyle(pre);
    const btn = b.getBoundingClientRect();
    const textTop = pre.getBoundingClientRect().top + parseFloat(cs.borderTopWidth) + parseFloat(cs.paddingTop);
    if (btn.bottom - textTop <= 0.5) {
      continue;
    }
    const left = pre.scrollLeft;
    pre.scrollLeft = pre.scrollWidth;
    const range = document.createRange();
    range.selectNodeContents(pre);
    const hits = [...range.getClientRects()].filter((r) => r.width > 0 && r.top < btn.bottom && r.bottom > btn.top && r.right > btn.left + 0.5);
    pre.scrollLeft = left;
    if (hits.length) {
      bad.push(`${Math.round(hits[0].right - btn.left)}px under it in "${pre.textContent.trim().slice(0, 24)}"`);
    }
  }
  return bad;
}
export async function checkCodeCopy(page, scheme, url, fails) {
  for (const w of COPY_WIDTHS) {
    await page.setViewportSize({ width: w, height: 900 });
    const bad = await page.evaluate(`(${coveredBlocks})()`);
    for (const b of bad) {
      fails.push(`code copy: button ${b} at ${w}px ${scheme} ${url}`);
    }
  }
  await page.setViewportSize({ width: 1024, height: 900 });
}
