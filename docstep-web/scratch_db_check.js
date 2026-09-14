const dbService = require('./db/dbService');

(async () => {
  try {
    const snap = await dbService.db.collection('users').get();
    console.log(`Found ${snap.size} users:`);
    snap.forEach(doc => {
      const data = doc.data();
      console.log(`- ID: ${doc.id}, Email: ${data.email}, Role: ${data.role}, Name: ${data.full_name}`);
    });
    process.exit(0);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
})();
