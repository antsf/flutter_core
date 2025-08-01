import 'package:flutter/widgets.dart';

/// Extensions on List<Widget>
extension ListWidgetX on List<Widget> {
  /// Adds [separator] between every existing widget
  List<Widget> separatedBy(Widget separator) {
    if (isEmpty) return this;
    final result = <Widget>[];
    for (var i = 0; i < length; i++) {
      result.add(this[i]);
      if (i != length - 1) result.add(separator);
    }
    return result;
  }

  /// Adds [space] of a given height (vertical) or width (horizontal)
  List<Widget> spaceBetween(double space, {Axis axis = Axis.vertical}) {
    return separatedBy(
      axis == Axis.vertical ? SizedBox(height: space) : SizedBox(width: space),
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
