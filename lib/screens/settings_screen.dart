import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/aide_shell.dart';
import '../services/app_storage.dart';
import 'about_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _autoConnectEnabled = true;

  String _themeMode = 'system';
  Color _primaryColor = const Color(0xFFEF6A3B);

  @override
  void initState() {
    super.initState();
    _loadThemeSettings();
  }

  Future<void> _loadThemeSettings() async {
    final themeMode = await AppStorage.getThemeMode();
    final primaryColor = await AppStorage.getPrimaryColor();

    setState(() {
      _themeMode = themeMode;
      _primaryColor = Color(primaryColor);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AideShell(
      showBack: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    child: Icon(
                      Icons.settings_rounded,
                      color: const Color(0xFFEF6A3B),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black87
                            : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Theme & Colors Section
              AideSectionTitle('Theme & Colors'),
              const SizedBox(height: 12),
              AidePanel(
                radius: 24,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.white.withValues(alpha: 0.92)
                    : AideColors.panel.withValues(alpha: 0.92),
                child: Column(
                  children: [
                    _themeRadioTile(
                      title: 'Dark Theme',
                      subtitle: 'Use dark colors for the app',
                      value: 'dark',
                      groupValue: _themeMode,
                      onChanged: (value) async {
                        setState(() => _themeMode = value!);
                        await AppStorage.setThemeMode(value!);
                      },
                    ),
                    Divider(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.black.withValues(alpha: 0.1)
                          : Colors.white.withValues(alpha: 0.1),
                      height: 1,
                    ),
                    _themeRadioTile(
                      title: 'Light Theme',
                      subtitle: 'Use light colors for the app',
                      value: 'light',
                      groupValue: _themeMode,
                      onChanged: (value) async {
                        setState(() => _themeMode = value!);
                        await AppStorage.setThemeMode(value!);
                      },
                    ),
                    Divider(
                      color: Colors.white.withOpacity(0.1),
                      height: 1,
                    ),
                    _themeRadioTile(
                      title: 'System Default',
                      subtitle: 'Follow device theme settings',
                      value: 'system',
                      groupValue: _themeMode,
                      onChanged: (value) async {
                        setState(() => _themeMode = value!);
                        await AppStorage.setThemeMode(value!);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Color Selection
              const AideSectionTitle('Accent Colors'),
              const SizedBox(height: 12),
              AidePanel(
                radius: 24,
                color: AideColors.panel.withOpacity(0.92),
                child: Column(
                  children: [
                    _colorPickerTile(
                      title: 'Primary Color',
                      subtitle: 'Main accent color',
                      color: _primaryColor,
                      onTap: () => _showColorPicker(
                        context,
                        'Primary Color',
                        _primaryColor,
                        (color) async {
                          setState(() => _primaryColor = color);
                          await AppStorage.setPrimaryColor(color.value);
                        },
                      ),
                    ),
                    Divider(
                      color: Colors.white.withOpacity(0.1),
                      height: 1,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // App Settings Section
              const AideSectionTitle('App Settings'),
              const SizedBox(height: 12),
              AidePanel(
                radius: 24,
                color: AideColors.panel.withOpacity(0.92),
                child: Column(
                  children: [
                    _settingTile(
                      title: 'Notifications',
                      subtitle: 'Receive alerts and updates',
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() => _notificationsEnabled = value);
                      },
                    ),
                    Divider(
                      color: Colors.white.withOpacity(0.1),
                      height: 1,
                    ),
                    _settingTile(
                      title: 'Auto Connect',
                      subtitle: 'Automatically connect to saved Jetson URL',
                      value: _autoConnectEnabled,
                      onChanged: (value) {
                        setState(() => _autoConnectEnabled = value);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Connection Settings Section
              const AideSectionTitle('Connection'),
              const SizedBox(height: 12),
              AidePanel(
                radius: 24,
                color: AideColors.panel.withOpacity(0.92),
                child: Column(
                  children: [
                    _settingButton(
                      title: 'Jetson URL',
                      subtitle: 'Configure robot connection',
                      icon: Icons.router_rounded,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Edit Jetson URL')),
                        );
                      },
                    ),
                    Divider(
                      color: Colors.white.withOpacity(0.1),
                      height: 1,
                    ),
                    _settingButton(
                      title: 'Network Info',
                      subtitle: 'View connection details',
                      icon: Icons.wifi_rounded,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Network Information')),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // System Section
              const AideSectionTitle('System'),
              const SizedBox(height: 12),
              AidePanel(
                radius: 24,
                color: AideColors.panel.withOpacity(0.92),
                child: Column(
                  children: [
                    _settingButton(
                      title: 'App Version',
                      subtitle: 'v1.0.0',
                      icon: Icons.info_rounded,
                      onTap: () {},
                    ),
                    Divider(
                      color: Colors.white.withOpacity(0.1),
                      height: 1,
                    ),
                    _settingButton(
                      title: 'About AIDE',
                      subtitle: 'Learn more about this app',
                      icon: Icons.info_outline_rounded,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AboutScreen(),
                          ),
                        );
                      },
                    ),
                    Divider(
                      color: Colors.white.withOpacity(0.1),
                      height: 1,
                    ),
                    _settingButton(
                      title: 'Clear Cache',
                      subtitle: 'Remove temporary files',
                      icon: Icons.delete_sweep_rounded,
                      onTap: () {
                        _showConfirmDialog(
                          context,
                          title: 'Clear Cache?',
                          message: 'This will remove temporary files. Continue?',
                          onConfirm: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Cache cleared')),
                            );
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Danger Zone
              const AideSectionTitle('Danger Zone'),
              const SizedBox(height: 12),
              AidePanel(
                radius: 24,
                color: AideColors.panel.withOpacity(0.92),
                child: InkWell(
                  onTap: () {
                    _showConfirmDialog(
                      context,
                      title: 'Logout?',
                      message: 'You will need to login again to access AIDE.',
                      confirmText: 'Logout',
                      isDestructive: true,
                      onConfirm: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Icon(
                          Icons.logout_rounded,
                          color: Colors.red.shade400,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Logout',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _themeRadioTile({
    required String title,
    required String subtitle,
    required String value,
    required String groupValue,
    required Function(String?) onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: const Color(0xFFEF6A3B),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
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

  Widget _colorPickerTile({
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 2,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFEF6A3B),
          ),
        ],
      ),
    );
  }

  Widget _settingButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFFEF6A3B),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(
    BuildContext context,
    String title,
    Color initialColor,
    Function(Color) onColorSelected,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: Text(
          'Select $title',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _colorOptions().length,
              itemBuilder: (context, index) {
                final color = _colorOptions()[index];
                return GestureDetector(
                  onTap: () {
                    onColorSelected(color);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Color updated! Theme will refresh shortly.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: initialColor == color
                            ? Colors.white
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  List<Color> _colorOptions() {
    return [
      const Color(0xFFEF6A3B), // Orange
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFF4CAF50), // Green
      const Color(0xFFE91E63), // Pink
      const Color(0xFF9C27B0), // Purple
      const Color(0xFFF44336), // Red
      const Color(0xFF2196F3), // Blue
      const Color(0xFFFF9800), // Amber
      const Color(0xFF00E676), // Light Green
      const Color(0xFF00B0FF), // Light Blue
      const Color(0xFFFFEA00), // Yellow
      const Color(0xFFD500F9), // Deep Purple
      const Color(0xFF76FF03), // Lime
      const Color(0xFF36D7FF), // Cyan
      const Color(0xFFFF3D00), // Deep Orange
    ];
  }

  void _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    bool isDestructive = false,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: onConfirm,
            child: Text(
              confirmText,
              style: TextStyle(
                color: isDestructive ? Colors.red : const Color(0xFFEF6A3B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
