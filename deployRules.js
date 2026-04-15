const admin = require("./functions/node_modules/firebase-admin");
const serviceAccount = require("./service_Acc_key.json");

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

async function deploy() {
  try {
    const source = {
      files: [
        {
          name: "firestore.rules",
          content: `rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && (request.auth.token.admin == true || request.auth.uid == userId);
    }
    match /workOrders/{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}`
        }
      ]
    };

    console.log("Creating ruleset...");
    const ruleset = await admin.securityRules().createRuleset(source);
    console.log("Created ruleset ID:", ruleset.name);

    console.log("Releasing ruleset for firestore...");
    await admin.securityRules().releaseFirestoreRuleset(ruleset.name);
    console.log("Successfully deployed new Firestore rules!");
  } catch (err) {
    console.error("Failed to deploy:", err);
  }
}

deploy();
