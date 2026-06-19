# Code Review — flutter_core v1.0.3

> Tanggal review: 2026-06-18  
> Reviewer: Claude Sonnet 4.6  
> Branch: `main`

---

## Ringkasan

Package ini adalah Flutter core library dengan arsitektur Clean Architecture yang solid. Secara keseluruhan kodenya terstruktur dengan baik, namun ada beberapa **bug nyata**, sejumlah **code smell**, dan beberapa **peluang optimisasi** yang perlu diperhatikan.

---

## Bug

### 1. `LocalStorage`: Asymmetry antara `_toString` dan `_fromString` untuk `Map`

**File:** `lib/src/core/storage/local_storage.dart` — baris 89–101

`_toString<T>()` sudah menangani `Map<String, dynamic>` dengan `jsonEncode`, tapi `_fromString<T>()` **tidak** menangani decode-nya. Hasilnya: Anda bisa menyimpan Map tapi tidak bisa membacanya kembali — akan melempar `UnsupportedError`.

```dart
// _toString: bisa encode Map
String _toString<T>(T value) {
  if (T == Map<String, dynamic>) {
    return jsonEncode(value); // ✅ OK
  }
  return value.toString();
}

// _fromString: TIDAK bisa decode Map
T? _fromString<T>(String raw) {
  if (T == String) return raw as T;
  if (T == int) return int.tryParse(raw) as T?;
  if (T == double) return double.tryParse(raw) as T?;
  if (T == bool) return (raw.toLowerCase() == 'true') as T;
  throw UnsupportedError('Type $T not supported'); // ❌ Map akan crash di sini
}
```

**Fix:**
```dart
T? _fromString<T>(String raw) {
  if (T == String) return raw as T;
  if (T == int) return int.tryParse(raw) as T?;
  if (T == double) return double.tryParse(raw) as T?;
  if (T == bool) return (raw.toLowerCase() == 'true') as T;
  if (T == Map<String, dynamic>) return jsonDecode(raw) as T?;
  throw UnsupportedError('LocalStorage: Type $T not supported. Supported: String, int, double, bool, Map<String, dynamic>');
}
```

---

### 2. `Failure.statusCode` default value semantically salah

**File:** `lib/src/core/domain/failures/failures.dart` — baris 21

Default `statusCode` untuk semua `Failure` adalah `200`, yang berarti **sukses** dalam HTTP. Ini menyesatkan — sebuah objek failure tidak seharusnya memiliki status code 200 sebagai default.

```dart
const Failure({
  required this.message,
  this.error,
  this.stackTrace,
  this.statusCode = 200, // ❌ 200 = HTTP OK, sangat menyesatkan untuk failure
});
```

**Fix:** Ganti ke `0` atau `-1` sebagai sentinel value yang tidak ambigu:
```dart
this.statusCode = 0, // 0 = tidak ada status code HTTP yang relevan
```

---

### 3. `safeRemoteCall` menggunakan `AuthFailure` sebagai fallback generic

**File:** `lib/src/core/data/repositories/safe_call.dart` — baris 51

Ketika `result.failure` adalah null (kondisi yang seharusnya tidak terjadi), kode ini mengembalikan `AuthFailure`. Ini akan membuat consumer salah mengira terjadi error autentikasi padahal mungkin itu error lain.

```dart
return Error(result.failure != null
    ? mapToFailure(result.failure!)
    : AuthFailure(message: genericError)); // ❌ Bukan error autentikasi!
```

**Fix:**
```dart
return Error(result.failure != null
    ? mapToFailure(result.failure!)
    : GenericFailure(message: genericError)); // ✅
```

---

### 4. `safeCall` (network layer) membuat `DioException` bersarang secara tidak perlu

**File:** `lib/src/core/network/safe_call.dart` — baris 41–48

Kode ini membuat `DioException` di dalam `DioException` hanya untuk mendapatkan `requestOptions`. Ini berlebihan dan membingungkan.

```dart
// ❌ Kode saat ini
return ApiResponse.failure(
  UnknownNetworkException(
    dioException: DioException(
      requestOptions:
          DioException(requestOptions: RequestOptions(path: 'safeCall'))
              .requestOptions, // membuat DioException hanya untuk ambil requestOptions!
      message: e.toString(),
    ),
  ),
);
```

**Fix:**
```dart
// ✅ Disederhanakan
return ApiResponse.failure(
  UnknownNetworkException(
    dioException: DioException(
      requestOptions: RequestOptions(path: 'safeCall'),
      message: e.toString(),
    ),
  ),
);
```

---

### 5. `ResultExtension` mendefinisikan ulang `isSuccess`/`isFailure` yang sudah ada di class

**File:** `lib/src/core/domain/failures/failures.dart` — baris 153–159

`Result` abstract class sudah mendefinisikan `isSuccess` dan `isFailure` sebagai abstract getter, dan `Success`/`Error` sudah mengimplementasikannya. `ResultExtension` mendefinisikan ulang keduanya dengan implementasi berbeda:

```dart
// Di abstract class Result:
bool get isSuccess; // abstract, diimplementasi oleh Success (true) dan Error (false)

// Di ResultExtension:
bool get isSuccess => data != null && failure == null; // ← TIDAK PERNAH dipanggil
                                                        // karena class member lebih prioritas
```

Karena class member selalu menang atas extension member di Dart, getter di `ResultExtension` ini adalah **dead code** dan tidak pernah dipanggil melalui accessor normal. Ini menyesatkan karena seolah-olah `Success(null)` (dipakai di `FutureResult<void>`) akan mengembalikan `isSuccess = false`, padahal kelas `Success` mengembalikan `true`.

**Fix:** Hapus definisi `isSuccess` dan `isFailure` dari `ResultExtension` — biarkan hanya `requiredData` dan `when`.

---

### 6. `UseCase.cancel()` memiliki potensi race condition

**File:** `lib/src/core/domain/usecases/base_usecase.dart` — baris 147–152

`_cancelController` di-null-kan di akhir `call()` (finally block). Jika `cancel()` dipanggil setelah `call()` selesai (controller sudah null), method ini diam-diam tidak melakukan apa-apa. Namun lebih berbahaya: jika `cancel()` dipanggil saat `call()` sedang berjalan dan controller baru saja di-assign, ada window di mana `_cancelController` bisa null sebentar.

Ini low-risk tapi perlu diperhatikan jika UseCase di-reuse secara concurrent.

---

## Code Smell & Kualitas Kode

### 7. Komentar `// 🚀 UPDATED` masih ada di production code

**File:** `lib/src/core/data/repositories/base_repository_impl.dart` — baris 263, 316, 363, 409, 463

Komentar seperti `/// 🚀 UPDATED to use safeRemoteCall` adalah catatan development, bukan dokumentasi. Ini harus dihapus dari kode final.

---

### 8. Banyak blok kode yang dikomentari

File-file berikut memiliki blok kode komentar yang besar dan mengurangi keterbacaan:

- `dio_client.dart` — retry interceptor, cache config (di-comment di banyak tempat)
- `base_repository_impl.dart` — `remoteCallWrapper` lama di hampir setiap method
- `string_ext.dart` — demo `main()` function di akhir file
- `pubspec.yaml` — dependency Hive, encrypt

Hapus atau pindahkan ke branch terpisah / CHANGELOG.

---

### 9. `safeRemoteCall` memiliki logger hardcoded

**File:** `lib/src/core/data/repositories/safe_call.dart` — baris 15–22

Logger di-instantiate langsung di file utility ini, bukan di-inject. Ini menyulitkan testing dan mengurangi fleksibilitas.

```dart
final _logger = Logger(
  printer: PrettyPrinter(...), // hardcoded
);
```

---

### 10. `mapToFailure` tidak melakukan apa-apa

**File:** `lib/src/core/data/repositories/safe_call.dart` — baris 69–72

Function ini hanya me-return failure yang sama dan log pesan. Tidak ada mapping apapun. Nama fungsi menyiratkan transformasi tapi tidak ada.

```dart
Failure mapToFailure(Failure failure) {
  _logger.w('Mapped failure: ${failure}'); // hanya log
  return failure; // kembalikan as-is
}
```

Hapus function ini dan panggil `result.failure!` langsung, atau implementasikan mapping yang nyata.

---

### 11. `_requestWithSafeCallApi` memiliki komentar yang salah

**File:** `lib/src/core/network/dio_client.dart` — baris 462

```dart
await _checkConnectivity(); // ← dipanggil di sini
return safeCall<T>(() async {
  // Note: We assume _checkConnectivity is handled either before this function
  // is called or within the requestFunction's internal logic. ← komentar salah!
```

`_checkConnectivity()` sudah dipanggil tepat di atas komentar tersebut. Komentar ini menyesatkan dan harus dihapus.

---

### 12. `ResultExtension.when()` menggunakan cast yang tidak aman

**File:** `lib/src/core/domain/failures/failures.dart` — baris 188–194

```dart
if (isSuccess) {
  return onSuccess((this as Success<T, F>).value); // bisa throw jika subclass custom
} else {
  return onFailure((this as Error<T, F>).error); // bisa throw jika subclass custom
}
```

Karena `Result` tidak `sealed`, class-nya bisa di-subclass. Cast ini bisa melempar `TypeError` jika ada subclass custom. Lebih aman menggunakan `is` check:

```dart
if (this is Success<T, F>) {
  return onSuccess((this as Success<T, F>).value);
} else if (this is Error<T, F>) {
  return onFailure((this as Error<T, F>).error);
} else {
  throw StateError('Unknown Result subtype: $runtimeType');
}
```

---

## Optimisasi

### 13. `BaseRepositoryImpl` — pattern result check diulang 5+ kali

**File:** `lib/src/core/data/repositories/base_repository_impl.dart`

Pattern ini muncul di setiap method (`getAll`, `getById`, `create`, `update`, `search`, `getPaginated`):

```dart
if (result.isSuccess && result.data != null) {
  return Success(result.data as T);
} else {
  return Error(result.failure ?? const GenericFailure(message: '...'));
}
```

Buat helper private:

```dart
FutureResult<T> _unwrapResult<T>(
  Result<T?, Failure> result,
  String fallbackMessage,
) {
  if (result.isSuccess && result.data != null) {
    return Future.value(Success(result.data as T));
  }
  return Future.value(Error(result.failure ?? GenericFailure(message: fallbackMessage)));
}
```

---

### 14. `_getAllFromRemote` memiliki try-catch ganda yang redundan

**File:** `lib/src/core/data/repositories/base_repository_impl.dart` — baris 149–176

`safeRemoteCall` sudah menangani exception, tapi `remoteCall` di dalamnya juga memiliki try-catch sendiri. Ini redundant untuk beberapa method:

```dart
// Di _getAllFromRemote:
final result = await safeRemoteCall<List<M>, List<T>>(
  remoteCall: () async {
    try { // ← try-catch ini redundant, safeRemoteCall sudah handle
      final models = await remoteDataSource!.getAll();
      return Success(models);
    } catch (e, s) {
      return Error(NetworkFailure(...));
    }
  },
```

Tapi di method lain seperti `update`, tidak ada inner try-catch. Ini inkonsisten. Pilih satu pendekatan.

---

### 15. `LocalStorage.clearBox` dan `deleteBoxFromDisk` melakukan hal yang sama

**File:** `lib/src/core/storage/local_storage.dart` — baris 68–83

```dart
Future<void> clearBox(String boxName) async {
  final all = await _storage.readAll();
  final keysToDelete = all.keys.where((k) => k.startsWith('$boxName|'));
  await Future.wait(keysToDelete.map((key) => _storage.delete(key: key)));
}

Future<void> deleteBoxFromDisk(String boxName) async =>
    await clearBox(boxName); // ← hanya memanggil clearBox
```

`deleteBoxFromDisk` hanyalah alias, tidak ada bedanya dengan `clearBox`. Pertimbangkan untuk menghapus salah satu atau mendokumentasikan perbedaan semantiknya dengan jelas.

---

### 16. `path_provider` dan `rxdart` di-import tapi tidak dipakai di core

**File:** `pubspec.yaml` — baris 39–41

`path_provider` dan `rxdart` terdaftar sebagai dependency, tapi tidak ada penggunaannya di source code utama (mungkin untuk fitur yang sudah di-comment). Hapus jika tidak dipakai untuk meminimalkan ukuran package.

```bash
# Cek penggunaan:
grep -r "path_provider\|rxdart" lib/
```

---

### 17. `dio_cache_interceptor` terdaftar sebagai dependency tapi tidak digunakan

**File:** `pubspec.yaml` — baris 22

`dio_cache_interceptor: ^3.5.0` ter-import di pubspec tapi implementasinya dikomentari. Hapus dari dependency sampai benar-benar diaktifkan.

---

## Fitur yang Bisa Ditambahkan

### A. `LocalStorage`: Method `getAllValues<T>()` untuk mengambil semua nilai di satu box

Saat ini hanya ada `getKeys()`. Untuk mendapatkan semua data dalam sebuah box, user harus loop sendiri. Tambahkan:

```dart
Future<Map<String, T?>> getAllValues<T>(String boxName) async {
  final all = await _storage.readAll();
  final result = <String, T?>{};
  for (final entry in all.entries) {
    if (entry.key.startsWith('$boxName|')) {
      final key = entry.key.substring(boxName.length + 1);
      result[key] = _fromString<T>(entry.value);
    }
  }
  return result;
}
```

---

### B. `Result`: Tambahkan method `map()` untuk transformasi

Saat ini untuk mentransformasi Result harus menggunakan `when()`. Method `map()` lebih idiomatis:

```dart
extension ResultMapExtension<T, F> on Result<T, F> {
  Result<R, F> map<R>(R Function(T value) transform) {
    if (this is Success<T, F>) {
      return Success(transform((this as Success<T, F>).value));
    }
    return Error((this as Error<T, F>).error);
  }

  Result<T, G> mapError<G>(G Function(F failure) transform) {
    if (this is Error<T, F>) {
      return Error(transform((this as Error<T, F>).error));
    }
    return Success((this as Success<T, F>).value);
  }
}
```

---

### C. `Result`: Jadikan `sealed class` (Dart 3)

Saat ini `Result` adalah abstract class. Dengan menjadikannya `sealed`, compiler bisa enforce exhaustive pattern matching:

```dart
sealed class Result<T, F> {
  const Result();
}

final class Success<T, F> extends Result<T, F> { ... }
final class Error<T, F> extends Result<T, F> { ... }

// Usage dengan pattern matching:
switch (result) {
  case Success(:final value): print('Got: $value');
  case Error(:final error): print('Error: $error');
}
```

---

### D. `DioClient`: Aktifkan Retry Interceptor

`DioRetryInterceptor` sudah ada di `lib/src/core/network/dio_retry_interceptor.dart` tapi dikomentari. Retry logic dengan exponential backoff sangat berguna untuk production:

```dart
// Aktifkan di constructor DioClient
DioClient({
  // ...
  RetryOptions retryOptions = const RetryOptions(maxAttempts: 3),
})
```

---

### E. `StringExt`: Tambahkan `isValidEmail()` dan `isValidPhone()` validator

Sudah ada `maskEmail()` dan `formatPhoneNumber()` tapi tidak ada validator:

```dart
extension StringExt on String {
  bool get isValidEmail {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(this);
  }

  bool get isValidIndonesianPhone {
    final digits = replaceAll(RegExp(r'\D'), '');
    return RegExp(r'^(62|0)[0-9]{9,12}$').hasMatch(digits);
  }
}
```

---

### F. `UseCase`: Tambahkan support `Stream` result

Saat ini `UseCase` hanya mendukung `Future`. Untuk use case yang butuh real-time data (misal polling, live updates), tambahkan `StreamUseCase`:

```dart
abstract class StreamUseCase<Type, Params> {
  Stream<Result<Type, Failure>> call(Params params);
}
```

---

### G. `BaseRepositoryImpl`: Tambahkan TTL untuk cache

Cache saat ini tidak memiliki Time-To-Live. Data bisa stale selamanya:

```dart
// Contoh pendekatan sederhana
abstract class BaseRepositoryImpl<T, M> {
  final Duration? cacheTtl; // null = tidak expire
  
  // Simpan timestamp saat cache:
  Future<void> _saveWithTimestamp(T entity) async {
    await localDataSource?.save(entity);
    await localDataSource?.saveTimestamp(entity.id, DateTime.now());
  }
  
  Future<bool> _isCacheExpired(String id) async {
    if (cacheTtl == null) return false;
    final timestamp = await localDataSource?.getTimestamp(id);
    if (timestamp == null) return true;
    return DateTime.now().difference(timestamp) > cacheTtl!;
  }
}
```

---

## Ringkasan Prioritas

| # | Item | Tipe | Prioritas |
|---|------|------|-----------|
| 1 | `LocalStorage._fromString` tidak handle `Map` | Bug | **Tinggi** |
| 2 | `Failure.statusCode` default `200` | Bug | **Tinggi** |
| 3 | `safeRemoteCall` return `AuthFailure` sebagai fallback | Bug | **Tinggi** |
| 4 | `safeCall` DioException bersarang | Bug | Sedang |
| 5 | `ResultExtension` isSuccess/isFailure dead code | Bug/Smell | Sedang |
| 6 | `UseCase` race condition pada cancel | Bug | Rendah |
| 7 | Komentar `🚀 UPDATED` di production code | Smell | Sedang |
| 8 | Banyak blok kode dikomentari | Smell | Sedang |
| 9 | Logger hardcoded di `safeRemoteCall` | Smell | Rendah |
| 10 | `mapToFailure` tidak melakukan apa-apa | Smell | Rendah |
| 11 | Komentar salah di `_requestWithSafeCallApi` | Smell | Rendah |
| 12 | Unsafe cast di `when()` | Optimisasi | Sedang |
| 13 | Pattern result check berulang | Optimisasi | Rendah |
| 14 | Double try-catch di `_getAllFromRemote` | Optimisasi | Rendah |
| 15 | `deleteBoxFromDisk` alias tanpa dokumentasi | Smell | Rendah |
| 16 | Dependency `path_provider`/`rxdart` tidak dipakai | Optimisasi | Sedang |
| 17 | `dio_cache_interceptor` terdaftar tapi tidak dipakai | Optimisasi | Sedang |
| A | `LocalStorage.getAllValues<T>()` | Fitur | Sedang |
| B | `Result.map()` transformer | Fitur | Sedang |
| C | `Result` sebagai `sealed class` | Fitur | Rendah |
| D | Aktifkan Retry Interceptor | Fitur | **Tinggi** |
| E | `isValidEmail()` / `isValidPhone()` validator | Fitur | Sedang |
| F | `StreamUseCase` | Fitur | Rendah |
| G | Cache TTL di `BaseRepositoryImpl` | Fitur | Rendah |
