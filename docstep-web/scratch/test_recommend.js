const dbService = require('../db/dbService');

(async () => {
  try {
    console.log('Testing recommendation for General Practice...');
    const courses = await dbService.recommendCoursesUsingGemini('General Practice');
    console.log('Returned courses:');
    console.log(JSON.stringify(courses, null, 2));
    process.exit(0);
  } catch (err) {
    console.error('Error:', err);
    process.exit(1);
  }
})();
