import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_role.dart';
import '../services/app_storage.dart';
import '../services/firestore_user_service.dart';
import '../theme/app_theme.dart';
import '../widgets/aide_shell.dart';
import 'password_change_screen.dart';
import 'settings_screen.dart';
import 'privacy_policy_screen.dart';
import 'help_support_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.role,
  });

  final AppRole role;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _robotNameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreUserService _userService = FirestoreUserService();

  bool _loading = true;
  bool _saving = false;
  String _message = '';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        _userEmail = currentUser.email ?? '';

        // Get display name from Firestore profile
        final profile = await _userService.getUserProfile(currentUser.uid);
        if (profile != null) {
          _displayNameController.text = profile.displayName;
        }
      }

      final robotName = await AppStorage.getRobotName();
      _robotNameController.text = robotName;

      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _message = 'Error loading profile: $e';
      });
    }
  }

  Future<void> _saveProfile() async {
    final displayName = _displayNameController.text.trim();
    final robotName = _robotNameController.text.trim();

    if (displayName.isEmpty) {
      setState(() {
        _message = 'Display name cannot be empty.';
      });
      return;
    }

    if (robotName.isEmpty) {
      setState(() {
        _message = 'Robot name cannot be empty.';
      });
      return;
    }

    setState(() {
      _saving = true;
      _message = '';
    });

    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Update display name in Firestore
        await _userService.updateUserProfile(
          uid: currentUser.uid,
          displayName: displayName,
        );
      }

      // Update robot name in local storage
      await AppStorage.updateProfileInfo(
        robotName: robotName,
        phoneNumber: '', // Phone number removed
      );

      if (!mounted) return;
      setState(() {
        _saving = false;
        _message = 'Profile updated successfully.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _message = 'Failed to save profile: $e';
      });
    }
  }

  Color _getMenuItemColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.light ? Colors.black87 : Colors.white;
  }

  void _showAboutDialog(BuildContext context) {
    final isLightTheme = Theme.of(context).brightness == Brightness.light;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isLightTheme ? Colors.white : Colors.grey.shade900,
        title: Text(
          'About AIDE',
          style: TextStyle(color: isLightTheme ? Colors.black87 : Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AIDE - Autonomous Indoor Delivery Explorer',
              style: TextStyle(
                color: isLightTheme ? Colors.black87 : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Version: 1.0.0',
              style: TextStyle(color: isLightTheme ? Colors.black54 : Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              'A smart robot control and monitoring system for autonomous navigation and task execution.',
              style: TextStyle(
                color: isLightTheme ? Colors.black54 : Colors.white70,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '© 2026 AIDE Team. All rights reserved.',
              style: TextStyle(
                color: isLightTheme ? Colors.black54 : Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: isLightTheme ? AideColors.primary : Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _robotNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const AideShell(
        showBack: true,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return AideShell(
      showBack: true,
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          switch (value) {
            case 'settings':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
              break;
            case 'help':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HelpSupportScreen(),
                ),
              );
              break;
            case 'privacy':
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PrivacyPolicyScreen(),
                ),
              );
              break;
            case 'about':
              _showAboutDialog(context);
              break;
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'settings',
            child: Row(
              children: [
                Icon(Icons.settings_rounded, size: 18, color: _getMenuItemColor(context)),
                const SizedBox(width: 10),
                Text('Settings', style: TextStyle(color: _getMenuItemColor(context))),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'help',
            child: Row(
              children: [
                Icon(Icons.help_rounded, size: 18, color: _getMenuItemColor(context)),
                const SizedBox(width: 10),
                Text('Help & Support', style: TextStyle(color: _getMenuItemColor(context))),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'privacy',
            child: Row(
              children: [
                Icon(Icons.privacy_tip_rounded, size: 18, color: _getMenuItemColor(context)),
                const SizedBox(width: 10),
                Text('Privacy Policy', style: TextStyle(color: _getMenuItemColor(context))),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'about',
            child: Row(
              children: [
                Icon(Icons.info_rounded, size: 18, color: _getMenuItemColor(context)),
                const SizedBox(width: 10),
                Text('About', style: TextStyle(color: _getMenuItemColor(context))),
              ],
            ),
          ),
        ],
        child: Icon(
          Icons.more_vert_rounded,
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.black87
              : Colors.white.withValues(alpha: 0.7),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
        child: ListView(
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.black.withValues(alpha: 0.06)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Image.asset('assets/images/robot_hero.png'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Profile',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Account Information Card
            AidePanel(
              radius: 24,
              color: AideColors.panel.withOpacity(0.92),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Account',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.grey.shade100
                            : Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).brightness == Brightness.light
                                  ? Colors.black54
                                  : Colors.white70,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _userEmail,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PasswordChangeScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.lock_rounded, size: 16),
                      label: const Text('Change Password'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Profile Information Card
            AidePanel(
              radius: 24,
              color: AideColors.panel.withOpacity(0.92),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Profile Information',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  AideTextField(
                    controller: _displayNameController,
                    label: 'Display Name',
                  ),
                  const SizedBox(height: 12),
                  AideTextField(
                    controller: _robotNameController,
                    label: 'Robot Name',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (_message.isNotEmpty)
              Text(
                _message,
                style: TextStyle(
                  color: _message.toLowerCase().contains('success')
                      ? Colors.greenAccent
                      : AideColors.primarySoft,
                ),
              ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _saveProfile,
                child: Text(_saving ? 'Saving...' : 'Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}