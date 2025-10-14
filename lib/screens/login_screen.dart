import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:local_auth/local_auth.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isLoading = false;
  bool _obscure = true;
  bool _canCheckBiometrics = false;
  bool _biometricAttempted = false;

  @override
  void initState() {
    super.initState();
    _initBiometricAutoLogin();
  }

  Future<void> _initBiometricAutoLogin() async {
    final box = Hive.box('authBox');
    final hasSavedLogin = box.get('username') != null && box.get('password') != null;
    final canCheck = await _auth.canCheckBiometrics;

    setState(() => _canCheckBiometrics = canCheck);

    if (hasSavedLogin && canCheck && !_biometricAttempted) {
      _biometricAttempted = true;
      await Future.delayed(const Duration(milliseconds: 600)); // smooth UX
      _authenticateWithBiometrics();
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      final didAuthenticate = await _auth.authenticate(
        localizedReason: 'Authenticate to log in',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      if (didAuthenticate) {
        final box = Hive.box('authBox');
        final savedUser = box.get('username');
        final savedPass = box.get('password');
        if (savedUser != null && savedPass != null) {
          widget.onLoginSuccess();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No saved login info. Please log in manually.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Biometric error: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please enter both username and password."),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    final box = Hive.box('authBox');
    box.put('username', username);
    box.put('password', password);
    box.put('isLoggedIn', true);

    setState(() => _isLoading = false);
    widget.onLoginSuccess();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [Colors.black87, Colors.grey.shade900]
                    : [Colors.blue.shade200, Colors.blue.shade50],
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(isDark ? 0.05 : 0.2),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.show_chart_rounded, size: 64, color: Colors.blueAccent),
                    const SizedBox(height: 16),
                    Text(
                      "TradeX Lite",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 40),
                    TextField(
                      controller: _usernameController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person_outline),
                        hintText: 'Username',
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.white.withOpacity(0.9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white70 : Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscure,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline),
                        hintText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color:
                            isDark ? Colors.white70 : Colors.grey.shade600,
                          ),
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.white.withOpacity(0.9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white70 : Colors.grey.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.blueAccent)
                        : GestureDetector(
                      onTap: _login,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 52,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            )
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_canCheckBiometrics)
                      IconButton(
                        icon: const Icon(Icons.fingerprint_rounded,
                            color: Colors.blueAccent, size: 50),
                        onPressed: _authenticateWithBiometrics,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
