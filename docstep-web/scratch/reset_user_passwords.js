const dbService = require('../db/dbService');
const bcrypt = require('bcryptjs');

(async () => {
  try {
    const snap = await dbService.db.collection('users').get();
    const hash = bcrypt.hashSync('password123', 10);
    for (const doc of snap.docs) {
      await dbService.db.collection('users').doc(doc.id).update({
        password_hash: hash
      });
      console.log(`Reset password for user: ${doc.data().email}`);
    }
    process.exit(0);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
})();
