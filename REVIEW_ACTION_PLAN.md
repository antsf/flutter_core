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

### [x] M2. Ganti nama `LocalStorage` → `SecureStorage` ✅ (commit `8ad9bd6`)
- [x] Rename class + file (`secure_storage.dart`); `@Deprecated typedef LocalStorage` untuk migrasi
- [x] Dokumentasikan caveat perf/keamanan (lambat, bulk op dekripsi semua key, web ≠ secure)
- [x] Tambah dukungan `List<dynamic>`
- **DoD:** ✅ Nama jujur. (Catatan: bulk op tetap `readAll()` — itu sifat secure storage; didokumentasikan. Split ke KV-store cepat = follow-up opsional jika butuh.)

### [x] M3. Connectivity pre-flight jadi opt-in ✅ (commit `8ad9bd6`)
- [x] `DioClient(checkConnectivityBeforeRequest: false)` default; offline tetap muncul sebagai `NoInternetConnectionException` via Dio `connectionError`
- [x] +1 test (default-off)
- **DoD:** ✅ Tidak ada platform-channel call sebelum tiap request secara default.

### [x] M4. `UseCase` cancellation — **MOOT** ✅
- [x] Tidak relevan lagi: `UseCase` sudah dihapus seluruhnya (commit `680cead`).

### [x] M7. Jangan re-export seluruh package pihak ketiga ✅ (commit menyusul)
- [x] Hapus re-export `google_fonts` & `intl` (internal-only); pertahankan `dio`/`connectivity_plus`/`flutter_screenutil` (dipakai di signature publik)
- **DoD:** ✅ Autocomplete consumer tidak banjir simbol google_fonts/intl.

### [x] M9. Hapus duplikasi `back()` pada `BuildContext` ✅ (commit menyusul)
- [x] `back()` hanya di `NavigationExtension`; dihapus dari `DialogsAndAlerts`
- [x] +1 regression test (impor via barrel)
- **DoD:** ✅ `context.back()` tidak ambigu via barrel.

### [x] M10. Hindari tabrakan nama dengan SDK ✅ (commit `8ad9bd6`)
- [x] `TimeoutException` → `NetworkTimeoutException` (tak lagi menutupi `dart:async`)
- **DoD:** ✅ Tidak ada shadowing `dart:async`.

---

## P3 — DOKUMENTASI & KEBERSIHAN

### [x] M8. Selaraskan dokumentasi dengan API nyata ✅
- [x] README theme example → pakai `currentTheme` saja (hapus `darkTheme`/`themeMode` yang tidak ada)
- [x] README feature bullet `BaseRepository`/`UseCase` → diganti "Result Type" (sebelumnya saat hapus UseCase)
- [x] Hapus tombol no-op "Set Blue Scheme" di example
- [x] README: `LocalStorage`→`SecureStorage`, `TimeoutException`→`NetworkTimeoutException`, catatan error-model & idempotent retry, deps google_fonts/intl ditandai internal
- [x] Koreksi klaim palsu di `REFACTOR_PLAN.md` (tambah catatan koreksi)
- [ ] (opsional) `ThemeProvider.setColorScheme` masih ada tapi no-op — biarkan/implement nanti
- **DoD:** ✅ Semua contoh README & example compile terhadap API nyata (analyze 0 issue).

### [ ] Minor — kebersihan kode & konfigurasi
- [x] Hapus dead code terkomentar di `core.dart` + self-import aneh (commit `874e7bf`)
- [x] Naikkan `flutter_lints ^3 → ^6` (commit menyusul); semua temuan baru dibereskan (17× `unnecessary_library_name` → `library;` anonim, 2× angle-bracket di doc comment). `strict-casts` = follow-up opsional terpisah.
- [ ] (opsional) Kurangi global singleton `FlutterCore`/`ThemeProvider` → DI — perubahan arsitektural besar, butuh diskusi
- [ ] (opsional) String ID hardcoded `safe_remote_call genericError` — sudah bisa di-override via parameter; rendah prioritas
- [ ] (opsional) Semantik null-success — sebagian besar sudah ditangani M1 (`toResult`); review jika perlu
- [x] `PhoneFormatter`/`CreditCardFormatter`/`ThousandsFormatter` — caret dipertahankan saat edit di tengah (hitung digit sebelum caret). Bonus: fix grouping `PhoneFormatter` agar cocok dengan doc (`0812 3456 7890`, bukan `081 2345 67890`). +6 test (commit menyusul).

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
