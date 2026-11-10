#!/usr/bin/env bash
# Build the PWA fixture (test/fixtures/sites/pwa) five times into $1 (default ROOT/pkg/pwa) for audit/features/pwa/:
# v1, v2 (another time:, so sw.js changes) and kill at /a, then v1 at /b and at the origin root (a user site beside it).
set -euo pipefail
root="$(cd "$(dirname "$0")/../../.." && pwd)"
out="$(realpath -m "${1:-$root/pkg/pwa}")"
src="$root/test/fixtures/sites/pwa"
cd "$root"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
printf '' > "$tmp/v1.yml"
printf 'time: "2026-01-02T00:00:00+00:00"\n' > "$tmp/v2.yml"
printf 'modootoday:\n  pwa: {enabled: kill}\n' > "$tmp/kill.yml"
printf 'baseurl: /b\n' > "$tmp/b.yml"
printf 'baseurl: ""\n' > "$tmp/root.yml"
rm -rf "$out"
for name in v1 v2 kill b root; do
  # A build revision would outrank time: in the worker's build version and make v1 and v2 the same.
  JEKYLL_BUILD_REVISION= bundle exec jekyll build -q -s "$src" -d "$out/$name" --config "$src/_config.yml,$tmp/$name.yml"
done
if cmp -s "$out/v1/sw.js" "$out/v2/sw.js"; then
  echo "build-pwa: v1 and v2 render the same sw.js, so the browser would find no update" >&2
  exit 1
fi
