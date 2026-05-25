# Firebase Security Rules Deployment Guide

## Overview
This document explains the Firestore security rules and how to deploy them.

## Security Rules Summary

### User Authentication
- All operations require user to be authenticated
- Admin users have elevated permissions

### Collections Protected

#### **Users Collection** (`/users/{userId}`)

**Read Access:**
- Users can read their own profile
- Admins can read all user profiles

**Create Access:**
- Only during registration
- User ID must match authenticated user
- Automatically assigns `role: 'operator'` for new users

**Update Access:**
- Users can update their own profile (except: uid, email, role, isActive, createdAt)
- Admins can update any user profile (including role and status)

**Delete Access:**
- Only admins can delete user profiles

**List Access:**
- Only admins can list all users

## How to Deploy Security Rules

### Option 1: Using Firebase Console (Recommended for Beginners)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your **AIDE** project
3. Navigate to **Firestore Database** → **Rules** tab
4. Copy the contents from `firestore.rules` file
5. Paste into the rules editor
6. Click **Publish**

### Option 2: Using Firebase CLI (Recommended for Production)

1. Install Firebase CLI (if not already installed):
   ```bash
   npm install -g firebase-tools
   ```

2. Login to Firebase:
   ```bash
   firebase login
   ```

3. Initialize Firebase in your project:
   ```bash
   firebase init firestore
   ```

4. Deploy the rules:
   ```bash
   firebase deploy --only firestore:rules
   ```

### Option 3: Using VS Code Firebase Extension

1. Install the "Firebase" extension in VS Code
2. Open Command Palette (`Ctrl+Shift+P`)
3. Search for "Firebase: Deploy"
4. Select your project
5. Choose to deploy Firestore rules

## Testing Rules

### Using Firebase Console

1. Go to Firestore Database → Rules
2. Click **Rules Playground** (if available)
3. Test different scenarios:
   - Authenticated user reading own profile
   - Admin reading all profiles
   - Unauthenticated access (should fail)

### Using Firestore Emulator

For local testing during development:

```bash
firebase emulators:start
```

Then run tests against the local emulator.

## Security Rules Explained

### Admin Check
```
function isAdmin() {
  return isAuthenticated() && 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
}
```
Verifies that the user is authenticated AND has role = 'admin'

### User Profile Read
```
allow read: if isAuthenticated() && 
            (request.auth.uid == userId || isAdmin());
```
- Users can only read their own profile
- Admins can read any profile

### Admin Full Access
```
allow update: if isAdmin() && 
              request.resource.data.uid == resource.data.uid &&
              request.resource.data.email == resource.data.email &&
              request.resource.data.createdAt == resource.data.createdAt;
```
- Admins can update profiles but cannot change uid, email, or creation date
- Prevents accidental data corruption

## Common Operations & Permissions

| Operation | Non-Admin User | Admin User |
|-----------|---|---|
| Read own profile | ✅ | ✅ |
| Read other's profile | ❌ | ✅ |
| Update own profile | ✅* | ✅ |
| Update other's profile | ❌ | ✅ |
| Delete profile | ❌ | ✅ |
| List all users | ❌ | ✅ |
| Delete own profile | ❌ | ❌ |

*Only displayName and photoURL, not email or role

## Important Notes

1. **First Admin**: Make sure your first admin user exists before deploying these rules
2. **Testing**: Test thoroughly in Firestore Emulator before production
3. **Backup**: Always have backup of your rules before deploying
4. **Monitoring**: Check Firestore Usage & Billing to monitor rule rejections

## Troubleshooting

### "Permission denied" errors after deploying rules

- Ensure your admin user has `role: 'admin'` in Firestore
- Check that you're logged in with correct credentials
- Wait a few seconds for rules to propagate

### Users can't create profiles

- Verify `firebaseOptions.dart` is correctly configured
- Check that email verification is not required
- Ensure user ID matches in both Auth and Firestore

### Admin can't access user data

- Verify admin user exists in Firestore with `role: 'admin'`
- Check that user document has all required fields
- Try logging out and back in to refresh auth tokens

## Need Help?

- [Firestore Security Rules Documentation](https://firebase.google.com/docs/firestore/security/get-started)
- [Firebase Security Best Practices](https://firebase.google.com/docs/rules/best-practices)
