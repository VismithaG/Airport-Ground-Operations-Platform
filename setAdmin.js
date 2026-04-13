const admin = require("firebase-admin");

// 1. Provide the direct local path to your Service Account JSON file.
const serviceAccount = require("./path-to-your-service-account-key.json");

// 2. Initialize App locally with admin credentials
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

// 3. Replace with your actual UID from the Firebase Authentication console
const myUid = "YOUR_OWN_FIREBASE_UID";

admin.auth().setCustomUserClaims(myUid, { admin: true, authorized: true })
  .then(() => {
    console.log(`Success! Admin claim set for ${myUid}`);
    process.exit();
  })
  .catch((error) => {
    console.error("Error setting claim:", error);
    process.exit(1);
  });
