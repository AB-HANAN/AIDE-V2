# AIDE Cloud Functions

This directory contains Cloud Functions for the AIDE project.

## Functions

### deleteUser

A callable Cloud Function that deletes a user from both Firebase Authentication and Firestore.

**Security:**
- Only authenticated users can call this function
- Only admin users can delete other users
- Checks the caller's role from their Firestore profile

**Usage:**
```javascript
const result = await httpsCallable(functions, 'deleteUser')({
  uid: 'user-uid-to-delete'
});
```

## Setup

### Prerequisites
- Node.js 20+ installed
- Firebase CLI installed globally: `npm install -g firebase-tools`
- Logged in to Firebase: `firebase login`

### Installation

1. Install dependencies:
```bash
cd functions
npm install
```

2. Build TypeScript:
```bash
npm run build
```

### Deployment

Deploy functions to Firebase:
```bash
npm run deploy
```

Or deploy everything:
```bash
firebase deploy
```

### Local Testing

Test functions locally:
```bash
npm run serve
```

Or use the functions shell:
```bash
npm run shell
```

## Notes

- The `deleteUser` function requires admin status in the user's Firestore profile
- It gracefully handles cases where a user exists in Firestore but not in Auth
- All errors are properly logged for debugging
