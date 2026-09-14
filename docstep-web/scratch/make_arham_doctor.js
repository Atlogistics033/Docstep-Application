const dbService = require('../db/dbService');

(async () => {
  try {
    const arhamUserId = 'V0PJ7M21QHez7Q5woYUgORBRXSu1';
    
    // 1. Get user
    const userDocRef = dbService.db.collection('users').doc(arhamUserId);
    const userSnap = await userDocRef.get();
    
    if (!userSnap.exists) {
      console.error('User Arham not found in users collection!');
      process.exit(1);
    }
    
    console.log('Current Arham User Data:', userSnap.data());
    
    // 2. Update role to 'doctor'
    await userDocRef.update({ role: 'doctor' });
    console.log('Updated Arham\'s role to doctor!');
    
    // 3. Create or Update Doctor Profile for Arham
    const profileSnap = await dbService.db.collection('doctor_profiles').where('user_id', '==', arhamUserId).get();
    
    const docProfileData = {
      user_id: arhamUserId,
      specialty: 'Gynecology',
      experience_years: 5,
      pmdc_number: 'PMDC-54321',
      pmdc_verified: 1,
      bio: 'Dr. Arham is a highly qualified obstetrician and gynecologist with over 5 years of experience in women\'s health, dedicated to providing advanced care.',
      city: 'Karachi',
      languages: 'Urdu, English',
      qualifications: 'MBBS, FCPS',
      availability: 'Evenings',
      hourly_rate: 1500,
      open_to_remote: 1,
      clinic_name: 'Arham Gyne Care',
      clinic_address: 'North Nazimabad',
      clinic_hospital_address: 'Block D, North Nazimabad, Karachi'
    };

    if (profileSnap.empty) {
      const docRef = await dbService.db.collection('doctor_profiles').add(docProfileData);
      console.log('Created doctor profile for Arham with ID:', docRef.id);
    } else {
      const docId = profileSnap.docs[0].id;
      await dbService.db.collection('doctor_profiles').doc(docId).set(docProfileData);
      console.log('Updated existing doctor profile for Arham with ID:', docId);
    }

    console.log('Verification: Fetching registered doctors from dbService...');
    const doctors = await dbService.getRegisteredDoctors();
    console.log(`Total registered doctors now: ${doctors.length}`);
    doctors.forEach(d => {
      console.log(`- Doctor ID: ${d.id}, Name: ${d.full_name}, Email: ${d.email}, Role: ${d.role}, Clinic Area: ${d.clinic_address}`);
    });
    
    process.exit(0);
  } catch (err) {
    console.error('Error:', err);
    process.exit(1);
  }
})();
