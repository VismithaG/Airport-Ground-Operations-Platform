const admin = require("./functions/node_modules/firebase-admin");

// 1. Provide the direct local path to your Service Account JSON file.
const serviceAccount = require("./service_Acc_key.json");

// 2. Initialize App locally with admin credentials
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

// 3. Replace with your actual UID from the Firebase Authentication console
const myUid = "v9LOaz6PdJPEt7UwGLJqEinrv2I3";

admin.auth().setCustomUserClaims(myUid, { admin: true, authorized: true })
  .then(() => {
    console.log(`Success! Admin claim set for ${myUid}`);
    process.exit();
  })
  .catch((error) => {
    console.error("Error setting claim:", error);
    process.exit(1);
  });
