# Action Plan — flutter_core (Hasil Brutal Review)

> Dibuat: 2026-06-19
> Sumber: brutal review v1.2.0 (branch `refactor/core-cleanup`)
> Status awal: **TIDAK BISA COMPILE** — `flutter analyze` = 168 error / 175 issue
> Skor awal: **2.5 / 10** — Publish: TIDAK · Production: TIDAK

Kerjakan **berurutan dari atas ke bawah**. Setiap item punya: lokasi file:line, kriteria selesai (DoD), dan severity. Centang `[x]` jika selesai.

**Aturan emas:** Jangan kerjakan item P1+ sebelum P0 hijau (`flutter analyze` = 0 error). Setiap fase ditutup dengan menjalankan `flutter analyze` + `flutter test`.

---

## P0 — BLOCKER (package harus bisa compile & terverifikasi)

> Tanpa ini, semua hal lain tidak relevan. Target: `flutter analyze` = 0 error, `flutter test` hijau.

### [ ] C1. Perbaiki semua path import/export yang rusak setelah pindah file
Severity: 10/10
File pindah dari `lib/src/core/*` → `lib/src/*` tapi barrel & file internal masih menunjuk path lama.
- [ ] `lib/flutter_core.dart:13,16,17,18,19,20,23,26,35` — perbaiki export `src/core/...` → `src/...`
- [ ] `lib/core.dart:50,55,57` — perbaiki import `src/core/...` → `src/...`
- [ ] `lib/src/domain/usecase.dart:2` — `'../failures/failures.dart'` → `'failures.dart'`
- [ ] `lib/src/theme/theme_provider.dart:2` — `package:flutter_core/src/core/storage/local_storage.dart` → path baru
- [ ] Cek ulang semua file lain yang masih mengandung `src/core/` (`grep -rn "src/core/" lib test example`)
- **DoD:** `flutter analyze` tidak lagi memunculkan error `uri_does_not_exist` / `undefined_class` / `undefined_function`.

### [ ] C2. Tambahkan CI/CD (akar penyebab C1 bisa lolos)
Severity: 9/10 — saat ini tidak ada `.github/`
- [ ] Buat `.github/workflows/ci.yml`: `pub get` → `dart format --set-exit-if-changed .` → `flutter analyze --fatal-warnings` → `flutter test --coverage` → `dart pub publish --dry-run`
- [ ] Jalankan di setiap PR + push ke `main`
- **DoD:** Workflow hijau di GitHub Actions; PR yang gagal analyze/test diblokir.

### [ ] C3. Perbaiki agar test suite bisa jalan
Severity: 9/10 — coverage efektif saat ini = 0
- [ ] Perbaiki import path test: `test/domain/failures/failure_test.dart:1`, `test/network/dio_client_test.dart:2`, `test/services/connectivity_service_test.dart:5`, `test/storage/local_storage_test.dart:3`
- [ ] Perbaiki error `const_initialized_with_non_constant_value` di `failure_test.dart:178,181,190,201,204,211,...`
- [ ] Perbaiki mock rusak: `test/mocks/mock_local_storage.dart:5` & `test/network/dio_client_test.dart:9` (`implements_non_class`)
- [ ] Perbaiki `isOnline` undefined di `test/services/connectivity_service_test.dart:25,29,33,37`
- **DoD:** `flutter test` compile & hijau seluruhnya.

---

## P1 — KEAMANAN PRODUKSI (fintech/banking footguns)

> Bug yang membuat package BERBAHAYA, bukan sekadar rusak.

### [ ] C4. Retry hanya untuk method idempotent (risiko transaksi ganda)
Severity: 9/10 — `lib/src/network/dio_retry_interceptor.dart:66-106`
Saat ini POST/PUT/PATCH/DELETE ikut diretry pada timeout & 5xx → potensi double payment.
- [ ] Default: retry hanya GET/HEAD/OPTIONS; POST wajib opt-in via idempotency key
- [ ] Tambah jitter pada backoff (`calculateDelay`, `:32-39`) untuk hindari thundering herd
- **DoD:** Test membuktikan POST tidak diretry by default; GET tetap diretry; ada test idempotency-key.
```dart
bool _isIdempotent(RequestOptions o) =>
    const {'GET', 'HEAD', 'OPTIONS'}.contains(o.method.toUpperCase()) ||
    o.extra['idempotencyKey'] != null;
```

### [ ] C5. Serialisasi token refresh (cegah stampede)
Severity: 8/10 — `lib/src/network/dio_client.dart:326-352`
Tidak ada lock → 401 paralel memicu banyak refresh bersamaan → logout acak.
- [ ] Gunakan single in-flight `Completer`/`Future`; antrekan request lain & replay setelah satu refresh selesai
- **DoD:** Test: N request 401 bersamaan hanya memicu 1 pemanggilan `refreshToken`.

### [ ] M5. Cache: beri batas LRU + key yang sadar identitas
Severity: 7/10 — `lib/src/network/dio_client.dart:54,99,309-314`
Cache unbounded (memory leak) + key path+query saja → data user A bisa terbaca user B.
- [ ] Batasi ukuran cache (LRU) + eviction entry kedaluwarsa
- [ ] Sertakan komponen identitas/token ke dalam `_cacheKey`
- [ ] Kosongkan/invalidate cache saat `setAuthToken`/`clearAuthToken`
- **DoD:** Test: ganti token → cache lama tidak terpakai; cache tidak tumbuh tak terbatas.

### [ ] M6. Jangan log data sensitif tanpa syarat
Severity: 7/10 — `lib/src/domain/safe_call.dart:12-19,31,68`
Logger module-level mencatat full result (PII/token) tanpa guard release.
- [ ] Gate semua log di belakang flag (mis. `kReleaseMode` / parameter)
- [ ] Jangan pernah log full payload secara default
- **DoD:** Build release tidak mengeluarkan body response ke log.

---

## P2 — DESAIN & API (koherensi, kebersihan permukaan publik)

### [ ] M1. Satukan model error/result
Severity: 7/10 — `lib/src/domain/failures.dart` vs `lib/src/network/api_response.dart`; dua file `safe_call.dart`
- [ ] Pilih satu model (`Result`/`Failure`) dan map `NetworkException` → `Failure`
- [ ] Hapus salah satu `safe_call.dart` yang duplikatif (`domain/` vs `network/`)
- **DoD:** Hanya satu jalur error; README tidak perlu konversi manual.

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
