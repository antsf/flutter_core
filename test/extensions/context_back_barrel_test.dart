import 'dart:async';

import 'package:flutter/material.dart';
// Import via the barrel so BOTH NavigationExtension and DialogsAndAlerts are in
// scope — this is exactly the case where a duplicated `back()` would make
// `context.back()` ambiguous and fail to compile (regression guard for M9).
import 'package:flutter_corekit/flutter_corekit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('context.back() is unambiguous when imported via the barrel',
      (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (c) {
            ctx = c;
            return const Scaffold(body: Text('home'));
          },
        ),
      ),
    );

    unawaited(ctx.to(const Scaffold(body: Text('next'))));
    await tester.pumpAndSettle();
    expect(find.text('next'), findsOneWidget);

    ctx.back(); // would not compile if `back()` were ambiguous
    await tester.pumpAndSettle();
    expect(find.text('next'), findsNothing);
    expect(find.text('home'), findsOneWidget);
  });
}
