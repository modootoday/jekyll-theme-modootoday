// jekyll-theme-modootoday — post share button: native share sheet where available, else copy the link.
(function () {
  document.querySelectorAll("[data-mt-share]").forEach(function (b) {
    var url = b.dataset.url || location.href, status = b.parentNode.querySelector("[role=status]");
    if (!navigator.share && !navigator.clipboard) return;
    b.hidden = false;
    b.addEventListener("click", function () {
      if (navigator.share) { navigator.share({ title: b.dataset.title, url: url }).catch(function () {}); return; }
      navigator.clipboard.writeText(url).then(function () {
        if (status) status.textContent = b.dataset.copied;
        b.dataset.state = "copied";
        setTimeout(function () { b.dataset.state = ""; if (status) status.textContent = ""; }, 2000);
      });
    });
  });
})();
