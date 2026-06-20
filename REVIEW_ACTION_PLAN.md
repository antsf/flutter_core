# Action Plan — flutter_core (Hasil Brutal Review)

> Dibuat: 2026-06-19
> Sumber: brutal review v1.2.0 (branch `refactor/core-cleanup`)
> Status awal: **TIDAK BISA COMPILE** — `flutter analyze` = 168 error / 175 issue
> Skor awal: **2.5 / 10** — Publish: TIDAK · Production: TIDAK
>
> **Update 2026-06-20 — P0 SELESAI ✅:** `flutter analyze --fatal-infos` = 0 issue · `flutter test` = **295 lulus** · CI ditambahkan. Selanjutnya: P1 (keamanan produksi).

Kerjakan **berurutan dari atas ke bawah**. Setiap item punya: lokasi file:line, kriteria selesai (DoD), dan severity. Centang `[x]` jika selesai.

**Aturan emas:** Jangan kerjakan item P1+ sebelum P0 hijau (`flutter analyze` = 0 error). Setiap fase ditutup dengan menjalankan `flutter analyze` + `flutter test`.

---

## P0 — BLOCKER (package harus bisa compile & terverifikasi)

> Tanpa ini, semua hal lain tidak relevan. Target: `flutter analyze` = 0 error, `flutter test` hijau.

### [x] C1. Perbaiki semua path import/export yang rusak setelah pindah file ✅
Severity: 10/10 — **SELESAI** (commit menyusul). `flutter analyze` = **No issues found!**
File pindah dari `lib/src/core/*` → `lib/src/*` tapi barrel & file internal masih menunjuk path lama.
- [x] `lib/flutter_core.dart:13,16,17,18,19,20,23,26,35` — perbaiki export `src/core/...` → `src/...`
- [x] `lib/core.dart:50,55,57` — perbaiki import `src/core/...` → `src/...` (+ hapus 2 baris import terkomentar mati)
- [x] `lib/src/domain/usecase.dart:2` — `'../failures/failures.dart'` → `'failures.dart'`
- [x] `lib/src/theme/theme_provider.dart:2` — path baru
- [x] Tests: `mock_local_storage.dart`, `failure_test.dart`, `local_storage_test.dart`, `dio_client_test.dart`, `connectivity_service_test.dart`
- [x] Verifikasi: `grep -rn "src/core/" lib test example` = kosong
- **DoD:** ✅ `flutter analyze` = 0 error (No issues found!).

### [x] C2. Tambahkan CI/CD (akar penyebab C1 bisa lolos) ✅
Severity: 9/10 — **SELESAI**. Dibuat `.github/workflows/ci.yml`.
- [x] Workflow: `pub get` → `dart format --set-exit-if-changed .` → `flutter analyze --fatal-infos` → `flutter test --timeout 60s` → `dart pub publish --dry-run`
- [x] Jalankan di setiap PR + push ke `main`
- [x] Seluruh gate diverifikasi lulus lokal (format, analyze --fatal-infos, test, dry-run bersih di checkout bersih)
- **DoD:** ✅ Workflow siap; gate akan memblokir PR yang gagal. (Perlu push ke GitHub agar Actions aktif.)
- **Catatan:** `dart pub publish --dry-run` memberi *hint* bahwa nama `flutter_core` sudah ada di pub.dev (versi 1.0.2). Distribusi saat ini via git dependency (lihat README). Bukan blocker CI, tapi nama harus dibereskan jika ingin publish ke pub.dev. → tracked sebagai catatan P2/P3.

### [x] C3. Perbaiki agar test suite bisa jalan ✅
Severity: 9/10 — **SELESAI**. `flutter test` = **+295 All tests passed**, EXIT 0.
- [x] Path import test diperbaiki (bagian dari C1) — semua file load
- [x] `const`/`implements_non_class`/`isOnline` errors hilang setelah path fix
- [x] **Deadlock navigation test**: `await context.toNamed(...)` menunggu push future yang tak pernah pop → hang 10 menit. Diganti `unawaited(...)` (14 lokasi) + `import 'dart:async'`.
- [x] **TestPage duplikat judul** di AppBar & body → `find.text` menemukan 2 widget. Judul dirender sekali.
- [x] **`removeUntil` dead-context**: `canBack()` pakai context home yang sudah dihapus → assertion. Diganti context halaman baru via `tester.element(...)`.
- [x] **Library fix**: `to`/`toReplacement`/`toAndRemoveUntil` pakai `MaterialPageRoute<T>` agar tipe hasil pop ter-propagate (`back with result`).
- [x] **Library fix**: `hasFocus` (dulu `primaryFocus != null` → hampir selalu true). Kini cek node non-scope yang `hasPrimaryFocus`. Test fokus pakai `node.hasPrimaryFocus`/`hasFocus`.
- [x] **google_fonts 6.2.1 const-eval error** (blokir compile 8 file test di SDK Dart terbaru) → bump ke `^8.0.0` (8.1.0). API `GoogleFonts.inter()` tetap.
- [x] **maskEmail test usang**: ekspektasi lama `jxxxxxxxxxxxxple.com` → benar `jxxxxxxx@xxxxple.com` (sesuai impl/README/CHANGELOG 1.1.0).
- [x] **debounce/throttle flaky** (timer wall-clock 50ms, margin ~10ms) → `fakeAsync` (virtual time, deterministik, lulus 3× berturut). `fake_async` ditambah ke dev_dependencies.
- [x] Repo diformat (`dart format`) agar gate format CI jujur.
- **DoD:** ✅ `flutter test` compile & hijau (295 lulus); `flutter analyze --fatal-infos` = 0 issue.

---

## P1 — KEAMANAN PRODUKSI (fintech/banking footguns) — ✅ SELESAI

> Bug yang membuat package BERBAHAYA, bukan sekadar rusak. Semua diselesaikan +
> ditambah test (commit `00d9b54`). Full suite: **308 lulus**.

### [x] C4. Retry hanya untuk method idempotent (risiko transaksi ganda) ✅
`lib/src/network/dio_retry_interceptor.dart`
- [x] Default retry hanya `{GET, HEAD, OPTIONS}` (`RetryOptions.retryableMethods`); POST/PUT/PATCH tidak diretry
- [x] Opt-in per-request via `Options(extra: {'retry': true})`
- [x] Jitter pada backoff (`RetryOptions.useJitter`, default on)
- [x] **8 test** (`test/network/dio_retry_interceptor_test.dart`)

### [x] C5. Serialisasi token refresh (cegah stampede) ✅
`lib/src/network/dio_client.dart` (`_ongoingRefresh` + `_refreshAuthToken`)
- [x] Single in-flight refresh dibagi semua 401 paralel (coalescing)
- [x] Guard `__retried_after_refresh` cegah loop refresh→retry tak terhingga
- [x] **2 test** integrasi (`dio_client_refresh_test.dart`): 5×401 → 1 refresh; 401 persisten → gagal tanpa loop

### [x] M5. Cache: batas LRU + key sadar identitas ✅
`lib/src/network/dio_client.dart`
- [x] LRU bound via `DioClient(maxCacheEntries: 100)` + eviction kedaluwarsa
- [x] `_cacheKey` menyertakan hash identitas (token) → data user A tidak bocor ke user B
- [x] **3 test** (`dio_client_cache_test.dart`): isolasi identitas, eviction LRU, forceRefresh

### [x] M6. Jangan log data sensitif tanpa syarat ✅
`lib/src/network/safe_remote_call.dart`
- [x] Hapus log full result (`_logger.d('... result: $result')`) → tidak ada PII/token di log
- [x] Log error di-gate ke debug saja (`kReleaseMode`)

---

## P2 — DESAIN & API (koherensi, kebersihan permukaan publik)

### [x] M1. Satukan model error/result ✅ (commit `af12686`)
- [x] **`Failure` jadi satu-satunya mata uang error**: `NetworkException` (+ semua subtipe) sekarang `extends Failure` → network error langsung masuk `Result<T, Failure>` tanpa remap lossy
- [x] `ApiResponse.toResult()` menjembatani transport HTTP → `Result<T?, Failure>` (ApiResponse tetap dipakai DioClient karena HTTP 204 = sukses tanpa body, tak bisa diwakili `Result.Success<T>`)
- [x] Hapus `network/safe_call.dart` (dead/duplikat) + `ResponseExtension` (unused); `safeRemoteCall` kembalikan failure spesifik apa adanya
- [x] +5 test (`api_response_test.dart`); bonus: fix flaky `theme_widget_test` (pakai `setFontBuilderForTesting`, bukan GoogleFonts asli)
- **DoD:** ✅ Satu mata uang error (`Failure`); konversi eksplisit via `toResult()`. Suite hijau 3× berturut (313).

### [ ] M2. Pisahkan & ganti nama `LocalStorage` (secure storage menyamar)
Severity: 7/10 — `lib/src/storage/local_storage.dart:17-26,72,78,89,111-124`
- [ ] Pisah: `KeyValueStore` cepat (prefs/Hive) vs `SecureStore` khusus rahasia
- [ ] Hindari `readAll()` di setiap operasi bulk
- [ ] Tambah dukungan `List` atau dokumentasikan batasan tipe dengan jelas
- [ ] Dokumentasikan perbedaan jaminan keamanan per platform (web ≠ secure)
- **DoD:** Nama jujur sesuai fungsi; bulk op tidak mendekripsi seluruh keychain.

### [ ] M3. Hapus/optional-kan connectivity pre-flight
Severity: 7/10 — `lib/src/network/dio_client.dart:265,297-307` + `connectivity_service.dart:156-161`
`connectivity_plus` melaporkan interface, bukan reachability; menambah latency tiap request.
- [ ] Hapus pre-check default; map `DioExceptionType.connectionError` → `NoInternetConnectionException`
- [ ] Jika dipertahankan, jadikan opt-in
- **DoD:** Request tidak lagi memanggil platform channel sebelum tiap HTTP call.

### [ ] M4. `UseCase` cancellation: implement sungguhan atau hapus
Severity: 6/10 — `lib/src/domain/usecase.dart:60-159`
Cancellation saat ini tidak berfungsi (hanya ganti pesan saat exception).
- [ ] Implement cancellation kooperatif nyata (pass `CancelToken`/`Completer` ke `execute`) **atau** hapus fitur + dokumentasi terkait
- **DoD:** Test membuktikan `cancel()` benar-benar menghentikan operasi, atau fitur dihapus bersih.

### [ ] M7. Jangan re-export seluruh package pihak ketiga
Severity: 6/10 — `lib/flutter_core.dart:41-45`
- [ ] Re-export hanya tipe yang dipakai di signature publik (`DioException`, `Options`, `CancelToken`), bukan seluruh `dio`/`google_fonts`/`intl`/`screenutil`/`connectivity_plus`
- **DoD:** Autocomplete consumer tidak banjir simbol pihak ketiga.

### [ ] M9. Hapus duplikasi `back()` pada `BuildContext`
Severity: 5/10 — `navigation_ext.dart:97` & `dialogs_and_alerts_ext.dart:26`
- [ ] Konsolidasikan ke satu extension
- **DoD:** `context.back()` tidak ambigu.

### [ ] M10. Hindari tabrakan nama dengan SDK
Severity: 5/10 — `network_exceptions.dart:215` (`TimeoutException` menutupi `dart:async`)
- [ ] Beri prefix: `NetworkTimeoutException`, dll. (juga `CancelledException`, `NotFoundException`, `ConflictException`)
- **DoD:** Tidak ada shadowing simbol `dart:async`/SDK.

---

## P3 — DOKUMENTASI & KEBERSIHAN

### [ ] M8. Selaraskan dokumentasi dengan API nyata
Severity: 6/10
- [ ] `README.md:53-54` — hapus/ganti `ThemeProvider.instance.darkTheme` & `.themeMode` (tidak ada)
- [ ] `README.md:14` — hapus klaim `BaseRepository` (sudah dihapus, lihat `CHANGELOG.md:30-33`)
- [ ] Hapus tombol "Set Blue Scheme" yang no-op di `example/lib/main.dart:144-152`
- [ ] Implement atau hapus `ThemeProvider.setColorScheme` (`theme_provider.dart:91-99`)
- [ ] Koreksi klaim palsu `REFACTOR_PLAN.md:5,124` ("Semua tahap SELESAI ✅" / "No issues found ✅")
- **DoD:** Semua contoh di README compile terhadap API nyata.

### [ ] Minor — kebersihan kode & konfigurasi
- [ ] Hapus dead code terkomentar: `core.dart:85-93,124-127,176-197`; `formatter.dart:109-116`; self-import aneh `core.dart:49`
- [ ] Kurangi global singleton: `FlutterCore` `static late final` (`core.dart:79,87`), `ThemeProvider` static + `static LocalStorage localStorage` (`theme_provider.dart:12`) → arah DI/testable
- [ ] Hapus string ID hardcoded di lib inti: `domain/safe_call.dart:27` ('Terjadi kesalahan tak terduga') → buat localizable
- [ ] Selaraskan semantik null-success: `api_response.dart:31` (null = sukses) vs `network/safe_call.dart:11-23` (null = gagal)
- [ ] `PhoneFormatter`/`CreditCardFormatter` (`formatter.dart:51-107`) — jaga posisi caret saat edit di tengah
- [ ] Naikkan `flutter_lints: ^3.0.0` → `^6.0.0`; aktifkan lint tambahan di `analysis_options.yaml` (`strict-casts`, `prefer_const`, dll.)

---

## Definition of Done (rilis)

- [ ] `flutter analyze --fatal-warnings` = 0 issue
- [ ] `flutter test` hijau + coverage dilaporkan
- [ ] `dart pub publish --dry-run` lolos
- [ ] CI hijau di GitHub Actions
- [ ] README & example compile terhadap API nyata
- [ ] Semua item P0 & P1 selesai (P2/P3 boleh menyusul, tapi P1 wajib sebelum dipakai produksi)

## Urutan eksekusi yang disarankan
1. P0 (C1 → C2 → C3) — buat hijau & berCI
2. P1 (C4, C5, M5, M6) — hilangkan bahaya produksi
3. P2 (M1, M3, M2, M4, M7, M9, M10) — rapikan desain/API
4. P3 (M8 + minor) — dokumentasi & polish
