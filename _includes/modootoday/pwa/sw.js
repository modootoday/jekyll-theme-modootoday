{%- comment -%}The service worker, rendered by the site's sw.js stub (modootoday-stubs --pwa). With modootoday.pwa.enabled: true it
  holds constants and imports the strategies (assets/js/modootoday/pwa/worker.js); otherwise it deletes this scope's caches
  and unregisters itself, inline, so a broken worker.js can never block the rollback.{%- endcomment -%}
{%- include modootoday/config.html -%}
{%- assign _sws = "/" | relative_url -%}
{%- if site.modootoday.pwa.enabled == true -%}
{%- include modootoday/assets/build.html -%}{%- include modootoday/pwa/precache.html -%}
{%- comment -%}assets follows the ?v= contract: the theme version unless asset_version is build or false.{%- endcomment -%}
{%- assign _swa = mt_asset_v -%}{%- if _swa != mt_version -%}{%- assign _swa = mt_build_v -%}{%- endif -%}
{%- include modootoday/assets/url.html path="/assets/js/modootoday/pwa/worker.js" -%}
self.MT_PWA = {"scope": {{ _sws | jsonify }}, "build": {{ mt_build_v | jsonify }}, "assets": {{ _swa | jsonify }}, "precache": {{ mt_pwa_precache | jsonify }}, "offline": {{ mt_pwa_offline }}};
importScripts({{ mt_asset_url | jsonify }});
{% else -%}
// modootoday.pwa is off: remove this scope's caches and the worker itself, then reload open pages without it.
self.addEventListener("install", function () {
  self.skipWaiting();
});
self.addEventListener("activate", function (event) {
  var prefix = {{ "mt:" | append: _sws | append: ":" | jsonify }};
  event.waitUntil(caches.keys().then(function (names) {
    return Promise.all(names.filter(function (name) {
      return name.indexOf(prefix) === 0;
    }).map(function (name) {
      return caches.delete(name);
    }));
  }).then(function () {
    return self.registration.unregister();
  }).then(function () {
    return self.clients.matchAll({ type: "window" });
  }).then(function (clients) {
    clients.forEach(function (client) {
      client.navigate(client.url).catch(function () {});
    });
  }));
});
{% endif -%}
