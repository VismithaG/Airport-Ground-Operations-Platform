const admin = require("./functions/node_modules/firebase-admin");
const serviceAccount = require("./service_Acc_key.json");

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

async function fetchRules() {
  try {
    const rules = await admin.securityRules().getFirestoreRules();
    console.log("RULES:", rules);
  } catch (err) {
    console.error("FAILED:", err);
  }
}

fetchRules();
