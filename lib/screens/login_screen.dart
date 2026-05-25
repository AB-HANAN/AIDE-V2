import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_role.dart';
import '../services/app_storage.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_user_service.dart';
import '../theme/app_theme.dart';
import '../widgets/aide_shell.dart';
import 'connect_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.role});
  final AppRole role;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreUserService _userService = FirestoreUserService();

  String _error = '';
  String _emailError = '';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _prefillEmail();
    _emailController.addListener(_validateEmailFormat);
  }

  Future<void> _prefillEmail() async {
    // Try to get email from Firebase Auth first (cached from previous login)
    String email = _authService.currentUserEmail ?? '';

    // Fall back to last used email from local storage
    if (email.isEmpty) {
      email = await AppStorage.getLastEmail();
    }

    if (!mounted) return;
    _emailController.text = email;
  }

  Future<void> _continue() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please enter both email and password.');
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() => _error = 'Please enter a valid email address.');
      return;
    }

    // Save this email as the last used one
    await AppStorage.setLastEmail(email);

    setState(() {
      _busy = true;
      _error = '';
    });

    try {
      final userCredential = await _authService.signIn(
        email: email,
        password: password,
      );

      if (!mounted) return;

      // Get user profile from Firestore to check their actual role
      final uid = userCredential.user?.uid;
      if (uid != null) {
        // Check if profile exists and get their actual role
        var profile = await _userService.getUserProfile(uid);
        
        if (profile != null) {
          // User exists in Firestore - check if role matches
          final actualRole = profile.role;
          
          // Convert AppRole to UserRole for comparison
          final expectedRole = widget.role == AppRole.admin 
              ? UserRole.admin 
              : UserRole.operator;
          
          // If user's actual role doesn't match selected role, reject
          if (actualRole != expectedRole) {
            if (!mounted) return;
            setState(() {
              _busy = false;
              _error = 'Invalid role. Your account is registered as ${actualRole.toString().split('.').last}. Please select the correct role.';
            });
            
            // Sign out this user since they tried wrong role
            await _authService.signOut();
            return;
          }

          // Check if password has changed (e.g., via forgot password reset)
          if (profile.password != password) {
            try {
              await _userService.updateUserPassword(
                uid: uid,
                newPassword: password,
                changedBy: 'user', // Password changed via forgot password reset
              );
            } catch (e) {
              print('Failed to update password history: $e');
            }
          }
        } else {
          // Profile doesn't exist - create one with selected role
          final userRole = widget.role == AppRole.admin 
              ? UserRole.admin 
              : UserRole.operator;
          
          await _userService.createUserProfile(
            uid: uid,
            email: email,
            displayName: email.split('@')[0],
            role: userRole,
          );
        }
      }

      Navigator.pushReplacement(
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
              SizedBox(
                height: 180,
                child: Image.asset('assets/images/robot_hero.png'),
              ),
              const SizedBox(height: 14),
              const Text(
                'Welcome To AIDE',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              AideChip(
                label: widget.role.label,
                color: widget.role == AppRole.admin
                    ? AideColors.primary
                    : AideColors.teal,
              ),
              const SizedBox(height: 30),
              AidePanel(
                radius: 28,
                color: AideColors.panel.withOpacity(0.92),
                child: Column(
                  children: [
                    AideSectionTitle('${widget.role.label} Login'),
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
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _busy
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const ForgotPasswordScreen(),
                                  ),
                                );
                              },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
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
                        child: Text(_busy ? 'Signing in...' : 'Login'),
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