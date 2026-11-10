// Feature checks (audit/features/): one per optional feature with a demo page, each opened under the strict CSP header,
// and the PWA flows on their own fixture builds (PWA_SITES).
import { serveSite } from "../site/server.mjs";
import { CSP, PWA_SITES } from "./config.mjs";
import { checkChart } from "./features/chart.mjs";
import { checkNoJs } from "./features/no-js.mjs";
import { checkPwa } from "./features/pwa.mjs";
import { checkToc } from "./features/toc.mjs";

export async function checkFeatures(browser, site, fails) {
  const { origin, close } = await serveSite(site, { csp: CSP });
  let rows;
  try {
    rows = { chart: await checkChart(browser, origin, fails), noJs: await checkNoJs(browser, origin, fails), toc: await checkToc(browser, origin, fails) };
  } finally {
    close();
  }
  return { ...rows, pwa: await checkPwa(browser, PWA_SITES, fails) };
}
