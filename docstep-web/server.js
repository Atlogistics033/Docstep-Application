// DocStep — Digital Health Portal server
const express = require('express');
const session = require('express-session');
const path = require('path');
const expressLayouts = require('express-ejs-layouts');
const dbService = require('./db/dbService'); // Yeh hamara Firestore db instance hai
const { injectUser } = require('./middleware/auth');
const fs = require('fs');

// Auto-seed if Firestore 'users' collection is empty
(async () => {
  try {
    // Firestore mein users count check karne ka sahi tarika
    const usersSnapshot = await dbService.db.collection('users').count().get();
    const userCount = usersSnapshot.data().count;

    if (userCount === 0) {
      console.log('[DocStep DB] Empty Firestore database — running seed...');
      const seed = require('./db/seed');
      await seed.runSeed();
    } else {
      console.log('[DocStep DB] Firestore already contains records. Seeding skipped.');
    }
  } catch (e) {
    console.error('[DocStep DB] Seed check failed:', e.message);
  }
})();

const app = express();
const PORT = process.env.PORT || 3000;

// Trust reverse proxy
app.set('trust proxy', 1);

// View engine
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
app.use(expressLayouts);
app.set('layout', 'layout');

// Static
app.use(express.static(path.join(__dirname, 'public')));

// Body parsing
app.use(express.urlencoded({ extended: true }));
app.use(express.json());

// Session — iframe / proxy friendly cookie settings
app.use(session({
  secret: 'docstep-fyp-secret-key-change-in-prod',
  resave: false,
  saveUninitialized: false,
  cookie: {
    maxAge: 7 * 24 * 60 * 60 * 1000,
    httpOnly: true,
    sameSite: 'lax',
    secure: false
  }
}));

app.use(injectUser);

// Routes
app.use('/api', require('./routes/api'));

// Serve static assets for uploads and images explicitly
app.use('/uploads', express.static(path.join(__dirname, 'public', 'uploads')));
app.use('/images', express.static(path.join(__dirname, 'public', 'images')));

// Serve React production build if it exists
const frontendDist = path.join(__dirname, 'frontend', 'dist');
app.use(express.static(frontendDist));

// React SPA Routing Fallback
app.get('*', (req, res, next) => {
  if (req.path.startsWith('/api') || req.path.startsWith('/uploads') || req.path.startsWith('/images')) {
    return next();
  }
  const indexHtml = path.join(frontendDist, 'index.html');
  if (fs.existsSync(indexHtml)) {
    return res.sendFile(indexHtml);
  }
  next();
});

app.use('/', require('./routes/public'));
app.use('/', require('./routes/auth'));
app.use('/doctor', require('./routes/doctor'));
app.use('/employer', require('./routes/employer'));
app.use('/admin', require('./routes/admin'));

// 404
app.use((req, res) => {
  res.status(404).render('404', { title: 'Page not found' });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`DocStep running on http://localhost:${PORT}`);
});