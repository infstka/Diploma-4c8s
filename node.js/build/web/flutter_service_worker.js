'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "51dd1d152fb07a07852495c7fa78d873",
"assets/AssetManifest.json": "48bd2458988728250ba4978efb22d2af",
"assets/assets/images/1.jpeg": "e7ac62ee28a08a40fdc34fee401e8ff7",
"assets/assets/images/1.jpg": "282dffdaa664f3cb0ae552b15d394d12",
"assets/assets/images/1.png": "48cab6770ac783a8ddc12867e2cdabd1",
"assets/assets/images/10.jpeg": "d9134bc396639e7bfd03971a1c612d4d",
"assets/assets/images/10.jpg": "f6cfb950f843cae762eb99c9020f0d32",
"assets/assets/images/11.jpeg": "6bbd6f07ea9e232bdcaabb96c2e29585",
"assets/assets/images/11.jpg": "fa774ab79764a05ba345d4075c34396d",
"assets/assets/images/12.jpeg": "485adea3faaa1e8fdddee4159b4d6c9a",
"assets/assets/images/12.jpg": "e1d219e29d69f8d859f87342a76f0b6b",
"assets/assets/images/13.jpeg": "2b35c608e975fd1b31a7bfc3b8cdcbf1",
"assets/assets/images/13.jpg": "a91356434df7b9e8ad1039f3af789c4b",
"assets/assets/images/14.jpeg": "26dc26bedd0363d3e941451e7f23a3d4",
"assets/assets/images/14.jpg": "2ca4ce92cea813d9bcacca12ba6deb45",
"assets/assets/images/15.jpg": "a09152aba137f786672beb9dc22e4415",
"assets/assets/images/16.jpg": "58215756da568f95a550f475e909cd7b",
"assets/assets/images/17.jpg": "c6b5f2e1f42e47635e1997e75a871ee8",
"assets/assets/images/18.jpg": "8b334f3546b8b4a8ee3c3df370f08a30",
"assets/assets/images/2.jpeg": "360ff34b03b77cd59ac2d6a6b0e904e3",
"assets/assets/images/2.jpg": "b575303edfc7702236e141a766db0b76",
"assets/assets/images/2.png": "e4ff618964ba10ea680b1c9662c878ad",
"assets/assets/images/3.jpeg": "3b44246bec326eb8dc5729bddbd8fd24",
"assets/assets/images/3.jpg": "a22a9aff69ef9970b02d9c12891652d6",
"assets/assets/images/3.png": "524114cca885e2dd3e333b74542f1a40",
"assets/assets/images/4.jpeg": "8ce5b36bdcdcb385c2f20d4a2bb9dbeb",
"assets/assets/images/4.jpg": "a67dd14a50b6432b12ce6adc3d0ec4b8",
"assets/assets/images/5.jpeg": "7c6f4bc2ce5214f404d8b66fccc7d002",
"assets/assets/images/5.jpg": "6da4f931117fc1ad4a941361864a4f91",
"assets/assets/images/6.jpeg": "fad37204db6d07fdfb36161a7642cd8e",
"assets/assets/images/6.jpg": "53d977b7f0018ef557607f2e3a85331b",
"assets/assets/images/7.jpeg": "9de8cc25d7097de8a9e2719e53b2025e",
"assets/assets/images/7.jpg": "5388e3f81b4d743c5067bff4522be219",
"assets/assets/images/8.jpeg": "8c1c0d6b64de22b4eddc84ef9b0939f8",
"assets/assets/images/8.jpg": "d76d8338e0d878a6fe227ec45a2a5f29",
"assets/assets/images/9.jpeg": "18492669f52aea4586a85c3b5ba17461",
"assets/assets/images/9.jpg": "e1d219e29d69f8d859f87342a76f0b6b",
"assets/assets/images/dsnrecords_logo_black_no_bg.png": "77a25bbc93c20773f049ba219b6d3b80",
"assets/assets/images/dsnrecords_logo_white_no_bg.png": "71ab8b9ffba4180697e900f263123485",
"assets/assets/images/no_connection.png": "03dad09a44cce00d34f79268c87c2d5c",
"assets/assets/images/text_black.png": "47748698c2dea9324332a9b7a8ce70e0",
"assets/assets/images/text_white.png": "2fc950f5ae7b7a82a07352c40cef25a1",
"assets/FontManifest.json": "6ecbe48ac2ca5b349003c29f98675e1a",
"assets/fonts/MaterialIcons-Regular.otf": "4489578aec9fb8c4052b1d7e8f12eccf",
"assets/NOTICES": "cf174a6f986cbeca13681519d55501fe",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "57d849d738900cfd590e9adc7e208250",
"assets/packages/fluttertoast/assets/toastify.css": "910ddaaf9712a0b0392cf7975a3b7fb5",
"assets/packages/fluttertoast/assets/toastify.js": "18cfdd77033aa55d215e8a78c090ba89",
"assets/packages/line_awesome_flutter/lib/fonts/LineAwesome.ttf": "bcc78af7963d22efd760444145073cd3",
"assets/shaders/ink_sparkle.frag": "57f2f020e63be0dd85efafc7b7b25d80",
"canvaskit/canvaskit.js": "73df95dcc5f14b78d234283bf1dd2fa7",
"canvaskit/canvaskit.wasm": "d3105230aad263f43ca0388a51e43598",
"canvaskit/chromium/canvaskit.js": "cc1b69a365ddc1241a9cad98f28dd9b6",
"canvaskit/chromium/canvaskit.wasm": "f3da99572bed65fc644f1e7f72cf7167",
"canvaskit/skwasm.js": "d26e50adf287aa04d3f2ede5d3873f69",
"canvaskit/skwasm.wasm": "2eb2817ce6951167562e9ddadd486376",
"canvaskit/skwasm.worker.js": "19659053a277272607529ef87acf9d8a",
"favicon.ico": "ab10ee688b354d6aa2dc201bace26213",
"flutter.js": "6b515e434cea20006b3ef1726d2c8894",
"icons/Icon-192.png": "5ddb4a9e896e1b2ee6931413b93c539e",
"icons/Icon-512.png": "14b22d6b36495ee897fa1d007f2a8ac1",
"icons/Icon-maskable-192.png": "74780d46f332586fbbb3dd169e4c5fe8",
"icons/Icon-maskable-512.png": "1f2c630b89b29092187f06df51749efb",
"index.html": "5d311c7cbca081ba2ac282b0e0733069",
"/": "5d311c7cbca081ba2ac282b0e0733069",
"main.dart.js": "933e46381e94152bce0cac5f2ce91aaf",
"manifest.json": "cb00e34dbffd90cd1255a85105d5d1d7",
"version.json": "71f21362f1205eac2735c07cb6c5b16e"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"assets/AssetManifest.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
