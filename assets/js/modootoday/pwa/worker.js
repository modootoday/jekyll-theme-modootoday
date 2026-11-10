// Service worker strategies; the site's sw.js sets self.MT_PWA (docs: recipes/pwa).
((sw) => {
  const C = sw.MT_PWA;
  const prefix = "mt:" + C.scope + ":";
  const ASSETS = prefix + "assets:" + C.assets;
  // Pages follow the theme files, not the build: a deploy that keeps them keeps what a reader saved for offline.
  const PAGES = prefix + "pages:" + C.assets;
  const MEDIA = prefix + "media";
  const THEME = new RegExp("^" + C.scope + "assets/(css|js)/modootoday");
  const NETWORK = /(\.md|\/llms[^/]*\.txt|\/feed[^/]*\.xml|\/sitemap\.xml|\.webmanifest|\/sw\.js)$/;
  const MEDIA_FILE = /\.(png|jpe?g|gif|webp|avif|svg|ico|woff2?|ttf|otf)$/;
  const pinned = C.precache.map((u) => new URL(u, sw.location).href);
  const noop = () => {};

  const kind = (req) => {
    const url = new URL(req.url);
    const path = url.pathname;
    if (req.method != "GET" || url.origin != sw.location.origin || !path.startsWith(C.scope) || req.headers.has("range")) {
      return "";
    }
    if (THEME.test(path)) {
      return "assets";
    }
    if (NETWORK.test(path)) {
      return "";
    }
    if (req.mode == "navigate" || /\/$|\.html$/.test(path)) {
      return "page";
    }
    if (path == C.scope + "search.json") {
      return "search";
    }
    return req.destination == "image" || req.destination == "font" || MEDIA_FILE.test(path) ? "media" : "site";
  };
  const bucket = (k) => (k == "assets" ? ASSETS : k == "media" ? MEDIA : PAGES);
  const ok = (res) => res && res.ok && !res.redirected;
  const cached = async (name, req) => (await caches.open(name)).match(req);

  // Re-putting moves an entry last, so trimming the first keeps the recently used.
  const put = async (name, req, res, max) => {
    const cache = await caches.open(name);
    await cache.delete(req);
    await cache.put(req, res);
    const old = (await cache.keys()).filter((k) => !pinned.includes(k.url));
    for (const k of old.slice(0, max ? Math.max(0, old.length - max) : 0)) {
      await cache.delete(k);
    }
  };

  const store = async (k, req) => {
    const res = await fetch(req);
    if (!ok(res)) {
      throw new Error(req.url);
    }
    await put(bucket(k), req, res);
  };

  const offline = (url) => {
    const path = new URL(url).pathname;
    const best = Object.keys(C.offline).filter((p) => path.startsWith(p)).sort((a, b) => b.length - a.length)[0];
    return cached(PAGES, C.offline[best]);
  };

  const fresh = async (e, k) => {
    const req = e.request;
    const nav = req.mode == "navigate";
    let res;
    try {
      res = (nav && (await e.preloadResponse)) || (await fetch(req));
    } catch (err) {
      const copy = await cached(PAGES, req);
      if (copy || !nav) {
        return copy || Promise.reject(err);
      }
      return offline(req.url);
    }
    if (ok(res)) {
      e.waitUntil(put(PAGES, req, res.clone(), k == "page" ? 50 : 0).catch(noop));
    } else if (res.status >= 500) {
      return (await cached(PAGES, req)) || res;
    }
    return res;
  };

  const kept = async (e, k) => {
    const req = e.request;
    const name = bucket(k);
    const copy = await cached(name, req);
    if (copy && k == "assets") {
      return copy;
    }
    const net = fetch(req).then((res) => {
      if (ok(res)) {
        e.waitUntil(put(name, req, res.clone(), k == "media" ? 60 : 0).catch(noop));
      }
      return res;
    });
    e.waitUntil(net.catch(noop));
    return copy || net;
  };

  // Only a missing offline page fails the install.
  sw.addEventListener("install", (e) => {
    const pages = Object.values(C.offline);
    e.waitUntil(Promise.all(C.precache.map((u) => {
      const req = new Request(u, { cache: "reload" });
      const done = store(kind(req) || "page", req);
      return pages.includes(u) ? done : done.catch(noop);
    })));
  });

  sw.addEventListener("activate", (e) => {
    const keep = [ASSETS, PAGES, MEDIA];
    const drop = async () => {
      for (const n of await caches.keys()) {
        if (n.startsWith(prefix) && !keep.includes(n)) {
          await caches.delete(n);
        }
      }
      await (sw.registration.navigationPreload && sw.registration.navigationPreload.enable());
      await sw.clients.claim();
    };
    e.waitUntil(drop());
  });

  sw.addEventListener("fetch", (e) => {
    try {
      const k = kind(e.request);
      if (k) {
        e.respondWith((k == "page" || k == "site" ? fresh(e, k) : kept(e, k)).catch(() => fetch(e.request)));
      }
    } catch (err) {}
  });

  // URLs the first, uncontrolled page loaded (register.js), so an offline start is styled.
  sw.addEventListener("message", (e) => {
    const urls = e.data && e.data.type == "mt:warm" && Array.isArray(e.data.urls) ? e.data.urls : [];
    e.waitUntil(Promise.all(urls.map((u) => {
      const req = new Request(u);
      const k = kind(req);
      return k ? store(k, req).catch(noop) : 0;
    })));
  });
})(self);
