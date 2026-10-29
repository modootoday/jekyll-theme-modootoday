// What the docs audit covers: widths, colour schemes, pages and size budgets.
import fs from "node:fs";
import path from "node:path";

export const WIDTHS = [360, 768, 1024, 1440];
export const SCHEMES = ["light", "dark"];
export const PAGES = ["", "install/", "first-page/", "components/", "components/kitchen-sink/", "configuration/", "customize/", "agents/", "changelog/", "tags/", "categories/", "blog/", "news/", "authors/modootoday/"];
export const RTL_PAGES = ["components/kitchen-sink-rtl/"]; // English tree only: dir="rtl" mirroring checks
export const EN_ONLY = ["guides/2026/10/28/archives/"]; // a sample post (post layout + footer term links); URLs differ per language
// Core bundles (every page) and the optional blog/news bundle (post, blog, news, news-article and author layouts only), budgeted apart.
export const BLOG_FILES = ["css/modootoday-blog.css", "js/modootoday/share.js"];
export const BUDGET = { css: 32 * 1024, js: 10 * 1024, "blog-css": 8 * 1024, "blog-js": 1024 }; // as built by the docs site (sass style: compressed, as README recommends); gzip is reported
export const JOBS = Math.max(1, +process.env.QA_JOBS || 4); // pages checked concurrently per colour scheme
export const langsOf = (site) => ["", "ko/", "ja/"].filter((l) => fs.existsSync(path.join(site, l, "index.html")));
