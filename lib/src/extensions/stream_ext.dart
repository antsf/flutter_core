import 'dart:async';

/// Stream utility extensions — debounce and throttle without external dependencies.
extension StreamExtension<T> on Stream<T> {
  /// Emits a value only after [ms] milliseconds of silence (no new events).
  Stream<T> debounceMs(int ms) {
    final controller = StreamController<T>.broadcast();
    Timer? timer;
    StreamSubscription<T>? sub;
    // Subscribe to the source lazily (on first listen) and tear it down when
    // the downstream cancels, so the source isn't subscribed forever / leaked.
    controller.onListen = () {
      sub = listen(
        (event) {
          timer?.cancel();
          timer = Timer(Duration(milliseconds: ms), () {
            if (!controller.isClosed) controller.add(event);
          });
        },
        onError: (Object e, StackTrace s) {
          if (!controller.isClosed) controller.addError(e, s);
        },
        onDone: () {
          timer?.cancel();
          controller.close();
        },
      );
    };
    controller.onCancel = () {
      timer?.cancel();
      final pending = sub?.cancel();
      sub = null;
      return pending;
    };
    return controller.stream;
  }

  /// Emits the first event then ignores subsequent events for [ms] milliseconds.
  Stream<T> throttleMs(int ms) {
    final controller = StreamController<T>.broadcast();
    bool throttled = false;
    StreamSubscription<T>? sub;
    controller.onListen = () {
      sub = listen(
        (event) {
          if (!throttled) {
            throttled = true;
            if (!controller.isClosed) controller.add(event);
            Timer(Duration(milliseconds: ms), () => throttled = false);
          }
        },
        onError: (Object e, StackTrace s) {
          if (!controller.isClosed) controller.addError(e, s);
        },
        onDone: () => controller.close(),
      );
    };
    controller.onCancel = () {
      final pending = sub?.cancel();
      sub = null;
      return pending;
    };
    return controller.stream;
  }
}
