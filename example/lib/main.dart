import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
  await ThemeProvider.instance.loadThemeMode();
  await FlutterCore.initialize(
    baseUrl: 'https://jsonplaceholder.typicode.com',
    connectTimeout: 30000,
    receiveTimeout: 30000,
    enableLogging: true,
    cacheMaxAge: const Duration(minutes: 5),
  );

  runApp(const ScreenUtilWrapper(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    FlutterCore.initializeUI();
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
  String _response = '';
  bool _isLoading = false;

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final result = await FlutterCore.dioClient.get('/posts/1');
      setState(() {
        _response = result.data.toString();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Core Demo'),
        actions: [
          IconButton(
            icon: Icon(ThemeProvider.instance.isDarkMode
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: () => ThemeProvider.instance.toggleTheme(),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    _response,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Load Data'),
            ),
          ],
        ),
      ),
    );
  }
}
