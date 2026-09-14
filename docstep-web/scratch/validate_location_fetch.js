const dbService = require('../db/dbService');

(async () => {
  try {
    const selectedLocation = 'North Nazimabad';
    
    // Simulate routes/public.js or routes/api.js filtering logic
    const allDoctors = await dbService.getRegisteredDoctors();
    console.log(`Total registered doctors found: ${allDoctors.length}`);
    
    const filteredDoctors = allDoctors.filter(doc => {
      const address = (doc.clinic_address || '').toLowerCase();
      const hospAddress = (doc.clinic_hospital_address || '').toLowerCase();
      const location = (doc.clinic_location || doc.clinicLocation || '').toLowerCase();
      const search = selectedLocation.toLowerCase();
      return address === search || location === search || address.includes(search) || hospAddress.includes(search);
    });

    console.log(`Filtered doctors for '${selectedLocation}': ${filteredDoctors.length}`);
    
    let hasBothFields = true;
    filteredDoctors.forEach(doc => {
      console.log(`- Doctor ID: ${doc.id}`);
      console.log(`  Name: ${doc.full_name}`);
      console.log(`  user_id field: ${doc.user_id}`);
      console.log(`  userId field: ${doc.userId}`);
      console.log(`  Clinic Name: ${doc.clinic_name}`);
      console.log(`  Clinic Area: ${doc.clinic_address}`);
      console.log(`  Clinic Address: ${doc.clinic_hospital_address}`);
      
      if (!doc.user_id || !doc.userId) {
        hasBothFields = false;
      }
    });

    const isTahaFound = filteredDoctors.some(doc => doc.full_name.includes('Mohammad Taha'));
    
    if (isTahaFound && hasBothFields) {
      console.log('\nSUCCESS: Mohammad Taha found under selected location and both user_id/userId fields are fetched!');
      process.exit(0);
    } else {
      console.error('\nFAILED: Mohammad Taha NOT found or missing user_id/userId fields.');
      process.exit(1);
    }
  } catch (err) {
    console.error('Validation script error:', err);
    process.exit(1);
  }
})();
