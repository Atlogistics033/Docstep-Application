const express = require('express');
const session = require('express-session');
const dbService = require('../db/dbService');
const { getAuth } = require('firebase-admin/auth');
const admin = require('firebase-admin');

// Initialize Firebase Admin SDK if not already done in testing
if (admin.getApps().length === 0) {
  const path = require('path');
  const serviceAccount = require(path.join(__dirname, '..', 'firebase-key.json'));
  admin.initializeApp({
    credential: admin.cert(serviceAccount)
  });
}

const auth = getAuth();

// Setup mock express app
const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(session({
  secret: 'test-secret',
  resave: false,
  saveUninitialized: false
}));

// Mock ejs rendering view engine dummy
app.set('view engine', 'ejs');
app.set('views', '../views');

// Mount routes
app.use('/api', require('../routes/api'));
app.use('/', require('../routes/auth'));

// Start server on random free port
const server = app.listen(0, async () => {
  const port = server.address().port;
  const baseUrl = `http://localhost:${port}`;
  console.log(`[TEST] Temporary test server running on ${baseUrl}`);
  
  let createdUids = [];

  try {
    console.log('[TEST] --- Starting REST API Endpoint Test ---');
    const apiTestEmail = `api_user_${Date.now()}@docstep.pk`;
    const apiPayload = {
      email: apiTestEmail,
      password: 'ApiPassword123!',
      full_name: 'API Doctor User',
      role: 'doctor',
      phone: '+92-300-9999999',
      city: 'Islamabad',
      specialty: 'Pediatrics'
    };

    const apiRes = await fetch(`${baseUrl}/api/auth/register`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(apiPayload)
    });

    const apiResStatus = apiRes.status;
    const apiResBody = await apiRes.json();

    console.log('[TEST] API Response Status:', apiResStatus);
    console.log('[TEST] API Response Body:', apiResBody);

    if (apiResStatus !== 200 || !apiResBody.success) {
      throw new Error(`API registration failed: ${JSON.stringify(apiResBody)}`);
    }

    const apiUid = apiResBody.user.id;
    createdUids.push(apiUid);
    console.log('[TEST] API User UID:', apiUid);

    // Verify in Firebase Auth and Firestore
    const apiFbUser = await auth.getUser(apiUid);
    console.log('[TEST] Found API User in Firebase Auth:', apiFbUser.email);
    const apiFsUser = await dbService.getUserById(apiUid);
    console.log('[TEST] Found API User in Firestore:', apiFsUser.email);

    console.log('[TEST] --- Starting MVC View Endpoint Test ---');
    const mvcTestEmail = `mvc_user_${Date.now()}@docstep.pk`;
    const mvcPayload = {
      email: mvcTestEmail,
      password: 'MvcPassword123!',
      full_name: 'MVC Employer User',
      role: 'employer',
      phone: '+92-300-8888888',
      city: 'Lahore',
      organization_name: 'Test Corp'
    };

    // Construct form URL encoded body manually
    const mvcBody = new URLSearchParams(mvcPayload).toString();

    const mvcRes = await fetch(`${baseUrl}/register`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: mvcBody,
      redirect: 'manual' // Prevent following redirect so we can assert status 302
    });

    console.log('[TEST] MVC Response Status (expected 302 redirect):', mvcRes.status);
    console.log('[TEST] MVC Redirect location:', mvcRes.headers.get('location'));

    if (mvcRes.status !== 302) {
      throw new Error(`MVC registration failed with status ${mvcRes.status}`);
    }

    // Since we redirected, let's query the database to find the user ID
    const mvcFsUser = await dbService.getUserByEmail(mvcTestEmail);
    if (!mvcFsUser) {
      throw new Error('MVC user not found in Firestore!');
    }

    const mvcUid = mvcFsUser.id;
    createdUids.push(mvcUid);
    console.log('[TEST] MVC User UID:', mvcUid);

    // Verify in Firebase Auth and Firestore
    const mvcFbUser = await auth.getUser(mvcUid);
    console.log('[TEST] Found MVC User in Firebase Auth:', mvcFbUser.email);

    console.log('[TEST] ALL ENDPOINT TESTS PASSED SUCCESSFULLY!');

  } catch (err) {
    console.error('[TEST] ENDPOINT TEST FAILED:', err);
  } finally {
    // Cleanup
    console.log('[TEST] Cleaning up created users:', createdUids);
    for (const uid of createdUids) {
      try {
        await auth.deleteUser(uid);
        await dbService.db.collection('users').doc(uid).delete();
        console.log(`[TEST] Cleaned up user UID: ${uid}`);
      } catch (cleanupErr) {
        console.error(`[TEST] Failed to cleanup ${uid}:`, cleanupErr.message);
      }
    }
    server.close(() => {
      console.log('[TEST] Temporary server closed.');
      process.exit(0);
    });
  }
});
