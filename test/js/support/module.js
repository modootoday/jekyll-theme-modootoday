// Loads a theme ES module (assets/js/modootoday/<rel>) for a jsdom test. It is imported once, so its own init(document)
// runs on an empty page; run() then calls init on the test's document, which gives the module that window's globals.
const path = require("node:path");
const { pathToFileURL } = require("node:url");
const { JSDOM } = require("jsdom");

const JS = path.join(__dirname, "../../../assets/js/modootoday");
const modules = new Map();

function load(rel) {
  if (!modules.has(rel)) {
    globalThis.document ??= new JSDOM("<!doctype html><html><body></body></html>").window.document;
    modules.set(rel, import(pathToFileURL(path.join(JS, rel)).href));
  }
  return modules.get(rel);
}

async function run(rel, window) {
  const mod = await load(rel);
  mod.init(window.document);
  return mod;
}

module.exports = { JS, load, run };
