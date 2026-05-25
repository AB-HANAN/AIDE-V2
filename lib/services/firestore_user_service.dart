import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum UserRole { admin, operator }

class PasswordChange {
  final String password;
  final DateTime changedAt;
  final String changedBy; // 'user' or 'admin'

  PasswordChange({
    required this.password,
    required this.changedAt,
    required this.changedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'password': password,
      'changedAt': changedAt,
      'changedBy': changedBy,
    };
  }

  factory PasswordChange.fromMap(Map<String, dynamic> map) {
    return PasswordChange(
      password: map['password'] ?? '',
      changedAt: (map['changedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      changedBy: map['changedBy'] ?? 'user',
    );
  }
}

class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final String photoURL;
  final String password; // Password set by admin (for reference only)
  final UserRole role;
  final bool isActive;
  final List<PasswordChange> passwordHistory; // Password change history
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt; // Timestamp when user was deleted (soft delete)

  UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoURL,
    required this.password,
    required this.role,
    required this.isActive,
    required this.passwordHistory,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'password': password,
      'role': role.toString().split('.').last, // 'admin' or 'operator'
      'isActive': isActive,
      'passwordHistory': passwordHistory.map((ph) => ph.toMap()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'deletedAt': deletedAt,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    final roleString = map['role'] ?? 'operator';
    final role = roleString == 'admin' ? UserRole.admin : UserRole.operator;
    
    final passwordHistoryList = (map['passwordHistory'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final passwordHistory = passwordHistoryList
        .map((ph) => PasswordChange.fromMap(ph))
        .toList();

    return UserProfile(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoURL: map['photoURL'] ?? '',
      password: map['password'] ?? '',
      role: role,
      isActive: map['isActive'] ?? true,
      passwordHistory: passwordHistory,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deletedAt: (map['deletedAt'] as Timestamp?)?.toDate(),
    );
  }
}

class FirestoreUserService {
  static final FirestoreUserService _instance = FirestoreUserService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  factory FirestoreUserService() {
    return _instance;
  }

  FirestoreUserService._internal();

  /// Get user collection reference
  CollectionReference get _usersCollection => _firestore.collection('users');

  /// Create user profile in Firestore
  Future<void> createUserProfile({
    required String uid,
    required String email,
    String displayName = '',
    String photoURL = '',
    String password = '',
    UserRole role = UserRole.operator,
    bool isActive = true,
  }) async {
    try {
      final now = DateTime.now();
      final initialPasswordChange = password.isNotEmpty
          ? PasswordChange(
              password: password,
              changedAt: now,
              changedBy: 'admin',
            )
          : null;

      final userProfile = UserProfile(
        uid: uid,
        email: email,
        displayName: displayName,
        photoURL: photoURL,
        password: password,
        role: role,
        isActive: isActive,
        passwordHistory: initialPasswordChange != null ? [initialPasswordChange] : [],
        createdAt: now,
        updatedAt: now,
      );

      await _usersCollection.doc(uid).set(userProfile.toMap());
    } catch (e) {
      rethrow;
    }
  }

  /// Get user profile by UID
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (doc.exists) {
        return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// Get current user profile
  Future<UserProfile?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      return await getUserProfile(user.uid);
    } catch (e) {
      rethrow;
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    required String uid,
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': DateTime.now(),
      };

      if (displayName != null) {
        updateData['displayName'] = displayName;
      }
      if (photoURL != null) {
        updateData['photoURL'] = photoURL;
      }

      await _usersCollection.doc(uid).update(updateData);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete user profile
  Future<void> deleteUserProfile(String uid) async {
    try {
      await _usersCollection.doc(uid).delete();
    } catch (e) {
      rethrow;
    }
  }

  /// Check if user profile exists
  Future<bool> userProfileExists(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      return doc.exists;
    } catch (e) {
      rethrow;
    }
  }

  /// Stream user profile changes
  Stream<UserProfile?> userProfileStream(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  // ================= ADMIN MANAGEMENT =================

  /// Get all users (Admin only) - excludes deleted users
  Future<List<UserProfile>> getAllUsers() async {
    try {
      final snapshot = await _usersCollection.get();
      return snapshot.docs
          .map((doc) => UserProfile.fromMap(doc.data() as Map<String, dynamic>))
          .where((user) => user.deletedAt == null) // Filter out deleted users
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Stream all users (Admin only) - excludes deleted users
  Stream<List<UserProfile>> getAllUsersStream() {
    return _usersCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => UserProfile.fromMap(doc.data() as Map<String, dynamic>))
          .where((user) => user.deletedAt == null) // Filter out deleted users
          .toList();
    });
  }

  /// Update user role (Admin only)
  Future<void> updateUserRole(String uid, UserRole role) async {
    try {
      await _usersCollection.doc(uid).update({
        'role': role.toString().split('.').last,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Activate/Deactivate user (Admin only)
  Future<void> setUserActive(String uid, bool isActive) async {
    try {
      await _usersCollection.doc(uid).update({
        'isActive': isActive,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Update user info (Admin only)
  Future<void> adminUpdateUser({
    required String uid,
    required String displayName,
    UserRole? role,
    bool? isActive,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'displayName': displayName,
        'updatedAt': DateTime.now(),
      };

      if (role != null) {
        updateData['role'] = role.toString().split('.').last;
      }
      if (isActive != null) {
        updateData['isActive'] = isActive;
      }

      await _usersCollection.doc(uid).update(updateData);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete user (Admin only) - marks user as deleted
  /// Uses Firestore Rules to ensure only admins can delete
  /// Soft delete: marks user as deleted instead of removing completely
  Future<void> adminDeleteUser(String uid) async {
    try {
      final now = DateTime.now();
      
      // Update user to mark as deleted
      // Firestore Rules will validate that caller is admin
      await _usersCollection.doc(uid).update({
        'isActive': false,
        'deletedAt': now,
        'updatedAt': now,
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Create user with Firebase Auth + Firestore profile (Admin only)
  /// Requires adminEmail and adminPassword to restore admin session after user creation
  Future<UserProfile> adminCreateUser({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) async {
    try {
      // Get current admin user before creating new user
      final currentAdminUser = _auth.currentUser;
      if (currentAdminUser == null) {
        throw Exception('No admin user logged in');
      }

      // Create Firebase Auth account
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;
      final now = DateTime.now();

      // Create Firestore profile with password stored for admin reference
      final initialPasswordChange = PasswordChange(
        password: password,
        changedAt: now,
        changedBy: 'admin',
      );
      
      final userProfile = UserProfile(
        uid: uid,
        email: email,
        displayName: displayName,
        photoURL: '',
        password: password, // Store password for admin reference
        role: role,
        isActive: true,
        passwordHistory: [initialPasswordChange],
        createdAt: now,
        updatedAt: now,
      );

      await _usersCollection.doc(uid).set(userProfile.toMap());

      // Sign out the newly created user
      await _auth.signOut();
      
      // Re-sign in as admin using their password from Firestore
      final adminProfile = await _usersCollection.doc(currentAdminUser.uid).get();
      if (adminProfile.exists) {
        final adminData = adminProfile.data() as Map<String, dynamic>;
        final storedAdminPassword = adminData['password'] as String?;
        
        if (storedAdminPassword != null && storedAdminPassword.isNotEmpty) {
          try {
            await _auth.signInWithEmailAndPassword(
              email: currentAdminUser.email!,
              password: storedAdminPassword,
            );
          } catch (e) {
            print('Failed to re-sign admin: $e');
            rethrow;
          }
        }
      }

      return userProfile;
    } catch (e) {
      rethrow;
    }
  }

  /// Check if current user is admin
  Future<bool> isCurrentUserAdmin() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      final profile = await getUserProfile(currentUser.uid);
      return profile?.role == UserRole.admin;
    } catch (e) {
      return false;
    }
  }

  /// Update user password and track in history (User can update their own, Admin can update any)
  Future<void> updateUserPassword({
    required String uid,
    required String newPassword,
    required String changedBy, // 'user' or 'admin'
  }) async {
    try {
      final profile = await getUserProfile(uid);
      if (profile == null) {
        throw Exception('User profile not found');
      }

      // Add new password to history
      final updatedHistory = List<PasswordChange>.from(profile.passwordHistory);
      updatedHistory.add(
        PasswordChange(
          password: newPassword,
          changedAt: DateTime.now(),
          changedBy: changedBy,
        ),
      );

      // Update Firestore
      await _usersCollection.doc(uid).update({
        'password': newPassword,
        'passwordHistory': updatedHistory.map((ph) => ph.toMap()).toList(),
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      rethrow;
    }
  }
}
