import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_core/src/core/storage/local_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Enable logging in debug mode
  if (kDebugMode) {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      debugPrint(details.toString());
    };
  }

  // Initialize theme and core services
  // await ThemeProvider.instance.loadThemeMode();
  await FlutterCore.initialize(
    baseUrl: 'https://jsonplaceholder.typicode.com',
    connectTimeout: 30000,
    receiveTimeout: 30000,
    enableLogging: true,
    cacheMaxAge: const Duration(minutes: 5),
  );

  // Initialize the LocalStorage service before use
  final localStorage = LocalStorage();
  await localStorage.init();

  // Example of providing a custom dark theme
  final customDarkTheme = AppTheme.defaultDarkTheme.copyWith(
    colorScheme: ColorSchemes.greenScheme,
  );

  ThemeProvider.configure(
    lightTheme: null, // Use default light theme
    darkTheme: customDarkTheme, // Use custom dark theme
  );

  await ThemeProvider.instance.loadThemeMode();

  runApp(const ScreenUtilWrapper(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // FlutterCore.initializeUI();

    return ListenableBuilder(
      listenable: ThemeProvider.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'Flutter Core Demo',
          theme: ThemeProvider.instance.currentTheme,
          home: const HomePage(),
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String response = '';
  bool isLoading = false;

  final localStorage = LocalStorage();

  Future<void> loadData() async {
    setState(() => isLoading = true);
    try {
      final result = await FlutterCore.dioClient.get('/posts/1');
      setState(() {
        response = result.data.toString();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        response = 'Error: $e';
        isLoading = false;
      });
    }
  }

  void localStorageVoid() async {
    await localStorage.set<String>('prefs', 'token', 'abc123');
    final token = await localStorage.get<String>('prefs', 'token');
    if (token.isNotNullOrEmpty) {
      await localStorage.set('prefs', 'token', token!);
    }
    await localStorage.delete('prefs', 'token');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider.instance;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flexible Theme Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Current Theme:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              themeProvider.isDarkMode ? 'Dark' : 'Light',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                themeProvider.toggleTheme();
              },
              child: Text(
                'Toggle Theme',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Example of setting a custom color scheme (doesn't change theme in this simple example)
                themeProvider.setColorScheme('blue');
              },
              child: Text(
                'Set Blue Scheme',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
