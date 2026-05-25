import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/aide_shell.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

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
                      Icons.help_rounded,
                      color: Color(0xFFEF6A3B),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Help & Support',
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
                  'Welcome to the AIDE support section. This page provides basic guidance for connecting and operating the robot system through the mobile application.',
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

              // Getting Started Section
              AideSectionTitle('Getting Started'),
              const SizedBox(height: 12),
              AidePanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StepItem('Power on the robot system.', isLightTheme),
                    const SizedBox(height: 10),
                    _StepItem('Ensure the robot and mobile device are connected to the same network.', isLightTheme),
                    const SizedBox(height: 10),
                    _StepItem('Open the AIDE application.', isLightTheme),
                    const SizedBox(height: 10),
                    _StepItem('Enter the robot server IP address and port number.', isLightTheme),
                    const SizedBox(height: 10),
                    _StepItem('Press Connect to establish communication.', isLightTheme),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Main Modules Section
              AideSectionTitle('Main Modules'),
              const SizedBox(height: 12),
              _ModuleItem(
                title: 'Dashboard',
                description: 'Displays robot telemetry, connection status, speed, heading, and system information.',
                isLightTheme: isLightTheme,
              ),
              const SizedBox(height: 12),
              _ModuleItem(
                title: 'Manual Drive',
                description: 'Allows users to control robot movement manually using directional controls and emergency stop functionality.',
                isLightTheme: isLightTheme,
              ),
              const SizedBox(height: 12),
              _ModuleItem(
                title: 'Person Following',
                description: 'Enables AI-based person-following mode. Users can start or stop tracking and monitor target lock status.',
                isLightTheme: isLightTheme,
              ),
              const SizedBox(height: 12),
              _ModuleItem(
                title: 'Localization',
                description: 'Provides controls for mapping, route tracing, and localization-related operations.',
                isLightTheme: isLightTheme,
              ),
              const SizedBox(height: 12),
              _ModuleItem(
                title: 'Chat AI',
                description: 'Allows users to interact with the integrated AI assistant through text-based communication.',
                isLightTheme: isLightTheme,
              ),
              const SizedBox(height: 20),

              // Troubleshooting Section
              AideSectionTitle('Troubleshooting'),
              const SizedBox(height: 12),
              _TroubleshootingItem(
                title: 'Unable to Connect',
                items: [
                  'Verify that the robot server is running.',
                  'Check the IP address and port number.',
                  'Ensure both devices are connected to the same network.',
                ],
                isLightTheme: isLightTheme,
              ),
              const SizedBox(height: 14),
              _TroubleshootingItem(
                title: 'No Camera Stream',
                items: [
                  'Verify the camera is connected properly.',
                  'Check if the streaming service is active.',
                  'Restart the application if necessary.',
                ],
                isLightTheme: isLightTheme,
              ),
              const SizedBox(height: 14),
              _TroubleshootingItem(
                title: 'Robot Not Responding',
                items: [
                  'Confirm telemetry connection is active.',
                  'Check robot power and controller status.',
                  'Use Emergency Stop and reconnect if required.',
                ],
                isLightTheme: isLightTheme,
              ),
              const SizedBox(height: 20),

              // Safety Notes Section
              AideSectionTitle('Safety Notes'),
              const SizedBox(height: 12),
              AidePanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SafetyItem('Operate the robot in safe indoor environments.', isLightTheme),
                    const SizedBox(height: 10),
                    _SafetyItem('Keep obstacles and sensitive equipment away from the robot path.', isLightTheme),
                    const SizedBox(height: 10),
                    _SafetyItem('Always use Emergency Stop in unsafe situations.', isLightTheme),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Contact Section
              AideSectionTitle('Contact'),
              const SizedBox(height: 12),
              AidePanel(
                child: Text(
                  'For technical assistance or project-related support, contact the AIDE development team or project supervisor.',
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

class _StepItem extends StatelessWidget {
  const _StepItem(this.text, this.isLightTheme);
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

class _ModuleItem extends StatelessWidget {
  const _ModuleItem({
    required this.title,
    required this.description,
    required this.isLightTheme,
  });

  final String title;
  final String description;
  final bool isLightTheme;

  @override
  Widget build(BuildContext context) {
    return AidePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFEF6A3B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: isLightTheme ? Colors.black87 : const Color(0xE8FFFFFF),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _TroubleshootingItem extends StatelessWidget {
  const _TroubleshootingItem({
    required this.title,
    required this.items,
    required this.isLightTheme,
  });

  final String title;
  final List<String> items;
  final bool isLightTheme;

  @override
  Widget build(BuildContext context) {
    return AidePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFEF6A3B),
            ),
          ),
          const SizedBox(height: 10),
          ...items.asMap().entries.map((entry) {
            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry.key + 1}. ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF44E3C1),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 12,
                          color: isLightTheme ? Colors.black87 : const Color(0xE8FFFFFF),
                        ),
                      ),
                    ),
                  ],
                ),
                if (entry.key < items.length - 1) const SizedBox(height: 8),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _SafetyItem extends StatelessWidget {
  const _SafetyItem(this.text, this.isLightTheme);
  final String text;
  final bool isLightTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(
            Icons.check,
            color: Colors.red,
            size: 12,
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
