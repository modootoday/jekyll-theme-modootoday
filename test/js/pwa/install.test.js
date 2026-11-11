// jsdom tests for assets/js/modootoday/pwa/install.js with a synthetic beforeinstallprompt: the button shows only while the
// browser offers installing, prompts only on a click and hides after a choice or an install; the installed app hides
// the section. Run: npm test
const test = require("node:test");
const assert = require("node:assert");
const { JSDOM } = require("jsdom");
const { load } = require("../support/module.js");

const SECTION = '<section class="mt-section mt-c-install"><h2>Install</h2><p>Lead.</p>\n<button type="button" class="mt-install" hidden>Install</button>\n<p class="mt-install-hint">Hint.</p></section>';

async function page({ app = false, early = null } = {}) {
  const w = new JSDOM(`<!doctype html><html><head><link rel="manifest" href="/m.webmanifest"></head><body>${SECTION}</body></html>`, { url: "https://x.test/" }).window;
  w.matchMedia = (q) => ({ matches: app && q.includes("standalone") });
  if (early) {
    w.document.querySelector("link").mtInstall = early;
  }
  (await load("pwa/install.js")).init(w.document);
  return { w, button: w.document.querySelector(".mt-install"), section: w.document.querySelector(".mt-c-install") };
}

// A synthetic offer: prompts counts prompt() calls, choose() settles userChoice.
function offer(w, outcome = "dismissed") {
  const e = new w.Event("beforeinstallprompt", { cancelable: true });
  e.prompts = 0;
  e.prompt = async () => {
    e.prompts++;
  };
  e.userChoice = Promise.resolve({ outcome });
  return e;
}

const tick = () => new Promise((r) => setTimeout(r, 5));

test("the button stays hidden until the browser offers installing", async () => {
  const { w, button } = await page();
  assert.strictEqual(button.hidden, true);
  const e = offer(w);
  w.dispatchEvent(e);
  assert.strictEqual(button.hidden, false);
  assert.strictEqual(e.defaultPrevented, true, "no browser infobar of its own");
  assert.strictEqual(e.prompts, 0, "never prompts by itself");
});

test("a click prompts once, then the button hides and the hint takes focus", async () => {
  const { w, button } = await page();
  const e = offer(w);
  w.dispatchEvent(e);
  button.focus();
  button.click();
  button.click();
  await tick();
  assert.strictEqual(e.prompts, 1);
  assert.strictEqual(button.hidden, true);
  assert.strictEqual(w.document.activeElement.className, "mt-install-hint");
});

test("an install hides the button", async () => {
  const { w, button } = await page();
  w.dispatchEvent(offer(w));
  w.dispatchEvent(new w.Event("appinstalled"));
  assert.strictEqual(button.hidden, true);
});

test("an offer kept by register.js before the module ran shows the button", async () => {
  const { button } = await page({ early: { prompt: async () => {}, userChoice: Promise.resolve({}) } });
  assert.strictEqual(button.hidden, false);
});

test("inside the installed app the section hides and offers are ignored", async () => {
  const { w, button, section } = await page({ app: true });
  assert.strictEqual(section.hidden, true);
  w.dispatchEvent(offer(w));
  assert.strictEqual(button.hidden, true);
});
