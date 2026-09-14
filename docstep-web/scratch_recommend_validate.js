const dbService = require('./db/dbService');

(async () => {
  try {
    console.log('Testing dynamic course generation and links for: Cardiology...');
    const cardioCourses = await dbService.recommendCoursesUsingGemini('Cardiology');
    console.log(`Generated ${cardioCourses.length} courses:`);
    let hasLinks = true;
    cardioCourses.forEach(c => {
      console.log(`- Title: "${c.title}", Specialty: "${c.specialty}", Link: "${c.website}"`);
      if (!c.website || !c.website.startsWith('http')) {
        hasLinks = false;
      }
    });

    console.log('\nTesting dynamic course generation and links for a custom typed specialty: Neurology...');
    const neuroCourses = await dbService.recommendCoursesUsingGemini('Neurology');
    console.log(`Generated ${neuroCourses.length} courses:`);
    neuroCourses.forEach(c => {
      console.log(`- Title: "${c.title}", Specialty: "${c.specialty}", Link: "${c.website}"`);
      if (!c.website || !c.website.startsWith('http')) {
        hasLinks = false;
      }
    });

    if (hasLinks && cardioCourses.length > 0 && neuroCourses.length > 0) {
      console.log('\nSUCCESS: Courses generated dynamically with valid external website links!');
      process.exit(0);
    } else {
      console.error('\nFAILED: Website link validation failed or courses list is empty.');
      process.exit(1);
    }
  } catch (err) {
    console.error('Validation error:', err);
    process.exit(1);
  }
})();
