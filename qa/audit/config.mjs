// What the docs audit covers: widths, colour schemes, pages and size budgets.
import fs from "node:fs";
import path from "node:path";

export const WIDTHS = [360, 768, 1024, 1440];
export const SCHEMES = ["light", "dark"];
export const PAGES = ["", "guides/install/", "guides/first-page/", "components/", "components/kitchen-sink/", "guides/configuration/", "guides/customize/", "guides/agents/", "reference/changelog/", "tags/", "categories/", "blog/", "news/", "authors/modootoday/", "layouts/demo/minimal/", "layouts/demo/wide/", "layouts/demo/home/", "layouts/demo/error/", "layouts/demo/search/", "layouts/directory/", "layouts/directory/portfolio/", "layouts/directory/team/", "layouts/directory/jobs/", "layouts/directory/events/", "layouts/directory/sponsors/", "layouts/directory/integrations/", "layouts/detail/", "layouts/detail/project/", "layouts/detail/job/", "layouts/detail/event/", "layouts/detail/episode/", "layouts/marketing/", "layouts/marketing/feature/", "layouts/marketing/pricing/", "layouts/marketing/brand/", "layouts/marketing/links/", "layouts/marketing/contact/", "layouts/docs-extra/", "layouts/docs-extra/reference/", "layouts/docs-extra/changelog/", "layouts/docs-extra/roadmap/", "layouts/docs-extra/glossary/", "layouts/docs-extra/hub/", "layouts/docs-extra/course/", "layouts/docs-extra/book/", "layouts/docs-extra/api/", "layouts/documents/", "layouts/documents/legal/", "layouts/documents/resume/", "layouts/blog-news/", "layouts/blog-news/blog/", "layouts/blog-news/post/", "layouts/blog-news/news/", "layouts/blog-news/article/", "layouts/blog-news/archive/", "recipes/docs/", "recipes/brand-tokens/", "layouts/demo/code-github/", "layouts/demo/orbit/"];
export const RTL_PAGES = ["components/kitchen-sink-rtl/"]; // English tree only: dir="rtl" mirroring checks
export const EN_ONLY = ["guides/2026/10/28/archives/", "layouts/demo/error-rtl/"]; // a sample post (post layout + footer term links); URLs differ per language
// Core (every page) and the optional blog/news bundle (post, blog, news, news-article, author and archive layouts only), budgeted apart.
export const BLOG_FILES = ["css/modootoday-blog.css", "js/modootoday/share.js"];
// css: core CSS one page links in total; js_total: all core scripts, gzip bytes; blog-*: the blog bundle (docs site build, sass style: compressed)
// css_showcase: 53 KiB (was 48, ~+10%): showcase pages (components index, kitchen-sink) link every optional sheet, and the kitchen sink also shows chrome: terminal.
export const BUDGET = { css: 35 * 1024, css_showcase: 53 * 1024, js_total: 7 * 1024, "blog-css": 8 * 1024, "blog-js": 1024, bundle: 8 * 1024, bundle_js: 2.5 * 1024 };
// Per page type: gzip bytes of what one page actually loads (stylesheets, scripts and their module imports). Limits: the largest
// page of the type, docs site built by the Pages builder, plus 10% rounded up to 0.25 KiB (js_total likewise: 6432 B measured, with the module helpers).
export const PAGE_TYPES = {
  doc: { pages: ["guides/configuration/", "guides/install/", "recipes/csp/"], css: 9.75 * 1024, js: 5.25 * 1024 },
  landing: { pages: ["", "layouts/demo/home/", "layouts/marketing/"], css: 11.5 * 1024, js: 5.25 * 1024 },
  blog: { pages: ["blog/", "guides/2026/10/28/archives/"], css: 11 * 1024, js: 4.25 * 1024 },
  showcase: { pages: ["components/", "components/kitchen-sink/", "layouts/demo/csp/"], css: 18.25 * 1024, js: 5.75 * 1024 },
  // A doc page with a script: visual: its site module and the theme helpers it imports (measured 9444 / 6120 B).
  visual: { pages: ["layouts/demo/orbit/"], css: 10.25 * 1024, js: 6.75 * 1024 },
};
// Pages the CSP audit (csp.mjs) opens under a strict Content-Security-Policy header; a feature with a demo page adds it here.
// The kitchen sink stays out: it embeds a third-party frame and aligned table columns (kramdown writes style attributes).
export const CSP_PAGES = ["layouts/demo/csp/", "", "guides/configuration/", "blog/", "layouts/demo/search/", "recipes/brand-tokens/", "layouts/demo/code-github/", "layouts/demo/orbit/"];
// Pages whose token palette the contrast check (contrast.mjs) measures in each scheme: the theme default, the brand tokens recipe
// and the GitHub code colours (code_theme: github).
export const CONTRAST_PAGES = ["", "recipes/brand-tokens/", "layouts/demo/code-github/"];
export const CSP = "default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self' data:; worker-src 'self'; manifest-src 'self'";
// Optional per-layout bundles css/modootoday-<name>.css (mt_bundle; not blog): each on BUDGET.bundle, never counted as core.
export const BUNDLE = /^css\/modootoday-(?!blog\.)([a-z0-9-]+)\.css$/;
// Optional renderer bundles js/modootoday-<name>.js (mermaid, math): loaded only on pages that need them, each on BUDGET.bundle_js, never counted as core.
export const BUNDLE_JS = /^js\/modootoday-([a-z0-9-]+)\.js$/;
// Per-sheet core CSS budgets (bytes). Limits leave some headroom (raised about 10%); keep the built sizes minimal. Section sheets under modootoday/showcase|structure/ share SECTION_SHEET.
export const SHEETS = { "css/modootoday.css": 27 * 1024, "css/modootoday/doc.css": 4 * 1024, "css/modootoday/search.css": 3 * 1024, "css/modootoday/loading.css": 2.5 * 1024, "css/modootoday/figure.css": 1.25 * 1024, "css/modootoday/lists.css": 1.25 * 1024, "css/modootoday/bleed.css": 1 * 1024 , "css/modootoday/terminal.css": 1024, "css/modootoday/visual.css": 1024};
export const SECTION_SHEET = 2 * 1024;
// Showcase pages that use every component on purpose get a larger per-page CSS budget (BUDGET.css_showcase): the components
// index, the kitchen sinks and the strict CSP demo.
export const SHOWCASE = /(^|\/)(components\/(kitchen-sink(-rtl)?\/)?|layouts\/demo\/csp\/)index\.html$/;
export const JOBS = Math.max(1, +process.env.QA_JOBS || 4); // pages checked concurrently per colour scheme
export const langsOf = (site) => ["", "ko/", "ja/"].filter((l) => fs.existsSync(path.join(site, l, "index.html")));
