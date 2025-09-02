import 'package:rxdart/rxdart.dart';

extension StreamX<T> on Stream<T> {
  /// Shortcut for debounceTime(Duration(milliseconds: ms))
  Stream<T> debounceMs(int ms) => debounceTime(Duration(milliseconds: ms));

  /// Shortcut for throttleTime(Duration(milliseconds: ms))
  Stream<T> throttleMs(int ms) => throttleTime(Duration(milliseconds: ms));
}
