import 'package:flutter/material.dart';
import '../services/admin_setup_service.dart';
import '../services/app_storage.dart';
import '../theme/app_theme.dart';
import '../widgets/aide_shell.dart';
import 'opening_screen.dart';

class AdminSetupScreen extends StatefulWidget {
  const AdminSetupScreen({super.key});

  @override
  State<AdminSetupScreen> createState() => _AdminSetupScreenState();
}

class _AdminSetupScreenState extends State<AdminSetupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final AdminSetupService _setupService = AdminSetupService();

  String _message = '';
  String _messageType = ''; // 'success' or 'error'
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = 'formanitech@gmail.com';
    _displayNameController.text = 'Admin';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _createAdmin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final displayName = _displayNameController.text.trim();

    if (email.isEmpty || password.isEmpty || displayName.isEmpty) {
      setState(() {
        _message = '❌ Please fill in all fields';
        _messageType = 'error';
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _message = '❌ Password must be at least 6 characters';
        _messageType = 'error';
      });
      return;
    }

    setState(() {
      _busy = true;
      _message = '';
    });

    try {
      setState(() => _message = '⏳ Checking if email already exists...');

      final exists = await _setupService.emailExists(email);
      if (exists) {
        setState(() {
          _busy = false;
          _message = '❌ Email already registered!';
          _messageType = 'error';
        });
        return;
      }

      setState(() => _message = '⏳ Creating Firebase Auth account...');

      final uid = await _setupService.createAdminWithAuth(
        email: email,
        password: password,
        displayName: displayName,
      );

      if (!mounted) return;

      setState(() {
        _busy = false;
        _message = '✅ Admin created successfully!\n\n'
            'Email: $email\n'
            'Password: $password\n'
            'Role: Admin\n\n'
            'Redirecting to login...';
        _messageType = 'success';
      });

      // Redirect to login after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const OpeningScreen()),
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _message = '❌ Error: ${e.toString()}';
        _messageType = 'error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AideShell(
      showBack: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              SizedBox(
                height: 180,
                child: Image.asset('assets/images/robot_hero.png'),
              ),
              const SizedBox(height: 14),
              const Text(
                'AIDE Admin Setup',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              const Text(
                'Create your first admin account',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              AidePanel(
                radius: 28,
                color: AideColors.panel.withOpacity(0.92),
                child: Column(
                  children: [
                    const AideSectionTitle('Create Admin Account'),
                    const SizedBox(height: 16),
                    AideTextField(
                      controller: _emailController,
                      label: 'Email',
                    ),
                    const SizedBox(height: 14),
                    AideTextField(
                      controller: _passwordController,
                      label: 'Password (min 6 chars)',
                      obscureText: true,
                    ),
                    const SizedBox(height: 14),
                    AideTextField(
                      controller: _displayNameController,
                      label: 'Display Name',
                    ),
                    const SizedBox(height: 18),
                    if (_message.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _messageType == 'success'
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          border: Border.all(
                            color: _messageType == 'success'
                                ? Colors.green
                                : Colors.red,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _message,
                          style: TextStyle(
                            color: _messageType == 'success'
                                ? Colors.green
                                : Colors.red,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _busy ? null : _createAdmin,
                        child: Text(
                          _busy ? 'Creating Admin...' : 'Create Admin Account',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _busy
                            ? null
                            : () async {
                                // Mark app as initialized when skipping admin setup
                                await AppStorage.markInitialized();
                                if (!mounted) return;
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const OpeningScreen(),
                                  ),
                                );
                              },
                        child: const Text('Skip and Select Role'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📋 Information:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• This screen appears on first run\n'
                      '• Create your first admin account\n'
                      '• Email is required for login\n'
                      '• Password must be 6+ characters\n'
                      '• Stored securely in Firebase\n'
                      '• After creation, you can login',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}