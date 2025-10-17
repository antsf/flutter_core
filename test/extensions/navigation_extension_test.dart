import 'package:flutter/material.dart';
import 'package:flutter_core/src/extensions/navigation_ext.dart';
import 'package:flutter_test/flutter_test.dart';

// --- EXTENSIONS UNDER TEST ---

/// Provides extension methods on [BuildContext] for simplified navigation,
/// dialog management, and displaying SnackBars or BottomSheets.
///
/// These extensions aim to reduce boilerplate code for common UI interactions.

/// Extension methods on [BuildContext] for navigation, dialogs, and transient UI elements.
// extension NavigationExtension on BuildContext {
//   // --- Navigation ---

//   /// Navigates to a new screen using its [routeName].
//   ///
//   /// Wraps `Navigator.of(this).pushNamed<T>()`.
//   /// [routeName]: The name of the route to push.
//   /// [arguments]: Optional arguments to pass to the new route.
//   Future<T?> toNamed<T extends Object?>(
//     String routeName, {
//     Object? arguments,
//   }) =>
//       Navigator.of(this).pushNamed<T>(
//         routeName,
//         arguments: arguments,
//       );

//   /// Replaces the current screen with a new one using its [routeName].
//   ///
//   /// Wraps `Navigator.of(this).pushReplacementNamed<T, Object?>()`.
//   /// [routeName]: The name of the route to push.
//   /// [arguments]: Optional arguments to pass to the new route.
//   Future<T?> toReplacementNamed<T extends Object?>(
//     String routeName, {
//     Object? arguments,
//   }) =>
//       Navigator.of(this).pushReplacementNamed<T, Object?>(
//         routeName,
//         arguments: arguments,
//       );

//   /// Navigates to a new screen using its [routeName] and removes all previous screens
//   /// from the navigation stack.
//   ///
//   /// Wraps `Navigator.of(this).pushNamedAndRemoveUntil<T>()`.
//   /// [routeName]: The name of the route to push.
//   /// [arguments]: Optional arguments to pass to the new route.
//   Future<T?> toNamedAndRemoveUntil<T extends Object?>(
//     String routeName, {
//     Object? arguments,
//   }) =>
//       Navigator.of(this).pushNamedAndRemoveUntil<T>(
//         routeName,
//         (_) =>
//             false, // Predicate that always returns false to remove all routes
//         arguments: arguments,
//       );

//   /// Navigates to a new screen by pushing the given [page] widget.
//   ///
//   /// Wraps `Navigator.of(this).push()` with a [MaterialPageRoute].
//   /// [page]: The widget representing the new screen.
//   Future<T?> to<T extends Object?>(Widget page) => Navigator.of(this).push<T>(
//         MaterialPageRoute(builder: (_) => page),
//       );

//   /// Replaces the current screen with a new one by pushing the given [page] widget.
//   ///
//   /// Wraps `Navigator.of(this).pushReplacement()` with a [MaterialPageRoute].
//   /// [page]: The widget representing the new screen.
//   Future<T?> toReplacement<T extends Object?>(Widget page) =>
//       Navigator.of(this).pushReplacement<T, Object?>(
//         MaterialPageRoute(builder: (_) => page),
//       );

//   /// Navigates to a new screen by pushing the given [page] widget and removes
//   /// all previous screens from the navigation stack.
//   ///
//   /// Wraps `Navigator.of(this).pushAndRemoveUntil()` with a [MaterialPageRoute].
//   /// [page]: The widget representing the new screen.
//   Future<T?> toAndRemoveUntil<T extends Object?>(Widget page) =>
//       Navigator.of(this).pushAndRemoveUntil<T>(
//         MaterialPageRoute(builder: (_) => page),
//         (_) =>
//             false, // Predicate that always returns false to remove all routes
//       );

//   /// Pops the current screen from the navigation stack.
//   ///
//   /// Wraps `Navigator.of(this).pop<T>(result)`.
//   /// [result]: An optional value to return to the previous screen.
//   void back<T extends Object?>([T? result]) =>
//       Navigator.of(this).pop<T>(result);

//   /// Checks if the navigator can be popped.
//   ///
//   /// Wraps `Navigator.canPop(this)`.
//   bool canBack() => Navigator.canPop(this);

//   /// Pops all routes until the initial route.
//   /// If a [result] is provided, it's passed to the pop method for each route.
//   ///
//   /// **Caution**: This will pop all routes above the very first route in the stack.
//   /// Ensure this is the desired behavior.
//   void maybeBack<T extends Object?>([T? result]) {
//     while (canBack()) {
//       back<T>(result);
//     }
//   }

//   // --- Keyboard & Focus ---
//   /// Unfocuses all focus nodes, hiding the keyboard if open.
//   void unfocusKeyboard() {
//     FocusManager.instance.primaryFocus?.unfocus();
//   }

//   /// Requests focus for the given [FocusNode].
//   void requestFocus(FocusNode node) {
//     FocusManager.instance.primaryFocus?.unfocus();
//     FocusScope.of(this).requestFocus(node);
//   }

//   /// Returns true if any input field currently has focus.
//   bool get hasFocus => FocusManager.instance.primaryFocus != null;

//   // --- Dialogs & Modals ---

//   /// Checks if a dialog is currently open over this context.
//   ///
//   /// This is a heuristic and might not be universally accurate for all types of
//   /// modal routes or dialog implementations. It checks if the current route
//   /// associated with this context is the topmost active route.
//   bool get isDialogOpen => ModalRoute.of(this)?.isCurrent != true;

//   /// Attempts to close an open dialog if [isDialogOpen] is true.
//   ///
//   /// Uses [back] to pop the current route, which is assumed to be a dialog.
//   /// See caveats for [isDialogOpen].
//   void closeDialog() {
//     if (isDialogOpen) {
//       back();
//     }
//   }
// }

// --- TEST UTILITIES ---

/// A simple page for navigation testing.
class TestPage extends StatelessWidget {
  final String title;
  const TestPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}

// --- UNIT TESTS ---

void main() {
  late BuildContext context;
  const String route1 = '/home';
  const String route2 = '/details';
  const String route3 = '/settings';

  // Setup a test environment with a Navigator and MaterialApp.
  Widget testApp = MaterialApp(
    title: 'Test App',
    // Define named routes for testing toNamed/toReplacementNamed
    onGenerateRoute: (settings) {
      if (settings.name == route1) {
        return MaterialPageRoute(builder: (_) => const TestPage(title: 'Home'));
      } else if (settings.name == route2) {
        return MaterialPageRoute(
            builder: (_) => const TestPage(title: 'Details'));
      } else if (settings.name == route3) {
        return MaterialPageRoute(
            builder: (_) => const TestPage(title: 'Settings'));
      }
      return null;
    },
    home: Scaffold(
      body: Builder(
        builder: (c) {
          // Grab the context of the Builder, which is under the Navigator
          context = c;
          return const Text('Initial Screen');
        },
      ),
    ),
  );

  group('NavigationExtension', () {
    testWidgets('toNamed pushes a new named route',
        (WidgetTester tester) async {
      await tester.pumpWidget(testApp);
      await tester.pumpAndSettle(); // Wait for initial route to settle

      // Navigate to route2
      await context.toNamed(route2);
      await tester.pumpAndSettle();

      // Verify that the new page is displayed
      expect(find.text('Details'), findsOneWidget);
    });

    testWidgets('toReplacementNamed replaces the current route',
        (WidgetTester tester) async {
      await tester.pumpWidget(testApp);
      await tester.pumpAndSettle();

      // 1. Push an intermediate route (Route 1)
      await context.toNamed(route1);
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);

      // 2. Replace Route 1 with Route 2
      await context.toReplacementNamed(route2);
      await tester.pumpAndSettle();

      // Verify Route 2 is visible
      expect(find.text('Details'), findsOneWidget);

      // 3. Try to go back. If successful, it means the stack depth was reduced by 1.
      context.back();
      await tester.pumpAndSettle();

      // If replacement worked, popping should land us on 'Initial Screen'
      expect(find.text('Initial Screen'), findsOneWidget);
      expect(find.text('Home'), findsNothing);
    });

    testWidgets('toNamedAndRemoveUntil removes all previous routes',
        (WidgetTester tester) async {
      await tester.pumpWidget(testApp);
      await tester.pumpAndSettle();

      // 1. Push an intermediate route (Route 1)
      await context.toNamed(route1);
      await tester.pumpAndSettle();

      // 2. Push Route 3 and remove all others
      await context.toNamedAndRemoveUntil(route3);
      await tester.pumpAndSettle();

      // Verify Route 3 is visible
      expect(find.text('Settings'), findsOneWidget);

      // 3. Try to go back. The app should not be able to pop anymore.
      expect(context.canBack(), isFalse);
    });

    testWidgets('to pushes a new MaterialPageRoute',
        (WidgetTester tester) async {
      await tester.pumpWidget(testApp);
      await tester.pumpAndSettle();

      await context.to(const TestPage(title: 'Pushed Page'));
      await tester.pumpAndSettle();

      expect(find.text('Pushed Page'), findsOneWidget);
    });

    testWidgets('toAndRemoveUntil removes all previous routes with a widget',
        (WidgetTester tester) async {
      await tester.pumpWidget(testApp);
      await tester.pumpAndSettle();

      // 1. Push an intermediate route (Route 1)
      await context.to(const TestPage(title: 'Intermediate Page'));
      await tester.pumpAndSettle();

      // 2. Push Final Page and remove all others
      await context.toAndRemoveUntil(const TestPage(title: 'Final Page'));
      await tester.pumpAndSettle();

      // Verify Final Page is visible
      expect(find.text('Final Page'), findsOneWidget);

      // 3. Try to go back. The app should not be able to pop anymore.
      expect(context.canBack(), isFalse);
    });

    testWidgets('toReplacement replaces the current route with a widget',
        (WidgetTester tester) async {
      await tester.pumpWidget(testApp);
      await tester.pumpAndSettle();

      // 1. Push an intermediate route (Route 1)
      await context.to(const TestPage(title: 'Original Route'));
      await tester.pumpAndSettle();
      expect(find.text('Original Route'), findsOneWidget);

      // 2. Replace Original Route with Replacement Route
      await context.toReplacement(const TestPage(title: 'Replacement Route'));
      await tester.pumpAndSettle();

      // Verify Replacement Route is visible
      expect(find.text('Replacement Route'), findsOneWidget);

      // 3. Try to go back. Popping should land us on 'Initial Screen'
      context.back();
      await tester.pumpAndSettle();
      expect(find.text('Initial Screen'), findsOneWidget);
      expect(find.text('Original Route'), findsNothing);
    });

    testWidgets('back pops the current route', (WidgetTester tester) async {
      await tester.pumpWidget(testApp);
      await tester.pumpAndSettle();

      // 1. Push a route
      await context.toNamed(route1);
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);

      // 2. Pop it back
      context.back();
      await tester.pumpAndSettle();

      // Verify the initial screen is back
      expect(find.text('Initial Screen'), findsOneWidget);
    });

    testWidgets('back with result returns the result',
        (WidgetTester tester) async {
      await tester.pumpWidget(testApp);
      await tester.pumpAndSettle();

      // Push a route and capture the result
      // The context here is the Builder's context, which is the previous route.
      final resultFuture =
          context.toNamed<String>(route1, arguments: 'from Home');
      await tester.pump(); // Start navigation

      // Get the context of the newly pushed route (Route 1)
      final poppedContext = tester.element(find.text('Home'));

      // Pop the route with a result using the new route's context
      poppedContext.back<String>('Success');
      await tester.pumpAndSettle();

      // The result should be 'Success'
      final result = await resultFuture;
      expect(result, 'Success');
    });

    testWidgets('canBack returns true/false correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(testApp);
      await tester.pumpAndSettle();

      // Initial state: only one route (the home route). canBack is false.
      expect(context.canBack(), isFalse);

      // Push a route
      await context.toNamed(route1);
      await tester.pumpAndSettle();

      // After push: canBack is true
      expect(context.canBack(), isTrue);

      // Pop the route
      context.back();
      await tester.pumpAndSettle();

      // After pop: canBack is false again
      expect(context.canBack(), isFalse);
    });

    testWidgets('maybeBack pops all routes until the root',
        (WidgetTester tester) async {
      await tester.pumpWidget(testApp);
      await tester.pumpAndSettle();

      // Push multiple routes
      await context.toNamed(route1);
      await tester.pumpAndSettle();
      await context.toNamed(route2);
      await tester.pumpAndSettle();
      expect(find.text('Details'), findsOneWidget); // Current screen

      // maybeBack
      context.maybeBack();
      await tester.pumpAndSettle();

      // Should be back at the root
      expect(find.text('Initial Screen'), findsOneWidget);
      expect(context.canBack(), isFalse);
    });
  });

  group('Dialog & Focus Extension', () {
    // Need a separate context for focus/dialog tests under MaterialApp/Scaffold
    late BuildContext focusDialogContext;

    // Test App for Dialog and Focus testing
    Widget focusTestApp = MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (c) {
            focusDialogContext = c;
            return Column(
              children: [
                const Text('Focus Test Root'),
                // Use a simple Container to ensure the text fields get size and can be tapped
                SizedBox(
                    width: 200,
                    child: TextField(
                        key: const ValueKey('textField1'),
                        focusNode: FocusNode())),
                SizedBox(
                    width: 200,
                    child: TextField(
                        key: const ValueKey('textField2'),
                        focusNode: FocusNode())),
              ],
            );
          },
        ),
      ),
    );

    testWidgets('isDialogOpen is false when no dialog is present',
        (WidgetTester tester) async {
      await tester.pumpWidget(focusTestApp);
      await tester.pumpAndSettle();

      // No dialog open
      expect(focusDialogContext.isDialogOpen, isFalse);
    });

    testWidgets('isDialogOpen is true when a dialog is present',
        (WidgetTester tester) async {
      await tester.pumpWidget(focusTestApp);
      await tester.pumpAndSettle();

      // Show a dialog
      showDialog(
        context: focusDialogContext,
        builder: (context) => const AlertDialog(content: Text('Test Dialog')),
      );
      await tester.pump(); // Start the dialog animation

      // isCurrent should be false for the original route
      expect(focusDialogContext.isDialogOpen, isTrue);

      // Pop the dialog manually to clean up
      Navigator.of(focusDialogContext).pop();
      await tester.pumpAndSettle();
    });

    testWidgets('closeDialog closes an open dialog',
        (WidgetTester tester) async {
      await tester.pumpWidget(focusTestApp);
      await tester.pumpAndSettle();

      // Show a dialog
      showDialog(
        context: focusDialogContext,
        builder: (context) => const AlertDialog(content: Text('Test Dialog')),
      );
      await tester.pump(); // Start the dialog animation

      // Verify dialog is open
      expect(find.text('Test Dialog'), findsOneWidget);
      expect(focusDialogContext.isDialogOpen, isTrue);

      // Close the dialog using the extension
      focusDialogContext.closeDialog();
      await tester.pumpAndSettle();

      // Verify dialog is closed
      expect(find.text('Test Dialog'), findsNothing);
      expect(focusDialogContext.isDialogOpen, isFalse);
    });

    testWidgets('unfocusKeyboard unfocuses all nodes',
        (WidgetTester tester) async {
      await tester.pumpWidget(focusTestApp);
      await tester.pumpAndSettle();

      // 1. Tap to focus the first TextField
      await tester.tap(find.byKey(const ValueKey('textField1')));
      await tester.pump();

      // Verify focus is set
      expect(FocusManager.instance.primaryFocus, isNotNull);

      // 2. Unfocus using the extension
      focusDialogContext.unfocusKeyboard();
      await tester.pump();

      // 3. Verify primaryFocus is null
      expect(FocusManager.instance.primaryFocus, isNull);
    });

    testWidgets('requestFocus transfers focus to the new node',
        (WidgetTester tester) async {
      await tester.pumpWidget(focusTestApp);
      await tester.pumpAndSettle();

      // Get the FocusNode of the second TextField
      final node2 =
          (tester.firstWidget(find.byKey(const ValueKey('textField2')))
                  as TextField)
              .focusNode!;

      // 1. Tap to focus the first TextField
      await tester.tap(find.byKey(const ValueKey('textField1')));
      await tester.pump();

      // Verify initial focus is on the first node
      final focusedWidgetKey1 =
          FocusManager.instance.primaryFocus?.context?.widget.key;
      expect(focusedWidgetKey1, const ValueKey('textField1'));

      // 2. Request focus for the second node using the extension
      focusDialogContext.requestFocus(node2);
      await tester.pump();

      // 3. Verify focus moved to the second node
      final focusedWidgetKey2 =
          FocusManager.instance.primaryFocus?.context?.widget.key;
      expect(FocusManager.instance.primaryFocus, node2);
      expect(focusedWidgetKey2, const ValueKey('textField2'));
    });

    testWidgets('hasFocus reflects current focus state',
        (WidgetTester tester) async {
      await tester.pumpWidget(focusTestApp);
      await tester.pumpAndSettle();

      // Initial state: no focus
      expect(focusDialogContext.hasFocus, isFalse);

      // Tap to focus
      await tester.tap(find.byKey(const ValueKey('textField1')));
      await tester.pump();

      // State after focus: has focus
      expect(focusDialogContext.hasFocus, isTrue);

      // Unfocus
      focusDialogContext.unfocusKeyboard();
      await tester.pump();

      // State after unfocus: no focus
      expect(focusDialogContext.hasFocus, isFalse);
    });
  });
}
