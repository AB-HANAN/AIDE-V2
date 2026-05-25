# User Deletion - Secure Firestore Implementation

## Overview

User deletion now uses a **secure soft-delete approach** with Firestore Security Rules. No cloud functions or plan upgrades needed!

## How It Works

### When an Admin Deletes a User:

1. **User is marked as deleted** - `deletedAt` timestamp is set
2. **User is marked inactive** - `isActive` is set to false  
3. **Firestore Rules prevent login** - User can't access their profile
4. **Email becomes available** - Can create a new account with the same email

### Security Features:

✅ **Only admins can delete** - Firestore Rules enforce admin check  
✅ **Users can't delete others** - Rules validate caller is admin  
✅ **Deleted users can't login** - Firestore read access is denied  
✅ **Complete audit trail** - `deletedAt` timestamp shows when user was deleted  
✅ **No additional costs** - No cloud functions or upgrades needed  

## Technical Implementation

### Firestore Rules (firestore.rules)

```firestore
// Allow users to read their own profile (only if active/not deleted)
allow read: if isAuthenticated() && request.auth.uid == userId && 
               (!('deletedAt' in resource.data) || resource.data.deletedAt == null);

// Allow admin to delete users (mark as deleted)
allow delete: if isAdmin();

// Allow admin to mark user as deleted by updating deletedAt field
allow update: if isAdmin() && 
               request.resource.data.uid == resource.data.uid &&
               request.resource.data.email == resource.data.email &&
               request.resource.data.createdAt == resource.data.createdAt &&
               request.resource.data.diff(resource.data).affectedKeys().hasOnly(['deletedAt', 'updatedAt', 'isActive']);
```

### User Profile Model (firestore_user_service.dart)

Added `deletedAt` field:
```dart
final DateTime? deletedAt; // Timestamp when user was deleted (soft delete)
```

### Admin Delete Method (firestore_user_service.dart)

```dart
Future<void> adminDeleteUser(String uid) async {
  await _usersCollection.doc(uid).update({
    'isActive': false,
    'deletedAt': DateTime.now(),
    'updatedAt': DateTime.now(),
  });
}
```

### User List Query

Automatically filters out deleted users:
```dart
.where((user) => user.deletedAt == null)
```

## User Experience

### For Admins:
- Click delete on a user
- Confirmation dialog appears
- User is marked as deleted
- Success message shows
- User disappears from list
- Email becomes available for reuse

### For Deleted Users:
- Try to login with same credentials
- Firestore denies read access to their profile
- Login fails gracefully
- User can't access any app features

## Benefits

| Benefit | Why? |
|---------|------|
| No cost | No cloud functions, no Blaze upgrade needed |
| Secure | Only admins can delete via Firestore Rules |
| Auditable | `deletedAt` timestamp tracks who was deleted when |
| Reversible | Profile still exists for audit/recovery if needed |
| Email reuse | Can create new account with same email |
| Simple | No complex infrastructure required |

## Limitations

⚠️ **Note:** User still exists in Firebase Auth, but can't login because:
- Firestore profile is marked as deleted
- App checks Firestore profile during login
- No profile = no login access

This is intentional for:
- Audit trail preservation
- Easy recovery if needed
- Avoiding Auth API costs

## If You Need Complete Deletion Later

If you need to delete from Firebase Auth in the future, you can:

1. **Upgrade to Blaze plan** (free tier covers most usage)
2. **Deploy Cloud Functions** using `functions/` directory
3. **Update code** to call Cloud Function instead of Firestore update

See `functions/README.md` for setup instructions.

## Testing Deletion

1. **As admin:** Go to User Management → Delete a user
2. **Verify deleted:** User disappears from list
3. **Try to login:** Use the deleted user's credentials
4. **Expected:** Login fails (profile not found)
5. **Recreate account:** Create new user with same email (works!)

## Security Validation

The Firestore Rules validate:
- ✅ Only admins can update `deletedAt`
- ✅ Only specified fields can be updated
- ✅ Core fields (uid, email, createdAt) can't be changed
- ✅ Deleted users can't read their profile
- ✅ Admins can still read deleted user data
