const admin = require("./functions/node_modules/firebase-admin");
const serviceAccount = require("./service_Acc_key.json");

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

const accounts = [
  { email: "vagbmf@airport.com", password: "vagbmf12", displayName: "Airport Staff" },
  { email: "vismithasupervisor@airport.com", password: "vismitha12", displayName: "Supervisor Vismitha" },
  { email: "vgadmin@airport.com", password: "admin1234", displayName: "Service Admin" },
  { email: "technician@airport.com", password: "technician12", displayName: "Technician" }
];

async function setup() {
  for (const acc of accounts) {
    try {
      let userRecord;
      try {
        userRecord = await admin.auth().getUserByEmail(acc.email);
        await admin.auth().updateUser(userRecord.uid, { password: acc.password });
        console.log(`Updated password for existing account: ${acc.email}`);
      } catch (err) {
        if (err.code === 'auth/user-not-found') {
          userRecord = await admin.auth().createUser({
            email: acc.email,
            password: acc.password,
            displayName: acc.displayName
          });
          console.log(`Created new account: ${acc.email}`);
        } else {
          throw err;
        }
      }

      // Auto-assign custom authorization claims over to them so they don't get stuck later
      let claims = { authorized: true };
      if (acc.email === "vgadmin@airport.com") {
        claims.admin = true;
      }
      await admin.auth().setCustomUserClaims(userRecord.uid, claims);
      console.log(`Verified custom claims for: ${acc.email}`);

      // Sync into Firestore 'users' collection to act as their profile backing
      const db = admin.firestore();
      await db.collection('users').doc(userRecord.uid).set({
        fullName: acc.displayName,
        workEmail: acc.email,
        userType: acc.email === "vgadmin@airport.com" ? "Admin" : (acc.email === "vismithasupervisor@airport.com" ? "Supervisor" : "Average User"),
        department: "System Configuration",
        status: "Active",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });
      console.log(`Synced Firestore profile mapping for: ${acc.email}`);

    } catch (err) {
      console.error(`Failed to process ${acc.email}:`, err.message);
    }
  }
  process.exit();
}

setup();
