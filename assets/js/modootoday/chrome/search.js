// Header search over /search.json. chrome/search-keys.js imports it on first use; matching is text/normalize.js.
import { normalize, squash, includesAll } from "../text/normalize.js";

const lang = (l) => l.toLowerCase().split("-")[0];

export function init(root) {
  const doc = root.ownerDocument || root;
  const win = doc.defaultView;
  const box = root.querySelector(".mt-search");
  if (!box || box.mtRender) {
    return;
  }
  const input = box.querySelector("input");
  const out = box.querySelector("ul");
  const cfg = box.dataset;
  const byTerms = cfg.match == "terms";
  const compact = cfg.compact != null;
  const max = +cfg.results || 8;
  const el = (t, c) => Object.assign(doc.createElement(t), { className: c || "" });
  const prep = (d) => {
    d.forEach((p) => {
      p.k = normalize(p.title + " " + p.text);
      p.f = compact && squash(p.k);
    });
    return d;
  };
  let data;
  const load = () => data || (data = win.fetch(cfg.index).then((r) => r.json()).then(prep).catch(() => []));
  // textarea decodes entities.
  const ta = el("textarea");
  const plain = (t) => {
    ta.innerHTML = t;
    return ta.value;
  };
  const show = (d, q) => {
    if (normalize(input.value.trim()) != q) {
      return;
    }
    const words = byTerms ? q.split(/\s+/) : [q];
    const fw = words.map(squash);
    // k, f (k without spaces): made once, at load.
    const match = (k, f) => includesAll(k, words) || (compact && includesAll(f, fw));
    let hits = d.filter((p) => match(p.k, p.f));
    // Page language, else site default, else all; title hits first.
    for (const l of [doc.documentElement.lang, cfg.lang]) {
      const same = hits.filter((p) => !l || !p.lang || lang(p.lang) == lang(l));
      if (same.length) {
        hits = same;
        break;
      }
    }
    hits.forEach((p) => {
      const t = normalize(p.title);
      p.t = match(t, squash(t));
    });
    hits.sort((a, b) => b.t - a.t).slice(0, max).forEach((p) => {
      const li = el("li");
      const a = el("a");
      const txt = plain(p.text).normalize("NFC");
      const i = txt.toLowerCase().indexOf(words[0]);
      a.href = p.url;
      a.append(Object.assign(el("span", "mt-search-title"), { textContent: p.title }));
      if (i > -1) {
        a.append(Object.assign(el("span", "mt-search-snippet"), { textContent: (i > 30 ? "…" : "") + txt.slice(Math.max(0, i - 30), i + 70).trim() + "…" }));
      }
      li.append(a);
      out.append(li);
    });
  };
  const render = (q) => {
    q = normalize(q.trim());
    out.textContent = "";
    if (q.length > 1) {
      load().then((d) => show(d, q));
    }
  };
  box.hidden = false;
  input.addEventListener("input", () => render(input.value));
  box.mtRender = render;
  load();
  // Text typed before this module arrived.
  if (input.value) {
    render(input.value);
  }
}

init(document);
