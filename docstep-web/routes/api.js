// Unified REST API Router for DocStep React Frontend
const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const dbService = require('../db/dbService');

// File upload setup
const uploadDir = path.join(__dirname, '..', 'public', 'uploads');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, uploadDir),
  filename: (req, file, cb) => cb(null, Date.now() + '-' + file.originalname.replace(/\s+/g, '_'))
});
const upload = multer({ storage, limits: { fileSize: 5 * 1024 * 1024 } });

// Custom API Middleware
const requireApiAuth = (req, res, next) => {
  if (req.session && req.session.user) return next();
  return res.status(401).json({ success: false, error: 'Unauthorized. Please login.' });
};

const requireApiRole = (role) => (req, res, next) => {
  if (req.session && req.session.user && req.session.user.role === role) return next();
  return res.status(403).json({ success: false, error: `Access restricted to ${role}s only.` });
};

// Helpers
async function doctorProfileFor(userId) {
  return await dbService.getDoctorProfileByUserId(userId);
}

async function employerProfileFor(userId) {
  return await dbService.getEmployerProfileByUserId(userId);
}

// ==========================================
// 1. Session Auth Endpoints
// ==========================================

// Get current logged-in user profile/session
router.get('/auth/me', (req, res) => {
  if (req.session && req.session.user) {
    return res.json({ success: true, user: req.session.user });
  }
  return res.json({ success: true, user: null });
});

// Login
router.post('/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ success: false, error: 'Email and password are required.' });
    }
    const user = await dbService.getUserByEmail(email);
    if (!user || !bcrypt.compareSync(password, user.password_hash)) {
      return res.status(401).json({ success: false, error: 'Invalid email or password.' });
    }

    let displayName = user.full_name;
    if (user.role === 'employer') {
      const profile = await dbService.getEmployerProfileByUserId(user.id);
      if (profile && profile.organization_name) {
        displayName = profile.organization_name;
      }
    }

    req.session.user = { id: user.id, email: user.email, role: user.role, full_name: displayName };
    req.session.save((err) => {
      if (err) {
        console.error('Session save error:', err);
        return res.status(500).json({ success: false, error: 'Session save failure.' });
      }
      return res.json({ success: true, user: req.session.user });
    });
  } catch (err) {
    console.error('API login error:', err);
    return res.status(500).json({ success: false, error: 'An error occurred during login.' });
  }
});

// Register
router.post('/auth/register', async (req, res) => {
  try {
    const { email, password, full_name, role, phone, organization_name, specialty, city } = req.body;
    if (!email || !password || !full_name || !role) {
      return res.status(400).json({ success: false, error: 'Required fields missing: email, password, full_name, role' });
    }
    if (!['doctor', 'employer'].includes(role)) {
      return res.status(400).json({ success: false, error: 'Invalid role.' });
    }

    const existing = await dbService.getUserByEmail(email);
    if (existing) {
      return res.status(400).json({ success: false, error: 'An account with this email already exists.' });
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
    req.session.save((err) => {
      if (err) {
        console.error('Session save error:', err);
        return res.status(500).json({ success: false, error: 'Session save failure.' });
      }
      return res.json({ success: true, user: req.session.user });
    });
  } catch (err) {
    console.error('API registration error:', err);
    let errMsg = 'An error occurred during registration.';
    if (err.code === 'auth/email-already-exists') {
      errMsg = 'An account with this email already exists.';
    } else if (err.code === 'auth/invalid-password') {
      errMsg = 'Password must be at least 6 characters long.';
    } else if (err.code === 'auth/invalid-email') {
      errMsg = 'The email address is badly formatted.';
    }
    return res.status(400).json({ success: false, error: errMsg });
  }
});

// Logout
router.post('/auth/logout', (req, res) => {
  if (req.session) {
    req.session.destroy((err) => {
      if (err) {
        console.error('Logout session destruction error:', err);
        return res.status(500).json({ success: false, error: 'Could not log out.' });
      }
      res.clearCookie('connect.sid');
      return res.json({ success: true });
    });
  } else {
    return res.json({ success: true });
  }
});

// API Forgot Password
router.post('/auth/forgot-password', async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) {
      return res.status(400).json({ success: false, error: 'Email is required.' });
    }

    const user = await dbService.getUserByEmail(email);
    if (!user) {
      return res.status(404).json({ success: false, error: 'No account found with this email address.' });
    }

    // Generate token
    const crypto = require('crypto');
    const token = crypto.randomBytes(20).toString('hex');
    const expiresAt = new Date(Date.now() + 3600000).toISOString();

    await dbService.createPasswordResetToken(email, token, expiresAt);
    const resetLink = `/reset-password?token=${token}`;

    return res.json({
      success: true,
      message: 'Password reset link generated successfully!',
      resetLink
    });
  } catch (err) {
    console.error('API Forgot password error:', err);
    return res.status(500).json({ success: false, error: 'An error occurred during password reset request.' });
  }
});

// API Reset Password
router.post('/auth/reset-password', async (req, res) => {
  try {
    const { token, password } = req.body;
    if (!token || !password) {
      return res.status(400).json({ success: false, error: 'Token and new password are required.' });
    }

    const resetRequest = await dbService.getPasswordResetToken(token);
    if (!resetRequest || new Date(resetRequest.expires_at) < new Date()) {
      return res.status(400).json({ success: false, error: 'Password reset token is invalid or has expired.' });
    }

    const user = await dbService.getUserByEmail(resetRequest.email);
    if (!user) {
      return res.status(404).json({ success: false, error: 'User account not found.' });
    }

    // Update password
    const hash = bcrypt.hashSync(password, 10);
    await dbService.updateUserPassword(user.id, hash);

    // Delete token
    await dbService.deletePasswordResetToken(resetRequest.id);

    return res.json({ success: true, message: 'Your password has been reset successfully. Please login.' });
  } catch (err) {
    console.error('API Reset password error:', err);
    return res.status(500).json({ success: false, error: 'An error occurred while resetting password.' });
  }
});

// ==========================================
// 2. Public Platform Endpoints
// ==========================================

// Stats
router.get('/public/stats', async (req, res) => {
  try {
    const stats = await dbService.getStats();
    return res.json({ success: true, stats });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: 'Failed to fetch stats.' });
  }
});

// Jobs List
router.get('/public/jobs', async (req, res) => {
  try {
    const { q, specialty, mode } = req.query;
    const jobs = await dbService.getJobs({ q, specialty, mode });
    const specialties = await dbService.getJobsDistinctSpecialties();
    const modes = await dbService.getJobsDistinctModes();
    return res.json({ success: true, jobs, specialties, modes });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: 'Failed to fetch jobs.' });
  }
});

// Job Details
router.get('/public/jobs/:id', async (req, res) => {
  try {
    const job = await dbService.getJobById(req.params.id);
    if (!job) return res.status(404).json({ success: false, error: 'Job not found.' });

    const related = await dbService.getRelatedJobs(job.specialty, job.id);
    let applied = false;
    if (req.session && req.session.user && req.session.user.role === 'doctor') {
      const dp = await doctorProfileFor(req.session.user.id);
      if (dp) applied = await dbService.hasDoctorApplied(job.id, dp.id);
    }
    return res.json({ success: true, job, related, applied });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: 'Failed to fetch job details.' });
  }
});

// Success Stories
router.get('/public/stories', async (req, res) => {
  try {
    const stories = await dbService.getSuccessStories();
    return res.json({ success: true, stories });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: 'Failed to fetch stories.' });
  }
});

// Courses
router.get('/public/courses', async (req, res) => {
  try {
    const forceRefresh = req.query.refresh === 'true';
    const courses = await dbService.getCourses(forceRefresh);
    return res.json({ success: true, courses });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: 'Failed to fetch courses.' });
  }
});

// Recommendation engine using Gemini
router.get('/public/courses/recommend', async (req, res) => {
  try {
    const { specialty } = req.query;
    const courses = await dbService.recommendCoursesUsingGemini(specialty);
    return res.json({ success: true, courses });
  } catch (err) {
    console.error('API courses/recommend error:', err);
    return res.status(500).json({ success: false, error: 'Failed to match courses.' });
  }
});

// Contact Us submit
router.post('/public/contact', async (req, res) => {
  try {
    const { name, email, subject, message } = req.body;
    if (!name || !email || !message) {
      return res.status(400).json({ success: false, error: 'Name, email, and message are required.' });
    }
    await dbService.createContactMessage(name, email, subject, message);
    return res.json({ success: true });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: 'Failed to save message.' });
  }
});

// GET doctor details for appointment booking
router.get('/public/doctor-details/:id', async (req, res) => {
  try {
    const docProfile = await dbService.getDoctorProfileById(req.params.id);
    if (!docProfile) return res.status(404).json({ success: false, error: 'Doctor not found.' });
    const u = await dbService.getUserById(docProfile.user_id);
    return res.json({
      success: true,
      doctor: {
        id: docProfile.id,
        name: u ? u.full_name : 'Doctor',
        specialty: docProfile.specialty,
        availability: docProfile.availability
      }
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: 'Failed to fetch doctor details.' });
  }
});

// GET list of all doctors (public)
router.get('/public/doctors', async (req, res) => {
  try {
    const snap = await dbService.db.collection('doctor_profiles').get();
    const doctors = [];
    for (const doc of snap.docs) {
      const data = doc.data();
      const u = await dbService.getUserById(data.user_id);
      if (u) {
        doctors.push({
          id: doc.id,
          name: u.full_name,
          specialty: data.specialty || 'General Practice',
          availability: data.availability || 'Flexible'
        });
      }
    }
    doctors.sort((a, b) => a.name.localeCompare(b.name));
    return res.json({ success: true, doctors });
  } catch (err) {
    console.error('API /public/doctors error:', err);
    return res.status(500).json({ success: false, error: 'Failed to fetch doctors.' });
  }
});

// Helper function to map doctor's availability to specific slots
function getSlotsForAvailability(availability, day) {
  const isWeekend = day === 'Saturday' || day === 'Sunday';
  const avail = (availability || '').toLowerCase();
  
  if (avail.includes('weekdays')) {
    if (day && isWeekend) return [];
    if (avail.includes('10am-2pm') || avail.includes('10am - 2pm')) {
      return [
        '10:00 AM - 10:30 AM',
        '10:30 AM - 11:00 AM',
        '11:00 AM - 11:30 AM',
        '11:30 AM - 12:00 PM',
        '12:00 PM - 12:30 PM',
        '12:30 PM - 01:00 PM',
        '01:00 PM - 01:30 PM',
        '01:30 PM - 02:00 PM'
      ];
    }
    if (avail.includes('afternoon')) {
      return [
        '12:00 PM - 12:30 PM',
        '12:30 PM - 01:00 PM',
        '01:00 PM - 01:30 PM',
        '01:30 PM - 02:00 PM',
        '02:00 PM - 02:30 PM',
        '02:30 PM - 03:00 PM',
        '03:00 PM - 03:30 PM',
        '03:30 PM - 04:00 PM'
      ];
    }
  }
  
  if (avail.includes('evenings & weekends')) {
    if (day && isWeekend) {
      return [
        '10:00 AM - 10:30 AM',
        '10:30 AM - 11:00 AM',
        '11:00 AM - 11:30 AM',
        '11:30 AM - 12:00 PM',
        '12:00 PM - 12:30 PM',
        '12:30 PM - 01:00 PM',
        '02:00 PM - 02:30 PM',
        '02:30 PM - 03:00 PM',
        '03:00 PM - 03:30 PM',
        '03:30 PM - 04:00 PM',
        '05:00 PM - 05:30 PM',
        '05:30 PM - 06:00 PM',
        '06:00 PM - 06:30 PM',
        '06:30 PM - 07:00 PM',
        '07:00 PM - 07:30 PM',
        '07:30 PM - 08:00 PM'
      ];
    } else {
      return [
        '05:00 PM - 05:30 PM',
        '05:30 PM - 06:00 PM',
        '06:00 PM - 06:30 PM',
        '06:30 PM - 07:00 PM',
        '07:00 PM - 07:30 PM',
        '07:30 PM - 08:00 PM'
      ];
    }
  }

  if (avail.includes('evening')) {
    return [
      '05:00 PM - 05:30 PM',
      '05:30 PM - 06:00 PM',
      '06:00 PM - 06:30 PM',
      '06:30 PM - 07:00 PM',
      '07:00 PM - 07:30 PM',
      '07:30 PM - 08:00 PM'
    ];
  }

  if (avail.includes('morning')) {
    return [
      '09:00 AM - 09:30 AM',
      '09:30 AM - 10:00 AM',
      '10:00 AM - 10:30 AM',
      '10:30 AM - 11:00 AM',
      '11:00 AM - 11:30 AM',
      '11:30 AM - 12:00 PM'
    ];
  }

  if (avail.includes('afternoon')) {
    if (day && isWeekend) return [];
    return [
      '12:00 PM - 12:30 PM',
      '12:30 PM - 01:00 PM',
      '01:00 PM - 01:30 PM',
      '01:30 PM - 02:00 PM',
      '02:00 PM - 02:30 PM',
      '02:30 PM - 03:00 PM',
      '03:00 PM - 03:30 PM',
      '03:30 PM - 04:00 PM'
    ];
  }

  // Default / Flexible
  return [
    '09:00 AM - 09:30 AM',
    '09:30 AM - 10:00 AM',
    '10:00 AM - 10:30 AM',
    '10:30 AM - 11:00 AM',
    '11:00 AM - 11:30 AM',
    '11:30 AM - 12:00 PM',
    '12:00 PM - 12:30 PM',
    '12:30 PM - 01:00 PM',
    '02:00 PM - 02:30 PM',
    '02:30 PM - 03:00 PM',
    '03:00 PM - 03:30 PM',
    '03:30 PM - 04:00 PM',
    '04:00 PM - 04:30 PM',
    '04:30 PM - 05:00 PM',
    '05:00 PM - 05:30 PM',
    '05:30 PM - 06:00 PM'
  ];
}

// GET doctor profile, specialty, and availability/slots (both public and standard)
const getDoctorAvailabilityHandler = async (req, res) => {
  try {
    const docProfile = await dbService.getDoctorProfileById(req.params.id);
    if (!docProfile) {
      return res.status(404).json({ success: false, error: 'Doctor not found.' });
    }
    const u = await dbService.getUserById(docProfile.user_id);
    
    // Generate available slots based on selected date
    let day = null;
    if (req.query.date) {
      const dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
      const d = new Date(req.query.date);
      day = dayNames[d.getDay()];
    }

    const availableSlots = getSlotsForAvailability(docProfile.availability, day);

    return res.json({
      success: true,
      doctor: {
        id: docProfile.id,
        name: u ? u.full_name : 'Doctor',
        specialty: docProfile.specialty,
        availability: docProfile.availability,
        open_to_remote: docProfile.open_to_remote,
        hourly_rate: docProfile.hourly_rate,
        city: docProfile.city,
        qualifications: docProfile.qualifications
      },
      specialty: docProfile.specialty,
      availableSlots
    });
  } catch (err) {
    console.error('API availability error:', err);
    return res.status(500).json({ success: false, error: 'Failed to fetch doctor availability.' });
  }
};

router.get('/doctors/:id/availability', getDoctorAvailabilityHandler);
router.get('/public/doctors/:id/availability', getDoctorAvailabilityHandler);

// POST create appointment
router.post('/public/appointments', async (req, res) => {
  try {
    const { doctor_id, patient_name, date, time_slot } = req.body;
    if (!doctor_id || !patient_name || !date || !time_slot) {
      return res.status(400).json({ success: false, error: 'Doctor ID, patient name, date, and time slot are required.' });
    }
    const docProfile = await dbService.getDoctorProfileById(doctor_id);
    if (!docProfile) return res.status(404).json({ success: false, error: 'Doctor profile not found.' });
    const u = await dbService.getUserById(docProfile.user_id);
    const doctor_name = u ? u.full_name : 'Doctor';

    // Calculate Day Name
    const dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    const d = new Date(date);
    const day = dayNames[d.getDay()];

    const employer_id = req.session && req.session.user && req.session.user.role === 'employer' ? req.session.user.id : null;
    const appointmentId = await dbService.createAppointment({
      doctor_id,
      employer_id,
      doctor_name,
      patient_name,
      date,
      day,
      time_slot,
      primary_specialty: docProfile.specialty,
      doctor_availability: docProfile.availability
    });

    return res.json({ success: true, appointmentId });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: 'Failed to save appointment.' });
  }
});

// GET search appointments by patient name
router.get('/public/appointments/search', async (req, res) => {
  try {
    const { patient_name } = req.query;
    if (!patient_name) {
      return res.json({ success: true, appointments: [] });
    }

    const searchStr = patient_name.toLowerCase().trim();
    const snapshot = await dbService.db.collection('appointments').get();
    const list = [];
    
    snapshot.forEach(doc => {
      const data = doc.data();
      if (data.patient_name && data.patient_name.toLowerCase().includes(searchStr)) {
        const status = (data.status || 'scheduled').toLowerCase();
        if (status !== 'cancelled' && status !== 'cancel' && status !== 'canceled') {
          list.push({ id: doc.id, ...data });
        }
      }
    });

    // Sort by date descending
    list.sort((a, b) => new Date(b.date) - new Date(a.date));
    return res.json({ success: true, appointments: list });
  } catch (err) {
    console.error('API search appointments error:', err);
    return res.status(500).json({ success: false, error: 'Failed to search appointments.' });
  }
});

// POST reschedule an appointment
router.post('/public/appointments/:id/reschedule', async (req, res) => {
  try {
    const { id } = req.params;
    const { date, time_slot, doctor_id } = req.body;

    if (!date || !time_slot) {
      return res.status(400).json({ success: false, error: 'Date and time slot are required.' });
    }

    const appointment = await dbService.getAppointmentById(id);
    if (!appointment) {
      return res.status(404).json({ success: false, error: 'Appointment not found.' });
    }

    // Calculate day name
    const dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    const d = new Date(date);
    const day = dayNames[d.getDay()];

    const updateData = {
      date,
      time_slot,
      day,
      status: 'rescheduled'
    };

    // If logged-in user is an employer, ensure their employer_id is attached to the appointment
    if (req.session && req.session.user && req.session.user.role === 'employer') {
      updateData.employer_id = req.session.user.id;
    }

    // If changing doctor
    if (doctor_id && doctor_id !== appointment.doctor_id) {
      const docProfile = await dbService.getDoctorProfileById(doctor_id);
      if (docProfile) {
        const u = await dbService.getUserById(docProfile.user_id);
        updateData.doctor_id = doctor_id;
        updateData.doctor_name = u ? u.full_name : 'Doctor';
        updateData.primary_specialty = docProfile.specialty;
        updateData.doctor_availability = docProfile.availability;
      } else {
        return res.status(404).json({ success: false, error: 'New doctor profile not found.' });
      }
    }

    await dbService.updateAppointment(id, updateData);
    if (req.session) {
      req.session.flash = { type: 'success', text: 'Appointment rescheduled successfully!' };
    }
    return res.json({ success: true, message: 'Appointment rescheduled successfully!' });
  } catch (err) {
    console.error('API reschedule appointment error:', err);
    return res.status(500).json({ success: false, error: 'Failed to reschedule appointment.' });
  }
});

// POST cancel an appointment (Update Status instead of Delete)
router.post('/public/appointments/:id/cancel', async (req, res) => {
  try {
    const { id } = req.params;
    const appointment = await dbService.getAppointmentById(id);
    if (!appointment) {
      return res.status(404).json({ success: false, error: 'Appointment not found.' });
    }

    await dbService.updateAppointment(id, { status: 'cancelled' });
    if (req.session) {
      req.session.flash = { type: 'success', text: 'Appointment cancelled successfully!' };
    }
    return res.json({ success: true, message: 'Appointment cancelled successfully!' });
  } catch (err) {
    console.error('API cancel appointment error:', err);
    return res.status(500).json({ success: false, error: 'Failed to cancel appointment.' });
  }
});

// Community posts list
router.get('/public/community', async (req, res) => {
  try {
    const posts = await dbService.getCommunityPosts();
    return res.json({ success: true, posts });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: 'Failed to fetch community posts.' });
  }
});

// Community post detail & replies
router.get('/public/community/:id', async (req, res) => {
  try {
    const post = await dbService.getCommunityPostById(req.params.id);
    if (!post) return res.status(404).json({ success: false, error: 'Post not found.' });

    const replies = await dbService.getCommunityReplies(req.params.id);
    return res.json({ success: true, post, replies });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: 'Failed to fetch post details.' });
  }
});

// Create community post (Auth)
router.post('/public/community/new', requireApiAuth, async (req, res) => {
  try {
    const { title, content, category } = req.body;
    if (!title || !content) {
      return res.status(400).json({ success: false, error: 'Title and content are required.' });
    }
    const postId = await dbService.createCommunityPost(req.session.user.id, title, content, category || 'General');
    return res.json({ success: true, postId });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: 'Failed to create post.' });
  }
});

// Reply to community post (Auth)
router.post('/public/community/:id/reply', requireApiAuth, async (req, res) => {
  try {
    const { content } = req.body;
    if (!content) {
      return res.status(400).json({ success: false, error: 'Reply content is required.' });
    }
    const replyId = await dbService.createCommunityReply(req.params.id, req.session.user.id, content);
    return res.json({ success: true, replyId });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: 'Failed to add reply.' });
  }
});


// ==========================================
// 3. Doctor Dashboard & Profile Endpoints
// ==========================================
router.use('/doctor', requireApiAuth, requireApiRole('doctor'));

// Doctor dashboard stats
router.get('/doctor/dashboard', async (req, res) => {
  try {
    const profile = await doctorProfileFor(req.session.user.id);
    if (!profile) return res.status(404).json({ success: false, error: 'Doctor profile not found.' });

    const appointments = await dbService.getAppointmentsByDoctor(profile.id);
    const activeAppointments = appointments.filter(a => {
      const s = (a.status || 'scheduled').toLowerCase();
      return s !== 'cancelled' && s !== 'cancel' && s !== 'canceled';
    });

    // Smart Recommended Jobs Fetching:
    // 1. Get open jobs matching doctor's specialty
    const matchingJobs = await dbService.getJobs({ specialty: profile.specialty });
    const openMatching = matchingJobs.filter(j => j.status === 'open');

    // 2. Get all open jobs
    const allJobs = await dbService.getJobs();
    const openAll = allJobs.filter(j => j.status === 'open');

    // 3. Combine them, keeping matching first
    const combined = [...openMatching];
    for (const job of openAll) {
      if (!combined.some(j => j.id === job.id)) {
        combined.push(job);
      }
    }
    const recommended = combined.slice(0, 4);

    const creds = await dbService.getCredentials(profile.id);

    const stats = {
      appointments: activeAppointments.length,
      credentials: creds.length,
      verifiedCredentials: creds.filter(c => c.verified === 1).length
    };

    return res.json({
      success: true,
      profile,
      appointments: appointments.slice(0, 5),
      recommended,
      stats
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: 'Dashboard fetch failed.' });
  }
});

// Doctor profile update
router.post('/doctor/profile', async (req, res) => {
  try {
    const { specialty, experience_years, pmdc_number, bio, city, languages, qualifications, availability, hourly_rate, open_to_remote, full_name, phone, clinic_name, clinic_address, clinic_hospital_address } = req.body;

    await dbService.updateDoctorProfile(req.session.user.id, {
      specialty,
      experience_years,
      pmdc_number,
      bio,
      city,
      languages,
      qualifications,
      availability,
      hourly_rate,
      open_to_remote,
      clinic_name,
      clinic_address,
      clinic_hospital_address
    });

    await dbService.updateUser(req.session.user.id, full_name, phone);
    req.session.user.full_name = full_name;

    return res.json({ success: true, message: 'Profile updated successfully.' });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: 'Failed to update profile.' });
  }
});

// Credentials list
router.get('/doctor/credentials', async (req, res) => {
  try {
    const profile = await doctorProfileFor(req.session.user.id);
    const creds = await dbService.getCredentials(profile.id);
    return res.json({ success: true, creds });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: 'Failed to fetch credentials.' });
  }
});

// Credential upload
router.post('/doctor/credentials/upload', upload.single('file'), async (req, res) => {
  try {
    const profile = await doctorProfileFor(req.session.user.id);
    const { cred_type, title } = req.body;
    const file_path = req.file ? '/uploads/' + req.file.filename : null;

    if (!cred_type || !title) {
      return res.status(400).json({ success: false, error: 'Credential type and title are required.' });
    }

    const credId = await dbService.createCredential(profile.id, { cred_type, title, file_path });
    return res.json({ success: true, credId, file_path });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: 'Upload failed.' });
  }
});

// Credential delete
router.post('/doctor/credentials/:id/delete', async (req, res) => {
  try {
    const profile = await doctorProfileFor(req.session.user.id);
    await dbService.deleteCredential(req.params.id, profile.id);
    return res.json({ success: true });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: 'Failed to delete credential.' });
  }
});

// CV Builder load
router.get('/doctor/cv-builder', async (req, res) => {
  try {
    const profile = await doctorProfileFor(req.session.user.id);
    return res.json({ success: true, profile });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: 'Failed to load CV builder data.' });
  }
});

// CV Builder save
router.post('/doctor/cv-builder', async (req, res) => {
  try {
    const { cv_summary, cv_skills, cv_experience, cv_education, cv_certifications } = req.body;
    await dbService.updateDoctorCv(req.session.user.id, {
      cv_summary,
      cv_skills,
      cv_experience,
      cv_education,
      cv_certifications
    });
    return res.json({ success: true });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: 'Failed to save CV.' });
  }
});

// Doctor appointments list with Day Filter
router.get('/doctor/appointments', async (req, res) => {
  try {
    const profile = await doctorProfileFor(req.session.user.id);
    if (!profile) return res.status(404).json({ success: false, error: 'Doctor profile not found.' });

    let list = await dbService.getAppointmentsByDoctor(profile.id);

    // Apply Day Filter
    const { filter, dateVal } = req.query;
    const todayStr = new Date().toISOString().split('T')[0];
    const tomorrowDate = new Date();
    tomorrowDate.setDate(tomorrowDate.getDate() + 1);
    const tomorrowStr = tomorrowDate.toISOString().split('T')[0];

    if (filter === 'today') {
      list = list.filter(a => a.date === todayStr);
    } else if (filter === 'tomorrow') {
      list = list.filter(a => a.date === tomorrowStr);
    } else if (filter === 'specific' && dateVal) {
      list = list.filter(a => a.date === dateVal);
    }

    return res.json({ success: true, appointments: list });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: 'Failed to fetch appointments.' });
  }
});

// Applications list
router.get('/doctor/applications', async (req, res) => {
  try {
    const profile = await doctorProfileFor(req.session.user.id);
    const apps = await dbService.getApplicationsByDoctor(profile.id);
    return res.json({ success: true, apps });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: 'Failed to fetch applications.' });
  }
});

// Submit Application
router.post('/doctor/apply/:jobId', async (req, res) => {
  try {
    const profile = await doctorProfileFor(req.session.user.id);
    const { cover_letter } = req.body;
    const appId = await dbService.createApplication(req.params.jobId, profile.id, cover_letter || '');
    return res.json({ success: true, appId });
  } catch (e) {
    return res.status(400).json({ success: false, error: 'You have already applied to this job.' });
  }
});

// Availability save
router.post('/doctor/availability', async (req, res) => {
  try {
    const { availability, open_to_remote, hourly_rate } = req.body;
    await dbService.updateDoctorAvailability(req.session.user.id, {
      availability,
      open_to_remote: open_to_remote ? 1 : 0,
      hourly_rate: hourly_rate || 0
    });
    return res.json({ success: true });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: 'Failed to update availability.' });
  }
});


// ==========================================
// 4. Employer Dashboard Endpoints
// ==========================================
router.use('/employer', requireApiAuth, requireApiRole('employer'));

// Employer dashboard stats
router.get('/employer/dashboard', async (req, res) => {
  try {
    const profile = await employerProfileFor(req.session.user.id);
    if (!profile) return res.status(404).json({ success: false, error: 'Employer profile not found.' });

    const jobs = await dbService.getEmployerJobs(profile.id);
    const appointments = await dbService.getAppointmentsByEmployer(req.session.user.id);
    const activeAppointments = appointments.filter(a => {
      const s = (a.status || 'scheduled').toLowerCase();
      return s !== 'cancelled' && s !== 'cancel' && s !== 'canceled';
    });

    const stats = {
      jobs: jobs.length,
      open: jobs.filter(j => j.status === 'open').length,
      appointments: activeAppointments.length,
    };

    return res.json({
      success: true,
      profile,
      jobs,
      appointments: appointments.slice(0, 10),
      stats
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: 'Dashboard fetch failed.' });
  }
});

// Employer jobs posted
router.get('/employer/jobs', async (req, res) => {
  try {
    const profile = await employerProfileFor(req.session.user.id);
    const jobs = await dbService.getEmployerJobs(profile.id);
    return res.json({ success: true, jobs });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: 'Failed to fetch employer jobs.' });
  }
});

// Employer create new job
router.post('/employer/jobs/new', async (req, res) => {
  try {
    const profile = await employerProfileFor(req.session.user.id);
    const { title, specialty, job_type, mode, city, salary_range, description, requirements } = req.body;

    if (!title || !specialty || !description) {
      return res.status(400).json({ success: false, error: 'Title, specialty, and description are required.' });
    }

    const jobId = await dbService.createJob(profile.id, {
      title,
      specialty,
      job_type,
      mode,
      city,
      salary_range,
      description,
      requirements
    });

    return res.json({ success: true, jobId });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: 'Failed to post job.' });
  }
});

// Employer edit job
router.post('/employer/jobs/:id/edit', async (req, res) => {
  try {
    const profile = await employerProfileFor(req.session.user.id);
    const job = await dbService.getJobById(req.params.id);
    if (!job || job.employer_id !== profile.id) {
      return res.status(403).json({ success: false, error: 'Forbidden. Not the job owner.' });
    }

    const { title, specialty, job_type, mode, city, salary_range, description, requirements, status } = req.body;
    await dbService.updateJob(req.params.id, profile.id, {
      title,
      specialty,
      job_type,
      mode,
      city,
      salary_range,
      description,
      requirements,
      status
    });

    return res.json({ success: true });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: 'Failed to update job.' });
  }
});

// Employer delete job
router.post('/employer/jobs/:id/delete', async (req, res) => {
  try {
    const profile = await employerProfileFor(req.session.user.id);
    const job = await dbService.getJobById(req.params.id);
    if (!job || job.employer_id !== profile.id) {
      return res.status(403).json({ success: false, error: 'Forbidden. Not the job owner.' });
    }

    await dbService.deleteJob(req.params.id, profile.id);
    return res.json({ success: true });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: 'Failed to delete job.' });
  }
});

// Employer search candidates
router.get('/employer/candidates', async (req, res) => {
  try {
    const { q, specialty, city } = req.query;
    const candidates = await dbService.getCandidates({ q, specialty, city });
    const specialties = await dbService.getCandidatesDistinctSpecialties();
    const cities = await dbService.getCandidatesDistinctCities();

    return res.json({ success: true, candidates, specialties, cities });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: 'Failed to search candidates.' });
  }
});

// Candidate detail
router.get('/employer/candidates/:id', async (req, res) => {
  try {
    const cand = await dbService.getCandidateDetail(req.params.id);
    if (!cand) return res.status(404).json({ success: false, error: 'Candidate not found.' });

    const creds = await dbService.getCredentials(cand.id);
    return res.json({ success: true, cand, creds });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: 'Failed to load candidate details.' });
  }
});

// Employer appointments list with Day Filter
router.get('/employer/appointments', async (req, res) => {
  try {
    let list = await dbService.getAppointmentsByEmployer(req.session.user.id);

    // Apply Day Filter
    const { filter, dateVal } = req.query;
    const todayStr = new Date().toISOString().split('T')[0];
    const tomorrowDate = new Date();
    tomorrowDate.setDate(tomorrowDate.getDate() + 1);
    const tomorrowStr = tomorrowDate.toISOString().split('T')[0];

    if (filter === 'today') {
      list = list.filter(a => a.date === todayStr);
    } else if (filter === 'tomorrow') {
      list = list.filter(a => a.date === tomorrowStr);
    } else if (filter === 'specific' && dateVal) {
      list = list.filter(a => a.date === dateVal);
    }

    return res.json({ success: true, appointments: list });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: 'Failed to fetch appointments.' });
  }
});

// Employer applications
router.get('/employer/applications', async (req, res) => {
  try {
    const profile = await employerProfileFor(req.session.user.id);
    const apps = await dbService.getEmployerApplications(profile.id);
    return res.json({ success: true, apps });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: 'Failed to load applications.' });
  }
});

// Employer update application status
router.post('/employer/applications/:id/status', async (req, res) => {
  try {
    const { status } = req.body;
    if (!status) return res.status(400).json({ success: false, error: 'Status is required.' });

    await dbService.updateApplicationStatus(req.params.id, status);
    return res.json({ success: true });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: 'Failed to update status.' });
  }
});

// Employer schedule interview
router.post('/employer/interviews/new', async (req, res) => {
  try {
    const { application_id, scheduled_at, mode, location, notes } = req.body;
    if (!application_id || !scheduled_at || !mode) {
      return res.status(400).json({ success: false, error: 'Application ID, schedule date, and mode are required.' });
    }

    const interviewId = await dbService.createInterview({
      application_id,
      scheduled_at,
      mode,
      location,
      notes
    });

    return res.json({ success: true, interviewId });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: 'Failed to schedule interview.' });
  }
});

// Employer interviews list
router.get('/employer/interviews', async (req, res) => {
  try {
    const profile = await employerProfileFor(req.session.user.id);
    const interviews = await dbService.getEmployerInterviews(profile.id);
    const allPendingApps = await dbService.getEmployerApplications(profile.id);
    const pendingApps = allPendingApps.filter(a => ['pending', 'shortlisted'].includes(a.status));

    return res.json({ success: true, interviews, pendingApps });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: 'Failed to fetch interviews.' });
  }
});

// Employer profile save
router.post('/employer/profile', async (req, res) => {
  try {
    const { organization_name, organization_type, city, website, about, full_name, phone } = req.body;

    await dbService.updateEmployerProfile(req.session.user.id, {
      organization_name,
      organization_type,
      city,
      website,
      about,
      logo: null
    });

    await dbService.updateUser(req.session.user.id, full_name, phone);
    req.session.user.full_name = organization_name || full_name;

    return res.json({ success: true });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: 'Failed to update profile.' });
  }
});


// ==========================================
// 5. Admin Dashboard Endpoints
// ==========================================
router.use('/admin', requireApiAuth, requireApiRole('admin'));

// Admin dashboard summary + items
router.get('/admin/dashboard', async (req, res) => {
  try {
    const stats = await dbService.getStats();
    const unverifiedDocs = await dbService.getUnverifiedDoctors();
    const unverifiedCreds = await dbService.getUnverifiedCredentials();
    const contacts = await dbService.getContactMessages();

    return res.json({
      success: true,
      stats,
      unverifiedDocs,
      unverifiedCreds,
      contacts
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: 'Admin dashboard failed.' });
  }
});

// Verify PMDC
router.post('/admin/verify-pmdc/:id', async (req, res) => {
  try {
    await dbService.verifyPmdc(req.params.id);
    return res.json({ success: true });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: 'Failed to verify PMDC.' });
  }
});

// Verify credential
router.post('/admin/verify-credential/:id', async (req, res) => {
  try {
    await dbService.verifyCredential(req.params.id);
    return res.json({ success: true });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: 'Failed to verify credential.' });
  }
});

// Delete/reject credential
router.post('/admin/delete-credential/:id', async (req, res) => {
  try {
    await dbService.deleteCredential(req.params.id, null);
    return res.json({ success: true });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: 'Failed to delete credential.' });
  }
});

// Public API: Suggest Best Doctor
router.get('/suggest-best-doctor', async (req, res) => {
  try {
    const selectedLocation = req.query.location || '';
    let doctors = [];

    if (selectedLocation) {
      const allDoctors = await dbService.getRegisteredDoctors();
      doctors = allDoctors.filter(doc => {
        const address = (doc.clinic_address || '').toLowerCase();
        const hospAddress = (doc.clinic_hospital_address || '').toLowerCase();
        const location = (doc.clinic_location || doc.clinicLocation || '').toLowerCase();
        const search = selectedLocation.toLowerCase();
        return address === search || location === search || address.includes(search) || hospAddress.includes(search);
      });
    }

    return res.json({
      success: true,
      doctors
    });
  } catch (err) {
    console.error('API Suggest best doctor error:', err);
    return res.status(500).json({ success: false, error: 'Failed to fetch doctors.' });
  }
});

module.exports = router;
