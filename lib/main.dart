import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const TradeXLiteApp());
}

class TradeXLiteApp extends StatefulWidget {
  const TradeXLiteApp({super.key});

  @override
  State<TradeXLiteApp> createState() => _TradeXLiteAppState();
}

class _TradeXLiteAppState extends State<TradeXLiteApp> {
  ThemeMode _themeMode = ThemeMode.light;
  Duration _refreshInterval = const Duration(seconds: 5);
  String _currency = 'INR';
  bool _isLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TradeX Lite',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: _isLoggedIn
          ? HomeScreen(
        themeModeSetter: (m) => setState(() => _themeMode = m),
        currentThemeMode: _themeMode,
        refreshIntervalSetter: (d) => setState(() => _refreshInterval = d),
        currentRefreshInterval: _refreshInterval,
        currencySetter: (c) => setState(() => _currency = c),
        currentCurrency: _currency,
      )
          : LoginScreen(onLoginSuccess: () {
        setState(() => _isLoggedIn = true);
      }),
    );
  }
}
