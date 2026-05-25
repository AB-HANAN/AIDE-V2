// Run this script to manually create an admin user
// Command: dart scripts/setup_admin.dart

import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../lib/firebase_options.dart';
import '../lib/services/admin_setup_service.dart';

void main() async {
  print('🔧 AIDE Admin Setup Script');
  print('=' * 60);

  try {
    // Initialize Firebase
    print('\n📱 Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized\n');

    final adminSetup = AdminSetupService();

    // Check if admin already exists
    print('🔍 Checking if admin email already exists...');
    final exists = await adminSetup.emailExists('formanitech@gmail.com');

    if (exists) {
      print('⚠️  Email already registered!\n');
      final admins = await adminSetup.getAdminUsers();
      print('📋 Existing Admin Users:');
      for (var admin in admins) {
        print('   • ${admin.email} (${admin.displayName}) - Active: ${admin.isActive}');
      }
    } else {
      // Create admin user with Firebase Auth
      print('➕ Creating admin user with authentication...\n');

      final uid = await adminSetup.createAdminWithAuth(
        email: 'formanitech@gmail.com',
        password: 'password6',
        displayName: 'Admin',
      );

      print('\n' + '=' * 60);
      print('✅ ADMIN SETUP COMPLETE!');
      print('=' * 60);
      print('\n📋 Admin Credentials:');
      print('   Email: formanitech@gmail.com');
      print('   Password: password6');
      print('   Role: Admin');
      print('   UID: $uid\n');

      // List all admins
      print('📋 All Admin Users in Firestore:');
      final admins = await adminSetup.getAdminUsers();
      for (var admin in admins) {
        print('   • ${admin.email} (${admin.displayName}) - Active: ${admin.isActive}');
      }
    }

    print('\n' + '=' * 60);
    print('Setup script completed successfully!');
    print('=' * 60);
    exit(0);
  } catch (e) {
    print('\n❌ Error during setup: $e');
    print('Make sure:');
    print('  1. Firebase is properly configured');
    print('  2. Firestore is enabled in Firebase Console');
    print('  3. You have internet connection');
    exit(1);
  }
}
