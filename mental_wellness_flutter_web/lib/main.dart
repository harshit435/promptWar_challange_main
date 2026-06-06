import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'services/state_manager.dart';
import 'screens/main_navigation.dart';
import 'screens/login_screen.dart';
import 'screens/entry_form.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force enable semantics overlay in DOM tree on load for automated scanners
  SemanticsBinding.instance.ensureSemantics();

  // Initialize state manager and load cached entries
  final state = StateManager();
  await state.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ZenPrep Sanctuary',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor:
            const Color(0xFF0C0E1A), // Deep space background
        primaryColor: const Color(0xFF64FFDA), // Calming mint
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF64FFDA),
          secondary: Color(0xFF80DEEA),
          surface: Color(0xFF111422),
          onSurface: Colors.white,
        ),
        fontFamily: 'Roboto', // Default clean font
        appBarTheme: const AppBarTheme(
          color: Color(0xFF090A14),
          elevation: 0,
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainNavigationShell(),
        '/': (context) => const MainNavigationShell(),
        '/entry': (context) =>
            const EntryFormScreen(isNavigatingFromShell: false),
      },
    );
  }
}
