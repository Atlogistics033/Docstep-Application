// public.js — Public routing for DocStep Express views
const express = require('express');
const router = express.Router();
const dbService = require('../db/dbService');

// Home page
router.get('/', async (req, res) => {
  try {
    const stats = await dbService.getStats();
    const featuredJobs = await dbService.getJobs({});
    const featuredStories = await dbService.getSuccessStories();
    res.render('home', {
      title: 'DocStep — Empowering Women Doctors',
      stats,
      featuredJobs: featuredJobs.slice(0, 4),
      featuredStories: featuredStories.slice(0, 3)
    });
  } catch (err) {
    console.error('Home page error:', err);
    res.render('home', {
      title: 'DocStep — Empowering Women Doctors',
      stats: { doctors: 0, jobs: 0, employers: 0 },
      featuredJobs: [],
      featuredStories: []
    });
  }
});

// About page
router.get('/about', (req, res) => {
  res.render('about', { title: 'About' });
});

// Opportunities (Book Appointment)
router.get('/opportunities', async (req, res) => {
  try {
    const doctorsSnapshot = await dbService.db.collection('doctor_profiles').get();
    const doctors = [];
    for (const doc of doctorsSnapshot.docs) {
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
    
    let selectedDoc = null;
    const docId = req.query.doctor_id;
    if (docId) {
      selectedDoc = await dbService.getDoctorProfileById(docId);
    }
    
    res.render('opportunities', {
      title: 'Book Appointment',
      doctors,
      selectedDoc,
      selectedDocId: docId || '',
      patientName: (req.session && req.session.user) ? req.session.user.full_name : ''
    });
  } catch (err) {
    console.error('Opportunities book appointment view error:', err);
    res.redirect('/');
  }
});

router.post('/opportunities', async (req, res) => {
  try {
    const { doctor_id, patient_name, date, time_slot } = req.body;
    const docProfile = await dbService.getDoctorProfileById(doctor_id);
    if (!docProfile) {
      req.session.flash = { type: 'error', text: 'Doctor profile not found.' };
      return res.redirect('/opportunities');
    }
    
    const u = await dbService.getUserById(docProfile.user_id);
    const doctor_name = u ? u.full_name : 'Doctor';
    
    const dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    const d = new Date(date);
    const day = dayNames[d.getDay()];
    
    const employer_id = req.session && req.session.user && req.session.user.role === 'employer' ? req.session.user.id : null;
    
    await dbService.createAppointment({
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
    
    req.session.flash = { type: 'success', text: 'Appointment booked successfully!' };
    res.redirect('/');
  } catch (err) {
    console.error('Opportunities book appointment post error:', err);
    req.session.flash = { type: 'error', text: 'Failed to book appointment.' };
    res.redirect('/opportunities');
  }
});

// Job Details
router.get('/jobs/:id', async (req, res) => {
  try {
    const job = await dbService.getJobById(req.params.id);
    if (!job) return res.status(404).render('404', { title: 'Job Not Found' });
    const related = await dbService.getRelatedJobs(job.specialty, job.id);
    
    let applied = false;
    if (req.session && req.session.user && req.session.user.role === 'doctor') {
      const profile = await dbService.getDoctorProfileByUserId(req.session.user.id);
      if (profile) {
        applied = await dbService.hasDoctorApplied(job.id, profile.id);
      }
    }
    
    res.render('job-detail', {
      title: job.title,
      job,
      related,
      applied
    });
  } catch (err) {
    console.error('Job details error:', err);
    res.redirect('/opportunities');
  }
});

// For Doctors
router.get('/for-doctors', (req, res) => {
  res.render('for-doctors', { title: 'For Doctors' });
});

// For Employers
router.get('/for-employers', (req, res) => {
  res.render('for-employers', { title: 'For Employers' });
});

// Stories
router.get('/stories', async (req, res) => {
  try {
    const stories = await dbService.getSuccessStories();
    res.render('stories', {
      title: 'Success Stories',
      stories
    });
  } catch (err) {
    console.error('Stories view error:', err);
    res.redirect('/');
  }
});

// Courses
router.get('/courses', async (req, res) => {
  try {
    const doctorsSnapshot = await dbService.db.collection('doctor_profiles').get();
    const doctors = [];
    for (const doc of doctorsSnapshot.docs) {
      const data = doc.data();
      const u = await dbService.getUserById(data.user_id);
      if (u) {
        doctors.push({
          id: doc.id,
          name: u.full_name,
          specialty: data.specialty || 'General Practice'
        });
      }
    }
    doctors.sort((a, b) => a.name.localeCompare(b.name));

    res.render('courses', {
      title: 'Courses',
      courses: [],
      doctors
    });
  } catch (err) {
    console.error('Courses view error:', err);
    res.redirect('/');
  }
});

// Contact
router.get('/contact', (req, res) => {
  res.render('contact', { title: 'Contact' });
});

router.post('/contact', async (req, res) => {
  try {
    const { name, email, subject, message } = req.body;
    await dbService.createContactMessage(name, email, subject, message);
    req.session.flash = { type: 'success', text: 'Thank you for your message. We will get back to you soon.' };
  } catch (err) {
    console.error('Contact post error:', err);
    req.session.flash = { type: 'error', text: 'Failed to send message.' };
  }
  res.redirect('/contact');
});

// Community
router.get('/community', async (req, res) => {
  try {
    const posts = await dbService.getCommunityPosts();
    res.render('community', {
      title: 'Community Forum',
      posts
    });
  } catch (err) {
    console.error('Community page error:', err);
    res.redirect('/');
  }
});

router.get('/community/:id', async (req, res) => {
  try {
    const post = await dbService.getCommunityPostById(req.params.id);
    if (!post) return res.status(404).render('404', { title: 'Post Not Found' });
    const replies = await dbService.getCommunityReplies(req.params.id);
    res.render('community-post', {
      title: post.title,
      post,
      replies
    });
  } catch (err) {
    console.error('Community post details error:', err);
    res.redirect('/community');
  }
});

router.post('/community/new', async (req, res) => {
  if (!req.session || !req.session.user) {
    req.session.flash = { type: 'error', text: 'Please log in to post.' };
    return res.redirect('/login');
  }
  try {
    const { title, content, category } = req.body;
    await dbService.createCommunityPost(req.session.user.id, title, content, category || 'General');
    req.session.flash = { type: 'success', text: 'Post created successfully.' };
  } catch (err) {
    console.error('Community new post error:', err);
    req.session.flash = { type: 'error', text: 'Failed to create post.' };
  }
  res.redirect('/community');
});

router.post('/community/:id/reply', async (req, res) => {
  if (!req.session || !req.session.user) {
    req.session.flash = { type: 'error', text: 'Please log in to reply.' };
    return res.redirect('/login');
  }
  try {
    const { content } = req.body;
    await dbService.createCommunityReply(req.params.id, req.session.user.id, content);
    req.session.flash = { type: 'success', text: 'Reply added.' };
  } catch (err) {
    console.error('Community new reply error:', err);
    req.session.flash = { type: 'error', text: 'Failed to add reply.' };
  }
  res.redirect('/community/' + req.params.id);
});

// Book Appointment
router.get('/book-appointment', async (req, res) => {
  try {
    const doctorsSnapshot = await dbService.db.collection('doctor_profiles').get();
    const doctors = [];
    for (const doc of doctorsSnapshot.docs) {
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
    
    let selectedDoc = null;
    const docId = req.query.doctor_id;
    if (docId) {
      selectedDoc = await dbService.getDoctorProfileById(docId);
    }
    
    res.render('book-appointment', {
      title: 'Book Appointment',
      doctors,
      selectedDoc,
      selectedDocId: docId || '',
      patientName: (req.session && req.session.user) ? req.session.user.full_name : ''
    });
  } catch (err) {
    console.error('Book appointment view error:', err);
    res.redirect('/');
  }
});

router.post('/book-appointment', async (req, res) => {
  try {
    const { doctor_id, patient_name, date, time_slot } = req.body;
    const docProfile = await dbService.getDoctorProfileById(doctor_id);
    if (!docProfile) {
      req.session.flash = { type: 'error', text: 'Doctor profile not found.' };
      return res.redirect('/book-appointment');
    }
    
    const u = await dbService.getUserById(docProfile.user_id);
    const doctor_name = u ? u.full_name : 'Doctor';
    
    const dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    const d = new Date(date);
    const day = dayNames[d.getDay()];
    
    const employer_id = req.session && req.session.user && req.session.user.role === 'employer' ? req.session.user.id : null;
    
    await dbService.createAppointment({
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
    
    req.session.flash = { type: 'success', text: 'Appointment booked successfully!' };
    res.redirect('/');
  } catch (err) {
    console.error('Book appointment post error:', err);
    req.session.flash = { type: 'error', text: 'Failed to book appointment.' };
    res.redirect('/book-appointment');
  }
});

// Suggest Best Doctor Search / Filter Page
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

    const locations = [
      'North Nazimabad',
      'Nazimabad',
      'FB Area',
      'Gulshan-e-Iqbal',
      'Gulistan-e-Johar',
      'PCHS',
      'Saddar',
      'Shah Faisal',
      'Shahrah-e-Faisal',
      'Malir'
    ];

    res.render('suggest-best-doctor', {
      title: 'Suggest Best Doctor',
      doctors,
      locations,
      selectedLocation
    });
  } catch (err) {
    console.error('Suggest best doctor view error:', err);
    res.redirect('/');
  }
});

module.exports = router;
