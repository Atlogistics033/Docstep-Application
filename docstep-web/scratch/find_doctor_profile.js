const dbService = require('../db/dbService');

(async () => {
  try {
    const userSnap = await dbService.db.collection('users').where('email', '==', 'mohammadtaha102046@gmail.com').get();
    if (userSnap.empty) {
      console.log('Doctor user not found');
      process.exit(0);
    }
    const docUser = userSnap.docs[0];
    const profSnap = await dbService.db.collection('doctor_profiles').where('user_id', '==', docUser.id).get();
    if (profSnap.empty) {
      console.log('Doctor profile not found. Creating one...');
      const profileId = await dbService.createDoctorProfile({
        user_id: docUser.id,
        specialty: 'Gynecology',
        experience_years: 5,
        pmdc_number: 'PMDC-12345',
        pmdc_verified: 1,
        city: 'Islamabad',
        languages: 'English, Urdu',
        qualifications: 'MBBS, FCPS',
        availability: 'Flexible',
        hourly_rate: 1500,
        open_to_remote: 1
      });
      console.log(`Created doctor profile: ${profileId}`);
    } else {
      console.log('Found doctor profile:');
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
