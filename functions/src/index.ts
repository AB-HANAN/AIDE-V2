import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

/**
 * Callable Cloud Function to delete a user
 * Deletes the user from Firebase Authentication and Firestore
 * 
 * @param uid - The user's UID to delete
 */
export const deleteUser = functions.https.onCall(async (data, context) => {
  // Check if user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Request must be authenticated"
    );
  }

  const uid = data.uid as string;
  if (!uid) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "UID is required"
    );
  }

  try {
    // Check if caller is admin
    const callerDoc = await admin
      .firestore()
      .collection("users")
      .doc(context.auth.uid)
      .get();

    if (!callerDoc.exists) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Caller user profile not found"
      );
    }

    const callerData = callerDoc.data();
    if (callerData?.role !== "admin") {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Only admins can delete users"
      );
    }

    // Delete user from Firebase Auth
    await admin.auth().deleteUser(uid);

    // Delete user from Firestore
    await admin.firestore().collection("users").doc(uid).delete();

    return {
      success: true,
      message: `User ${uid} deleted successfully from both Auth and Firestore`,
    };
  } catch (error) {
    console.error("Error deleting user:", error);

    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    // Firebase Auth errors
    if (
      error instanceof Error &&
      error.message.includes("user-not-found")
    ) {
      // User not in Auth, just delete from Firestore
      await admin.firestore().collection("users").doc(uid).delete();
      return {
        success: true,
        message: "User deleted from Firestore (was not in Auth)",
      };
    }

    throw new functions.https.HttpsError(
      "internal",
      `Failed to delete user: ${error instanceof Error ? error.message : "Unknown error"}`
    );
  }
});
