// Showcase dismiss: hidden for the visit in this tab (theme-init.js reads the flag before the next paint).
export function init(root) {
  const doc = root.ownerDocument || root;
  for (const b of root.querySelectorAll(".mt-showcase-dismiss")) {
    b.addEventListener("click", () => {
      doc.documentElement.dataset.mtShowcase = "off";
      try {
        doc.defaultView.sessionStorage.setItem("mt-showcase", "off");
      } catch (e) {}
      doc.querySelector(".mt-skip")?.focus();
    });
  }
}

init(document);
