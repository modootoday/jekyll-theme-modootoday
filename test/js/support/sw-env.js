// A service worker global for node tests of assets/js/modootoday/pwa/worker.js and the inline kill worker of
// _includes/modootoday/pwa/sw.js: listeners, Cache Storage in memory, a scripted fetch and window clients.
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");

const ROOT = path.join(__dirname, "../../..");
const ORIGIN = "https://x.test";

class FakeCache {
  constructor() {
    this.map = new Map();
  }
  key(req) {
    return new URL(typeof req == "string" ? req : req.url, ORIGIN).href;
  }
  async match(req) {
    const res = this.map.get(this.key(req));
    return res ? res.clone() : undefined;
  }
  async put(req, res) {
    this.map.set(this.key(req), res);
  }
  async delete(req) {
    return this.map.delete(this.key(req));
  }
  async keys() {
    return [...this.map.keys()].map((url) => ({ url }));
  }
}

class FakeCaches {
  constructor() {
    this.map = new Map();
  }
  async open(name) {
    if (!this.map.has(name)) {
      this.map.set(name, new FakeCache());
    }
    return this.map.get(name);
  }
  async keys() {
    return [...this.map.keys()];
  }
  async delete(name) {
    return this.map.delete(name);
  }
  async has(name) {
    return this.map.has(name);
  }
  urls(name) {
    return this.map.has(name) ? [...this.map.get(name).map.keys()].map((u) => u.slice(ORIGIN.length)) : [];
  }
}

// A worker resolves a relative request URL against its own location.
class WorkerRequest extends Request {
  constructor(url, init) {
    super(typeof url == "string" ? new URL(url, ORIGIN).href : url, init);
  }
}

// A request as the fetch event carries it; navigations are plain objects since node cannot build mode "navigate".
function request(url, init = {}) {
  const abs = new URL(url, ORIGIN).href;
  if (init.mode == "navigate") {
    return { url: abs, method: "GET", mode: "navigate", destination: "document", headers: new Headers(init.headers) };
  }
  return new Request(abs, init);
}

// net(url, req) returns a Response or throws (a network error); every call is kept in fetched.
function env({ scope = "/docs/", constants = {}, net = () => new Response("ok"), script } = {}) {
  const listeners = {};
  const fetched = [];
  const navigated = [];
  const state = { preload: false, claimed: false, unregistered: false, net };
  const caches = new FakeCaches();
  const self = {
    location: new URL(scope + "sw.js", ORIGIN),
    registration: {
      navigationPreload: { enable: async () => { state.preload = true; } },
      unregister: async () => {
        state.unregistered = true;
        return true;
      },
    },
    clients: {
      claim: async () => { state.claimed = true; },
      matchAll: async () => [{ url: ORIGIN + scope + "a/", navigate: async (u) => navigated.push(u) }],
    },
    skipWaiting: () => { state.skipped = true; },
    addEventListener: (type, fn) => { listeners[type] = fn; },
    MT_PWA: { scope, build: "1.7.0-abc1234", assets: "1.7.0", precache: [], offline: { [scope]: scope + "offline/" }, ...constants },
  };
  const doFetch = async (req) => {
    const url = typeof req == "string" ? new URL(req, ORIGIN).href : req.url;
    fetched.push(url.slice(ORIGIN.length));
    return state.net(url.slice(ORIGIN.length), req);
  };
  const ctx = vm.createContext({ self, caches, fetch: doFetch, Request: WorkerRequest, Response, Headers, URL, console });
  vm.runInContext(script || fs.readFileSync(path.join(ROOT, "assets/js/modootoday/pwa/worker.js"), "utf8"), ctx);

  // Runs one event; resolves with what respondWith got (null when the worker left the request alone) after every waitUntil.
  async function dispatch(type, props = {}) {
    let answer = null;
    const waits = [];
    const e = { ...props, respondWith: (p) => { answer = p; }, waitUntil: (p) => waits.push(Promise.resolve(p)) };
    listeners[type](e);
    const res = answer ? await answer : null;
    for (let i = 0; i < waits.length; i++) {
      await waits[i];
    }
    return res;
  }

  const go = (url, init = {}, preload) => dispatch("fetch", { request: request(url, init), preloadResponse: Promise.resolve(preload) });
  return { self, caches, fetched, navigated, state, dispatch, go, listeners };
}

module.exports = { ORIGIN, ROOT, env, request };
