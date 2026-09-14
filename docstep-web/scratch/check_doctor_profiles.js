const dbService = require('../db/dbService');

(async () => {
  try {
    const userSnap = await dbService.db.collection('users').get();
    console.log('--- USERS ---');
    userSnap.forEach(doc => {
      console.log(`User ID: ${doc.id}, Email: ${doc.data().email}, Name: ${doc.data().full_name}`);
    });

    const docSnap = await dbService.db.collection('doctor_profiles').get();
    console.log('\n--- DOCTOR PROFILES ---');
    docSnap.forEach(doc => {
      console.log(`Profile ID: ${doc.id}, user_id: ${doc.data().user_id}, Specialty: ${doc.data().specialty}`);
    });

    const empSnap = await dbService.db.collection('employer_profiles').get();
    console.log('\n--- EMPLOYER PROFILES ---');
    empSnap.forEach(doc => {
      console.log(`Profile ID: ${doc.id}, user_id: ${doc.data().user_id}, Org: ${doc.data().organization_name}`);
    });

    process.exit(0);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
})();
