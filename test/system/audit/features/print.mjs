// The print sheet (modootoday.print, chrome/print.css) on the docs site under print emulation and the strict CSP: the site
// chrome, banner, feedback row and page actions are hidden, every tab panel shows, the page is black on white in the
// dark theme too, a link prints its address, and no CSP violation a stylesheet could cause.
export const PRINT_PAGES = ["", "guides/customize/", "components/kitchen-sink/", "reference/changelog/"];

const HIDDEN = [".mt-header", ".mt-skip", ".mt-banner", ".mt-page-feedback", ".mt-page-actions", ".mt-doc-aside", ".mt-sidebar-mobile", ".mt-toc-mobile", ".mt-footer"];

const watch = () => {
  window.mtCspViolations = [];
  document.addEventListener("securitypolicyviolation", (e) => window.mtCspViolations.push(`${e.effectiveDirective} ${e.blockedURI || "inline"}`));
  try { localStorage.setItem("mt-theme", "dark"); } catch {}
};

const probe = (hidden) => ({
  shown: hidden.filter((s) => [...document.querySelectorAll(s)].some((el) => getComputedStyle(el).display !== "none")),
  tabs: [...document.querySelectorAll('[role="tabpanel"]')].filter((p) => getComputedStyle(p).display === "none").length,
  colors: [getComputedStyle(document.body).color, getComputedStyle(document.body).backgroundColor],
  linkAfter: (() => {
    const a = document.querySelector('.mt-prose a[href^="http"], .mt-doc a[href^="http"]');
    return a ? getComputedStyle(a, "::after").content : null;
  })(),
  csp: window.mtCspViolations,
});

// origin: a server that sends the strict CSP header. Returns how many pages it checked.
export async function checkPrint(browser, origin, fails) {
  const ctx = await browser.newContext({ viewport: { width: 1024, height: 900 } });
  await ctx.addInitScript(watch);
  const page = await ctx.newPage();
  await page.emulateMedia({ media: "print" });
  let checked = 0;
  try {
    for (const path of PRINT_PAGES) {
      const fail = (m) => fails.push(`print /${path}: ${m}`);
      await page.goto(`${origin}/${path}`, { waitUntil: "load" });
      const r = await page.evaluate(probe, HIDDEN);
      checked += 1;
      if (r.shown.length > 0) fail(`still shown in print: ${r.shown.join(", ")}`);
      if (r.tabs > 0) fail(`${r.tabs} tab panel(s) hidden in print`);
      if (r.colors[0] !== "rgb(0, 0, 0)" || r.colors[1] !== "rgb(255, 255, 255)") fail(`not black on white in the dark theme: ${r.colors.join(" on ")}`);
      if (r.linkAfter !== null && !/\(http/.test(r.linkAfter)) fail(`an external link prints no address (${r.linkAfter})`);
      // A stylesheet can only break style-src-elem; inline style attributes come from component scripts, checked elsewhere.
      const sheets = r.csp.filter((v) => !v.startsWith("style-src-attr"));
      if (sheets.length > 0) fail(`CSP violations: ${sheets.join(", ")}`);
    }
  } finally {
    await ctx.close();
  }
  return checked;
}
