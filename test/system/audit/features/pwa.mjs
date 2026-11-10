// The PWA flows (features/pwa/) on the fixture builds of test/system/site/build-pwa.sh, on one origin under the strict CSP.
// Command: node test/system/audit/features/pwa.mjs DIR [--browser=webkit] [--only=offline] [--smoke]; with --cdp=WS_URL,
// --origin=PUBLIC_URL and --port=N it drives a remote browser through a tunnel to the local server (CONTRIBUTING).
import fs from "node:fs";
import path from "node:path";
import { pathToFileURL } from "node:url";
import { serveSites } from "../../site/server.mjs";
import { CSP } from "../config.mjs";
import { watch } from "./pwa/session.mjs";
import { checkOffline } from "./pwa/offline.mjs";
import { checkUpdate } from "./pwa/update.mjs";
import { checkKill } from "./pwa/kill.mjs";
import { checkScope } from "./pwa/scope.mjs";

export const BUILDS = ["v1", "v2", "kill", "b", "root"];
export const CHECKS = { offline: checkOffline, update: checkUpdate, kill: checkKill, scope: checkScope };

// Build name => folder, or null after a fail naming the command when one is missing.
export function builds(dir, fails) {
  const missing = BUILDS.filter((b) => !fs.existsSync(path.join(dir, b, "index.html")));
  if (missing.length) {
    fails.push(`pwa: no fixture build ${missing.join(", ")} in ${dir}; run test/system/site/build-pwa.sh`);
    return null;
  }
  return Object.fromEntries(BUILDS.map((b) => [b, path.resolve(dir, b)]));
}

// context: a browser context to reuse (a remote session's default one, the only one that reports installability), else a
// new one. origin: the public address of the server (a tunnel to port); offline then cuts the context's network, since an
// origin cut behind a tunnel answers 502 instead of failing. Returns the measured rows per check.
export async function checkPwa(browser, dir, fails, { only = Object.keys(CHECKS), smoke = false, context, origin, port } = {}) {
  const dirs = builds(dir, fails);
  if (!dirs) {
    return {};
  }
  const srv = await serveSites({ "/a": dirs.v1 }, { csp: CSP, port });
  const ctx = context || (await browser.newContext());
  if (origin) {
    srv.root = origin.replace(/\/$/, "");
    srv.url = (base) => `${srv.root}${base}/`;
    srv.offline = (on) => ctx.setOffline(on);
  }
  await ctx.addInitScript(watch);
  const rows = {};
  try {
    for (const name of only) {
      try {
        rows[name] = await CHECKS[name](ctx, srv, dirs, fails, { smoke });
      } catch (e) {
        fails.push(`pwa ${name}: ${e.message.split("\n")[0]}`);
      }
    }
  } finally {
    if (!context) {
      await ctx.close();
    }
    srv.close();
  }
  return rows;
}

async function main(argv) {
  const flag = (name) => argv.find((a) => a.startsWith(`--${name}=`))?.slice(name.length + 3);
  const dir = argv.find((a) => !a.startsWith("--"));
  if (!dir) {
    console.error("usage: node test/system/audit/features/pwa.mjs DIR [--browser=chromium|webkit] [--only=a,b] [--smoke] [--cdp=URL --origin=URL --port=N]");
    return 2;
  }
  const fails = [];
  if (!builds(dir, fails)) {
    console.error(`FAIL ${fails[0]}`);
    return 1;
  }
  const pw = await import("playwright");
  const cdp = flag("cdp");
  const auth = process.env.CDP_AUTHORIZATION;
  const browser = cdp ? await pw.chromium.connectOverCDP(cdp, { headers: auth ? { Authorization: auth } : {} }) : await pw[flag("browser") || "chromium"].launch();
  const only = flag("only") ? flag("only").split(",") : undefined;
  try {
    const rows = await checkPwa(browser, dir, fails, { only, smoke: argv.includes("--smoke"), context: cdp ? browser.contexts()[0] : undefined, origin: flag("origin"), port: +flag("port") || 0 });
    console.log(JSON.stringify(rows, null, 2));
  } finally {
    await browser.close();
  }
  fails.forEach((f) => console.error(`FAIL ${f}`));
  return fails.length ? 1 : 0;
}

if (process.argv[1] && import.meta.url === pathToFileURL(path.resolve(process.argv[1])).href) {
  process.exitCode = await main(process.argv.slice(2));
}
