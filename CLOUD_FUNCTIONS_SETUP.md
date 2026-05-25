# AIDE Cloud Functions Deployment Guide

## ⚠️ IMPORTANT: User Deletion Feature

The admin user deletion feature requires Firebase Cloud Functions to be deployed. Without this setup, attempting to delete users will fail.

## Quick Setup

### Prerequisites
- Node.js 20+ installed
- Firebase CLI: `npm install -g firebase-tools`
- Logged in: `firebase login`

### Step 1: Deploy Cloud Functions

```bash
cd functions
npm install
npm run deploy
```

**That's it!** The `deleteUser` Cloud Function is now deployed.

### Step 2: Verify Deployment

1. Open Firebase Console
2. Go to Project → Functions
3. You should see the `deleteUser` function listed

### What This Does

When you delete a user from the admin panel, the Cloud Function:
- ✅ Deletes the user from Firebase Authentication
- ✅ Deletes the user from Firestore
- ✅ Ensures no "email already in use" errors for recreated accounts
- ✅ Validates admin privileges before deletion

## Troubleshooting

### "deleteUser function not found" Error

**Solution:** Deploy the Cloud Functions:
```bash
cd functions
npm run deploy
```

### "PERMISSION_DENIED" Error

**Cause:** The caller doesn't have admin role

**Solution:** Ensure the deleting user has `role: 'admin'` in their Firestore profile

### Deployment Issues

**Check Firebase CLI version:**
```bash
firebase --version
```

**Try verbose output:**
```bash
npm run deploy -- --debug
```

**Check logs:**
```bash
firebase functions:log
```

## Local Development

To test functions locally:

```bash
cd functions
npm run serve
```

Then the Flutter app will automatically call the local function (if emulator is configured).

## Production Notes

- Cloud Functions have generous free tier quotas
- First 125K invocations/month are free
- Subsequent invocations: $0.40 per million
- Typical user deletion = 1 invocation

## Security

The `deleteUser` function:
- Requires Firebase Authentication
- Validates admin role via Firestore
- Validates the UID parameter
- Has proper error handling
- Logs all operations

## For More Information

See `functions/README.md` for technical details.
