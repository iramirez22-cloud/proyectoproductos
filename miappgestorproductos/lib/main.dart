import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/products_screen.dart';
import 'services/product_api.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final api = ProductApi();
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6750D8),
      brightness: Brightness.light,
      primary: const Color(0xFF6750D8),
      secondary: const Color(0xFFFF8A45),
    );
    return MaterialApp(
      title: 'Gestor de productos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F6FC),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 3,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
          ),
        ),
      ),
      home: _AppEntry(api: api),
    );
  }
}

class _AppEntry extends StatefulWidget {
  const _AppEntry({required this.api});

  final ProductApi api;

  @override
  State<_AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<_AppEntry> {
  bool _authenticated = false;

  @override
  Widget build(BuildContext context) {
    if (!_authenticated) {
      return LoginScreen(onLogin: () => setState(() => _authenticated = true));
    }
    return ProductsScreen(
      api: widget.api,
      onLogout: () => setState(() => _authenticated = false),
    );
  }
}
