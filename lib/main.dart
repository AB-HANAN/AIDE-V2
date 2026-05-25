import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/opening_screen.dart';
import 'screens/admin_setup_screen.dart';
import 'services/app_storage.dart';
import 'services/admin_setup_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AideApp());
}

class AideApp extends StatefulWidget {
  const AideApp({super.key});

  @override
  State<AideApp> createState() => _AideAppState();
}

class _AideAppState extends State<AideApp> {
  String _themeMode = 'dark';
  Color _primaryColor = const Color(0xFFEF6A3B);
  Color _secondaryColor = const Color(0xFF00BCD4);
  bool _initialized = false;
  bool _hasAdmins = false;
  final AdminSetupService _setupService = AdminSetupService();

  @override
  void initState() {
    super.initState();
    _loadThemeSettings();
    _checkAdminSetup();
    _startThemeWatcher();
  }

  Future<void> _checkAdminSetup() async {
    try {
      final admins = await _setupService.getAdminUsers();
      setState(() {
        _hasAdmins = admins.isNotEmpty;
      });
    } catch (e) {
      print('Error checking admins: $e');
      setState(() {
        _hasAdmins = true; // Assume admin exists on error
      });
    }
  }

  Future<void> _loadThemeSettings() async {
    final themeMode = await AppStorage.getThemeMode();
    final primaryColor = await AppStorage.getPrimaryColor();
    final secondaryColor = await AppStorage.getSecondaryColor();

    setState(() {
      _themeMode = themeMode;
      _primaryColor = Color(primaryColor);
      _secondaryColor = Color(secondaryColor);
      _initialized = true;
    });
  }

  void _startThemeWatcher() {
    // Periodically check for theme changes (every 500ms)
    Future.delayed(Duration.zero, () {
      _watchThemeChanges();
    });
  }

  void _watchThemeChanges() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) break;

      final themeMode = await AppStorage.getThemeMode();
      final primaryColor = await AppStorage.getPrimaryColor();
      final secondaryColor = await AppStorage.getSecondaryColor();

      if (mounted &&
          (_themeMode != themeMode ||
              _primaryColor.value != primaryColor ||
              _secondaryColor.value != secondaryColor)) {
        setState(() {
          _themeMode = themeMode;
          _primaryColor = Color(primaryColor);
          _secondaryColor = Color(secondaryColor);
        });
      }
    }
  }

  ThemeData _getTheme() {
    switch (_themeMode) {
      case 'light':
        return AideTheme.light(
          primaryColor: _primaryColor,
          secondaryColor: _secondaryColor,
        );
      case 'system':
        // Use device brightness
        final brightness = MediaQuery.of(context).platformBrightness;
        if (brightness == Brightness.light) {
          return AideTheme.light(
            primaryColor: _primaryColor,
            secondaryColor: _secondaryColor,
          );
        } else {
          return AideTheme.dark(
            primaryColor: _primaryColor,
            secondaryColor: _secondaryColor,
          );
        }
      case 'dark':
      default:
        return AideTheme.dark(
          primaryColor: _primaryColor,
          secondaryColor: _secondaryColor,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return MaterialApp(
        title: 'AIDE',
        debugShowCheckedModeBanner: false,
        theme: AideTheme.dark(),
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    // Show admin setup screen if no admins exist
    final homeScreen = !_hasAdmins ? const AdminSetupScreen() : const OpeningScreen();

    return MaterialApp(
      title: 'AIDE',
      debugShowCheckedModeBanner: false,
      theme: _getTheme(),
      home: homeScreen,
    );
  }
}