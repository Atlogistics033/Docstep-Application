const dbService = require('../db/dbService');

(async () => {
  try {
    const snapshot = await dbService.db.collection('courses').get();
    console.log(`Found ${snapshot.size} courses in Firestore:`);
    snapshot.forEach(doc => {
      const data = doc.data();
      console.log(`- ID: ${doc.id}, Title: "${data.title}", Specialty: "${data.specialty}", Instructor: "${data.instructor}", Website: "${data.website}"`);
    });
    process.exit(0);
  } catch (err) {
    console.error('Error listing courses:', err);
    process.exit(1);
  }
})();
