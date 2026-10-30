// Optional Mermaid bundle (site.modootoday.mermaid): renders ```mermaid fences with the Mermaid script loaded before it.
// The fence stays as the fallback (hidden once its SVG is drawn; kept on a parse error). Theme follows the page.
(() => {
  const m = window.mermaid, me = document.currentScript, root = document.documentElement;
  if (!m || !me) return;
  const mq = matchMedia("(prefers-color-scheme: dark)"), still = matchMedia("(prefers-reduced-motion: reduce)").matches;
  const items = [...document.querySelectorAll(".mt-main code.language-mermaid")].map((code) => ({ box: code.closest("div.highlighter-rouge") || code.closest("pre") || code, src: code.textContent }));
  if (!items.length) return;
  const pick = () => {
    const t = me.dataset.mtTheme;
    if (t && t != "auto") return t;
    const d = root.dataset.theme;
    return (d ? d == "dark" : mq.matches) ? "dark" : "default";
  };
  let theme, n = 0;
  const draw = () => {
    const t = pick();
    if (t == theme) return;
    theme = t;
    m.initialize({ startOnLoad: false, securityLevel: "strict", theme: t, themeCSS: still ? "*{animation:none!important;transition:none!important}" : "" });
    items.forEach((it) => m.render("mt-mermaid-" + n++, it.src).then(({ svg }) => {
      let f = it.fig;
      if (!f) {
        f = it.fig = document.createElement("div");
        f.className = "mt-mermaid";
        f.style.overflowX = "auto";
        it.box.before(f);
        it.box.hidden = true;
      }
      f.innerHTML = svg;
      if (f.scrollWidth > f.clientWidth + 1) {
        f.tabIndex = 0; f.role = "region"; f.ariaLabel = root.dataset.mtDiagram || "Diagram";
      }
    }, () => {}));
  };
  draw();
  new MutationObserver(draw).observe(root, { attributes: true, attributeFilter: ["data-theme"] });
  if (mq.addEventListener) mq.addEventListener("change", draw);
})();
