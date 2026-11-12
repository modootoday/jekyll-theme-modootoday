// "On this page": the link of the section being read gets aria-current="location" (adr:modootoday/20261110172642).
// Observers only wake it; one frame then reads the heading positions. It never scrolls the page.
const decode = (s) => {
  try {
    return decodeURIComponent(s);
  } catch (e) {
    return s;
  }
};
const idOf = (a) => decode(a.getAttribute("href").slice(1));

// Per list, the link that marks each heading: the sticky column hides h3, so there an h3 marks its h2.
function links(list) {
  const column = !!list.closest(".mt-doc-aside");
  const map = new Map();
  let h2;
  for (const a of list.querySelectorAll("li > a[href^='#']")) {
    const h3 = a.parentNode.classList.contains("mt-toc-h3");
    h2 = h3 ? h2 : a;
    map.set(idOf(a), (column && h3 && h2) || a);
  }
  return { list, column, map };
}

export function init(root) {
  const doc = root.ownerDocument || root;
  const win = doc.defaultView;
  const html = doc.documentElement;
  const lists = [...root.querySelectorAll(".mt-toc, .mt-toc-mobile")].map(links);
  if (!lists.length || !win.IntersectionObserver) {
    return;
  }
  const ids = new Set(lists.flatMap((l) => [...l.map.keys()]));
  const heads = [...ids].map((id) => [id, doc.getElementById(id)]).filter((h) => h[1]);
  const top = (i) => heads[i][1].getBoundingClientRect().top;
  let current;
  let pin = -1;
  let queued;
  const line = () => {
    const header = doc.querySelector(".mt-header");
    const rem = parseFloat(win.getComputedStyle(html).fontSize) || 16;
    return Math.max(0, header ? header.getBoundingClientRect().bottom : 0) + rem;
  };
  const mark = (i) => {
    const id = i < 0 ? null : heads[i][0];
    if (id === current) {
      return;
    }
    current = id;
    for (const { list, column, map } of lists) {
      list.querySelectorAll("[aria-current]").forEach((a) => a.removeAttribute("aria-current"));
      const a = map.get(id);
      if (a) {
        a.setAttribute("aria-current", "location");
      }
      // The column scrolls on its own; the marked link is kept inside its visible part, without smooth scrolling.
      if (a && column) {
        const r = a.getBoundingClientRect();
        const b = list.getBoundingClientRect();
        list.scrollTop += Math.min(0, r.top - b.top) || Math.max(0, r.bottom - b.bottom);
      }
    }
  };
  const update = () => {
    queued = false;
    const y = line() + 1;
    const view = win.innerHeight;
    const bottom = view + win.scrollY >= html.scrollHeight - 2;
    let at = -1;
    heads.forEach((h, i) => {
      // A heading with no box (in a closed tab panel) reports a top of 0 and would read as already passed.
      if (!h[1].getClientRects().length) {
        return;
      }
      if (top(i) <= y || (bottom && win.scrollY > 0 && top(i) < view)) {
        at = i;
      }
    });
    // A followed link the page cannot bring up to the line (a short last section) stays marked while it is in view.
    if (pin >= 0 && bottom && top(pin) >= 0 && top(pin) < view) {
      at = pin;
    } else {
      pin = -1;
    }
    mark(at);
  };
  const wake = () => {
    if (!queued) {
      queued = true;
      win.requestAnimationFrame(update);
    }
  };
  const jump = (id) => {
    const i = heads.findIndex((h) => h[0] === id);
    if (i >= 0) {
      pin = i;
      mark(i);
    }
    wake();
  };
  const io = new win.IntersectionObserver(wake, { rootMargin: `-${Math.round(line())}px 0px 0px 0px`, threshold: [0, 1] });
  heads.forEach((h) => io.observe(h[1]));
  const foot = doc.querySelector(".mt-footer");
  if (foot) {
    io.observe(foot);
  }
  for (const { list } of lists) {
    list.addEventListener("click", (e) => {
      const a = e.target.closest("a[href^='#']");
      if (a) {
        jump(idOf(a));
      }
    });
  }
  const hash = () => jump(decode(win.location.hash.slice(1)));
  win.addEventListener("hashchange", hash);
  win.addEventListener("scrollend", wake);
  hash();
}

init(document);
