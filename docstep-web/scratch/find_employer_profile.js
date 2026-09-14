const dbService = require('../db/dbService');

(async () => {
  try {
    const userSnap = await dbService.db.collection('users').where('email', '==', 'hasan123@gmail.com').get();
    if (userSnap.empty) {
      console.log('Employer user not found');
      process.exit(0);
    }
    const empUser = userSnap.docs[0];
    const profSnap = await dbService.db.collection('employer_profiles').where('user_id', '==', empUser.id).get();
    if (profSnap.empty) {
      console.log('Employer profile not found. Creating one...');
      const profileId = await dbService.createEmployerProfile({
        user_id: empUser.id,
        organization_name: 'Hasan Health Clinic',
        organization_type: 'Private Clinic',
        city: 'Karachi',
        website: 'https://hasanhealth.pk',
        about: 'A premium healthcare clinic network.'
      });
      console.log(`Created employer profile: ${profileId}`);
    } else {
      console.log('Found employer profile:');
      profSnap.forEach(doc => {
        console.log(JSON.stringify({ id: doc.id, ...doc.data() }, null, 2));
      });
    }
    process.exit(0);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
})();
