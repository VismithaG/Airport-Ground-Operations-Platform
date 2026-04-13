const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Initialize the Admin SDK
admin.initializeApp();

exports.grantAuthorizedClaim = functions.https.onCall(async (data, context) => {
  // 1. Verify the caller is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "You must be logged in to grant access."
    );
  }

  // 2. Security Check: Verify the caller is an Administrator
  // (Assuming you have a separate 'admin' claim for your IT Ops Lead)
  if (context.auth.token.admin !== true) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Only administrators can authorize new users."
    );
  }

  // 3. Get the UID of the user you want to authorize from the request data
  const targetUid = data.uid;
  if (!targetUid) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "The function must be called with one argument 'uid'."
    );
  }

  try {
    // 4. Set the custom claim on the target user
    await admin.auth().setCustomUserClaims(targetUid, { authorized: true });
    
    return { 
      message: `Successfully granted authorized claim to user ${targetUid}` 
    };
  } catch (error) {
    console.error("Error setting custom claim:", error);
    throw new functions.https.HttpsError("internal", "Failed to assign claim.");
  }
});
