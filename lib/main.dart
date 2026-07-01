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
      seedColor: const Color(0xFF57534E),
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'Flutter Interview Prep',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      scrollBehavior: const _AppScrollBehavior(),
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8FBFF),
        colorScheme: scheme,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF3F8FF),
          foregroundColor: Color(0xFF0F172A),
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
