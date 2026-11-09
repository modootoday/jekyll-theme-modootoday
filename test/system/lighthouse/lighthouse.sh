#!/usr/bin/env bash
# Lighthouse on a built docs site, served at the Pages baseurl.
# Usage: test/system/lighthouse/lighthouse.sh [SITE_DIR=docs/_site] [OUT=qa-out/lighthouse]
# Env: RUNS (default 1; CI uses 3, the median score per category is kept), PORT, CHROME_PATH; for a starter demo build
# (rake starters:demo) BASE, its repository name, and PAGES, its qa: pages separated by spaces (. for the home page).
# Then `node test/system/lighthouse/budget.mjs OUT` checks the medians against test/system/lighthouse/budget.json.
set -euo pipefail
site="${1:-docs/_site}"; out="${2:-qa-out/lighthouse}"; port="${PORT:-8799}"; runs="${RUNS:-1}"
# A server left on the port would answer instead of this site and every score would read "-".
if (exec 3<>"/dev/tcp/127.0.0.1/$port") 2>/dev/null; then echo "lighthouse.sh: port $port is already in use; free it or set PORT" >&2; exit 1; fi
name="${BASE:-jekyll-theme-modootoday}"; name="${name#/}"
root="$(mktemp -d)"; mkdir -p "$root/$name" "$out"
cp -r "$site/." "$root/$name/"
(cd "$root" && exec python3 -m http.server "$port" >/dev/null 2>&1) & srv=$! # exec: $srv is the server itself
trap 'kill $srv 2>/dev/null; rm -rf "$root"' EXIT
sleep 1
base="http://localhost:$port/$name"
pages=("" components/ components/kitchen-sink/ guides/install/ ko/ ko/components/kitchen-sink/ layouts/demo/orbit/ recipes/charts/ 404.html)
if [ -n "${PAGES:-}" ]; then IFS=' ' read -r -a pages <<< "$PAGES"; pages=("${pages[@]/#./}"); fi
for p in "${pages[@]}"; do
  for f in mobile desktop; do
    n="$(echo "${p:-home}" | tr / _)-$f"; extra=(); [ "$f" = desktop ] && extra=(--preset=desktop)
    for r in $(seq 1 "$runs"); do
      npx -y lighthouse@13 "$base/$p" "${extra[@]}" --quiet --chrome-flags="--headless=new --no-sandbox" \
        --output=json --output-path="$out/$n.run$r.json" >/dev/null 2>&1 || true
    done
  done
done
node test/system/lighthouse/budget.mjs "$out" --summary-only ${SKIP:+--skip "$SKIP"}
