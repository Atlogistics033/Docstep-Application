const dbService = require('../db/dbService');

(async () => {
  try {
    const userId = 'ZrDoUeAxl5Q1SsBcy2U2KP2r6V42'; // Mohammad Taha's user ID
    const profile = await dbService.getDoctorProfileByUserId(userId);
    
    if (profile) {
      console.log('Current profile data before fix:', {
        clinic_address: profile.clinic_address,
        clinic_hospital_address: profile.clinic_hospital_address,
        clinic_location: profile.clinic_location,
        clinicLocation: profile.clinicLocation
      });

      await dbService.db.collection('doctor_profiles').doc(profile.id).update({
        clinic_address: 'North Nazimabad',
        clinic_hospital_address: '5 Star Block I North Nazimabad karachi'
      });

      console.log('Successfully updated Mohammad Taha\'s doctor profile!');
      
      const updatedProfile = await dbService.getDoctorProfileByUserId(userId);
      console.log('Updated profile data:', {
        clinic_address: updatedProfile.clinic_address,
        clinic_hospital_address: updatedProfile.clinic_hospital_address
      });
      process.exit(0);
    } else {
      console.error('Doctor profile not found for user ID:', userId);
      process.exit(1);
    }
  } catch (err) {
    console.error('Error fixing profile:', err);
    process.exit(1);
  }
})();
