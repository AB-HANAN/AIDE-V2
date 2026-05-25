import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/aide_shell.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuthService _authService = FirebaseAuthService();

  String _message = '';
  String _messageType = ''; // 'success' or 'error'
  String _emailError = '';
  bool _busy = false;
  bool _emailSent = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmailFormat);
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

  Future<void> _sendResetEmail() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _message = '❌ Please enter your email address';
        _messageType = 'error';
      });
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() {
        _message = '❌ Please enter a valid email address';
        _messageType = 'error';
      });
      return;
    }

    setState(() {
      _busy = true;
      _message = '';
    });

    try {
      setState(() => _message = '⏳ Sending password reset email...');

      await _authService.resetPassword(email: email);

      if (!mounted) return;

      setState(() {
        _busy = false;
        _emailSent = true;
        _message = '✅ Password reset email sent!\n\n'
            'Check your email ($email) for instructions to reset your password.\n\n'
            'If you don\'t see the email, check your spam folder.\n\n'
            'The reset link will expire in 24 hours.';
        _messageType = 'success';
      });
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      
      String errorMessage = '❌ Error: ';
      
      // Handle specific Firebase Auth errors
      if (e.code == 'user-not-found') {
        errorMessage += 'No account found with this email address.';
      } else if (e.code == 'invalid-email') {
        errorMessage += 'Invalid email address.';
      } else if (e.code == 'too-many-requests') {
        errorMessage += 'Too many requests. Please try again later.';
      } else {
        errorMessage += e.message ?? 'Failed to send reset email. Please try again.';
      }

      setState(() {
        _busy = false;
        _message = errorMessage;
        _messageType = 'error';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _message = '❌ An unexpected error occurred. Please try again.';
        _messageType = 'error';
      });
    }
  }

  void _goBackToLogin() {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateEmailFormat);
    _emailController.dispose();
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
                'Reset Password',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your email to receive password reset instructions',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              AidePanel(
                radius: 28,
                color: AideColors.panel.withOpacity(0.92),
                child: Column(
                  children: [
                    const AideSectionTitle('Password Recovery'),
                    const SizedBox(height: 16),
                    if (!_emailSent) ...[
                      AideTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        enabled: !_busy,
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
                    ],
                    if (_message.isNotEmpty) ...[
                      const SizedBox(height: 14),
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
                    ],
                    const SizedBox(height: 18),
                    if (!_emailSent) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (_busy || _emailError.isNotEmpty)
                              ? null
                              : _sendResetEmail,
                          child: Text(
                            _busy ? 'Sending...' : 'Send Reset Email',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _busy ? null : _goBackToLogin,
                          child: const Text('Back to Login'),
                        ),
                      ),
                    ] else ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _goBackToLogin,
                          child: const Text('Back to Login'),
                        ),
                      ),
                    ],
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
                      '• A reset link will be sent to your email\n'
                      '• The link expires in 24 hours\n'
                      '• Check spam/junk folder if not found\n'
                      '• You can only reset if your email is registered\n'
                      '• After reset, use your new password to login',
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
