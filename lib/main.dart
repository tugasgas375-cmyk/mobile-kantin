import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'dashboard_page.dart';
import 'firebase_options.dart';
import 'store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // Firebase is optional while running in local demo mode.
  }
  await Store.instance.init();
  runApp(const KantinApp());
}

class KantinApp extends StatelessWidget {
  const KantinApp({super.key});

  static const _brand = Color(0xFFB84A24);

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _brand,
      brightness: Brightness.light,
      surface: const Color(0xFFFFFCF8),
    );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF7F5F1),
      textTheme: ThemeData.light().textTheme.apply(
            bodyColor: const Color(0xFF282521),
            displayColor: const Color(0xFF282521),
          ),
    );

    return MaterialApp(
      title: 'Kantin • POS',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F5F1),
          foregroundColor: Color(0xFF282521),
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            color: Color(0xFF282521),
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: Color(0xFFEDE9E2)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE7E1D8)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE7E1D8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _brand, width: 1.6),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(48, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String? _error;
  bool _hidePassword = true;

  void _login() {
    final user = Store.instance.users.firstWhereOrNull(
      (u) => u.username == _userCtrl.text.trim() && u.password == _passCtrl.text,
    );
    if (user == null) {
      setState(() => _error = 'Username atau password tidak cocok.');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DashboardPage(user: user)),
    );
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -110,
            right: -85,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: .08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [scheme.primary, const Color(0xFFE58A4F)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: scheme.primary.withValues(alpha: .22),
                              blurRadius: 28,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 27,
                              backgroundColor: Colors.white24,
                              child: Icon(Icons.storefront_rounded, color: Colors.white, size: 29),
                            ),
                            SizedBox(height: 28),
                            Text(
                              'Selamat datang\nkembali.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                height: 1.08,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Kelola kantin lebih mudah, mulai dari sini.',
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text('Masuk akun', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 5),
                              Text('Gunakan akun demo untuk melanjutkan.', style: TextStyle(color: Colors.grey.shade600)),
                              const SizedBox(height: 22),
                              TextField(
                                controller: _userCtrl,
                                textInputAction: TextInputAction.next,
                                onChanged: (_) => setState(() => _error = null),
                                decoration: const InputDecoration(
                                  labelText: 'Username',
                                  prefixIcon: Icon(Icons.person_outline_rounded),
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextField(
                                controller: _passCtrl,
                                obscureText: _hidePassword,
                                onChanged: (_) => setState(() => _error = null),
                                onSubmitted: (_) => _login(),
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                                  suffixIcon: IconButton(
                                    tooltip: _hidePassword ? 'Tampilkan password' : 'Sembunyikan password',
                                    onPressed: () => setState(() => _hidePassword = !_hidePassword),
                                    icon: Icon(_hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                  ),
                                ),
                              ),
                              if (_error != null) ...[
                                const SizedBox(height: 12),
                                Text(_error!, style: TextStyle(color: scheme.error, fontWeight: FontWeight.w600)),
                              ],
                              const SizedBox(height: 18),
                              FilledButton.icon(
                                onPressed: _login,
                                icon: const Icon(Icons.arrow_forward_rounded),
                                label: const Text('Masuk ke aplikasi'),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'DEMO  ·  admin/admin  ·  kasir/kasir  ·  customer/customer',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600, height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension IterableFirstWhereOrNull<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
