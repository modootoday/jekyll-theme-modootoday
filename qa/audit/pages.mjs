// Per page: screenshots at every width, horizontal overflow, RTL mirroring and axe (WCAG 2.2 AA).
import AxeBuilder from "@axe-core/playwright";
import fs from "node:fs";
import path from "node:path";
import { WIDTHS, RTL_PAGES } from "./config.mjs";
import { checkExampleCards } from "./layout/example-cards.mjs";
import { checkTabsScroll } from "./layout/tabs-scroll.mjs";
import { checkChipRows } from "./layout/chip-rows.mjs";
import { checkListRows } from "./layout/list-rows.mjs";
import { checkInlineCodeWrap } from "./layout/inline-code-wrap.mjs";
import { checkHeaderEnd, checkHeaderHeight } from "./layout/header-end.mjs";
import { checkCjkClip } from "./layout/cjk-clip.mjs";
import { checkAnchorOffset } from "./layout/anchor-offset.mjs";
import { checkColumnAlign, ALIGN_PAGES } from "./layout/column-align.mjs";
import { checkCodeCopy } from "./layout/code-copy.mjs";

// Header height: a doc page, pricing, the blog list and the home page; anchor jumps: two long pages.
const HEADER_PAGES = ["guides/configuration/", "layouts/marketing/pricing/", "blog/", ""];
const ANCHOR_PAGES = ["guides/configuration/", "layouts/documents/legal/"];

async function checkRtl(page, scheme, url, fails) {
  // logical properties must mirror: callout icon and steps rail on the right, code left-to-right
  const r = await page.evaluate(() => {
    const cs = (s) => { const e = document.querySelector(s); return e && getComputedStyle(e); };
    const t = document.querySelector(".mt-callout-title"), i = t && t.querySelector("svg");
    const st = cs(".mt-c-steps > ol > li"), pre = cs("pre");
    const box = (e) => e.getBoundingClientRect();
    return { dir: document.documentElement.dir, callout: i && box(i).left > box(t).left + box(t).width / 2,
      steps: st && parseFloat(st.paddingRight) > parseFloat(st.paddingLeft), pre: pre && pre.direction === "ltr" };
  });
  for (const [k, ok] of Object.entries(r)) if (k === "dir" ? ok !== "rtl" : !ok) fails.push(`rtl ${k} not mirrored ${scheme} ${url}`);
}

export async function checkPage(page, { origin, out, report, fails }, { scheme, lang, p }) {
  const url = origin + lang + p;
  const resp = await page.goto(url, { waitUntil: "networkidle" });
  if (!resp || resp.status() !== 200) { if (lang === "ja/") return; fails.push(`HTTP ${resp && resp.status()} ${url}`); return; }
  const name = `${(lang || "en/").replace("/", "")}-${(p || "home/").replace(/\//g, "_").replace(/_$/, "")}`;
  for (const w of WIDTHS) {
    await page.setViewportSize({ width: w, height: 900 });
    const dir = path.join(out, "shots", scheme, String(w)); fs.mkdirSync(dir, { recursive: true });
    await page.screenshot({ path: path.join(dir, name + ".png"), fullPage: true });
    report.shots++;
    const overflow = await page.evaluate(() => document.documentElement.scrollWidth - window.innerWidth);
    if (overflow > 1) fails.push(`horizontal overflow ${overflow}px at ${w}px ${scheme} ${url}`);
  }
  await page.setViewportSize({ width: 1024, height: 900 });
  if (RTL_PAGES.includes(p)) await checkRtl(page, scheme, url, fails);
  if (p === "components/") await checkExampleCards(page, scheme, url, fails);
  if (await page.$(".mt-badge")) await checkChipRows(page, scheme, url, fails);
  await checkListRows(page, scheme, url, fails);
  if (await page.$('[role="tablist"]')) await checkTabsScroll(page, scheme, url, fails);
  if (p === "guides/agents/" || p === "layouts/blog-news/post/") await checkInlineCodeWrap(page, scheme, url, fails);
  if ((p === "guides/agents/" && !lang) || RTL_PAGES.includes(p)) await checkHeaderEnd(page, scheme, url, fails);
  if (p === "" && (lang === "ko/" || lang === "ja/")) await checkCjkClip(page, scheme, url, fails);
  if (!lang && HEADER_PAGES.includes(p)) await checkHeaderHeight(page, scheme, url, fails);
  if (!lang && ANCHOR_PAGES.includes(p)) await checkAnchorOffset(page, scheme, url, fails);
  if (!lang && ALIGN_PAGES.includes(p)) await checkColumnAlign(page, scheme, url, fails);
  if (await page.$(".mt-code-copy")) await checkCodeCopy(page, scheme, url, fails);
  const axe = await new AxeBuilder({ page }).withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa"]).analyze();
  for (const v of axe.violations) {
    report.axe.push({ scheme, url, id: v.id, impact: v.impact, nodes: v.nodes.slice(0, 3).map((n) => n.target.join(" ")) });
    fails.push(`axe ${v.id} (${v.impact}) ${scheme} ${url}`);
  }
}
