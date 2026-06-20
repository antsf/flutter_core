import 'package:fake_async/fake_async.dart';
import 'package:flutter_corekit/src/constants/default.dart';
import 'package:test/test.dart';

void main() {
  group('defaultDelay', () {
    test('completes only after kDuration', () {
      fakeAsync((async) {
        var done = false;
        defaultDelay().then((_) => done = true);

        async.elapse(kDuration - const Duration(milliseconds: 1));
        expect(done, isFalse);

        async.elapse(const Duration(milliseconds: 1));
        expect(done, isTrue);
      });
    });

    test('each call delays afresh (not a one-shot shared future)', () {
      fakeAsync((async) {
        var first = false;
        defaultDelay().then((_) => first = true);
        async.elapse(kDuration);
        expect(first, isTrue);

        // A second call must still wait the full duration. A single shared
        // future (the old `final defaultDelay = Future.delayed(...)`) would have
        // already completed and resolved this immediately.
        var second = false;
        defaultDelay().then((_) => second = true);
        expect(second, isFalse);
        async.elapse(kDuration);
        expect(second, isTrue);
      });
    });
  });
}
