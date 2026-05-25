import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/aide_shell.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLightTheme = Theme.of(context).brightness == Brightness.light;

    return AideShell(
      showBack: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isLightTheme
                          ? Colors.black.withValues(alpha: 0.06)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.privacy_tip_rounded,
                      color: Color(0xFFEF6A3B),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Privacy Policy',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: isLightTheme ? Colors.black87 : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Introduction
              AidePanel(
                child: Text(
                  'AIDE respects user privacy and is committed to protecting application and system data. This application is designed primarily for educational, research, and project demonstration purposes.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.7,
                    color: isLightTheme
                        ? Colors.black87
                        : const Color(0xE8FFFFFF),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Information Collected Section
              AideSectionTitle('Information Collected'),
              const SizedBox(height: 12),
              AidePanel(
                child: Text(
                  'The application may temporarily process:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isLightTheme
                        ? Colors.black87
                        : const Color(0xE8FFFFFF),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              AidePanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PolicyItem('Robot telemetry information', isLightTheme),
                    const SizedBox(height: 8),
                    _PolicyItem('Connection status information', isLightTheme),
                    const SizedBox(height: 8),
                    _PolicyItem('Camera and video stream data', isLightTheme),
                    const SizedBox(height: 8),
                    _PolicyItem('User login credentials', isLightTheme),
                    const SizedBox(height: 8),
                    _PolicyItem('Robot control commands', isLightTheme),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Data Usage Section
              AideSectionTitle('Data Usage'),
              const SizedBox(height: 12),
              AidePanel(
                child: Text(
                  'The collected information is used only for:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isLightTheme
                        ? Colors.black87
                        : const Color(0xE8FFFFFF),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              AidePanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PolicyItem('Establishing communication with the robot', isLightTheme),
                    const SizedBox(height: 8),
                    _PolicyItem('Displaying telemetry and robot status', isLightTheme),
                    const SizedBox(height: 8),
                    _PolicyItem('Enabling robot control features', isLightTheme),
                    const SizedBox(height: 8),
                    _PolicyItem('Supporting person-following and localization functions', isLightTheme),
                    const SizedBox(height: 8),
                    _PolicyItem('Improving system reliability and user experience', isLightTheme),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Camera and Streaming Section
              AideSectionTitle('Camera and Streaming'),
              const SizedBox(height: 12),
              AidePanel(
                child: Text(
                  'The application may access live camera streams from the robot to provide monitoring and navigation functionality. Streaming data is intended only for connected authorized users.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.7,
                    color: isLightTheme
                        ? Colors.black87
                        : const Color(0xE8FFFFFF),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Data Storage Section
              AideSectionTitle('Data Storage'),
              const SizedBox(height: 12),
              AidePanel(
                child: Text(
                  'AIDE does not permanently store sensitive personal information on external servers. Most communication occurs locally between the mobile application and the robot system over the connected network.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.7,
                    color: isLightTheme
                        ? Colors.black87
                        : const Color(0xE8FFFFFF),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Security Section
              AideSectionTitle('Security'),
              const SizedBox(height: 12),
              AidePanel(
                child: Text(
                  'Basic authentication and access control mechanisms are implemented to reduce unauthorized access to the robot system. However, users are advised to use trusted and secure local networks while operating the application.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.7,
                    color: isLightTheme
                        ? Colors.black87
                        : const Color(0xE8FFFFFF),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Educational Use Section
              AideSectionTitle('Educational Use'),
              const SizedBox(height: 12),
              AidePanel(
                child: Text(
                  'This application is developed for academic and research purposes as part of a university Final Year Project.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.7,
                    color: isLightTheme
                        ? Colors.black87
                        : const Color(0xE8FFFFFF),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Footer
              Center(
                child: Text(
                  '© 2024-2026 AIDE Project',
                  style: TextStyle(
                    fontSize: 12,
                    color: isLightTheme
                        ? Colors.black38
                        : const Color(0x80FFFFFF),
                  ),
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

class _PolicyItem extends StatelessWidget {
  const _PolicyItem(this.text, this.isLightTheme);
  final String text;
  final bool isLightTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '•',
          style: TextStyle(
            fontSize: 16,
            color: const Color(0xFF44E3C1),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: isLightTheme ? Colors.black87 : const Color(0xE8FFFFFF),
            ),
          ),
        ),
      ],
    );
  }
}
