import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// --- MOCK DEPENDENCIES ---

// 1. Mock UiExt (or similar) to provide spacing widgets, as required by spaceBetween.
// We make these return SizedBoxes with the correct dimension set.
extension MockUiExt on num {
  Widget get spacingHeight => SizedBox(height: toDouble());
  Widget get spacingWidth => SizedBox(width: toDouble());
}

// --- EXTENSIONS UNDER TEST (Copied/Inlined for testing environment) ---

/// Extensions on List<Widget>
extension ListWidgetX on List<Widget> {
  /// Adds [separator] between every existing widget
  List<Widget> separatedBy(Widget separator) {
    if (this.isEmpty) return this;
    final result = <Widget>[];
    for (var i = 0; i < length; i++) {
      result.add(this[i]);
      if (i != length - 1) result.add(separator);
    }
    return result;
  }

  /// Adds [space] of a given height (vertical) or width (horizontal)
  List<Widget> spaceBetween(double space, {Axis axis = Axis.vertical}) {
    // Uses the mocked UiExt getters (spacingHeight/spacingWidth)
    return separatedBy(
      axis == Axis.vertical ? space.spacingHeight : space.spacingWidth,
    );
  }

  /// Surrounds the entire list with [leading] and [trailing] widgets
  List<Widget> surroundWith({Widget? leading, Widget? trailing}) {
    return [
      if (leading != null) leading,
      ...this,
      if (trailing != null) trailing,
    ];
  }

  /// Adds [widget] only when [condition] is true
  List<Widget> addIf(bool condition, Widget widget) {
    return condition ? [...this, widget] : this;
  }

  /// Adds [ifTrue] when condition is true, otherwise [ifFalse]
  List<Widget> addIfElse(bool condition, Widget ifTrue, Widget ifFalse) {
    return [...this, condition ? ifTrue : ifFalse];
  }

  /// Adds every widget in [widgets] if [condition] is true
  List<Widget> addAllIf(bool condition, Iterable<Widget> widgets) {
    return condition ? [...this, ...widgets] : this;
  }

  /// Adds [ifTrue] list when condition is true, otherwise [ifFalse] list
  List<Widget> addAllIfElse(
    bool condition,
    Iterable<Widget> ifTrue,
    Iterable<Widget> ifFalse,
  ) {
    return [...this, ...(condition ? ifTrue : ifFalse)];
  }
}

/// Extensions on a single Widget
extension WidgetX on Widget {
  /// Returns a list containing only this widget
  List<Widget> get asList => [this];

  /// Wraps this widget with [leading] and/or [trailing] siblings
  List<Widget> surroundWith({Widget? leading, Widget? trailing}) {
    return [
      if (leading != null) leading,
      this,
      if (trailing != null) trailing,
    ];
  }
}

// --- UNIT TESTS ---

void main() {
  const Widget widgetA = Placeholder(key: ValueKey('A'));
  const Widget widgetB = Placeholder(key: ValueKey('B'));
  const Widget separator = Divider(key: ValueKey('Separator'));
  const Widget leading = Placeholder(key: ValueKey('Leading'));
  const Widget trailing = Placeholder(key: ValueKey('Trailing'));
  const Widget ifTrue = Placeholder(key: ValueKey('IfTrue'));
  const Widget ifFalse = Placeholder(key: ValueKey('IfFalse'));

  group('ListWidgetX', () {
    final list = [widgetA, widgetB];
    final emptyList = <Widget>[];

    test('separatedBy inserts separator correctly', () {
      final result = list.separatedBy(separator);
      expect(result.length, 3);
      expect(result[0], widgetA);
      expect(result[1], separator);
      expect(result[2], widgetB);
    });

    test('separatedBy returns empty list if source is empty', () {
      final result = emptyList.separatedBy(separator);
      expect(result, isEmpty);
    });

    testWidgets('spaceBetween creates vertical spacing correctly',
        (tester) async {
      final result = list.spaceBetween(15.0, axis: Axis.vertical);
      // The list should be [widgetA, SizedBox(height: 15.0), widgetB]
      expect(result.length, 3);
      expect(result[1], isA<SizedBox>());
      expect((result[1] as SizedBox).height, 15.0);
      expect((result[1] as SizedBox).width, isNull);
    });

    testWidgets('spaceBetween creates horizontal spacing correctly',
        (tester) async {
      final result = list.spaceBetween(10.0, axis: Axis.horizontal);
      // The list should be [widgetA, SizedBox(width: 10.0), widgetB]
      expect(result.length, 3);
      expect(result[1], isA<SizedBox>());
      expect((result[1] as SizedBox).width, 10.0);
      expect((result[1] as SizedBox).height, isNull);
    });

    test('surroundWith adds leading and trailing widgets', () {
      final result = list.surroundWith(leading: leading, trailing: trailing);
      expect(result.length, 4);
      expect(result.first, leading);
      expect(result.last, trailing);
      expect(result[1], widgetA);
    });

    test('surroundWith adds only leading widget', () {
      final result = list.surroundWith(leading: leading);
      expect(result.length, 3);
      expect(result.first, leading);
    });

    test('addIf adds widget when condition is true', () {
      final result = list.addIf(true, widgetA);
      expect(result.length, 3);
      expect(result.last, widgetA);
    });

    test('addIf does not add widget when condition is false', () {
      final result = list.addIf(false, widgetA);
      expect(result.length, 2);
    });

    test('addIfElse adds ifTrue widget when condition is true', () {
      final result = list.addIfElse(true, ifTrue, ifFalse);
      expect(result.length, 3);
      expect(result.last, ifTrue);
    });

    test('addIfElse adds ifFalse widget when condition is false', () {
      final result = list.addIfElse(false, ifTrue, ifFalse);
      expect(result.length, 3);
      expect(result.last, ifFalse);
    });

    test('addAllIf adds all widgets when condition is true', () {
      final widgetsToAdd = [leading, trailing];
      final result = list.addAllIf(true, widgetsToAdd);
      expect(result.length, 4);
      expect(result.last, trailing);
    });

    test('addAllIf does not add any widgets when condition is false', () {
      final widgetsToAdd = [leading, trailing];
      final result = list.addAllIf(false, widgetsToAdd);
      expect(result.length, 2);
    });

    test('addAllIfElse adds ifTrue list when condition is true', () {
      final listIfTrue = [leading, leading];
      final listIfFalse = [trailing];
      final result = list.addAllIfElse(true, listIfTrue, listIfFalse);
      expect(result.length, 4);
      expect(result.last, leading);
    });

    test('addAllIfElse adds ifFalse list when condition is false', () {
      final listIfTrue = [leading, leading];
      final listIfFalse = [trailing];
      final result = list.addAllIfElse(false, listIfTrue, listIfFalse);
      expect(result.length, 3);
      expect(result.last, trailing);
    });
  });

  group('WidgetX', () {
    test('asList converts a single widget to a list of one', () {
      final result = widgetA.asList;
      expect(result, isA<List<Widget>>());
      expect(result.length, 1);
      expect(result.first, widgetA);
    });

    test('surroundWith wraps widget correctly with leading and trailing', () {
      final result = widgetA.surroundWith(leading: leading, trailing: trailing);
      expect(result.length, 3);
      expect(result[0], leading);
      expect(result[1], widgetA);
      expect(result[2], trailing);
    });

    test('surroundWith wraps widget correctly with only trailing', () {
      final result = widgetA.surroundWith(trailing: trailing);
      expect(result.length, 2);
      expect(result[0], widgetA);
      expect(result[1], trailing);
    });
  });
}
