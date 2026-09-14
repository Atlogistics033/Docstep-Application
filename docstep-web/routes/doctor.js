// Doctor dashboard routes - direct Firebase Firestore
const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const dbService = require('../db/dbService');
const { requireRole } = require('../middleware/auth');

const uploadDir = path.join(__dirname, '..', 'public', 'uploads');
if (!fs.existsSync(uploadDir)) fs.mkdirSync(uploadDir, { recursive: true });

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, uploadDir),
  filename: (req, file, cb) => cb(null, Date.now() + '-' + file.originalname.replace(/\s+/g, '_'))
});
const upload = multer({ storage, limits: { fileSize: 5 * 1024 * 1024 } });

router.use(requireRole('doctor'));

async function profileFor(userId) {
  return await dbService.getDoctorProfileByUserId(userId);
}

router.get('/dashboard', async (req, res) => {
  try {
    const profile = await profileFor(req.session.user.id);
    if (!profile) {
      req.session.flash = { type: 'error', text: 'Doctor profile not found.' };
      return res.redirect('/');
    }
    
    const appointments = await dbService.getAppointmentsByDoctor(profile.id);
    const interviews = await dbService.getInterviewsByDoctor(profile.id);
    const recommended = await dbService.getJobs({ specialty: profile.specialty });
    const creds = await dbService.getCredentials(profile.id);
    
    const stats = {
      appointments: appointments.length,
      interviews: interviews.length,
      credentials: creds.length,
      verifiedCredentials: creds.filter(c => c.verified === 1).length
    };
    
    res.render('doctor/dashboard', { 
      title: 'Doctor Dashboard', 
      profile, 
      appointments: appointments.slice(0, 5), 
      interviews, 
      recommended: recommended.slice(0, 4), 
      stats, 
      side: 'home' 
    });
  } catch (err) {
    console.error('Doctor dashboard error:', err);
    res.redirect('/');
  }
});

router.get('/profile', async (req, res) => {
  try {
    const profile = await profileFor(req.session.user.id);
    res.render('doctor/profile', { title: 'My Profile', profile, side: 'profile' });
  } catch (err) {
    console.error('Doctor profile view error:', err);
    res.redirect('/doctor/dashboard');
  }
});

router.post('/profile', async (req, res) => {
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
    req.session.flash = { type: 'success', text: 'Profile updated.' };
    res.redirect('/doctor/profile');
  } catch (err) {
    console.error('Doctor profile save error:', err);
    req.session.flash = { type: 'error', text: 'Failed to update profile.' };
    res.redirect('/doctor/profile');
  }
});

router.get('/credentials', async (req, res) => {
  try {
    const profile = await profileFor(req.session.user.id);
    const creds = await dbService.getCredentials(profile.id);
    res.render('doctor/credentials', { title: 'Credentials', profile, creds, side: 'credentials' });
  } catch (err) {
    console.error('Doctor credentials error:', err);
    res.redirect('/doctor/dashboard');
  }
});

router.post('/credentials/upload', upload.single('file'), async (req, res) => {
  try {
    const profile = await profileFor(req.session.user.id);
    const { cred_type, title } = req.body;
    const file_path = req.file ? '/uploads/' + req.file.filename : null;
    
    await dbService.createCredential(profile.id, { cred_type, title, file_path });
    req.session.flash = { type: 'success', text: 'Credential uploaded — pending verification.' };
    res.redirect('/doctor/credentials');
  } catch (err) {
    console.error('Credential upload error:', err);
    req.session.flash = { type: 'error', text: 'Failed to upload credential.' };
    res.redirect('/doctor/credentials');
  }
});

router.post('/credentials/:id/delete', async (req, res) => {
  try {
    const profile = await profileFor(req.session.user.id);
    await dbService.deleteCredential(req.params.id, profile.id);
    req.session.flash = { type: 'success', text: 'Credential removed.' };
    res.redirect('/doctor/credentials');
  } catch (err) {
    console.error('Credential delete error:', err);
    res.redirect('/doctor/credentials');
  }
});

router.get('/cv-builder', async (req, res) => {
  try {
    const profile = await profileFor(req.session.user.id);
    res.render('doctor/cv-builder', { title: 'CV Builder', profile, side: 'cv' });
  } catch (err) {
    console.error('CV builder page error:', err);
    res.redirect('/doctor/dashboard');
  }
});

router.post('/cv-builder', async (req, res) => {
  try {
    const { cv_summary, cv_skills, cv_experience, cv_education, cv_certifications } = req.body;
    await dbService.updateDoctorCv(req.session.user.id, {
      cv_summary,
      cv_skills,
      cv_experience,
      cv_education,
      cv_certifications
    });
    req.session.flash = { type: 'success', text: 'CV saved.' };
    res.redirect('/doctor/cv-builder');
  } catch (err) {
    console.error('CV builder save error:', err);
    req.session.flash = { type: 'error', text: 'Failed to save CV.' };
    res.redirect('/doctor/cv-builder');
  }
});

router.get('/appointments', async (req, res) => {
  try {
    const profile = await profileFor(req.session.user.id);
    let list = await dbService.getAppointmentsByDoctor(profile.id);

    // Filter appointments
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

    res.render('doctor/appointments', { 
      title: 'My Appointments', 
      appointments: list, 
      side: 'appointments',
      filter: filter || 'all',
      dateVal: dateVal || ''
    });
  } catch (err) {
    console.error('Doctor appointments view error:', err);
    res.redirect('/doctor/dashboard');
  }
});

router.post('/apply/:jobId', async (req, res) => {
  try {
    const profile = await profileFor(req.session.user.id);
    const { cover_letter } = req.body;
    await dbService.createApplication(req.params.jobId, profile.id, cover_letter || '');
    req.session.flash = { type: 'success', text: 'Application submitted.' };
  } catch (e) {
    req.session.flash = { type: 'error', text: 'You already applied to this job.' };
  }
  res.redirect('/jobs/' + req.params.jobId);
});

router.get('/availability', async (req, res) => {
  try {
    const profile = await profileFor(req.session.user.id);
    res.render('doctor/availability', { title: 'Availability', profile, side: 'availability' });
  } catch (err) {
    console.error('Availability view error:', err);
    res.redirect('/doctor/dashboard');
  }
});

router.post('/availability', async (req, res) => {
  try {
    const { availability, open_to_remote, hourly_rate } = req.body;
    await dbService.updateDoctorAvailability(req.session.user.id, {
      availability,
      open_to_remote: open_to_remote ? 1 : 0,
      hourly_rate: hourly_rate || 0
    });
    req.session.flash = { type: 'success', text: 'Availability updated.' };
    res.redirect('/doctor/availability');
  } catch (err) {
    console.error('Availability save error:', err);
    req.session.flash = { type: 'error', text: 'Failed to update availability.' };
    res.redirect('/doctor/availability');
  }
});

module.exports = router;
