<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

# Flutter Core

A comprehensive Flutter core package that provides essential utilities and services for building robust Flutter applications.

## Features

- **Theme Management**
  - Light/Dark theme support
  - Custom color schemes
  - Responsive text scaling
  - Theme persistence

- **Network Layer**
  - Dio-based HTTP client
  - Request/response caching
  - Error handling
  - Connectivity checking
  - Request/response logging

- **Storage**
  - Secure, encrypted, and versioned storage (with migration and backup)
  - Simple multi-box Hive storage

- **UI Extensions**
  - Screen size adaptation
  - Responsive layouts
  - Navigation helpers
  - Dialog builders
  - Snackbar utilities

## Getting Started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_core: ^0.0.1
```

## Usage

### Theme Setup

```dart
import 'package:flutter_core/flutter_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeProvider.instance.loadThemeMode();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeProvider.instance,
      builder: (context, _) {
        return MaterialApp(
          theme: ThemeProvider.instance.currentTheme,
          home: const HomePage(),
        );
      },
    );
  }
}
```

### Network Requests

```dart
import 'package:flutter_core/flutter_core.dart';

final dioClient = DioClient(
  baseUrl: 'https://api.example.com',
  connectTimeout: 30000,
  receiveTimeout: 30000,
  enableLogging: true,
  cacheConfig: const DioCacheConfig(
    maxAge: Duration(minutes: 5),
  ),
);

Future<void> fetchData() async {
  final result = await dioClient.get('/posts/1');
  print(result.data);
}
```

### Secure Storage

```dart
import 'package:flutter_core/flutter_core.dart';

final storage = SecureStorageService(version: 1);

await storage.initialize();
await storage.save('user', {'name': 'John', 'age': 30});
final user = await storage.load<Map<String, dynamic>>('user');
```

### Simple Multi-Box Storage

```dart
import 'package:flutter_core/flutter_core.dart';

final storage = SimpleStorageService();
await storage.init();
await storage.set('users', 'user1', {'name': 'Alice'});
final user = await storage.get<Map<String, dynamic>>('users', 'user1');
```

### UI Extensions

```dart
// Screen size adaptation
SizedBox(height: 16.h);  // 16 logical pixels in height
SizedBox(width: 16.w);   // 16 logical pixels in width
EdgeInsets.all(16.r);    // 16 logical pixels in radius

// Navigation
context.push(NextPage());           // Push new page
context.pushReplacement(NextPage());// Replace current page
context.pop();                      // Go back

// Dialogs
context.showLoadingDialog();        // Show loading dialog
context.showErrorDialog('Error');   // Show error dialog
context.showSnackBar('Message');    // Show snackbar
```

## Exports

All features are available via:

```dart
import 'package:flutter_core/flutter_core.dart';
```

## Exports Overview

- Theme: `theme.dart`, `theme_provider.dart`, `text_theme.dart`, `color_schemes.dart`
- Network: `dio_client.dart`, `dio_interceptor.dart`, `dio_cache_config.dart`, `dio_retry_interceptor.dart`
- Storage: `secure_storage_service.dart`, `key_manager.dart`, `simple_storage_service.dart`, `local_storage.dart`
- Services: `connectivity_service.dart`
- Constants: `constants.dart`, `colors.dart`, `default.dart`
- Utils: `utils.dart`, `path_utils.dart`, `ui_helper.dart`
<!-- - Domain/Data: All base entities, repositories, usecases, models, datasources -->
- Extensions: All widget, context, and style extensions

## Dependencies

- flutter_screenutil
- dio
- dio_cache_interceptor
- dio_cache_interceptor_hive_store
- connectivity_plus
- hive
- hive_flutter
- flutter_secure_storage
- path_provider
- google_fonts
- logger
- encrypt

## Contributing

Contributions are welcome! Please submit a Pull Request.

## License

See [LICENSE](LICENSE).

## Additional information

For more details, see the documentation or open an issue on GitHub.
