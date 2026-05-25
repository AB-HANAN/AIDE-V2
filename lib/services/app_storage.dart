import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_role.dart';

class AppStorage {
  // ================= KEYS =================
  static const String _isInitializedKey = 'is_initialized';

  static const String _adminNameKey = 'admin_name';
  static const String _adminPasswordKey = 'admin_password';

  static const String _userNameKey = 'user_name';
  static const String _userPasswordKey = 'user_password';

  static const String _robotNameKey = 'robot_name';
  static const String _phoneNumberKey = 'phone_number';

  static const String _jetsonUrlKey = 'jetson_url';

  static const String _lastEmailKey = 'last_email';

  static const String _themeKey = 'theme_mode'; // 'dark', 'light', 'system'
  static const String _primaryColorKey = 'primary_color';
  static const String _secondaryColorKey = 'secondary_color';

  // ================= INTERNAL =================
  static Future<SharedPreferences> _prefs() async {
    return SharedPreferences.getInstance();
  }

  // ================= INIT =================
  static Future<bool> isInitialized() async {
    final prefs = await _prefs();
    return prefs.getBool(_isInitializedKey) ?? false;
  }

  static Future<void> markInitialized() async {
    final prefs = await _prefs();
    await prefs.setBool(_isInitializedKey, true);
  }

  static Future<void> createAdmin({
    required String adminName,
    required String adminPassword,
  }) async {
    final prefs = await _prefs();

    await prefs.setString(_adminNameKey, adminName.trim());
    await prefs.setString(_adminPasswordKey, adminPassword.trim());
    await prefs.setBool(_isInitializedKey, true);

    // defaults
    if (!prefs.containsKey(_userNameKey)) {
      await prefs.setString(_userNameKey, '');
    }

    if (!prefs.containsKey(_userPasswordKey)) {
      await prefs.setString(_userPasswordKey, '');
    }

    if (!prefs.containsKey(_robotNameKey)) {
      await prefs.setString(_robotNameKey, 'AIDE');
    }

    if (!prefs.containsKey(_phoneNumberKey)) {
      await prefs.setString(_phoneNumberKey, '+92 300 0000000');
    }

    if (!prefs.containsKey(_jetsonUrlKey)) {
      await prefs.setString(_jetsonUrlKey, 'http://192.168.1.8:5000');
    }
  }

  // ================= GETTERS =================
  static Future<String> getAdminName() async {
    final prefs = await _prefs();
    return prefs.getString(_adminNameKey) ?? '';
  }

  static Future<String> getAdminPassword() async {
    final prefs = await _prefs();
    return prefs.getString(_adminPasswordKey) ?? '';
  }

  static Future<String> getUserName() async {
    final prefs = await _prefs();
    return prefs.getString(_userNameKey) ?? '';
  }

  static Future<String> getUserPassword() async {
    final prefs = await _prefs();
    return prefs.getString(_userPasswordKey) ?? '';
  }

  static Future<String> getRobotName() async {
    final prefs = await _prefs();
    return prefs.getString(_robotNameKey) ?? 'AIDE';
  }

  static Future<String> getPhoneNumber() async {
    final prefs = await _prefs();
    return prefs.getString(_phoneNumberKey) ?? '+92 300 0000000';
  }

  static Future<String> getJetsonUrl() async {
    final prefs = await _prefs();
    return prefs.getString(_jetsonUrlKey) ??
        'http://192.168.1.8:5000';
  }

  // ================= VALIDATION =================
  static Future<bool> hasUserCredentials() async {
    final userName = await getUserName();
    final userPassword = await getUserPassword();
    return userName.isNotEmpty && userPassword.isNotEmpty;
  }

  static Future<bool> validateLogin({
    required AppRole role,
    required String username,
    required String password,
  }) async {
    final enteredName = username.trim();
    final enteredPassword = password.trim();

    if (role == AppRole.admin) {
      final savedName = await getAdminName();
      final savedPassword = await getAdminPassword();
      return enteredName == savedName &&
          enteredPassword == savedPassword;
    }

    final savedName = await getUserName();
    final savedPassword = await getUserPassword();
    return enteredName == savedName &&
        enteredPassword == savedPassword;
  }

  // ================= UPDATE =================
  static Future<void> setAdminName(String adminName) async {
    final prefs = await _prefs();
    await prefs.setString(_adminNameKey, adminName.trim());
  }

  static Future<void> setUserName(String userName) async {
    final prefs = await _prefs();
    await prefs.setString(_userNameKey, userName.trim());
  }

  static Future<String> getLastEmail() async {
    final prefs = await _prefs();
    return prefs.getString(_lastEmailKey) ?? '';
  }

  static Future<void> setLastEmail(String email) async {
    final prefs = await _prefs();
    await prefs.setString(_lastEmailKey, email.trim());
  }

  static Future<void> updateAdmin({
    required String adminName,
    required String adminPassword,
  }) async {
    final prefs = await _prefs();
    await prefs.setString(_adminNameKey, adminName.trim());
    await prefs.setString(_adminPasswordKey, adminPassword.trim());
  }

  static Future<void> updateUser({
    required String userName,
    required String userPassword,
  }) async {
    final prefs = await _prefs();
    await prefs.setString(_userNameKey, userName.trim());
    await prefs.setString(_userPasswordKey, userPassword.trim());
  }

  static Future<void> updateProfileInfo({
    required String robotName,
    required String phoneNumber,
  }) async {
    final prefs = await _prefs();
    await prefs.setString(_robotNameKey, robotName.trim());
    await prefs.setString(_phoneNumberKey, phoneNumber.trim());
  }

  static Future<void> updateJetsonUrl(String url) async {
    final prefs = await _prefs();
    await prefs.setString(_jetsonUrlKey, url.trim());
  }

  // ================= THEME & COLORS =================
  static Future<String> getThemeMode() async {
    final prefs = await _prefs();
    return prefs.getString(_themeKey) ?? 'system';
  }

  static Future<void> setThemeMode(String themeMode) async {
    final prefs = await _prefs();
    await prefs.setString(_themeKey, themeMode);
  }

  static Future<int> getPrimaryColor() async {
    final prefs = await _prefs();
    return prefs.getInt(_primaryColorKey) ?? 0xFFEF6A3B; // Default orange
  }

  static Future<void> setPrimaryColor(int color) async {
    final prefs = await _prefs();
    await prefs.setInt(_primaryColorKey, color);
  }

  static Future<int> getSecondaryColor() async {
    final prefs = await _prefs();
    return prefs.getInt(_secondaryColorKey) ?? 0xFF00BCD4; // Default cyan
  }

  static Future<void> setSecondaryColor(int color) async {
    final prefs = await _prefs();
    await prefs.setInt(_secondaryColorKey, color);
  }
}