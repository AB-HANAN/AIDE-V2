import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/aide_shell.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
                      Icons.info_rounded,
                      color: Color(0xFFEF6A3B),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'About',
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

              // App Title
              AidePanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AIDE',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFEF6A3B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Autonomous Interactive Delivery Entity',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isLightTheme
                            ? Colors.black54
                            : const Color(0xB2FFFFFF),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'v1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isLightTheme
                            ? Colors.black38
                            : const Color(0x80FFFFFF),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Description Section 1
              AidePanel(
                child: Text(
                  'AIDE is an intelligent indoor robotic assistant designed to provide interactive navigation, person-following, delivery assistance, monitoring, and remote robot control through a mobile application. The system combines robotics, artificial intelligence, computer vision, and real-time communication technologies to create a smart and user-friendly robotic platform.',
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

              // Description Section 2
              AidePanel(
                child: Text(
                  'The AIDE mobile application allows users to connect directly to the robot and access multiple control and monitoring features from a single interface. The application provides real-time telemetry, manual movement controls, person-following management, localization tools, live camera streaming, and AI-based interaction features.',
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

              // Description Section 3
              AidePanel(
                child: Text(
                  'The robot is powered by the NVIDIA Jetson Orin Nano and uses computer vision techniques for human detection and tracking. The system also integrates safety mechanisms such as emergency stop controls and obstacle awareness to improve operational reliability.',
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

              // Main Features Section
              AideSectionTitle('Main Features'),
              const SizedBox(height: 12),
              AidePanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FeatureItem('Real-time robot telemetry monitoring', isLightTheme),
                    const SizedBox(height: 10),
                    _FeatureItem('Manual robot movement control', isLightTheme),
                    const SizedBox(height: 10),
                    _FeatureItem('AI-based person-following system', isLightTheme),
                    const SizedBox(height: 10),
                    _FeatureItem('Live camera and video streaming', isLightTheme),
                    const SizedBox(height: 10),
                    _FeatureItem('Localization and mapping controls', isLightTheme),
                    const SizedBox(height: 10),
                    _FeatureItem('AI chat interaction support', isLightTheme),
                    const SizedBox(height: 10),
                    _FeatureItem('Administrator and operator access management', isLightTheme),
                    const SizedBox(height: 10),
                    _FeatureItem('Emergency stop and safety controls', isLightTheme),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Technologies Used Section
              AideSectionTitle('Technologies Used'),
              const SizedBox(height: 12),
              AidePanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TechItem('Flutter Mobile Application', isLightTheme),
                    const SizedBox(height: 10),
                    _TechItem('Flask Backend Server', isLightTheme),
                    const SizedBox(height: 10),
                    _TechItem('NVIDIA Jetson Orin Nano', isLightTheme),
                    const SizedBox(height: 10),
                    _TechItem('YOLO-based Computer Vision', isLightTheme),
                    const SizedBox(height: 10),
                    _TechItem('WebRTC Streaming', isLightTheme),
                    const SizedBox(height: 10),
                    _TechItem('Python and REST APIs', isLightTheme),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Development Purpose Section
              AideSectionTitle('Development Purpose'),
              const SizedBox(height: 12),
              AidePanel(
                child: Text(
                  'This application was developed as a Final Year Project to demonstrate the integration of mobile computing, robotics, artificial intelligence, and real-time communication technologies into a unified smart robotic system.',
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
                child: Column(
                  children: [
                    Text(
                      '© 2024-2026 AIDE Project',
                      style: TextStyle(
                        fontSize: 12,
                        color: isLightTheme
                            ? Colors.black38
                            : const Color(0x80FFFFFF),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'All rights reserved',
                      style: TextStyle(
                        fontSize: 11,
                        color: isLightTheme
                            ? Colors.black26
                            : const Color(0x66FFFFFF),
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

class _FeatureItem extends StatelessWidget {
  const _FeatureItem(this.text, this.isLightTheme);
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
            color: const Color(0xFFEF6A3B).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(
            Icons.check,
            color: Color(0xFFEF6A3B),
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

class _TechItem extends StatelessWidget {
  const _TechItem(this.text, this.isLightTheme);
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
