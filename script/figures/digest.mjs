// The data-mt-src rule of lib/modootoday/figures.rb, which owns it; test/fixtures/figures/digests.json keeps the two equal.
// Usage: node script/figures/digest.mjs [FILE]   prints the digest of a fence body (stdin without FILE)
import { createHash } from "node:crypto";
import { readFileSync } from "node:fs";
import { pathToFileURL } from "node:url";

export function digest(body) {
  const text = body.replace(/\r\n?/g, "\n").replace(/\n+$/, "");
  const hex = createHash("sha256").update(text, "utf8").digest("hex");
  return `sha256-${hex}`;
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const body = readFileSync(process.argv[2] ?? 0, "utf8");
  console.log(digest(body));
}
