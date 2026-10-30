// What the docs audit covers: widths, colour schemes, pages and size budgets.
import fs from "node:fs";
import path from "node:path";

export const WIDTHS = [360, 768, 1024, 1440];
export const SCHEMES = ["light", "dark"];
export const PAGES = ["", "guides/install/", "guides/first-page/", "components/", "components/kitchen-sink/", "guides/configuration/", "guides/customize/", "guides/agents/", "reference/changelog/", "tags/", "categories/", "blog/", "news/", "authors/modootoday/", "layouts/demo/minimal/", "layouts/demo/wide/", "layouts/demo/home/", "layouts/demo/error/", "layouts/demo/search/", "layouts/directory/", "layouts/directory/portfolio/", "layouts/directory/team/", "layouts/directory/jobs/", "layouts/directory/events/", "layouts/directory/sponsors/", "layouts/directory/integrations/", "layouts/detail/", "layouts/detail/project/", "layouts/detail/job/", "layouts/detail/event/", "layouts/detail/episode/", "layouts/marketing/", "layouts/marketing/feature/", "layouts/marketing/pricing/", "layouts/marketing/brand/", "layouts/marketing/links/", "layouts/marketing/contact/", "layouts/docs-extra/", "layouts/docs-extra/reference/", "layouts/docs-extra/changelog/", "layouts/docs-extra/roadmap/", "layouts/docs-extra/glossary/", "layouts/docs-extra/hub/", "layouts/docs-extra/course/", "layouts/docs-extra/book/", "layouts/documents/", "layouts/documents/legal/", "layouts/documents/resume/", "layouts/blog-news/", "layouts/blog-news/blog/", "layouts/blog-news/post/", "layouts/blog-news/news/", "layouts/blog-news/article/", "layouts/blog-news/archive/", "recipes/docs/"];
export const RTL_PAGES = ["components/kitchen-sink-rtl/"]; // English tree only: dir="rtl" mirroring checks
export const EN_ONLY = ["guides/2026/10/28/archives/", "layouts/demo/error-rtl/"]; // a sample post (post layout + footer term links); URLs differ per language
// Core (every page) and the optional blog/news bundle (post, blog, news, news-article, author and archive layouts only), budgeted apart.
export const BLOG_FILES = ["css/modootoday-blog.css", "js/modootoday/share.js"];
// css: core CSS one page links in total; js: all core scripts; blog-*: the blog bundle (docs site build, sass style: compressed)
export const BUDGET = { css: 32 * 1024, css_showcase: 48 * 1024, js: 10 * 1024, "blog-css": 8 * 1024, "blog-js": 1024, bundle: 8 * 1024, bundle_js: 2 * 1024 };
// Optional per-layout bundles css/modootoday-<name>.css (mt_bundle; not blog): each on BUDGET.bundle, never counted as core.
export const BUNDLE = /^css\/modootoday-(?!blog\.)([a-z0-9-]+)\.css$/;
// Optional renderer bundles js/modootoday-<name>.js (mermaid, math): loaded only on pages that need them, each on BUDGET.bundle_js, never counted as core.
export const BUNDLE_JS = /^js\/modootoday-([a-z0-9-]+)\.js$/;
// Per-sheet core CSS budgets (bytes). Section sheets under modootoday/showcase|structure/ share SECTION_SHEET.
export const SHEETS = { "css/modootoday.css": 24 * 1024, "css/modootoday/doc.css": 4 * 1024, "css/modootoday/search.css": 3 * 1024, "css/modootoday/loading.css": 2 * 1024, "css/modootoday/figure.css": 1024 };
export const SECTION_SHEET = 2 * 1024;
// Showcase pages that use every component on purpose get a larger per-page CSS budget (BUDGET.css_showcase).
export const SHOWCASE = /(^|\/)components\/(kitchen-sink(-rtl)?\/)?index\.html$/;
export const JOBS = Math.max(1, +process.env.QA_JOBS || 4); // pages checked concurrently per colour scheme
export const langsOf = (site) => ["", "ko/", "ja/"].filter((l) => fs.existsSync(path.join(site, l, "index.html")));
