// Search over /search.json; keys live in search-keys.js.
(() => {
  const box = document.querySelector(".mt-search"); if (!box) return;
  const input = box.querySelector("input"), out = box.querySelector("ul"), el = (t, c) => Object.assign(document.createElement(t), { className: c || "" });
  let data; box.hidden = false;
  const load = () => data || (data = fetch(box.dataset.index).then((r) => r.json()).catch(() => []));
  // textarea decodes entities.
  const ta = el("textarea"), plain = (t) => (ta.innerHTML = t, ta.value), lg = (l) => l.toLowerCase().split("-")[0];
  const render = (q) => {
    q = q.trim().toLowerCase(); out.textContent = "";
    if (q.length > 1) load().then((d) => {
      if (input.value.trim().toLowerCase() != q) return;
      // Page language, else site default, else all; title hits first.
      let hits = d.filter((p) => (p.title + " " + p.text).toLowerCase().includes(q));
      [document.documentElement.lang, box.dataset.lang].some((l) => {
        const same = hits.filter((p) => !l || !p.lang || lg(p.lang) == lg(l));
        if (same.length) return hits = same;
      });
      const inTitle = (p) => p.title.toLowerCase().includes(q);
      hits.sort((a, b) => inTitle(b) - inTitle(a)).slice(0, 8).forEach((p) => {
        const li = el("li"), a = el("a"), txt = plain(p.text), i = txt.toLowerCase().indexOf(q);
        a.href = p.url; a.append(Object.assign(el("span", "mt-search-title"), { textContent: p.title }));
        if (i > -1) a.append(Object.assign(el("span", "mt-search-snippet"), { textContent: (i > 30 ? "…" : "") + txt.slice(Math.max(0, i - 30), i + 70).trim() + "…" }));
        li.append(a); out.append(li);
      });
    });
  };
  input.addEventListener("focus", load);
  input.addEventListener("input", () => render(input.value));
  box.mtRender = render;
})();
