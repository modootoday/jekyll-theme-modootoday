#!/usr/bin/env bash
# Local Lighthouse run on a built docs site (not in CI: scores vary with runner load).
# Usage: qa/lighthouse.sh [SITE_DIR=docs/_site] [OUT=qa-out/lighthouse]
# Needs Chrome (CHROME_PATH) and network access for `npx lighthouse`.
set -euo pipefail
site="${1:-docs/_site}"; out="${2:-qa-out/lighthouse}"; port="${PORT:-8799}"
root="$(mktemp -d)"; mkdir -p "$root/jekyll-theme-modootoday" "$out"
cp -r "$site/." "$root/jekyll-theme-modootoday/"
(cd "$root" && python3 -m http.server "$port" >/dev/null 2>&1) & srv=$!
trap 'kill $srv' EXIT
sleep 1
base="http://localhost:$port/jekyll-theme-modootoday"
for p in "" components/ components/kitchen-sink/ install/ ko/ ko/components/kitchen-sink/ 404.html; do
  for f in mobile desktop; do
    n="$(echo "${p:-home}" | tr / _)-$f"; extra=(); [ "$f" = desktop ] && extra=(--preset=desktop)
    npx -y lighthouse@13 "$base/$p" "${extra[@]}" --quiet --chrome-flags="--headless=new --no-sandbox" \
      --output=json --output-path="$out/$n.json" >/dev/null 2>&1 || true
    node -e 'const c=require(process.argv[1]).categories;console.log(process.argv[2].padEnd(40),["performance","accessibility","best-practices","seo"].map(k=>c[k].score===null?"-":Math.round(c[k].score*100)).join(" "))' "$PWD/$out/$n.json" "$n"
  done
done
