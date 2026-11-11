import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'customer_page.dart';
import 'dashboard_page.dart';
import 'firebase_options.dart';
import 'models.dart';
import 'store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {
    // The app can still open in local/demo mode when Firebase is not configured.
  }
  await Store.instance.init();
  runApp(const KantinApp());
}

class KantinApp extends StatelessWidget {
  const KantinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kantin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const RoleSelectionPage(),
    );
  }
}

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedRole;
  String? _errorMessage;

  void _selectRole(String role) {
    if (role == Role.customer) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const CustomerPage()),
      );
      return;
    }

    setState(() {
      _selectedRole = role;
      _errorMessage = null;
      _usernameController.clear();
      _passwordController.clear();
    });
  }

  void _login() {
    final username = _usernameController.text.trim();
    final user = Store.instance.users.where((candidate) {
      return candidate.username == username &&
          candidate.password == _passwordController.text &&
          candidate.role == _selectedRole;
    }).firstOrNull;

    if (user == null) {
      setState(() => _errorMessage = 'Username atau password tidak sesuai dengan role.');
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => DashboardPage(user: user)),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: _selectedRole == null
          ? null
          : AppBar(
              leading: IconButton(
                tooltip: 'Kembali pilih role',
                onPressed: () => setState(() {
                  _selectedRole = null;
                  _errorMessage = null;
                }),
                icon: const Icon(Icons.arrow_back),
              ),
              title: Text('Login ${_selectedRole == Role.admin ? 'Admin' : 'Kasir'}'),
            ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: _selectedRole == null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.storefront, size: 72, color: theme.colorScheme.primary),
                        const SizedBox(height: 12),
                        Text('Selamat Datang', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Pilih role untuk melanjutkan', style: theme.textTheme.bodyLarge),
                        const SizedBox(height: 28),
                        _RoleCard(
                          icon: Icons.restaurant,
                          title: 'Customer',
                          subtitle: 'Lihat menu dan pesan tanpa login',
                          onTap: () => _selectRole(Role.customer),
                        ),
                        const SizedBox(height: 12),
                        _RoleCard(
                          icon: Icons.admin_panel_settings,
                          title: 'Admin',
                          subtitle: 'Login untuk mengelola kantin',
                          onTap: () => _selectRole(Role.admin),
                        ),
                        const SizedBox(height: 12),
                        _RoleCard(
                          icon: Icons.point_of_sale,
                          title: 'Kasir',
                          subtitle: 'Login untuk mengelola pesanan dan transaksi',
                          onTap: () => _selectRole(Role.kasir),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _selectedRole == Role.admin ? Icons.admin_panel_settings : Icons.point_of_sale,
                          size: 64,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text('Login ${_selectedRole == Role.admin ? 'Admin' : 'Kasir'}', style: theme.textTheme.headlineSmall),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _usernameController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          onSubmitted: (_) => _login(),
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock),
                          ),
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Text(_errorMessage!, style: TextStyle(color: theme.colorScheme.error)),
                        ],
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(onPressed: _login, child: const Text('Login')),
                        ),
                        const SizedBox(height: 12),
                        const Text('Demo: admin/admin  •  kasir/kasir', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
