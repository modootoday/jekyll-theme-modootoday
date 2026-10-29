// jekyll-theme-modootoday — tiny client search over /search.json [{title,url,text}].
(function () {
  var box = document.querySelector(".mt-search"); if (!box) return;
  var input = box.querySelector("input"), out = box.querySelector("ul"), data = null;
  box.hidden = false;
  function load() {
    if (!data) data = fetch(box.getAttribute("data-index")).then(function (r) { return r.json(); }).catch(function () { return []; });
    return data;
  }
  // The index text is HTML-escaped (strip_html keeps entities); decode the common ones for display.
  function plain(t) { return t.replace(/&lt;/g, "<").replace(/&gt;/g, ">").replace(/&quot;/g, '"').replace(/&#39;/g, "'").replace(/&amp;/g, "&"); }
  function lg(l) { return l.toLowerCase().split("-")[0]; }
  function render(q) {
    q = q.trim().toLowerCase(); out.textContent = "";
    if (q.length < 2) return;
    load().then(function (d) {
      if (input.value.trim().toLowerCase() !== q) return;
      // This page's language, else the site default, else all; title hits first.
      var hits = d.filter(function (p) { return (p.title + " " + p.text).toLowerCase().indexOf(q) > -1; });
      [document.documentElement.lang, box.getAttribute("data-lang")].some(function (l) {
        var same = hits.filter(function (p) { return !l || !p.lang || lg(p.lang) === lg(l); });
        if (same.length) return hits = same;
      });
      hits.sort(function (a, b) { return (b.title.toLowerCase().indexOf(q) > -1) - (a.title.toLowerCase().indexOf(q) > -1); });
      hits.slice(0, 8).forEach(function (p) {
        var li = document.createElement("li"), a = document.createElement("a"), t = document.createElement("span");
        a.href = p.url; t.className = "mt-search-title"; t.textContent = p.title; a.appendChild(t);
        var txt = plain(p.text), i = txt.toLowerCase().indexOf(q);
        if (i > -1) {
          var s = document.createElement("span"); s.className = "mt-search-snippet";
          s.textContent = (i > 30 ? "…" : "") + txt.slice(Math.max(0, i - 30), i + 70).trim() + "…"; a.appendChild(s);
        }
        li.appendChild(a); out.appendChild(li);
      });
    });
  }
  input.addEventListener("focus", load);
  input.addEventListener("input", function () { render(input.value); });
  input.addEventListener("keydown", function (e) { if (e.key === "Escape") { input.value = ""; out.textContent = ""; } });
})();
