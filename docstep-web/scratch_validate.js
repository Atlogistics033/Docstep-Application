const dbService = require('./db/dbService');

(async () => {
  try {
    console.log('Validating courses generation...');
    // Call getCourses with forceRefresh = true to populate the Firestore db
    const courses = await dbService.getCourses(true);
    console.log(`Successfully fetched/generated ${courses.length} courses.`);
    
    // Check if we have at least 4 courses per specialty
    const specialties = ["General Practice", "Gynecology", "Pediatrics", "Psychiatry", "Dermatology", "Internal Medicine", "Cardiology", "Other"];
    const counts = {};
    specialties.forEach(spec => counts[spec] = 0);
    
    courses.forEach(c => {
      if (counts[c.specialty] !== undefined) {
        counts[c.specialty]++;
      } else {
        counts[c.specialty] = 1;
      }
    });
    
    console.log('Course counts by specialty:');
    console.log(counts);
    
    let allGood = true;
    specialties.forEach(spec => {
      if (counts[spec] < 4) {
        console.error(`Error: specialty ${spec} has only ${counts[spec]} courses, expected at least 4.`);
        allGood = false;
      }
    });
    
    if (allGood) {
      console.log('SUCCESS: All specialties have at least 4 realistic courses generated!');
      process.exit(0);
    } else {
      console.error('FAILED: Specialty validation failed.');
      process.exit(1);
    }
  } catch (err) {
    console.error('Validation error:', err);
    process.exit(1);
  }
})();
