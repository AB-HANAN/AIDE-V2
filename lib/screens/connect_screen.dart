import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_role.dart';
import '../services/app_storage.dart';
import '../services/robot_api.dart';
import '../services/firestore_user_service.dart';
import '../theme/app_theme.dart';
import '../widgets/aide_shell.dart';
import 'dashboard_screen.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({
    super.key,
    required this.role,
    this.username = '',
    this.profileKey = '',
  });

  final AppRole role;
  final String username;
  final String profileKey;

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  final TextEditingController _controller = TextEditingController();

  String _status = '';
  bool _busy = false;
  bool _loadingSavedUrl = true;

  @override
  void initState() {
    super.initState();
    _loadSavedUrl();
  }

  Future<void> _loadSavedUrl() async {
    final savedUrl = await AppStorage.getJetsonUrl();

    if (!mounted) return;

    _controller.text = RobotApi.normalizeBaseUrl(savedUrl);
    setState(() {
      _loadingSavedUrl = false;
    });
  }

  Future<void> _connect({required bool skipCheck}) async {
    final url = RobotApi.normalizeBaseUrl(_controller.text);

    if (url.isEmpty) {
      setState(() {
        _status = 'Please enter the Jetson base URL first.';
      });
      return;
    }

    final api = RobotApi(url);

    if (skipCheck) {
      await AppStorage.updateJetsonUrl(url);
      if (!mounted) return;
      _goToDashboard(api: api, isDemoMode: true);
      return;
    }

    setState(() {
      _busy = true;
      _status = 'Checking $url/telemetry...';
    });

    final check = await api.checkConnection();

    if (!mounted) return;

    if (!check.ok) {
      setState(() {
        _busy = false;
        _status = '${check.message}\n'
            'Check that your phone and Jetson are on the same Wi-Fi, the IP/port is correct, and the Jetson API is running.';
      });
      return;
    }

    try {
      await api.setAutoMode(false);
    } catch (_) {
      // Keep going even if mode reset fails.
    }

    await AppStorage.updateJetsonUrl(url);

    if (!mounted) return;

    setState(() {
      _busy = false;
      _status = 'Connected successfully.';
    });

    _goToDashboard(api: api, isDemoMode: false);
  }

  void _goToDashboard({
    required RobotApi api,
    required bool isDemoMode,
  }) async {
    // Fetch user profile from Firestore to get real display name
    final userService = FirestoreUserService();
    final currentUser = FirebaseAuth.instance.currentUser;
    String displayName = widget.username; // Fallback to email

    if (currentUser != null) {
      try {
        final profile = await userService.getUserProfile(currentUser.uid);
        if (profile != null && profile.displayName.isNotEmpty) {
          displayName = profile.displayName;
        }
      } catch (e) {
        print('Error fetching user profile: $e');
      }
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DashboardScreen(
          api: api,
          role: widget.role,
          displayName: displayName,
          profileKey: widget.profileKey,
          isDemoMode: isDemoMode,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingSavedUrl) {
      return const AideShell(
        showBack: true,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
              const SizedBox(height: 16),
              const Text(
                'Connect To AIDE',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter the Jetson server URL to connect to your robot.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AideColors.textMuted,
                ),
              ),
              const SizedBox(height: 30),
              AidePanel(
                radius: 28,
                color: AideColors.panel.withOpacity(0.92),
                child: Column(
                  children: [
                    AideTextField(
                      controller: _controller,
                      label: 'Jetson Base URL',
                      hintText: 'http://192.168.1.8:5000',
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _busy ? null : () => _connect(skipCheck: false),
                        child: Text(_busy ? 'Connecting...' : 'Connect'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _busy ? null : () => _connect(skipCheck: true),
                        child: const Text('Skip for now'),
                      ),
                    ),
                    if (_status.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        _status,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AideColors.textMuted),
                      ),
                    ],
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
