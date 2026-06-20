import 'dart:async';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_corekit/flutter_corekit.dart';
import 'package:flutter_test/flutter_test.dart';

// --- EXTENSIONS UNDER TEST ---

// extension StreamExtension<T> on Stream<T> {
//   /// Shortcut for debounceTime(Duration(milliseconds: ms))
//   Stream<T> debounce(int ms) => debounceTime(Duration(milliseconds: ms));

//   /// Shortcut for throttleTime(Duration(milliseconds: ms))
//   Stream<T> throttle(int ms) => throttleTime(Duration(milliseconds: ms));
// }

// extension NullableExtension<T> on T? {
//   /// Run block if value is NOT null
//   R? let<R>(R Function(T) block) => this == null ? null : block(this as T);

//   /// Provide default when null
//   T or(T defaultValue) => this ?? defaultValue;

//   /// true if value is null
//   bool get isNull => this == null;

//   /// true if value is NOT null
//   bool get isNotNull => this != null;
// }

// extension NullableMapExtension<K, V> on Map<K, V>? {
//   /// true if null OR empty
//   bool get isNullOrEmpty => this == null || this?.isEmpty == true;

//   /// true if not null and not empty
//   bool get isNotNullOrEmpty => !isNullOrEmpty;

//   /// Get value or null safely
//   V? get(K key) => this?[key];

//   /// Pretty-print with indent
//   String pretty() {
//     const encoder = JsonEncoder.withIndent('  ');
//     return encoder.convert(this);
//   }
// }

// extension NullableIterableExtension<T> on Iterable<T>? {
//   /// true if null OR empty
//   bool get isNullOrEmpty => this == null || this?.isEmpty == true;

//   /// true if not null and not empty
//   bool get isNotNullOrEmpty => !isNullOrEmpty;

//   /// Returns second element or null
//   T? get second => (this?.length ?? 0) > 1 ? this?.elementAt(1) : null;

//   /// Returns last element or null
//   T? get lastOrNull => isNullOrEmpty ? null : this?.last;

//   /// Returns first element matching test or null
//   T? firstWhereOrNull(bool Function(T) test) {
//     if (isNotNullOrEmpty) {
//       for (final e in this!) {
//         if (test(e)) return e;
//       }
//     }
//     return null;
//   }
// }

// --- UNIT TESTS ---

void main() {
  group('StreamExtension (RxDart Extensions)', () {
    // Uses fakeAsync to drive virtual time — deterministic, not wall-clock
    // dependent (the previous real-timer version flaked under load).
    test('debounce only emits the last value within the debounce period', () {
      fakeAsync((async) {
        final controller = StreamController<int>();
        final emittedValues = <int>[];

        controller.stream
            .debounce(const Duration(milliseconds: 50))
            .listen(emittedValues.add);

        // Emit values quickly
        controller.add(1);
        controller.add(2);
        async.elapse(const Duration(milliseconds: 20));
        controller.add(3); // This will be emitted

        // Wait for the debounce period to pass
        async.elapse(const Duration(milliseconds: 60));
        expect(emittedValues, [3]);

        // Emit a new value and wait to ensure it's emitted
        controller.add(4);
        async.elapse(const Duration(milliseconds: 60));
        expect(emittedValues, [3, 4]);

        controller.close();
      });
    });

    test('throttle only emits the first value within the throttle period', () {
      fakeAsync((async) {
        final controller = StreamController<int>();
        final emittedValues = <int>[];

        controller.stream
            .throttle(const Duration(milliseconds: 50))
            .listen(emittedValues.add);

        // Emit the first value - should be emitted immediately
        controller.add(1);
        async.elapse(const Duration(milliseconds: 5));
        expect(emittedValues, [1]);

        // Emit values quickly - should be ignored due to throttle
        controller.add(2);
        controller.add(3);
        async.elapse(const Duration(milliseconds: 40));
        controller.add(4); // Ignored (still within the throttle window)
        async.elapse(const Duration(milliseconds: 20));

        expect(emittedValues, [1]);

        // The throttle period should have passed now. Emit a new value.
        controller.add(5);
        async.elapse(const Duration(milliseconds: 5));
        expect(emittedValues, [1, 5]);

        controller.close();
      });
    });
  });

  group('NullableExtension Tests', () {
    test('let runs block on non-null value and returns result', () {
      int? nonNullValue = 5;
      final result = nonNullValue.let((v) => v * 2);
      expect(result, 10);
    });

    test('let returns null when value is null', () {
      int? nullValue;
      final result = nullValue.let((v) => v * 2);
      expect(result, isNull);
    });

    test('or returns value if non-null', () {
      int? value = 10;
      expect(value.or(0), 10);
    });

    test('or returns default value if null', () {
      int? value;
      expect(value.or(0), 0);
    });

    test('isNull and isNotNull operators work correctly', () {
      String? nonNull = 'test';
      String? isNull;
      expect(nonNull.isNull, isFalse);
      expect(nonNull.isNotNull, isTrue);
      expect(isNull.isNull, isTrue);
      expect(isNull.isNotNull, isFalse);
    });
  });

  group('NullableMapExtension Tests', () {
    const Map<String, int>? nullMap = null;
    final Map<String, int> emptyMap = {};
    final Map<String, int> dataMap = {'a': 1, 'b': 2};

    test('isNullOrEmpty checks correctly', () {
      expect(nullMap.isNullOrEmpty, isTrue);
      expect(emptyMap.isNullOrEmpty, isTrue);
      expect(dataMap.isNullOrEmpty, isFalse);
    });

    test('isNotNullOrEmpty checks correctly', () {
      expect(nullMap.isNotNullOrEmpty, isFalse);
      expect(emptyMap.isNotNullOrEmpty, isFalse);
      expect(dataMap.isNotNullOrEmpty, isTrue);
    });

    test('valueOrNull safely retrieves values', () {
      expect(dataMap.valueOrNull('a'), 1);
      expect(dataMap.valueOrNull('c'), isNull);
      expect(nullMap.valueOrNull('a'), isNull);
    });

    test('pretty formats the map with indentation', () {
      const expected = '''{
  "key1": "value1",
  "key2": 123
}''';
      expect({'key1': 'value1', 'key2': 123}.pretty(), expected);
      expect(nullMap.pretty(), 'null');
    });
  });

  group('NullableIterableExtension Tests', () {
    const List<int>? nullList = null;
    final List<int> emptyList = [];
    final List<int> singleList = [1];
    final List<int> dataList = [10, 20, 30, 40];

    test('isNullOrEmpty checks correctly', () {
      expect(nullList.isNullOrEmpty, isTrue);
      expect(emptyList.isNullOrEmpty, isTrue);
      expect(dataList.isNullOrEmpty, isFalse);
    });

    test('isNotNullOrEmpty checks correctly', () {
      expect(nullList.isNotNullOrEmpty, isFalse);
      expect(emptyList.isNotNullOrEmpty, isFalse);
      expect(dataList.isNotNullOrEmpty, isTrue);
    });

    test('second retrieves the second element or null', () {
      expect(nullList.second, isNull);
      expect(emptyList.second, isNull);
      expect(singleList.second, isNull);
      expect(dataList.second, 20);
    });

    test('lastOrNull retrieves the last element or null', () {
      expect(nullList.lastOrNull, isNull);
      expect(emptyList.lastOrNull, isNull);
      expect(singleList.lastOrNull, 1);
      expect(dataList.lastOrNull, 40);
    });

    test('firstWhereOrNull returns element when found', () {
      expect(dataList.firstWhereOrNull((e) => e > 25), 30);
    });

    test('firstWhereOrNull returns null when not found', () {
      expect(dataList.firstWhereOrNull((e) => e > 50), isNull);
    });

    test('firstWhereOrNull returns null for empty or null iterables', () {
      expect(emptyList.firstWhereOrNull((e) => true), isNull);
      expect(nullList.firstWhereOrNull((e) => true), isNull);
    });
  });
}
