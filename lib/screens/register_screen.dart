import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_role.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_user_service.dart';
import '../theme/app_theme.dart';
import '../widgets/aide_shell.dart';
import 'connect_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.role});
  final AppRole role;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreUserService _userService = FirestoreUserService();

  String _error = '';
  String _emailError = '';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmailFormat);
  }

  Future<void> _continue() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validation
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() => _error = 'Please fill in all fields.');
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() => _error = 'Please enter a valid email address.');
      return;
    }

    if (password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }

    if (password != confirmPassword) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }

    setState(() {
      _busy = true;
      _error = '';
    });

    try {
      final userCredential = await _authService.signUp(
        email: email,
        password: password,
      );

      if (!mounted) return;

      // Create user profile in Firestore
      final uid = userCredential.user?.uid;
      if (uid != null) {
        await _userService.createUserProfile(
          uid: uid,
          email: email,
          displayName: email.split('@')[0], // Use part of email as display name
          role: UserRole.operator, // New users are operators by default
        );
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ConnectScreen(
            role: widget.role,
            username: email,
            profileKey: password,
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = _authService.getErrorMessage(e);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'An unexpected error occurred. Please try again.';
      });
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return emailRegex.hasMatch(email);
  }

  void _validateEmailFormat() {
    final email = _emailController.text.trim();
    String errorMessage = '';

    if (email.isNotEmpty) {
      if (!_isValidEmail(email)) {
        errorMessage = 'Please enter a valid email address';
      }
    }

    if (_emailError != errorMessage) {
      setState(() {
        _emailError = errorMessage;
      });
    }
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateEmailFormat);
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AideShell(
      showBack: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              SizedBox(height: 170, child: Image.asset('assets/images/robot_hero.png')),
              const SizedBox(height: 14),
              const Text('Welcome To AIDE', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
              const SizedBox(height: 30),
              AidePanel(
                radius: 28,
                color: AideColors.panel.withOpacity(0.92),
                child: Column(
                  children: [
                    const AideSectionTitle('Sign Up'),
                    const SizedBox(height: 16),
                    AideTextField(
                      controller: _emailController,
                      label: 'Email',
                    ),
                    if (_emailError.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        _emailError,
                        style: const TextStyle(
                          color: AideColors.primarySoft,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    AideTextField(
                      controller: _passwordController,
                      label: 'Password',
                      obscureText: true,
                    ),
                    const SizedBox(height: 14),
                    AideTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      obscureText: true,
                    ),
                    if (_error.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        _error,
                        style: const TextStyle(color: AideColors.primarySoft),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (_busy || _emailError.isNotEmpty) ? null : _continue,
                        child: Text(_busy ? 'Creating account...' : 'Register'),
                      ),
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
