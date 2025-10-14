import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('authBox');
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
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final box = Hive.box('authBox');
    await box.put('isLoggedIn', false);
    final savedTheme = box.get('themeMode', defaultValue: 'light');
    final initialTheme = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
    setState(() {
      _themeMode = initialTheme;
      _isLoggedIn = false;
      _initialized = true;
    });
  }


  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: Colors.blueAccent),
          ),
        ),
      );
    }

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
        refreshIntervalSetter: (d) =>
            setState(() => _refreshInterval = d),
        currentRefreshInterval: _refreshInterval,
        currencySetter: (c) => setState(() => _currency = c),
        currentCurrency: _currency,
      )
          : LoginScreen(
        onLoginSuccess: () {
          final box = Hive.box('authBox');
          box.put('isLoggedIn', true);
          setState(() => _isLoggedIn = true);
        },
      ),
    );
  }
}
