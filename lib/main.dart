import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/window_transparency/window_transparency.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WindowTransparencyService.initialize();
  runApp(const FlutterInterviewPrepApp());
}

class FlutterInterviewPrepApp extends StatelessWidget {
  const FlutterInterviewPrepApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF4F6AF0),
      brightness: Brightness.dark,
    );

    return MaterialApp(
      title: 'Flutter Interview Prep',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const _AppScrollBehavior(),
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F1117),
        colorScheme: scheme,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121826),
          foregroundColor: Color(0xFFF7FAFC),
          centerTitle: false,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class _AppScrollBehavior extends MaterialScrollBehavior {
  const _AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
      };
}

// I want to add some other section to this app, App optimization and howmany