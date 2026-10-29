// jekyll-theme-modootoday — accordion (APG disclosure pattern) for sections with `c: accordion`.
// Without JS the questions and answers stay plain headings and paragraphs.
(function () {
  var n = 0;
  document.querySelectorAll('[data-c="accordion"]').forEach(function (sec) {
    sec.querySelectorAll(":scope > h3").forEach(function (h) {
      var id = "mt-acc-" + (++n), panel = document.createElement("div");
      panel.className = "mt-accordion-panel"; panel.id = id; panel.hidden = true;
      while (h.nextSibling && !(h.nextSibling.nodeType === 1 && /^H[23]$/.test(h.nextSibling.tagName))) panel.append(h.nextSibling);
      h.after(panel);
      var b = document.createElement("button");
      b.type = "button"; b.className = "mt-accordion-trigger";
      b.setAttribute("aria-expanded", "false"); b.setAttribute("aria-controls", id);
      while (h.firstChild) b.append(h.firstChild);
      h.append(b);
      b.addEventListener("click", function () {
        var open = b.getAttribute("aria-expanded") !== "true";
        b.setAttribute("aria-expanded", String(open)); panel.hidden = !open;
      });
    });
  });
})();
