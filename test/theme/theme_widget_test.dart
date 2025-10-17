// test/theme/theme_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_core/src/theme/theme_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks/mock_local_storage.dart';
import '../test_helpers.dart';

void main() {
  late MockLocalStorage mockStorage;
  late ThemeProvider provider;

  setUp(() {
    initScreenUtilForTests();

    mockStorage = MockLocalStorage();

    // ✅ Use thenAnswer for async methods (returning Future)
    when(() => mockStorage.get<bool>(any(), any()))
        .thenAnswer((_) async => false);
    when(() => mockStorage.get<String>(any(), any()))
        .thenAnswer((_) async => 'default');
    when(() => mockStorage.set<bool>(any(), any(), any()))
        .thenAnswer((_) async => true);
    when(() => mockStorage.set<String>(any(), any(), any()))
        .thenAnswer((_) async => true);

    // Inject mock
    ThemeProvider.localStorage = mockStorage;

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

    final initialBrightness = provider.currentTheme.brightness;
    expect(initialBrightness, Brightness.light);

    await provider.toggleTheme();
    await tester.pump();

    final newBrightness = provider.currentTheme.brightness;
    expect(newBrightness, Brightness.dark);
    expect(newBrightness, isNot(equals(initialBrightness)));

    verify(() => mockStorage.set<bool>(
          ThemeProvider.themeBoxName,
          ThemeProvider.themeKey,
          true,
        )).called(1);
  });
}
