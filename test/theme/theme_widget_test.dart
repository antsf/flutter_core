// test/theme/theme_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_corekit/flutter_corekit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_helpers.dart';

void main() {
  late ThemeProvider provider;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    initScreenUtilForTests();

    // Plain TextStyle builder instead of GoogleFonts.inter so the theme never
    // triggers a real font fetch (flaky under parallel load).
    setFontBuilderForTesting(setFontForTesting);

    // ThemeProvider is a singleton; reset so state doesn't leak between tests.
    ThemeProvider.reset();
    provider = ThemeProvider.instance;
  });

  testWidgets('MyApp rebuilds on theme change', (tester) async {
    await tester.pumpWidget(
      ListenableBuilder(
        listenable: provider,
        builder: (context, _) {
          return MaterialApp(
            theme: provider.currentTheme,
            home: const Scaffold(
              body: Center(child: Text('Theme Test')),
            ),
          );
        },
      ),
    );

    expect(provider.currentTheme.brightness, Brightness.light);

    await provider.toggleTheme();
    await tester.pump();

    expect(provider.currentTheme.brightness, Brightness.dark);

    // The choice was persisted.
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(ThemeProvider.themeKey), isTrue);
  });
}
