import 'package:flutter/material.dart';
import '../models/app_role.dart';
import '../services/app_storage.dart';
import '../theme/app_theme.dart';
import '../widgets/aide_shell.dart';
import 'admin_setup_screen.dart';
import 'login_screen.dart';

class OpeningScreen extends StatefulWidget {
  const OpeningScreen({super.key});

  @override
  State<OpeningScreen> createState() => _OpeningScreenState();
}

class _OpeningScreenState extends State<OpeningScreen> {
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkInitialization();
  }

  Future<void> _checkInitialization() async {
    final initialized = await AppStorage.isInitialized();

    if (!mounted) return;

    if (!initialized) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminSetupScreen()),
      );
      return;
    }

    setState(() {
      _checking = false;
    });
  }

  void _openLogin(AppRole role) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen(role: role)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const AideShell(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return AideShell(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        child: Column(
          children: [
            const Spacer(flex: 2),
            SizedBox(
              height: 290,
              child: Image.asset(
                'assets/images/robot_hero.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Welcome To AIDE',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Theme.of(context).brightness == Brightness.light ? Colors.black87 : Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Text(
                'Autonomous Interactive Delivery Entity',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black54
                      : AideColors.textMuted,
                  height: 1.45,
                ),
              ),
            ),
            const Spacer(),
            AidePanel(
              radius: 28,
              padding: const EdgeInsets.all(18),
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.white.withValues(alpha: 0.92)
                  : AideColors.panel.withValues(alpha: 0.92),
              child: Column(
                children: [
                  _RoleButton(
                    title: 'Admin',
                    subtitle: 'Full control and system settings',
                    onTap: () => _openLogin(AppRole.admin),
                  ),
                  const SizedBox(height: 12),
                  _RoleButton(
                    title: 'User',
                    subtitle: 'Operator access and assistant chat',
                    onTap: () => _openLogin(AppRole.user),
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  const _RoleButton({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isLight
              ? Colors.black.withValues(alpha: 0.06)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isLight
                ? Colors.black.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.07),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AideColors.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.arrow_outward_rounded,
                color: AideColors.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: isLight ? Colors.black87 : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isLight ? Colors.black54 : AideColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}