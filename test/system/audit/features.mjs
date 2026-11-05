// Feature checks (audit/features/): one per optional feature with a demo page, each opened under the strict CSP header.
import { serveSite } from "../site/server.mjs";
import { CSP } from "./config.mjs";
import { checkChart } from "./features/chart.mjs";

export async function checkFeatures(browser, site, fails) {
  const { origin, close } = await serveSite(site, { csp: CSP });
  try {
    return { chart: await checkChart(browser, origin, fails) };
  } finally {
    close();
  }
}
