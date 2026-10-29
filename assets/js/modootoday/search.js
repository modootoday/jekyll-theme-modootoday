// jekyll-theme-modootoday — client search over /search.json [{title,url,text,lang}].
// Keys: "/" or Ctrl/Cmd+K focus the box, Down/Up move through results, Esc clears (from a result: back to the box).
(() => {
  const box = document.querySelector(".mt-search"); if (!box) return;
  const input = box.querySelector("input"), out = box.querySelector("ul"), el = (t, c) => Object.assign(document.createElement(t), { className: c || "" });
  let data;
  const load = () => data || (data = fetch(box.dataset.index).then((r) => r.json()).catch(() => []));
  // The index text is HTML-escaped (strip_html keeps entities); a detached textarea decodes it.
  const ta = el("textarea"), plain = (t) => (ta.innerHTML = t, ta.value), lg = (l) => l.toLowerCase().split("-")[0];
  const render = (q) => {
    q = q.trim().toLowerCase(); out.textContent = "";
    if (q.length > 1) load().then((d) => {
      if (input.value.trim().toLowerCase() != q) return;
      // This page's language, else the site default, else all; title hits first.
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
  box.addEventListener("keydown", (e) => {
    const links = [...out.querySelectorAll("a")], i = links.indexOf(document.activeElement), k = e.key;
    if (k == "Escape") { e.preventDefault(); if (i > -1) input.focus(); else render(input.value = ""); }
    else if ((k == "ArrowDown" || k == "ArrowUp") && links.length) {
      e.preventDefault();
      const n = k == "ArrowDown" ? Math.min(i + 1, links.length - 1) : i - 1;
      (n < 0 ? input : links[n]).focus();
    }
  });
  document.addEventListener("keydown", (e) => {
    const t = e.target, typing = t.isContentEditable || /^(INPUT|TEXTAREA|SELECT)$/.test(t.tagName), mod = e.ctrlKey || e.metaKey;
    if ((e.key == "/" && !typing && !mod && !e.altKey) || (mod && e.key.toLowerCase() == "k")) { e.preventDefault(); input.focus(); input.select(); }
  });
})();
