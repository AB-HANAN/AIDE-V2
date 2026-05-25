import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_user_service.dart';

class AdminSetupService {
  static final AdminSetupService _instance = AdminSetupService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  factory AdminSetupService() {
    return _instance;
  }

  AdminSetupService._internal();

  /// Create admin with Firebase Auth + Firestore profile
  Future<String> createAdminWithAuth({
    required String email,
    required String password,
    String displayName = '',
  }) async {
    try {
      // Step 1: Create Firebase Auth account
      print('📝 Creating Firebase Auth account for: $email');
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;
      print('✅ Auth account created with UID: $uid');

      // Step 2: Create Firestore profile
      print('💾 Creating Firestore profile...');
      final now = DateTime.now();

      final userProfile = UserProfile(
        uid: uid,
        email: email,
        displayName: displayName.isNotEmpty ? displayName : email.split('@')[0],
        photoURL: '',
        password: password,
        role: UserRole.admin,
        isActive: true,
        passwordHistory: [PasswordChange(password: password, changedAt: now, changedBy: 'admin')],
        createdAt: now,
        updatedAt: now,
      );

      await _firestore.collection('users').doc(uid).set(userProfile.toMap());
      print('✅ Firestore profile created');

      final message = '\n✅ Admin user created successfully!\n'
          'Email: $email\n'
          'Password: $password\n'
          'Display Name: ${userProfile.displayName}\n'
          'UID: $uid\n'
          'Role: Admin';

      print(message);
      return uid;
    } on FirebaseAuthException catch (e) {
      final errorMessage = '❌ Auth Error: ${e.message}';
      print(errorMessage);
      rethrow;
    } catch (e) {
      final errorMessage = '❌ Error creating admin user: $e';
      print(errorMessage);
      rethrow;
    }
  }

  /// Manually create an admin user in Firestore only (for initial setup)
  /// This creates a user profile without requiring Firebase Auth
  Future<String> createManualAdminUser({
    required String email,
    String displayName = '',
    String? customUid,
  }) async {
    try {
      final uid = customUid ?? email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final now = DateTime.now();

      final userProfile = UserProfile(
        uid: uid,
        email: email,
        displayName: displayName.isNotEmpty ? displayName : email.split('@')[0],
        photoURL: '',
        password: '',
        role: UserRole.admin,
        isActive: true,
        passwordHistory: [],
        createdAt: now,
        updatedAt: now,
      );

      // Add to Firestore
      await _firestore.collection('users').doc(uid).set(userProfile.toMap());

      final message = '✅ Admin user created successfully!\n'
          'Email: $email\n'
          'Display Name: ${userProfile.displayName}\n'
          'UID: $uid';

      print(message);
      return uid;
    } catch (e) {
      final errorMessage = '❌ Error creating admin user: $e';
      print(errorMessage);
      rethrow;
    }
  }

  /// List all existing admin users
  Future<List<UserProfile>> getAdminUsers() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .get();

      return snapshot.docs
          .map((doc) => UserProfile.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error fetching admin users: $e');
      rethrow;
    }
  }

  /// Check if email is already registered
  Future<bool> emailExists(String email) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('❌ Error checking email: $e');
      rethrow;
    }
  }
}