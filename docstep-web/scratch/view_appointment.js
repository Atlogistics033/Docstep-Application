const dbService = require('../db/dbService');

(async () => {
  try {
    const snap = await dbService.db.collection('appointments').get();
    console.log(`Found ${snap.size} appointments:`);
    snap.forEach(doc => {
      console.log(`ID: ${doc.id}`);
      console.log(JSON.stringify(doc.data(), null, 2));
    });
    process.exit(0);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
})();
