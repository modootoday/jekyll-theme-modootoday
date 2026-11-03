// List and table filter for [data-mt-filter] roots (filter: on a section or page, filter_text: on a directory).
// Liquid writes the controls hidden, so without JavaScript every item stays visible.
import { terms, matches } from "../text/normalize.js";
import { readConfig } from "../dom/config.js";
import { chips, cellText } from "./chips.js";

// Items hidden by something else (the directory's CSS facet) do not count as shown.
const shown = (r) => !r.hidden && (!r.checkVisibility || r.checkVisibility());

export function initFilter(root) {
  const box = root.querySelector(".mt-filter");
  const target = root.querySelector(":scope > ul, :scope > ol, :scope > table, :scope > .mt-table > table");
  if (!box || !target) {
    return;
  }
  const input = box.querySelector("input");
  const out = box.querySelector("output");
  const rows = [...target.querySelectorAll(":scope > li, :scope > tbody > tr")];
  const { facet } = readConfig(root, { facet: 0 });
  let chosen = null;
  const count = () => {
    out.textContent = out.dataset.count.replace("[n]", rows.filter(shown).length);
  };
  const apply = () => {
    const words = terms(input.value);
    rows.forEach((r) => {
      const inFacet = chosen == null || cellText(r, facet) == chosen;
      r.hidden = !(inFacet && matches(r.textContent, words, true));
    });
    count();
  };
  if (facet > 0 && target.tBodies) {
    box.append(chips(target, facet, rows, (value) => {
      chosen = value;
      apply();
    }));
  }
  input.addEventListener("input", apply);
  input.addEventListener("keydown", (e) => {
    if (e.key == "Escape" && input.value) {
      e.preventDefault();
      input.value = "";
      apply();
    }
  });
  root.addEventListener("change", (e) => {
    if (e.target != input) {
      count();
    }
  });
  // A table sits in its scroll wrapper; the controls go before the wrapper, outside the scrolling box.
  const outer = target.parentElement == root ? target : target.parentElement;
  outer.before(box);
  count();
  box.hidden = false;
}

document.querySelectorAll("[data-mt-filter]").forEach(initFilter);
