# Refactor Plan — flutter_core

> Dibuat: 2026-06-18  
> Diimplementasikan: 2026-06-18 di branch `refactor/core-cleanup`  
> Status: **Tahap 1–3 SELESAI** | Tahap 4 perlu diskusi tim

---

## Prinsip Perubahan

1. **Pertahankan** apa yang berguna dan tidak opinionated (extensions, formatters, colors)
2. **Hapus** abstraksi yang conflict dengan ecosystem modern Flutter (Riverpod, BLoC, freezed)
3. **Perbaiki** bug nyata sebelum mengerjakan hal lain
4. **Sederhanakan** API yang membingungkan menjadi satu pattern yang konsisten

---

## Tahap 1 — Bug Fix ✅ SELESAI

### 1.1 `LocalStorage` tidak bisa baca `Map<String, dynamic>` ✅
**File:** `lib/src/core/storage/local_storage.dart`
Ditambahkan `if (T == Map<String, dynamic>) return jsonDecode(raw) as T?;` di `_fromString`.

### 1.2 `Failure.statusCode` default `200` ✅
**File:** `lib/src/core/domain/failures/failures.dart`
Diubah dari `200` menjadi `0`.

### 1.3 `safeRemoteCall` return `AuthFailure` sebagai fallback ✅
**File:** `lib/src/core/data/repositories/safe_call.dart`
Diubah dari `AuthFailure` menjadi `GenericFailure`.

### 1.4 `safeCall` (network) — nested `DioException` tidak perlu ✅
**File:** `lib/src/core/network/safe_call.dart`
Disederhanakan menjadi `RequestOptions(path: 'safeCall')` langsung.

### 1.5 `ui_ext.dart` — breaking change Flutter SDK terbaru ✅
**File:** `lib/src/extensions/ui_ext.dart`, `test/extensions/ui_extensions_test.dart`
Return type diubah ke `InputDecorationThemeData`.

---

## Tahap 2 — Hapus / Bersihkan ✅ SELESAI

### 2.1 Dependency yang tidak dipakai ✅
- `path_provider` — dihapus dari pubspec
- `dio_cache_interceptor` — dihapus dari pubspec
- `rxdart` — dihapus dari pubspec, diganti implementasi native Dart

### 2.2 File stub yang isinya 100% komentar ✅
Dihapus:
- `lib/src/core/network/dio_cache_config.dart`
- `lib/src/core/storage/secure_storage_service.dart`
- `lib/src/core/storage/key_manager.dart`
- `lib/src/core/services/storage_service.dart`

### 2.3 Komentar development di production code ✅
- Semua komentar `/// 🚀 UPDATED to use safeRemoteCall` dihapus
- Semua blok `remoteCallWrapper` yang dikomentari dihapus dari `BaseRepositoryImpl`
- Demo `main()` dihapus dari `string_ext.dart` dan `number_ext.dart`

### 2.4 `ResultExtension` — hapus duplikasi dead code ✅
`isSuccess` dan `isFailure` dihapus dari extension (class member selalu menang).
`when()` diupdate dengan `is` type check yang lebih aman.

### 2.5 `mapToFailure` — fungsi yang tidak melakukan apa-apa ✅
Dihapus, diganti dengan `result.failure!` langsung.

---

## Tahap 3 — Tambah & Improve ✅ SELESAI

### 4.1 `LocalStorage.getAllValues<T>()` ✅
Ditambahkan — mengembalikan semua key-value di satu box sebagai `Map<String, T?>`.

### 4.2 `StringExt` — validator email dan nomor HP Indonesia ✅
Ditambahkan `isValidEmail` dan `isValidIndonesianPhone` getter.

### 4.3 `Result` — tambahkan `map()` dan `mapFailure()` transformer ✅
Ditambahkan ke `ResultExtension`.

### 4.4 Aktifkan `DioRetryInterceptor` ✅
File `dio_retry_interceptor.dart` di-uncomment dan dibersihkan.
`DioClient` ditambahkan parameter `retryOptions` dengan default 3 attempts.

---

## Tahap 4 — Pertimbangkan (Perlu Diskusi Tim)

Item berikut membutuhkan keputusan lebih besar — pertimbangkan jika package ini akan dipublikasikan ke pub.dev atau dipakai lintas tim.

| Item | Opsi A | Opsi B |
|---|---|---|
| `BaseRepositoryImpl` | Pertahankan tapi dokumentasikan keterbatasan vs Riverpod/BLoC | Pindahkan ke package terpisah `flutter_core_arch` |
| `UseCase` base class | Pertahankan untuk tim yang pakai clean arch | Hapus, ganti dengan README/contoh pattern saja |
| `BaseModel<T>` | Pertahankan | Hapus, buat consumer pakai `freezed` langsung |
| `ThemeProvider` | Pertahankan (ChangeNotifier) | Sediakan juga versi Riverpod/BLoC |
| `flutter_screenutil` coupling | Pertahankan | Jadikan optional agar package tidak memaksa ScreenUtil |

---

## Hasil Akhir

```
flutter analyze → No issues found ✅
Dependency berkurang: -3 (rxdart, dio_cache_interceptor, path_provider)
File dihapus: 4 stub files
Breaking changes: UseCase type param Type→Output, Failure.statusCode default 0→200, rxdart tidak di-re-export
Versi: 1.0.3 → 1.1.0
```
