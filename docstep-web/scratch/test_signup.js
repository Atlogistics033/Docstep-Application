const dbService = require('../db/dbService');
const admin = require('firebase-admin');
const { getAuth } = require('firebase-admin/auth');
const bcrypt = require('bcryptjs');

// Initialize Firebase Admin SDK if not already done in testing
if (admin.getApps().length === 0) {
  const path = require('path');
  const serviceAccount = require(path.join(__dirname, '..', 'firebase-key.json'));
  admin.initializeApp({
    credential: admin.cert(serviceAccount)
  });
}

const auth = getAuth();

(async () => {
  const testEmail = `testuser_${Date.now()}@docstep.pk`;
  const testPassword = 'TestPassword123!';
  const hash = bcrypt.hashSync(testPassword, 10);
  const fullName = 'Test User';
  const role = 'doctor';
  const phone = '+92-300-1234567';

  console.log(`[TEST] Starting signup sync test with email: ${testEmail}`);
  let testUid = null;

  try {
    // 1. Create the user
    testUid = await dbService.createUser(testEmail, hash, role, fullName, phone, testPassword);
    console.log(`[TEST] User created with UID: ${testUid}`);

    if (!testUid) {
      throw new Error('createUser did not return a UID');
    }

    // 2. Retrieve from Firebase Auth
    console.log('[TEST] Checking user in Firebase Authentication...');
    const firebaseUser = await auth.getUser(testUid);
    console.log('[TEST] Firebase Auth check passed. Found user:', firebaseUser.email);
    if (firebaseUser.email !== testEmail) {
      throw new Error(`Email mismatch in Firebase Auth. Expected: ${testEmail}, Got: ${firebaseUser.email}`);
    }

    // 3. Retrieve from Firestore
    console.log('[TEST] Checking user in Firestore...');
    const firestoreUser = await dbService.getUserById(testUid);
    console.log('[TEST] Firestore check passed. Found user document:', firestoreUser.email);
    if (!firestoreUser) {
      throw new Error('User document not found in Firestore');
    }
    if (firestoreUser.email !== testEmail) {
      throw new Error(`Email mismatch in Firestore. Expected: ${testEmail}, Got: ${firestoreUser.email}`);
    }

    console.log('[TEST] SUCCESS: User successfully created in both Firebase Auth and Firestore with matching UIDs!');

  } catch (err) {
    console.error('[TEST] FAILURE:', err);
  } finally {
    // Cleanup
    if (testUid) {
      console.log(`[TEST] Cleaning up test user with UID: ${testUid}`);
      try {
        // Delete from Firebase Auth
        await auth.deleteUser(testUid);
        console.log('[TEST] Cleaned up from Firebase Authentication.');

        // Delete from Firestore
        await dbService.db.collection('users').doc(testUid).delete();
        console.log('[TEST] Cleaned up from Firestore.');
      } catch (cleanupErr) {
        console.error('[TEST] Cleanup warning:', cleanupErr.message);
      }
    }
    process.exit(0);
  }
})();
