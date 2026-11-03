// Search over /search.json; keys in search-keys.js. Classic script: the rules of text/normalize.js, tested together.
(() => {
  const box = document.querySelector(".mt-search");
  if (!box) {
    return;
  }
  const input = box.querySelector("input");
  const out = box.querySelector("ul");
  const cfg = box.dataset;
  const byTerms = cfg.match == "terms";
  const compact = cfg.compact != null;
  const max = +cfg.results || 8;
  const el = (t, c) => Object.assign(document.createElement(t), { className: c || "" });
  const norm = (t) => t.normalize("NFC").toLowerCase();
  const flat = (t) => t.replace(/\s+/g, "");
  const found = (hay, words) => words.every((w) => hay.includes(w));
  const prep = (d) => {
    d.forEach((p) => {
      p.k = norm(p.title + " " + p.text);
      p.f = compact && flat(p.k);
    });
    return d;
  };
  let data;
  box.hidden = false;
  const load = () => data || (data = fetch(cfg.index).then((r) => r.json()).then(prep).catch(() => []));
  // textarea decodes entities.
  const ta = el("textarea");
  const plain = (t) => {
    ta.innerHTML = t;
    return ta.value;
  };
  const lg = (l) => l.toLowerCase().split("-")[0];
  const show = (d, q) => {
    if (norm(input.value.trim()) != q) {
      return;
    }
    const words = byTerms ? q.split(/\s+/) : [q];
    const fw = words.map(flat);
    // k, f (k without spaces): made once, at load.
    const match = (k, f) => found(k, words) || (compact && found(f, fw));
    let hits = d.filter((p) => match(p.k, p.f));
    // Page language, else site default, else all; title hits first.
    for (const l of [document.documentElement.lang, cfg.lang]) {
      const same = hits.filter((p) => !l || !p.lang || lg(p.lang) == lg(l));
      if (same.length) {
        hits = same;
        break;
      }
    }
    hits.forEach((p) => {
      const t = norm(p.title);
      p.t = match(t, flat(t));
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
    q = norm(q.trim());
    out.textContent = "";
    if (q.length > 1) {
      load().then((d) => show(d, q));
    }
  };
  input.addEventListener("focus", load);
  input.addEventListener("input", () => render(input.value));
  box.mtRender = render;
})();
