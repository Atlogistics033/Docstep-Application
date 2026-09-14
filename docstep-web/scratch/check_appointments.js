const dbService = require('../db/dbService');

(async () => {
  try {
    const snap = await dbService.db.collection('appointments').get();
    console.log(`Found ${snap.size} appointments:`);
    snap.forEach(doc => {
      const data = doc.data();
      console.log(`- ID: ${doc.id}`);
      console.log(`  Patient: ${data.patient_name}`);
      console.log(`  Doctor: ${data.doctor_name} (ID: ${data.doctor_id})`);
      console.log(`  Employer ID: ${data.employer_id}`);
      console.log(`  Date/Time: ${data.date} / ${data.time_slot}`);
      console.log(`  Status: ${data.status}`);
      console.log(`-----------------------------------`);
    });
    process.exit(0);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
})();
