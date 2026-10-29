// jekyll-theme-modootoday — tiny client search over /search.json [{title,url,text}].
(function () {
  var box = document.querySelector(".mt-search"); if (!box) return;
  var input = box.querySelector("input"), out = box.querySelector("ul"), data = null;
  box.hidden = false;
  function load() {
    if (!data) data = fetch(box.getAttribute("data-index")).then(function (r) { return r.json(); }).catch(function () { return []; });
    return data;
  }
  function render(q) {
    q = q.trim().toLowerCase(); out.textContent = "";
    if (q.length < 2) return;
    load().then(function (d) {
      if (input.value.trim().toLowerCase() !== q) return;
      d.filter(function (p) { return (p.title + " " + p.text).toLowerCase().indexOf(q) > -1; }).slice(0, 8).forEach(function (p) {
        var li = document.createElement("li"), a = document.createElement("a");
        a.href = p.url; a.textContent = p.title; li.appendChild(a); out.appendChild(li);
      });
    });
  }
  input.addEventListener("focus", load);
  input.addEventListener("input", function () { render(input.value); });
  input.addEventListener("keydown", function (e) { if (e.key === "Escape") { input.value = ""; out.textContent = ""; } });
})();
