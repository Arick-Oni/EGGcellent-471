'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "f72dfc545dd6146e1dc110acb9598cf8",
"assets/AssetManifest.bin.json": "fdffa8fee1209245a1200c790629c059",
"assets/assets/images/a.png": "f9ae055b971d7a8daea6bac70640740d",
"assets/assets/images/a1.png": "0aab4185e86f1aa645b5c0e91a8dc9c4",
"assets/assets/images/a2.png": "ca10a48244885d4fbd27a9a0a7326d0d",
"assets/assets/images/ad.png": "3d651b6b77918c9480b47ab586f66530",
"assets/assets/images/addcircle.png": "a84a76691157f303e60f879853a3398b",
"assets/assets/images/adduser.png": "6d554d23ad071cd68e33e8f043da1b55",
"assets/assets/images/ads.png": "4a4cad8a59bf573795c245c611db883c",
"assets/assets/images/apple.png": "7448be64ee56643fb7a439d3ba2b71c6",
"assets/assets/images/b.png": "8827e7e2a4ef4d33ff7a8f89fb6e5d55",
"assets/assets/images/bag.png": "4d942fd50424c81663f2e96504677141",
"assets/assets/images/bch.png": "501c90e44602bb99eb71f01bc6a65906",
"assets/assets/images/bdeshi.png": "5dcf20777b81a26dadf495a1e15fb73a",
"assets/assets/images/be.png": "b96e212d031c247bc764412d1bf0db19",
"assets/assets/images/begg.png": "ef167ba89a844814967d8780b0d5ce17",
"assets/assets/images/bi.png": "e38fbc4efcfdd16c09bcad90f204a098",
"assets/assets/images/birds.png": "a452e5faaa167be6896d82788d6a69ff",
"assets/assets/images/body.png": "2ea3bdc10654e18d5e139217c381fe2d",
"assets/assets/images/broiler.png": "1c08e15978e647fc5b9356082fcd9a0d",
"assets/assets/images/btrolley.png": "a3e6dfe1186079a7514160c552daf203",
"assets/assets/images/call.png": "e1eff513f269beeef153569daf0c6ebc",
"assets/assets/images/cd.png": "063dcd72afe224e80758478a432f8494",
"assets/assets/images/chick.png": "448874c74b0fca38b45f593301deb00e",
"assets/assets/images/close%25201.png": "95c9fea1db7e3f07538c398ce60a603f",
"assets/assets/images/close.png": "990ffed498ecaf4de3893e6f2fb3c4cc",
"assets/assets/images/cross.png": "f0b1ed4157104fff073ec10ca16e51d9",
"assets/assets/images/crown.png": "925ff0f1f5939d9e5711c9e1c505b6db",
"assets/assets/images/currency.png": "1541d49bd391773ba2cc7756a26202be",
"assets/assets/images/delete.png": "8c4ea0d0a0cd00c39436f9cedac56922",
"assets/assets/images/deshi.png": "5dcf20777b81a26dadf495a1e15fb73a",
"assets/assets/images/download.png": "a2c79071e6ac6940b9300de95b3479dc",
"assets/assets/images/duck.png": "b76eb198ec7aced44c9cd2ac5e402541",
"assets/assets/images/edit.png": "2379022490efc2c11c719039540a9f70",
"assets/assets/images/editI.png": "d3760ccbbc2a29242b1c29b3783415b1",
"assets/assets/images/egg.png": "3170cd42f90d964a3c4df05bbf3635f5",
"assets/assets/images/eggI.png": "b2c070f81e5a9314ae9ecb1cd024bd24",
"assets/assets/images/eggLogo.jpeg": "38ad3ff9e3d40706beef3f2c3e32e782",
"assets/assets/images/eggs.png": "2a8e2cd78c84821cd3cb7b7d3faeb38a",
"assets/assets/images/eggtrau.png": "0249663c7670d947c63d0c7b9e2b14ba",
"assets/assets/images/error.png": "22d49aac32109eaf9d8fd83aff25ba19",
"assets/assets/images/excel.png": "4f0d05b8cdfaafca9caf984b6536d9f5",
"assets/assets/images/expense.png": "09e40e2b4d721e62f715e9955a70af9f",
"assets/assets/images/f.png": "e7ec9f4693d02a5ad9f83973fdb99fc7",
"assets/assets/images/fe.png": "dff55651f4b095bafc3b9cd3ab7f3df5",
"assets/assets/images/fee.png": "6ec18d9750f1e699d71d78447ab2e45b",
"assets/assets/images/feed.png": "8582a2db92fe95a6d258c79b0f5c1ee4",
"assets/assets/images/feedbag.png": "1859fa55ced72ccfe5bed140cb94fdc7",
"assets/assets/images/feedreq.png": "6fb8a70858e30999f68193727eac1d0a",
"assets/assets/images/feeds.png": "a68b2f6f15f00b7e628ccef005aa00f6",
"assets/assets/images/filter.png": "322c01333a2a26471ed3e32ec1e6ed40",
"assets/assets/images/flag.png": "5a1550bd25600da06989d58865aca0ee",
"assets/assets/images/g.png": "caa17691a16037abb0965afe985169dd",
"assets/assets/images/happy.png": "f73c13691e8460d53b82a8d72189d0d1",
"assets/assets/images/hen.png": "1f8a2a4e5abd6f3fe0cae83e1c7819e5",
"assets/assets/images/henI.png": "07f104170d39d78576bad3951ca9ac0d",
"assets/assets/images/income.png": "0290ae90fb7002fdd294f211b2782d66",
"assets/assets/images/intro.png": "a867a083a21dec29dafc38186de5eee7",
"assets/assets/images/intro1.png": "d27eb1cd288da01081ab490bd380d64f",
"assets/assets/images/intro2.png": "c076d12d6ce9a897fe69b549219398cd",
"assets/assets/images/lang.png": "7b99ec3250c35e3f196262a773dfb714",
"assets/assets/images/language.png": "9196143f690abff4ec00c6bb356acd45",
"assets/assets/images/list.png": "62653c237afcfae8d4af6571d6825225",
"assets/assets/images/logo.png": "dca915a638a0658746af6eb675092050",
"assets/assets/images/logout.png": "7eb29afa9e3ae6b5752035c01da492fd",
"assets/assets/images/machine.png": "e1250ce91ace7acb74339fe1ecefce24",
"assets/assets/images/meat.png": "d2210bdda0004b90474f0976a7ca808a",
"assets/assets/images/med.png": "2b0e5b496e1222466f27033fbdf5523a",
"assets/assets/images/medi.png": "86eb8a72ef9fbd0db65f902b13dc352a",
"assets/assets/images/medicine.png": "89be9f08ad5ca13d0ce1f42cbaa36221",
"assets/assets/images/mort.png": "285ede1fbedd35d20ffa877294e82586",
"assets/assets/images/newMurgi.png": "b7e67f3856f4fbd57730c27f0190c050",
"assets/assets/images/noti.png": "4184ae84fec7d4dd5abd6fdcde2f0092",
"assets/assets/images/personadd.png": "a7eb0c7e96007ab94ce86ce925050553",
"assets/assets/images/phone.png": "163ce0f0b1a2e2a07c74ec8683b449c0",
"assets/assets/images/profile.png": "6d554d23ad071cd68e33e8f043da1b55",
"assets/assets/images/recommend.png": "66651893576231023af56fe63240ec80",
"assets/assets/images/remind.png": "0118806ac7d77b8d31e6d910a38a261e",
"assets/assets/images/reminder.png": "c14c71583e326e467d07a24fb5bc865e",
"assets/assets/images/report.png": "fd6f2d26c506d2c88b9e7dce9e115136",
"assets/assets/images/req.png": "eadf06bfa9a82b83e72b37ea5852d5e1",
"assets/assets/images/restore.png": "d92016e356d734450695d1dfeeea477a",
"assets/assets/images/rs.png": "da32ed11556505d44357744a876e55bc",
"assets/assets/images/s.png": "9932e7828c9793097486d5007f03727e",
"assets/assets/images/set.png": "c2253f3e080c71fd0f7b82920c40e3f2",
"assets/assets/images/sh.png": "625905f6d69649579486f8ceae3d63d1",
"assets/assets/images/share.png": "98eb74016b53f275497b288926a5419a",
"assets/assets/images/shop.png": "ad77db27b5435288c38d3af87e900ffd",
"assets/assets/images/stock.png": "981036cbbfc244e17067a210c440d10e",
"assets/assets/images/successmark.png": "8a73c60b57f4e8cc98954c051caa2edb",
"assets/assets/images/tpad.png": "0e4278619e785513279b9e40af4b8c80",
"assets/assets/images/transfer.png": "7aabbe5d77c8568a5573fb3dfee31275",
"assets/assets/images/transport.png": "c4e800379a79ab4b7641a4b141060c86",
"assets/assets/images/tray.png": "fe14eebae33e3a56067c9f9be75b47f1",
"assets/assets/images/user.png": "f882b539b7cb6b7b5b68c438b82651ea",
"assets/assets/images/useradd.png": "23a5dfa552b0658d401d491511ac1e95",
"assets/assets/images/vac.png": "2632fcec5267a8cc08b56c6eed807494",
"assets/assets/images/vaccine.png": "c2a9fd518e676793ba161856dbe4df30",
"assets/assets/images/verify.png": "709e8f170e6572e09b2373adeb78066c",
"assets/assets/images/weight.png": "d42d61e7bea1db06e7e5e53601f3d360",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "7a5a0da65d9d35db08223a4f2bf66ef2",
"assets/NOTICES": "a7b2d054f22db70462ff8c4472afd7ba",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "552fb38507bb414fac78b093b4c5d8d8",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/canvaskit.js.symbols": "80e8f131119f63a164c0adda80515009",
"canvaskit/canvaskit.wasm": "b9176a7e969a26cbd5377c8017acc8f1",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.js.symbols": "ee71615b4771fe00f4c077b7238f07bd",
"canvaskit/chromium/canvaskit.wasm": "5587a61c2b0a1697052bf44ec53bce5b",
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/skwasm.js.symbols": "b1d2280fb36c6d5a51c5959da3c3d232",
"canvaskit/skwasm.wasm": "5173ef1887754164ddfa6df6fedf8221",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/skwasm_heavy.js.symbols": "e3424caea126826f15d4492a542f69a4",
"canvaskit/skwasm_heavy.wasm": "d86656623eda143f0ad619a0968f75aa",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"flutter_bootstrap.js": "0fdc3a7b9077cb1ec932a1af1dcb6380",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "e0582f2b764777b760058bc0e5dbbfa3",
"/": "e0582f2b764777b760058bc0e5dbbfa3",
"main.dart.js": "8e60e0b38924390ffd3b01db0ae3ef31",
"manifest.json": "9faf847a77db0788625c46a2b8d98f7e",
"version.json": "387c014064c223cc21c7f0b1670e326a"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
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
