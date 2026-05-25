import 'dart:async';

import 'package:flutter/material.dart';
import '../models/app_role.dart';
import '../services/robot_api.dart';
import '../widgets/aide_shell.dart';
import '../widgets/robot_live_feed.dart';
import 'ai_chat_screen.dart';
import 'localization_screen.dart';
import 'manual_drive_screen.dart';
import 'person_follow_screen.dart';
import 'profile_screen.dart';
import 'admin_user_management_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.api,
    required this.role,
    required this.displayName,
    this.profileKey = '',
    this.isDemoMode = false,
  });

  final RobotApi api;
  final AppRole role;
  final String displayName;
  final String profileKey;
  final bool isDemoMode;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final TextEditingController _targetController;
  Timer? _telemetryTimer;

  Telemetry? _telemetry;
  bool _loadingTelemetry = true;
  String _telemetryStatus = '';
  bool _applyingTarget = false;

  @override
  void initState() {
    super.initState();
    _targetController = TextEditingController(text: '21');
    _refreshTelemetry();
    _telemetryTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _refreshTelemetry(),
    );
  }

  Future<void> _refreshTelemetry() async {
    if (widget.isDemoMode) {
      if (!mounted) return;
      setState(() {
        _loadingTelemetry = false;
        _telemetryStatus = 'Demo mode active';
      });
      return;
    }

    final telemetry = await widget.api.getTelemetry();

    if (!mounted) return;

    setState(() {
      _telemetry = telemetry;
      _loadingTelemetry = false;
      _telemetryStatus =
          telemetry == null ? 'Unable to fetch live telemetry' : 'Connected';
    });

    if (telemetry != null) {
      final target = telemetry.target.trim();
      if (target.isNotEmpty && target != '-') {
        _targetController.text = target;
      }
    }
  }

  void _open(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  Future<void> _applyTarget() async {
    final target = _targetController.text.trim();

    if (target.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a target number first.'),
        ),
      );
      return;
    }

    if (widget.isDemoMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Demo mode is active. Target preview: $target'),
        ),
      );
      return;
    }

    setState(() {
      _applyingTarget = true;
    });

    try {
      await widget.api.setTarget(target);
      await _refreshTelemetry();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Target set to $target'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to set target: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _applyingTarget = false;
        });
      }
    }
  }

  String _modeText() {
    if (widget.isDemoMode) {
      return 'Preview';
    }
    final mode = _telemetry?.mode.trim() ?? '';
    if (mode.isEmpty || mode == '-') {
      return 'Live';
    }
    return mode;
  }

  String _targetText() {
    if (widget.isDemoMode) {
      return _targetController.text.trim().isEmpty
          ? '21'
          : _targetController.text.trim();
    }
    final target = _telemetry?.target.trim() ?? '';
    if (target.isEmpty || target == '-') {
      return _targetController.text.trim().isEmpty
          ? '-'
          : _targetController.text.trim();
    }
    return target;
  }

  String _speedText() {
    if (widget.isDemoMode) {
      return '0.45 m/s';
    }
    final speed = _telemetry?.speedMps ?? 0.0;
    return '${speed.toStringAsFixed(2)} m/s';
  }

  String _headingText() {
    if (widget.isDemoMode) {
      return '274°';
    }
    final heading = _telemetry?.heading ?? 0.0;
    return '${heading.toStringAsFixed(0)}°';
  }

  Widget _sectionTitle(String title, {String? subtitle}) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: isLight ? Colors.black87 : Colors.white,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: isLight ? Colors.black54 : Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    IconData? icon,
  }) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return AidePanel(
      radius: 22,
      color: isLight
          ? Colors.black.withValues(alpha: 0.05)
          : Colors.white.withValues(alpha: 0.035),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null)
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isLight
                        ? Colors.black.withValues(alpha: 0.08)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: isLight ? Colors.black54 : Colors.white70,
                  ),
                ),
              if (icon != null) const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isLight ? Colors.black54 : Colors.white70,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isLight ? Colors.black87 : Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _navCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AidePanel(
        radius: 24,
        color: isLight
            ? Colors.black.withValues(alpha: 0.08)
            : const Color(0xFF091337).withValues(alpha: 0.82),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEF6A3B).withValues(alpha: isLight ? 0.15 : 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFFEF6A3B),
                size: 22,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isLight ? Colors.black87 : Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            SizedBox(
              height: 32,
              child: Text(
                subtitle,
                style: TextStyle(
                  color: isLight ? Colors.black54 : Colors.white70,
                  fontSize: 10,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    if (_loadingTelemetry) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isLight
              ? Colors.black.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isLight ? Colors.black87 : Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Loading',
              style: TextStyle(
                fontSize: 12,
                color: isLight ? Colors.black87 : Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    final success =
        widget.isDemoMode || (_telemetry != null && _telemetryStatus == 'Connected');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: success
            ? Colors.greenAccent.withValues(alpha: 0.10)
            : const Color(0xFFEF6A3B).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: success
              ? Colors.greenAccent.withValues(alpha: 0.20)
              : const Color(0xFFEF6A3B).withValues(alpha: 0.24),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            success ? Icons.check_circle_rounded : Icons.error_outline_rounded,
            size: 16,
            color: success ? Colors.greenAccent : const Color(0xFFF18B63),
          ),
          const SizedBox(width: 6),
          Text(
            widget.isDemoMode ? 'Demo Mode' : _telemetryStatus,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: success ? Colors.greenAccent : const Color(0xFFF18B63),
            ),
          ),
        ],
      ),
    );
  }

  Widget _targetPanel() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return AidePanel(
      radius: 26,
      color: isLight
          ? Colors.black.withValues(alpha: 0.05)
          : Colors.white.withValues(alpha: 0.03),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'Target Control',
            subtitle: 'Set the numeric target ID for follow mode.',
          ),
          const SizedBox(height: 16),
          AideTextField(
            controller: _targetController,
            label: 'Target ID',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _applyingTarget ? null : _applyTarget,
              child: Text(
                _applyingTarget ? 'Applying...' : 'Apply Target',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _liveDetailsPanel() {
    if (widget.isDemoMode || _telemetry == null) {
      return const SizedBox.shrink();
    }

    final isLight = Theme.of(context).brightness == Brightness.light;
    return AidePanel(
      radius: 26,
      color: isLight
          ? Colors.black.withValues(alpha: 0.05)
          : Colors.white.withValues(alpha: 0.03),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'Live Details',
            subtitle: 'Realtime robot state from telemetry.',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _detailChip(
                'Distance',
                '${_telemetry!.distM.toStringAsFixed(2)} m',
              ),
              _detailChip(
                'Throttle',
                _telemetry!.thr.toStringAsFixed(2),
              ),
              _detailChip(
                'Steering',
                _telemetry!.steer.toStringAsFixed(0),
              ),
              _detailChip(
                'FPS',
                _telemetry!.fps.toStringAsFixed(1),
              ),
              _detailChip(
                'Follow',
                _telemetry!.followEnabled ? 'ON' : 'OFF',
              ),
              _detailChip(
                'Locked',
                _telemetry!.locked ? 'YES' : 'NO',
              ),
              _detailChip(
                'E-Stop',
                _telemetry!.estop ? 'ACTIVE' : 'CLEAR',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailChip(String label, String value) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.035),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _telemetryTimer?.cancel();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayName =
        widget.displayName.trim().isEmpty ? 'Andrew Smith' : widget.displayName;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return AideShell(
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 920;

            return Scaffold(
              backgroundColor: Colors.transparent,
              body: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AidePanel(
                      radius: 28,
                      color: Colors.white.withOpacity(0.03),
                      padding: const EdgeInsets.all(20),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Status chip at top right (separate row)
                              Align(
                                alignment: Alignment.topRight,
                                child: _statusChip(),
                              ),
                              const SizedBox(height: 16),
                              
                              // Robot image and content side by side
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isLight
                                          ? Colors.black.withValues(alpha: 0.06)
                                          : Colors.white.withValues(alpha: 0.04),
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(
                                        color: isLight
                                            ? Colors.black.withValues(alpha: 0.08)
                                            : Colors.white.withValues(alpha: 0.06),
                                      ),
                                    ),
                                    child: Image.asset(
                                      'assets/images/robot_hero.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Welcome back',
                                          style: TextStyle(
                                            color: isLight ? Colors.black54 : Colors.white.withValues(alpha: 0.7),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          widget.displayName,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.w900,
                                            color: isLight ? Colors.black87 : Colors.white,
                                            height: 1.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          
                          // Role badge at bottom right
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: widget.role == AppRole.admin
                                    ? Colors.orange.withValues(alpha: 0.15)
                                    : Colors.blue.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.role.label.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: widget.role == AppRole.admin
                                      ? Colors.orange
                                      : Colors.blue,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _sectionTitle(
                      'Live Camera',
                      subtitle: 'Monitor the robot view and current session state.',
                    ),
                    const SizedBox(height: 12),
                    AidePanel(
                      radius: 28,
                      color: isLight
                          ? Colors.black.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.42),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Stack(
                          children: [
                            RobotLiveFeed(
                              baseUrl: widget.api.baseUrl,
                              demoMode: widget.isDemoMode,
                            ),
                            Positioned(
                              top: 12,
                              right: 12,
                              child: FloatingActionButton.small(
                                heroTag: 'fullscreen_dashboard',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => _FullScreenCamera(api: widget.api),
                                    ),
                                  );
                                },
                                child: const Icon(Icons.fullscreen),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _sectionTitle(
                      'System Overview',
                      subtitle: 'Main motion and tracking indicators.',
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: wide ? 4 : 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: wide ? 1.45 : 1.55,
                      children: [
                        _statCard(
                          title: 'Mode',
                          value: _modeText(),
                          icon: Icons.tune_rounded,
                        ),
                        _statCard(
                          title: 'Target',
                          value: _targetText(),
                          icon: Icons.gps_fixed_rounded,
                        ),
                        _statCard(
                          title: 'Speed',
                          value: _speedText(),
                          icon: Icons.speed_rounded,
                        ),
                        _statCard(
                          title: 'Heading',
                          value: _headingText(),
                          icon: Icons.explore_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (wide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: _targetPanel(),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 7,
                            child: _liveDetailsPanel(),
                          ),
                        ],
                      )
                    else ...[
                      _targetPanel(),
                      const SizedBox(height: 18),
                      _liveDetailsPanel(),
                    ],
                  ],
                ),
              ),
              bottomNavigationBar: _buildBottomNavBar(displayName),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(String displayName) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _bottomNavButton(
                icon: Icons.sports_esports_rounded,
                label: 'Drive',
                onTap: () => _open(ManualDriveScreen(api: widget.api)),
              ),
              _bottomNavButton(
                icon: Icons.accessibility_new_rounded,
                label: 'Follow',
                onTap: () => _open(PersonFollowScreen(api: widget.api)),
              ),
              _bottomNavButton(
                icon: Icons.map_rounded,
                label: 'Localize',
                onTap: () => _open(LocalizationScreen(api: widget.api)),
              ),
              _bottomNavButton(
                icon: Icons.person_rounded,
                label: 'Profile',
                onTap: () => _open(ProfileScreen(role: widget.role)),
              ),
              if (widget.role == AppRole.admin)
                _bottomNavButton(
                  icon: Icons.people_rounded,
                  label: 'Manage Users',
                  onTap: () => _open(const AdminUserManagementScreen()),
                ),
              _bottomNavButton(
                icon: Icons.smart_toy_rounded,
                label: 'Chat AI',
                onTap: () => _open(
                  AiChatScreen(
                    api: widget.api,
                    role: widget.role,
                    displayName: displayName,
                    isDemoMode: widget.isDemoMode,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomNavButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF091337).withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: const Color(0xFFEF6A3B),
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Full screen camera view for dashboard
class _FullScreenCamera extends StatelessWidget {
  const _FullScreenCamera({required this.api});
  final RobotApi api;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Preview'),
        leading: IconButton(
          icon: const Icon(Icons.fullscreen_exit),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: RobotLiveFeed(
          baseUrl: api.baseUrl,
          height: MediaQuery.of(context).size.height - 80,
        ),
      ),
    );
  }
}