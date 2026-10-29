// Accessibility-tree snapshot (Playwright ariaSnapshot) as the stand-in for NVDA/VoiceOver: the reading
// order and names a screen reader announces. Written per page for review; returns the text.
import fs from "node:fs";
import path from "node:path";
export async function snapshotTree(page, outDir, name) {
  const yml = await page.locator("body").ariaSnapshot();
  fs.mkdirSync(outDir, { recursive: true });
  fs.writeFileSync(path.join(outDir, name + ".yml"), yml);
  return yml;
}
