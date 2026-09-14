// Auth routes - direct Firebase Firestore
const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const crypto = require('crypto');
const dbService = require('../db/dbService');

router.get('/login', (req, res) => res.render('auth/login', { title: 'Login', layout: 'layout-auth' }));

router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await dbService.getUserByEmail(email);
    if (!user || !bcrypt.compareSync(password, user.password_hash)) {
      req.session.flash = { type: 'error', text: 'Invalid email or password.' };
      return req.session.save(() => res.redirect('/login'));
    }
    
    let displayName = user.full_name;
    if (user.role === 'employer') {
      const profile = await dbService.getEmployerProfileByUserId(user.id);
      if (profile && profile.organization_name) {
        displayName = profile.organization_name;
      }
    }
    
    req.session.user = { id: user.id, email: user.email, role: user.role, full_name: displayName };
    req.session.flash = { type: 'success', text: `Welcome back, ${displayName}!` };
    
    req.session.save(() => {
      if (user.role === 'doctor') return res.redirect('/doctor/dashboard');
      if (user.role === 'employer') return res.redirect('/employer/dashboard');
      if (user.role === 'admin') return res.redirect('/admin/dashboard');
      return res.redirect('/');
    });
  } catch (err) {
    console.error('Login error:', err);
    req.session.flash = { type: 'error', text: 'An error occurred during login.' };
    res.redirect('/login');
  }
});

router.get('/register', (req, res) => res.render('auth/register', { title: 'Create account', role: req.query.role || 'doctor', layout: 'layout-auth' }));

router.post('/register', async (req, res) => {
  try {
    const { email, password, full_name, role, phone, organization_name, specialty, city } = req.body;
    
    const existing = await dbService.getUserByEmail(email);
    if (existing) {
      req.session.flash = { type: 'error', text: 'An account with this email already exists.' };
      return res.redirect('/register?role=' + role);
    }
    
    if (!['doctor', 'employer'].includes(role)) {
      req.session.flash = { type: 'error', text: 'Invalid role.' };
      return res.redirect('/register');
    }
    
    const hash = bcrypt.hashSync(password, 10);
    const uid = await dbService.createUser(email, hash, role, full_name, phone || null, password);

    if (role === 'doctor') {
      await dbService.createDoctorProfile({
        user_id: uid,
        specialty: specialty || 'General Practice',
        city: city || '',
        availability: 'Flexible',
        experience_years: 0,
        pmdc_number: '',
        pmdc_verified: 0,
        bio: '',
        languages: '',
        qualifications: '',
        profile_image: null,
        hourly_rate: 0,
        open_to_remote: 1,
        cv_summary: '',
        cv_skills: '',
        cv_experience: '',
        cv_education: '',
        cv_certifications: ''
      });
    } else {
      await dbService.createEmployerProfile({
        user_id: uid,
        organization_name: organization_name || 'My Organization',
        city: city || '',
        organization_type: '',
        website: '',
        about: '',
        logo: null
      });
    }

    let displayName = full_name;
    if (role === 'employer') {
      displayName = organization_name || 'My Organization';
    }

    req.session.user = { id: uid, email, role, full_name: displayName };
    req.session.flash = { type: 'success', text: 'Account created. Welcome to DocStep!' };
    
    req.session.save(() => {
      if (role === 'doctor') return res.redirect('/doctor/dashboard');
      return res.redirect('/employer/dashboard');
    });
  } catch (err) {
    console.error('Registration error:', err);
    let errMsg = 'An error occurred during registration.';
    if (err.code === 'auth/email-already-exists') {
      errMsg = 'An account with this email already exists.';
    } else if (err.code === 'auth/invalid-password') {
      errMsg = 'Password must be at least 6 characters long.';
    } else if (err.code === 'auth/invalid-email') {
      errMsg = 'The email address is badly formatted.';
    }
    req.session.flash = { type: 'error', text: errMsg };
    res.redirect('/register?role=' + (req.body.role || 'doctor'));
  }
});

router.get('/logout', (req, res) => {
  req.session.destroy(() => res.redirect('/'));
});

// Forgot Password View
router.get('/forgot-password', (req, res) => {
  res.render('auth/forgot-password', { title: 'Forgot Password', layout: 'layout-auth', resetLink: null, error: null });
});

// Forgot Password Form Submission
router.post('/forgot-password', async (req, res) => {
  try {
    const { email } = req.body;
    const user = await dbService.getUserByEmail(email);
    if (!user) {
      return res.render('auth/forgot-password', {
        title: 'Forgot Password',
        layout: 'layout-auth',
        resetLink: null,
        error: 'No account found with this email address.'
      });
    }

    // Generate Token
    const token = crypto.randomBytes(20).toString('hex');
    const expiresAt = new Date(Date.now() + 3600000).toISOString(); // 1 hour expiry

    await dbService.createPasswordResetToken(email, token, expiresAt);
    const resetLink = `/reset-password?token=${token}`;

    res.render('auth/forgot-password', {
      title: 'Forgot Password',
      layout: 'layout-auth',
      resetLink,
      error: null
    });
  } catch (err) {
    console.error('Forgot password error:', err);
    res.render('auth/forgot-password', {
      title: 'Forgot Password',
      layout: 'layout-auth',
      resetLink: null,
      error: 'An error occurred. Please try again.'
    });
  }
});

// Reset Password View
router.get('/reset-password', async (req, res) => {
  try {
    const { token } = req.query;
    if (!token) {
      req.session.flash = { type: 'error', text: 'Invalid or missing password reset token.' };
      return res.redirect('/forgot-password');
    }

    const resetRequest = await dbService.getPasswordResetToken(token);
    if (!resetRequest || new Date(resetRequest.expires_at) < new Date()) {
      req.session.flash = { type: 'error', text: 'Password reset token is invalid or has expired.' };
      return res.redirect('/forgot-password');
    }

    res.render('auth/reset-password', {
      title: 'Reset Password',
      layout: 'layout-auth',
      token,
      error: null
    });
  } catch (err) {
    console.error('Get reset-password error:', err);
    res.redirect('/forgot-password');
  }
});

// Reset Password Submission
router.post('/reset-password', async (req, res) => {
  const { token, password } = req.body;
  try {
    if (!token || !password) {
      return res.redirect('/forgot-password');
    }

    const resetRequest = await dbService.getPasswordResetToken(token);
    if (!resetRequest || new Date(resetRequest.expires_at) < new Date()) {
      req.session.flash = { type: 'error', text: 'Password reset token is invalid or has expired.' };
      return res.redirect('/forgot-password');
    }

    const user = await dbService.getUserByEmail(resetRequest.email);
    if (!user) {
      req.session.flash = { type: 'error', text: 'User account not found.' };
      return res.redirect('/forgot-password');
    }

    // Update password
    const hash = bcrypt.hashSync(password, 10);
    await dbService.updateUserPassword(user.id, hash);

    // Delete token
    await dbService.deletePasswordResetToken(resetRequest.id);

    req.session.flash = { type: 'success', text: 'Your password has been reset successfully. Please log in.' };
    req.session.save(() => res.redirect('/login'));
  } catch (err) {
    console.error('Post reset-password error:', err);
    res.render('auth/reset-password', {
      title: 'Reset Password',
      layout: 'layout-auth',
      token,
      error: 'An error occurred during password reset.'
    });
  }
});

module.exports = router;
