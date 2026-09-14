const dbService = require('../db/dbService');

(async () => {
  try {
    const snap = await dbService.db.collection('appointments').get();
    console.log(`Found ${snap.size} appointments:`);
    snap.forEach(doc => {
      const data = doc.data();
      console.log(`- ID: ${doc.id}, Patient: ${data.patient_name}, Doctor: ${data.doctor_name}, Date: ${data.date}, Time: ${data.time_slot}`);
    });
    process.exit(0);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
})();
