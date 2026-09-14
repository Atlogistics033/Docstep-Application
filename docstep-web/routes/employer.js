// Employer dashboard routes - direct Firebase Firestore
const express = require('express');
const router = express.Router();
const dbService = require('../db/dbService');
const { requireRole } = require('../middleware/auth');

router.use(requireRole('employer'));

async function profileFor(userId) {
  return await dbService.getEmployerProfileByUserId(userId);
}

router.get('/dashboard', async (req, res) => {
  try {
    const profile = await profileFor(req.session.user.id);
    if (!profile) {
      req.session.flash = { type: 'error', text: 'Employer profile not found.' };
      return res.redirect('/');
    }
    const jobs = await dbService.getEmployerJobs(profile.id);
    const appointments = await dbService.getAppointmentsByEmployer(req.session.user.id);
    const interviews = await dbService.getEmployerInterviews(profile.id);
    
    const stats = {
      jobs: jobs.length,
      open: jobs.filter(j => j.status === 'open').length,
      appointments: appointments.length,
      interviews: interviews.length,
    };
    
    res.render('employer/dashboard', { 
      title: 'Employer Dashboard', 
      profile, 
      jobs, 
      appointments: appointments.slice(0, 10), 
      interviews, 
      stats, 
      side: 'home' 
    });
  } catch (err) {
    console.error('Employer dashboard error:', err);
    res.redirect('/');
  }
});

router.get('/jobs', async (req, res) => {
  try {
    const profile = await profileFor(req.session.user.id);
    const jobs = await dbService.getEmployerJobs(profile.id);
    res.render('employer/jobs', { title: 'My Job Postings', jobs, side: 'jobs' });
  } catch (err) {
    console.error('Employer jobs page error:', err);
    res.redirect('/employer/dashboard');
  }
});

router.get('/jobs/new', (req, res) => {
  res.render('employer/post-job', { title: 'Post a New Job', job: null, side: 'jobs' });
});

router.post('/jobs/new', async (req, res) => {
  try {
    const profile = await profileFor(req.session.user.id);
    const { title, specialty, job_type, mode, city, salary_range, description, requirements } = req.body;
    
    await dbService.createJob(profile.id, {
      title,
      specialty,
      job_type,
      mode,
      city,
      salary_range,
      description,
      requirements
    });
    
    req.session.flash = { type: 'success', text: 'Job posted successfully.' };
    res.redirect('/employer/jobs');
  } catch (err) {
    console.error('Job post error:', err);
    req.session.flash = { type: 'error', text: 'Failed to post job.' };
    res.redirect('/employer/jobs');
  }
});

router.get('/jobs/:id/edit', async (req, res) => {
  try {
    const profile = await profileFor(req.session.user.id);
    const job = await dbService.getJobById(req.params.id);
    if (!job || job.employer_id !== profile.id) {
      return res.redirect('/employer/jobs');
    }
    res.render('employer/post-job', { title: 'Edit Job', job, side: 'jobs' });
  } catch (err) {
    console.error('Job edit view error:', err);
    res.redirect('/employer/jobs');
  }
});

router.post('/jobs/:id/edit', async (req, res) => {
  try {
    const profile = await profileFor(req.session.user.id);
    const { title, specialty, job_type, mode, city, salary_range, description, requirements, status } = req.body;
    
    // Check ownership
    const job = await dbService.getJobById(req.params.id);
    if (!job || job.employer_id !== profile.id) {
      return res.redirect('/employer/jobs');
    }
    
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
    
    req.session.flash = { type: 'success', text: 'Job updated.' };
    res.redirect('/employer/jobs');
  } catch (err) {
    console.error('Job update error:', err);
    req.session.flash = { type: 'error', text: 'Failed to update job.' };
    res.redirect('/employer/jobs');
  }
});

router.post('/jobs/:id/delete', async (req, res) => {
  try {
    const profile = await profileFor(req.session.user.id);
    const job = await dbService.getJobById(req.params.id);
    if (!job || job.employer_id !== profile.id) {
      return res.redirect('/employer/jobs');
    }
    
    await dbService.deleteJob(req.params.id, profile.id);
    req.session.flash = { type: 'success', text: 'Job removed.' };
    res.redirect('/employer/jobs');
  } catch (err) {
    console.error('Job delete error:', err);
    res.redirect('/employer/jobs');
  }
});

router.get('/candidates', async (req, res) => {
  try {
    const { q, specialty, city } = req.query;
    const candidates = await dbService.getCandidates({ q, specialty, city });
    const specialties = await dbService.getCandidatesDistinctSpecialties();
    const cities = await dbService.getCandidatesDistinctCities();
    
    res.render('employer/candidates', { 
      title: 'Search Candidates', 
      candidates, 
      specialties, 
      cities, 
      q: q || '', 
      selSpec: specialty || '', 
      selCity: city || '', 
      side: 'candidates' 
    });
  } catch (err) {
    console.error('Candidates list page error:', err);
    res.redirect('/employer/dashboard');
  }
});

router.get('/candidates/:id', async (req, res) => {
  try {
    const cand = await dbService.getCandidateDetail(req.params.id);
    if (!cand) return res.redirect('/employer/candidates');
    const creds = await dbService.getCredentials(cand.id);
    res.render('employer/candidate-detail', { title: cand.full_name, cand, creds, side: 'candidates' });
  } catch (err) {
    console.error('Candidate detail page error:', err);
    res.redirect('/employer/candidates');
  }
});

router.get('/appointments', async (req, res) => {
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

    res.render('employer/appointments', { 
      title: 'My Appointments', 
      appointments: list, 
      side: 'appointments',
      filter: filter || 'all',
      dateVal: dateVal || ''
    });
  } catch (err) {
    console.error('Employer appointments view error:', err);
    res.redirect('/employer/dashboard');
  }
});

router.post('/applications/:id/status', async (req, res) => {
  try {
    const { status } = req.body;
    await dbService.updateApplicationStatus(req.params.id, status);
    req.session.flash = { type: 'success', text: 'Application status updated.' };
    res.redirect(req.get('Referrer') || '/employer/applications');
  } catch (err) {
    console.error('Application status update error:', err);
    res.redirect('/employer/applications');
  }
});

router.post('/interviews/new', async (req, res) => {
  try {
    const { application_id, scheduled_at, mode, location, notes } = req.body;
    await dbService.createInterview({
      application_id,
      scheduled_at,
      mode,
      location,
      notes
    });
    
    req.session.flash = { type: 'success', text: 'Interview scheduled.' };
    res.redirect('/employer/interviews');
  } catch (err) {
    console.error('Interview schedule error:', err);
    req.session.flash = { type: 'error', text: 'Failed to schedule interview.' };
    res.redirect('/employer/interviews');
  }
});

router.get('/interviews', async (req, res) => {
  try {
    const profile = await profileFor(req.session.user.id);
    const interviews = await dbService.getEmployerInterviews(profile.id);
    
    // Get pending or shortlisted applications to schedule new interviews
    const allPendingApps = await dbService.getEmployerApplications(profile.id);
    const pendingApps = allPendingApps.filter(a => ['pending', 'shortlisted'].includes(a.status));
    
    res.render('employer/interviews', { 
      title: 'Interviews', 
      interviews, 
      pendingApps, 
      side: 'interviews' 
    });
  } catch (err) {
    console.error('Interviews view error:', err);
    res.redirect('/employer/dashboard');
  }
});

router.get('/profile', async (req, res) => {
  try {
    const profile = await profileFor(req.session.user.id);
    res.render('employer/profile', { title: 'Organization Profile', profile, side: 'profile' });
  } catch (err) {
    console.error('Profile view error:', err);
    res.redirect('/employer/dashboard');
  }
});

router.post('/profile', async (req, res) => {
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
    req.session.flash = { type: 'success', text: 'Organization profile updated.' };
    res.redirect('/employer/profile');
  } catch (err) {
    console.error('Employer profile save error:', err);
    req.session.flash = { type: 'error', text: 'Failed to update profile.' };
    res.redirect('/employer/profile');
  }
});

module.exports = router;
