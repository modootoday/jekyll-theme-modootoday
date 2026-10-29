// Serves a built docs site at the Pages baseurl on a random local port (shared by the audit and visual checks).
import http from "node:http";
import fs from "node:fs";
import path from "node:path";

export const BASE = "/jekyll-theme-modootoday";
const TYPES = { ".html": "text/html; charset=utf-8", ".css": "text/css", ".js": "text/javascript", ".txt": "text/plain; charset=utf-8", ".md": "text/markdown; charset=utf-8", ".svg": "image/svg+xml", ".png": "image/png", ".json": "application/json" };

// Returns { origin, close } where origin ends with BASE + "/".
export async function serveSite(site) {
  const server = http.createServer((req, res) => {
    const u = decodeURIComponent(req.url.split("?")[0]);
    if (!u.startsWith(BASE)) { res.writeHead(404); return res.end(); }
    let f = path.join(site, u.slice(BASE.length));
    if (fs.existsSync(f) && fs.statSync(f).isDirectory()) f = path.join(f, "index.html");
    if (!fs.existsSync(f)) { res.writeHead(404); return res.end("404"); }
    res.writeHead(200, { "content-type": TYPES[path.extname(f)] || "application/octet-stream" });
    fs.createReadStream(f).pipe(res);
  });
  await new Promise((r) => server.listen(0, "127.0.0.1", r));
  return { origin: `http://127.0.0.1:${server.address().port}${BASE}/`, close: () => server.close() };
}
