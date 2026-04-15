const admin = require("./functions/node_modules/firebase-admin");
const serviceAccount = require("./service_Acc_key.json");

async function main() {
  try {
    const credential = admin.credential.cert(serviceAccount);
    const tokenObj = await credential.getAccessToken();
    const token = tokenObj.access_token;
    const projectId = serviceAccount.project_id;
    
    // Node.js >= 18 has global fetch
    const res = await fetch(`https://firebaserules.googleapis.com/v1/projects/${projectId}/releases`, {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    const data = await res.json();
    console.log("Releases:", JSON.stringify(data, null, 2));

    const release = data.releases.find(r => r.name.includes("firestore") || r.name.includes("cloud.firestore"));
    if (!release) {
        console.log("No firestore release found");
        return;
    }
    const rulesetName = release.rulesetName;
    const rulesRes = await fetch(`https://firebaserules.googleapis.com/v1/${rulesetName}`, {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    const rulesData = await rulesRes.json();
    console.log("Ruleset Files:", JSON.stringify(rulesData.source.files, null, 2));
  } catch (e) {
    console.error(e);
  }
}
main();
