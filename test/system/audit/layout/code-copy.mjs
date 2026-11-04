// Code copy: the copy button never covers code. No text of its block lies under it, with the block scrolled to its
// start or to its end (in a title bar it stays above the text; over the top-end corner, a long first line gets a strip).
export const COPY_WIDTHS = [360, 768, 1024, 1440];
export function coveredBlocks() {
  const bad = [];
  const under = (pre, btn) => {
    const hits = [];
    const walk = document.createTreeWalker(pre, NodeFilter.SHOW_TEXT);
    for (let n = walk.nextNode(); n; n = walk.nextNode()) {
      const range = document.createRange();
      range.selectNodeContents(n);
      for (const r of range.getClientRects()) {
        if (r.width > 0 && r.top < btn.bottom - 0.5 && r.bottom > btn.top + 0.5 && r.right > btn.left + 0.5 && r.left < btn.right - 0.5) {
          hits.push(r);
        }
      }
    }
    return hits;
  };
  for (const b of document.querySelectorAll(".mt-code-copy")) {
    const pre = b.parentElement.matches("pre") ? b.parentElement : b.parentElement.querySelector("pre");
    if (!pre || !b.offsetParent) {
      continue;
    }
    const left = pre.scrollLeft;
    const btn = b.getBoundingClientRect();
    pre.scrollLeft = 0;
    const atStart = under(pre, btn);
    pre.scrollLeft = pre.scrollWidth;
    const atEnd = under(pre, btn);
    pre.scrollLeft = left;
    const hit = atStart[0] || atEnd[0];
    if (hit) {
      bad.push(`${Math.round(Math.min(hit.right, btn.right) - Math.max(hit.left, btn.left))}px under it ${atStart[0] ? "at the start" : "at the end"} in "${pre.textContent.trim().slice(0, 24)}"`);
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
