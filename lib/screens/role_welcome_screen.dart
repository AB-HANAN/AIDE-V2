import 'package:flutter/material.dart';
import '../models/app_role.dart';
import '../theme/app_theme.dart';
import '../widgets/aide_shell.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class RoleWelcomeScreen extends StatelessWidget {
  const RoleWelcomeScreen({super.key, required this.role});
  final AppRole role;

  @override
  Widget build(BuildContext context) {
    return AideShell(
      showBack: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        child: Column(
          children: [
            const Spacer(),
            SizedBox(height: 230, child: Image.asset('assets/images/robot_hero.png')),
            const SizedBox(height: 16),
            Text(
              'Welcome To AIDE',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: Theme.of(context).brightness == Brightness.light ? Colors.black87 : Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            AideChip(label: role.label, color: role == AppRole.admin ? AideColors.primary : AideColors.teal),
            const Spacer(),
            AidePanel(
              radius: 28,
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.white.withValues(alpha: 0.93)
                  : AideColors.panel.withValues(alpha: 0.92),
              child: Column(
                children: [
                  Text(
                    'Continue as ${role.label}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).brightness == Brightness.light ? Colors.black87 : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AideColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen(role: role))),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AideColors.primary, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen(role: role))),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AideColors.primary,
                        ),
                      ),
                    ),
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
