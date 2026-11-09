// Opens CSP_PAGES with the server sending a strict Content-Security-Policy header (config.mjs CSP) and counts
// securitypolicyviolation events, console errors and page errors on each; every count must be 0.
import { serveSite } from "../site/server.mjs";
import { CSP, CSP_PAGES } from "./config.mjs";

// pages and base: a starter demo build's qa: pages and its Pages base path (test/system/site/demos.mjs).
export async function checkCsp(browser, site, fails, pages = CSP_PAGES, base = undefined) {
  const { origin, close } = await serveSite(site, { csp: CSP, base });
  const ctx = await browser.newContext();
  // Registered before any page script runs, so violations during parsing are counted too.
  await ctx.addInitScript(() => {
    window.mtCspViolations = [];
    document.addEventListener("securitypolicyviolation", (e) => {
      window.mtCspViolations.push(`${e.effectiveDirective} ${e.blockedURI || "inline"}`);
    });
  });
  const page = await ctx.newPage();
  let errors = [];
  page.on("console", (m) => {
    if (m.type() === "error") {
      errors.push(m.text());
    }
  });
  page.on("pageerror", (e) => {
    errors.push(e.message);
  });
  const rows = [];
  for (const p of pages) {
    errors = [];
    const res = await page.goto(origin + p, { waitUntil: "networkidle" });
    const header = res ? res.headers()["content-security-policy"] : undefined;
    const violations = await page.evaluate(() => window.mtCspViolations);
    const url = `/${p}`;
    rows.push({ url, violations, errors });
    if (header !== CSP) {
      fails.push(`csp ${url}: the server did not send the policy`);
    }
    for (const v of violations) {
      fails.push(`csp ${url}: violation ${v}`);
    }
    for (const e of errors) {
      fails.push(`csp ${url}: console error ${e}`);
    }
  }
  // Control: an inline style must be reported, or the zero counts above prove nothing.
  errors = [];
  const seen = await page.evaluate(() => new Promise((resolve) => {
    document.addEventListener("securitypolicyviolation", () => resolve(true), { once: true });
    document.head.append(Object.assign(document.createElement("style"), { textContent: "html{}" }));
    setTimeout(() => resolve(false), 2000);
  }));
  if (!seen) {
    fails.push("csp: the control inline style was not reported; the audit cannot see violations");
  }
  await ctx.close();
  close();
  return rows;
}
