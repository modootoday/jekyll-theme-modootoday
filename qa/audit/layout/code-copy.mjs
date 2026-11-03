// Code copy: the copy button never covers code. Its box stays above the top of each block's text (the pre's content
// box), whether it sits in the reserved strip or in a title bar, at 360, 768 and 1440px.
export const COPY_WIDTHS = [360, 768, 1440];
export function coveredBlocks() {
  const bad = [];
  for (const b of document.querySelectorAll(".mt-code-copy")) {
    const pre = b.parentElement.matches("pre") ? b.parentElement : b.parentElement.querySelector("pre");
    if (!pre || !b.offsetParent) {
      continue;
    }
    const cs = getComputedStyle(pre);
    const textTop = pre.getBoundingClientRect().top + parseFloat(cs.borderTopWidth) + parseFloat(cs.paddingTop);
    const over = b.getBoundingClientRect().bottom - textTop;
    if (over > 0.5) {
      bad.push(`${Math.round(over)}px over "${pre.textContent.trim().slice(0, 24)}"`);
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
