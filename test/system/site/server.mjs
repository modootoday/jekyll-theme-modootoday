// Serves built sites on a random local port (shared by the audit and visual checks): one site at the Pages baseurl, or
// several on one origin by base path for the PWA flows.
import http from "node:http";
import fs from "node:fs";
import path from "node:path";

export const BASE = "/jekyll-theme-modootoday";
const TYPES = { ".html": "text/html; charset=utf-8", ".css": "text/css", ".js": "text/javascript", ".txt": "text/plain; charset=utf-8", ".md": "text/markdown; charset=utf-8", ".svg": "image/svg+xml", ".png": "image/png", ".json": "application/json", ".webmanifest": "application/manifest+json" };

// The longest base path that holds the URL path ("" is the origin root, which holds every path).
export function siteFor(sites, u) {
  const base = Object.keys(sites).filter((b) => u === b || u.startsWith(`${b}/`)).sort((x, y) => y.length - x.length)[0];
  return base === undefined ? null : { base, dir: sites[base] };
}

// sites: base path => built site folder, changeable with set(). csp: a Content-Security-Policy header for HTML; port: fixed
// for a tunnel (default: any free one). offline(true) destroys every socket, open or new: a service worker's fetch gets a
// network error, which a browser's own offline mode may not give it.
export async function serveSites(sites, { csp, port = 0 } = {}) {
  const map = { ...sites };
  const sockets = new Set();
  let down = false;
  const server = http.createServer((req, res) => {
    if (down) {
      return req.socket.destroy();
    }
    const u = decodeURIComponent(req.url.split("?")[0]);
    const site = siteFor(map, u);
    if (!site) {
      res.writeHead(404);
      return res.end();
    }
    let f = path.join(site.dir, u.slice(site.base.length));
    if (fs.existsSync(f) && fs.statSync(f).isDirectory()) {
      f = path.join(f, "index.html");
    }
    if (!fs.existsSync(f)) {
      res.writeHead(404);
      return res.end("404");
    }
    const headers = { "content-type": TYPES[path.extname(f)] || "application/octet-stream" };
    if (csp && path.extname(f) === ".html") {
      headers["content-security-policy"] = csp;
    }
    res.writeHead(200, headers);
    fs.createReadStream(f).pipe(res);
  });
  server.on("connection", (s) => {
    sockets.add(s);
    s.on("close", () => sockets.delete(s));
    if (down) {
      s.destroy();
    }
  });
  await new Promise((r) => server.listen(port, "127.0.0.1", r));
  const root = `http://127.0.0.1:${server.address().port}`;
  return {
    root,
    url: (base) => `${root}${base}/`,
    set: (base, dir) => {
      map[base] = dir;
    },
    offline: (on) => {
      down = on;
      if (on) {
        sockets.forEach((s) => s.destroy());
      }
    },
    close: () => {
      sockets.forEach((s) => s.destroy());
      server.close();
    },
  };
}

// Returns { origin, close } where origin ends with base + "/". base: the site's baseurl (a starter demo's is its
// repository name).
export async function serveSite(site, { csp, base = BASE } = {}) {
  const s = await serveSites({ [base]: site }, { csp });
  return { origin: s.url(base), close: s.close };
}
