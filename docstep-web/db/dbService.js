const admin = require('firebase-admin');
const { getFirestore } = require('firebase-admin/firestore');
const { getAuth } = require('firebase-admin/auth');
const path = require('path');

// Initialize Firebase Admin SDK
if (admin.getApps().length === 0) {
  const serviceAccount = require(path.join(__dirname, '..', 'firebase-key.json'));
  admin.initializeApp({
    credential: admin.cert(serviceAccount)
  });
}

const db = getFirestore();
const auth = getAuth();

// -------------------------------------------------------------
// Users collection queries
// -------------------------------------------------------------
async function getUserCount() {
  try {
    const snapshot = await db.collection('users').count().get();
    return snapshot.data().count;
  } catch (err) {
    console.error('getUserCount error:', err);
    return 0;
  }
}

async function createUser(email, password_hash, role, full_name, phone, plaintextPassword = null) {
  let uid = null;
  
  if (plaintextPassword) {
    try {
      const userRecord = await auth.createUser({
        email,
        password: plaintextPassword,
        displayName: full_name
      });
      uid = userRecord.uid;
    } catch (authErr) {
      console.error('Firebase Auth user creation failed:', authErr);
      throw authErr;
    }
  }

  const userData = {
    email,
    password_hash,
    role,
    full_name,
    phone: phone || null,
    created_at: new Date().toISOString()
  };

  if (uid) {
    await db.collection('users').doc(uid).set(userData);
    return uid;
  } else {
    const docRef = await db.collection('users').add(userData);
    return docRef.id;
  }
}

async function getUserByEmail(email) {
  const snapshot = await db.collection('users').where('email', '==', email).limit(1).get();
  if (snapshot.empty) return null;
  const doc = snapshot.docs[0];
  return { id: doc.id, ...doc.data() };
}

async function getUserById(id) {
  const doc = await db.collection('users').doc(id).get();
  if (!doc.exists) return null;
  return { id: doc.id, ...doc.data() };
}

async function updateUser(id, full_name, phone) {
  await db.collection('users').doc(id).update({
    full_name,
    phone: phone || null
  });
}

// -------------------------------------------------------------
// Doctor Profiles
// -------------------------------------------------------------
async function createDoctorProfile(profileData) {
  const docRef = await db.collection('doctor_profiles').add({
    user_id: profileData.user_id,
    specialty: profileData.specialty || 'General Practice',
    experience_years: Number(profileData.experience_years) || 0,
    pmdc_number: profileData.pmdc_number || '',
    pmdc_verified: Number(profileData.pmdc_verified) || 0,
    bio: profileData.bio || '',
    city: profileData.city || '',
    languages: profileData.languages || '',
    qualifications: profileData.qualifications || '',
    availability: profileData.availability || 'Flexible',
    hourly_rate: Number(profileData.hourly_rate) || 0,
    open_to_remote: Number(profileData.open_to_remote) || 0,
    cv_summary: profileData.cv_summary || '',
    cv_skills: profileData.cv_skills || '',
    cv_experience: profileData.cv_experience || '',
    cv_education: profileData.cv_education || '',
    cv_certifications: profileData.cv_certifications || '',
    profile_image: profileData.profile_image || null,
    clinic_name: profileData.clinic_name || '',
    clinic_address: profileData.clinic_address || '',
    clinic_hospital_address: profileData.clinic_hospital_address || ''
  });
  return docRef.id;
}

async function getDoctorProfileByUserId(userId) {
  let snapshot = await db.collection('doctor_profiles').where('user_id', '==', userId).limit(1).get();
  if (snapshot.empty) {
    snapshot = await db.collection('doctor_profiles').where('userId', '==', userId).limit(1).get();
  }
  if (snapshot.empty) {
    const u = await getUserById(userId);
    if (u && u.role === 'doctor') {
      console.log(`[DocStep] Dynamic doctor profile creation for user: ${userId}`);
      await createDoctorProfile({
        user_id: userId,
        specialty: 'General Practice',
        city: '',
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
        cv_certifications: '',
        clinic_name: '',
        clinic_address: '',
        clinic_hospital_address: ''
      });
      return await getDoctorProfileByUserId(userId);
    }
    return null;
  }
  const doc = snapshot.docs[0];
  if (!doc.exists) return null;
  const profileData = doc.data();
  const u = await getUserById(userId);
  return {
    id: doc.id,
    ...profileData,
    user_id: profileData.user_id || profileData.userId || userId,
    userId: profileData.userId || profileData.user_id || userId,
    full_name: u ? u.full_name : '',
    email: u ? u.email : '',
    phone: u ? u.phone : ''
  };
}

async function getDoctorProfileById(id) {
  const doc = await db.collection('doctor_profiles').doc(id).get();
  if (!doc.exists) return null;
  const profileData = doc.data();
  const u = await getUserById(profileData.user_id || profileData.userId);
  return {
    id: doc.id,
    ...profileData,
    user_id: profileData.user_id || profileData.userId,
    userId: profileData.userId || profileData.user_id,
    full_name: u ? u.full_name : '',
    email: u ? u.email : '',
    phone: u ? u.phone : ''
  };
}

async function updateDoctorProfile(userId, profileData) {
  const profile = await getDoctorProfileByUserId(userId);
  if (!profile) throw new Error('Doctor profile not found.');
  
  const cleanData = {};
  const fields = [
    'specialty', 'experience_years', 'pmdc_number', 'bio', 'city',
    'languages', 'qualifications', 'availability', 'hourly_rate', 'open_to_remote',
    'clinic_name', 'clinic_address', 'clinic_hospital_address'
  ];
  fields.forEach(f => {
    if (profileData[f] !== undefined) {
      if (['experience_years', 'hourly_rate', 'open_to_remote'].includes(f)) {
        cleanData[f] = Number(profileData[f]) || 0;
      } else {
        cleanData[f] = profileData[f];
      }
    }
  });
  await db.collection('doctor_profiles').doc(profile.id).update(cleanData);
}

async function getRegisteredDoctors() {
  const snapshot = await db.collection('doctor_profiles').get();
  const doctors = [];
  for (const doc of snapshot.docs) {
    const data = doc.data();
    const u = await getUserById(data.user_id || data.userId);
    if (u && u.role === 'doctor') {
      doctors.push({
        id: doc.id,
        ...data,
        user_id: data.user_id || data.userId,
        userId: data.userId || data.user_id,
        full_name: u.full_name,
        email: u.email,
        phone: u.phone
      });
    }
  }
  return doctors;
}

async function updateDoctorCv(userId, cvData) {
  const profile = await getDoctorProfileByUserId(userId);
  if (!profile) throw new Error('Doctor profile not found.');
  const cleanData = {};
  const fields = ['cv_summary', 'cv_skills', 'cv_experience', 'cv_education', 'cv_certifications'];
  fields.forEach(f => {
    if (cvData[f] !== undefined) cleanData[f] = cvData[f];
  });
  await db.collection('doctor_profiles').doc(profile.id).update(cleanData);
}

async function updateDoctorAvailability(userId, data) {
  const profile = await getDoctorProfileByUserId(userId);
  if (!profile) throw new Error('Doctor profile not found.');
  const updateData = {};
  if (data.availability !== undefined) updateData.availability = data.availability;
  if (data.open_to_remote !== undefined) updateData.open_to_remote = Number(data.open_to_remote) || 0;
  if (data.hourly_rate !== undefined) updateData.hourly_rate = Number(data.hourly_rate) || 0;
  await db.collection('doctor_profiles').doc(profile.id).update(updateData);
}

// -------------------------------------------------------------
// Employer Profiles
// -------------------------------------------------------------
async function createEmployerProfile(profileData) {
  const docRef = await db.collection('employer_profiles').add({
    user_id: profileData.user_id,
    organization_name: profileData.organization_name || '',
    organization_type: profileData.organization_type || '',
    city: profileData.city || '',
    website: profileData.website || '',
    about: profileData.about || '',
    logo: profileData.logo || null
  });
  return docRef.id;
}

async function getEmployerProfileByUserId(userId) {
  let snapshot = await db.collection('employer_profiles').where('user_id', '==', userId).limit(1).get();
  if (snapshot.empty) {
    snapshot = await db.collection('employer_profiles').where('userId', '==', userId).limit(1).get();
  }
  if (snapshot.empty) {
    const u = await getUserById(userId);
    if (u && u.role === 'employer') {
      console.log(`[DocStep] Dynamic employer profile creation for user: ${userId}`);
      await createEmployerProfile({
        user_id: userId,
        organization_name: 'My Organization',
        city: '',
        organization_type: '',
        website: '',
        about: '',
        logo: null
      });
      let newSnap = await db.collection('employer_profiles').where('user_id', '==', userId).limit(1).get();
      if (newSnap.empty) {
        newSnap = await db.collection('employer_profiles').where('userId', '==', userId).limit(1).get();
      }
      if (!newSnap.empty) {
        const doc = newSnap.docs[0];
        return {
          id: doc.id,
          ...doc.data(),
          user_id: doc.data().user_id || doc.data().userId || userId,
          userId: doc.data().userId || doc.data().user_id || userId,
          full_name: u.full_name,
          email: u.email,
          phone: u.phone
        };
      }
    }
    return null;
  }
  const doc = snapshot.docs[0];
  const profileData = doc.data();
  const u = await getUserById(userId);
  return {
    id: doc.id,
    ...profileData,
    user_id: profileData.user_id || profileData.userId || userId,
    userId: profileData.userId || profileData.user_id || userId,
    full_name: u ? u.full_name : '',
    email: u ? u.email : '',
    phone: u ? u.phone : ''
  };
}

async function getEmployerProfileById(id) {
  const doc = await db.collection('employer_profiles').doc(id).get();
  if (!doc.exists) return null;
  const profileData = doc.data();
  const u = await getUserById(profileData.user_id || profileData.userId);
  return {
    id: doc.id,
    ...profileData,
    user_id: profileData.user_id || profileData.userId,
    userId: profileData.userId || profileData.user_id,
    full_name: u ? u.full_name : '',
    email: u ? u.email : '',
    phone: u ? u.phone : ''
  };
}

async function updateEmployerProfile(userId, data) {
  const profile = await getEmployerProfileByUserId(userId);
  if (!profile) throw new Error('Employer profile not found.');
  const cleanData = {};
  const fields = ['organization_name', 'organization_type', 'city', 'website', 'about', 'logo'];
  fields.forEach(f => {
    if (data[f] !== undefined) cleanData[f] = data[f];
  });
  await db.collection('employer_profiles').doc(profile.id).update(cleanData);
}

// -------------------------------------------------------------
// Jobs
// -------------------------------------------------------------
async function createJob(employerProfileId, jobData) {
  const docRef = await db.collection('jobs').add({
    employer_id: employerProfileId,
    title: jobData.title,
    specialty: jobData.specialty,
    job_type: jobData.job_type || 'Full-time',
    mode: jobData.mode || 'Remote',
    city: jobData.city || '',
    salary_range: jobData.salary_range || 'Negotiable',
    description: jobData.description,
    requirements: jobData.requirements || '',
    posted_at: new Date().toISOString(),
    status: jobData.status || 'open'
  });
  return docRef.id;
}

async function getJobs(filters = {}) {
  let query = db.collection('jobs');
  const snapshot = await query.get();
  let jobs = [];
  for (const doc of snapshot.docs) {
    const data = doc.data();
    const emp = await getEmployerProfileById(data.employer_id);
    jobs.push({
      id: doc.id,
      ...data,
      organization_name: emp ? emp.organization_name : 'DocStep Partner',
      organization_logo: emp ? emp.logo : null
    });
  }
  
  if (filters.specialty) {
    jobs = jobs.filter(j => j.specialty.toLowerCase() === filters.specialty.toLowerCase());
  }
  if (filters.mode) {
    jobs = jobs.filter(j => j.mode.toLowerCase() === filters.mode.toLowerCase());
  }
  if (filters.q) {
    const term = filters.q.toLowerCase();
    jobs = jobs.filter(j => 
      j.title.toLowerCase().includes(term) || 
      j.description.toLowerCase().includes(term) ||
      j.organization_name.toLowerCase().includes(term)
    );
  }
  
  jobs.sort((a, b) => {
    if (a.status === 'open' && b.status !== 'open') return -1;
    if (a.status !== 'open' && b.status === 'open') return 1;
    return new Date(b.posted_at) - new Date(a.posted_at);
  });
  return jobs;
}

async function getJobById(id) {
  const doc = await db.collection('jobs').doc(id).get();
  if (!doc.exists) return null;
  const data = doc.data();
  const emp = await getEmployerProfileById(data.employer_id);
  return {
    id: doc.id,
    ...data,
    organization_name: emp ? emp.organization_name : 'DocStep Partner',
    organization_logo: emp ? emp.logo : null,
    organization_about: emp ? emp.about : '',
    organization_phone: emp ? emp.phone : ''
  };
}

async function getEmployerJobs(employerId) {
  const snapshot = await db.collection('jobs').where('employer_id', '==', employerId).get();
  const jobs = [];
  for (const doc of snapshot.docs) {
    jobs.push({ id: doc.id, ...doc.data() });
  }
  jobs.sort((a, b) => new Date(b.posted_at) - new Date(a.posted_at));
  return jobs;
}

async function updateJob(id, employerId, jobData) {
  const docRef = db.collection('jobs').doc(id);
  const doc = await docRef.get();
  if (!doc.exists || doc.data().employer_id !== employerId) {
    throw new Error('Not authorized to update this job.');
  }
  const cleanData = {};
  const fields = ['title', 'specialty', 'job_type', 'mode', 'city', 'salary_range', 'description', 'requirements', 'status'];
  fields.forEach(f => {
    if (jobData[f] !== undefined) cleanData[f] = jobData[f];
  });
  await docRef.update(cleanData);
}

async function deleteJob(id, employerId) {
  const docRef = db.collection('jobs').doc(id);
  const doc = await docRef.get();
  if (!doc.exists || doc.data().employer_id !== employerId) {
    throw new Error('Not authorized to delete this job.');
  }
  await docRef.delete();
}

async function getRelatedJobs(specialty, currentJobId) {
  const allJobs = await getJobs({ specialty });
  return allJobs.filter(j => j.id !== currentJobId && j.status === 'open').slice(0, 3);
}

async function getJobsDistinctSpecialties() {
  const snapshot = await db.collection('jobs').get();
  const specs = new Set();
  snapshot.forEach(doc => {
    if (doc.data().specialty) specs.add(doc.data().specialty);
  });
  return Array.from(specs).sort();
}

async function getJobsDistinctModes() {
  const snapshot = await db.collection('jobs').get();
  const modes = new Set();
  snapshot.forEach(doc => {
    if (doc.data().mode) modes.add(doc.data().mode);
  });
  return Array.from(modes).sort();
}

// -------------------------------------------------------------
// Applications
// -------------------------------------------------------------
async function createApplication(jobId, doctorProfileId, coverLetter) {
  const existing = await db.collection('applications')
    .where('job_id', '==', jobId)
    .where('doctor_id', '==', doctorProfileId)
    .get();
  if (!existing.empty) {
    throw new Error('Already applied to this job.');
  }
  
  const docRef = await db.collection('applications').add({
    job_id: jobId,
    doctor_id: doctorProfileId,
    cover_letter: coverLetter || '',
    status: 'pending',
    applied_at: new Date().toISOString()
  });
  return docRef.id;
}

async function getApplicationsByDoctor(doctorProfileId) {
  const snapshot = await db.collection('applications').where('doctor_id', '==', doctorProfileId).get();
  const apps = [];
  for (const doc of snapshot.docs) {
    const data = doc.data();
    const job = await getJobById(data.job_id);
    apps.push({
      id: doc.id,
      ...data,
      job_title: job ? job.title : 'Deleted Position',
      organization_name: job ? job.organization_name : 'DocStep Partner'
    });
  }
  apps.sort((a, b) => new Date(b.applied_at) - new Date(a.applied_at));
  return apps;
}

async function getEmployerApplications(employerProfileId) {
  const employerJobs = await getEmployerJobs(employerProfileId);
  const jobIds = employerJobs.map(j => j.id);
  if (jobIds.length === 0) return [];
  
  const snapshot = await db.collection('applications').get();
  const apps = [];
  for (const doc of snapshot.docs) {
    const data = doc.data();
    if (jobIds.includes(data.job_id)) {
      const doctor = await getDoctorProfileById(data.doctor_id);
      const job = employerJobs.find(j => j.id === data.job_id);
      apps.push({
        id: doc.id,
        ...data,
        job_title: job ? job.title : 'Unknown Job',
        candidate_name: doctor ? doctor.full_name : 'Doctor',
        candidate_specialty: doctor ? doctor.specialty : 'General Practice',
        candidate_city: doctor ? doctor.city : 'Karachi'
      });
    }
  }
  apps.sort((a, b) => new Date(b.applied_at) - new Date(a.applied_at));
  return apps;
}

async function updateApplicationStatus(applicationId, status) {
  await db.collection('applications').doc(applicationId).update({ status });
}

async function hasDoctorApplied(jobId, doctorProfileId) {
  const snap = await db.collection('applications')
    .where('job_id', '==', jobId)
    .where('doctor_id', '==', doctorProfileId)
    .limit(1)
    .get();
  return !snap.empty;
}

// -------------------------------------------------------------
// Interviews
// -------------------------------------------------------------
async function createInterview(interviewData) {
  const docRef = await db.collection('interviews').add({
    application_id: interviewData.application_id,
    scheduled_at: interviewData.scheduled_at,
    mode: interviewData.mode,
    location: interviewData.location || '',
    notes: interviewData.notes || '',
    status: 'scheduled'
  });
  return docRef.id;
}

async function getInterviewsByDoctor(doctorProfileId) {
  const appsSnapshot = await db.collection('applications').where('doctor_id', '==', doctorProfileId).get();
  const appIds = [];
  const appMap = {};
  appsSnapshot.forEach(doc => {
    appIds.push(doc.id);
    appMap[doc.id] = doc.data();
  });
  if (appIds.length === 0) return [];
  
  const interviewsSnapshot = await db.collection('interviews').get();
  const interviews = [];
  for (const doc of interviewsSnapshot.docs) {
    const data = doc.data();
    if (appIds.includes(data.application_id)) {
      const app = appMap[data.application_id];
      const job = await getJobById(app.job_id);
      interviews.push({
        id: doc.id,
        ...data,
        job_title: job ? job.title : 'Job Posting',
        organization_name: job ? job.organization_name : 'DocStep Partner'
      });
    }
  }
  return interviews;
}

async function getEmployerInterviews(employerProfileId) {
  const apps = await getEmployerApplications(employerProfileId);
  const appIds = apps.map(a => a.id);
  if (appIds.length === 0) return [];
  
  const interviewsSnapshot = await db.collection('interviews').get();
  const interviews = [];
  for (const doc of interviewsSnapshot.docs) {
    const data = doc.data();
    if (appIds.includes(data.application_id)) {
      const app = apps.find(a => a.id === data.application_id);
      interviews.push({
        id: doc.id,
        ...data,
        job_title: app.job_title,
        candidate_name: app.candidate_name
      });
    }
  }
  return interviews;
}

// -------------------------------------------------------------
// Credentials
// -------------------------------------------------------------
async function getCredentials(doctorProfileId) {
  // Find user_id associated with this doctor profile
  let userId = null;
  const docProfile = await db.collection('doctor_profiles').doc(doctorProfileId).get();
  if (docProfile.exists) {
    userId = docProfile.data().user_id;
  } else {
    // If doctorProfileId is actually a user ID, find the profile ID
    const snap = await db.collection('doctor_profiles').where('user_id', '==', doctorProfileId).limit(1).get();
    if (!snap.empty) {
      userId = doctorProfileId;
      doctorProfileId = snap.docs[0].id;
    }
  }

  // Fetch all credentials and filter in-memory
  const snapshot = await db.collection('credentials').get();
  const creds = [];
  snapshot.forEach(doc => {
    const data = doc.data();
    if (
      data.doctor_id === doctorProfileId || 
      (userId && data.doctor_id === userId) || 
      data.doctorProfileId === doctorProfileId || 
      (userId && data.doctorId === userId)
    ) {
      creds.push({ id: doc.id, ...data });
    }
  });
  creds.sort((a, b) => new Date(b.uploaded_at) - new Date(a.uploaded_at));
  return creds;
}

async function createCredential(doctorProfileId, credentialData) {
  const docRef = await db.collection('credentials').add({
    doctor_id: doctorProfileId,
    cred_type: credentialData.cred_type,
    title: credentialData.title,
    file_path: credentialData.file_path || null,
    verified: 0,
    uploaded_at: new Date().toISOString()
  });
  return docRef.id;
}

async function deleteCredential(id, doctorProfileId) {
  const docRef = db.collection('credentials').doc(id);
  const doc = await docRef.get();
  if (!doc.exists) return;
  
  const data = doc.data();
  // Resolve user_id associated with this doctor profile
  let userId = null;
  const docProfile = await db.collection('doctor_profiles').doc(doctorProfileId).get();
  if (docProfile.exists) {
    userId = docProfile.data().user_id;
  }
  
  const matchesDoctor = (
    data.doctor_id === doctorProfileId || 
    (userId && data.doctor_id === userId) ||
    data.doctorProfileId === doctorProfileId ||
    (userId && data.doctorId === userId)
  );
  
  if (doctorProfileId && !matchesDoctor) {
    throw new Error('Not authorized to delete this credential.');
  }
  await docRef.delete();
}

// -------------------------------------------------------------
// Candidates
// -------------------------------------------------------------
async function getCandidates(filters = {}) {
  const snapshot = await db.collection('doctor_profiles').get();
  let candidates = [];
  for (const doc of snapshot.docs) {
    const data = doc.data();
    const u = await getUserById(data.user_id);
    if (u) {
      candidates.push({
        id: doc.id,
        ...data,
        full_name: u.full_name,
        email: u.email,
        phone: u.phone
      });
    }
  }
  
  if (filters.specialty) {
    candidates = candidates.filter(c => c.specialty.toLowerCase() === filters.specialty.toLowerCase());
  }
  if (filters.city) {
    candidates = candidates.filter(c => c.city.toLowerCase() === filters.city.toLowerCase());
  }
  if (filters.q) {
    const term = filters.q.toLowerCase();
    candidates = candidates.filter(c => 
      c.full_name.toLowerCase().includes(term) || 
      c.bio.toLowerCase().includes(term) ||
      c.qualifications.toLowerCase().includes(term)
    );
  }
  
  return candidates;
}

async function getCandidatesDistinctSpecialties() {
  const snapshot = await db.collection('doctor_profiles').get();
  const specs = new Set();
  snapshot.forEach(doc => {
    if (doc.data().specialty) specs.add(doc.data().specialty);
  });
  return Array.from(specs).sort();
}

async function getCandidatesDistinctCities() {
  const snapshot = await db.collection('doctor_profiles').get();
  const cities = new Set();
  snapshot.forEach(doc => {
    if (doc.data().city) cities.add(doc.data().city);
  });
  return Array.from(cities).sort();
}

async function getCandidateDetail(id) {
  return await getDoctorProfileById(id);
}

// -------------------------------------------------------------
// Admin & Portal Stats
// -------------------------------------------------------------
async function getStats() {
  const doctorsSnap = await db.collection('doctor_profiles').get();
  const jobsSnap = await db.collection('jobs').get();
  const employersSnap = await db.collection('employer_profiles').get();
  
  return {
    doctors: doctorsSnap.size,
    jobs: jobsSnap.size,
    employers: employersSnap.size
  };
}

async function getUnverifiedDoctors() {
  const snapshot = await db.collection('doctor_profiles').where('pmdc_verified', '==', 0).get();
  const docs = [];
  for (const doc of snapshot.docs) {
    const data = doc.data();
    const u = await getUserById(data.user_id);
    if (u) {
      docs.push({
        id: doc.id,
        ...data,
        full_name: u.full_name,
        email: u.email
      });
    }
  }
  return docs;
}

async function getUnverifiedCredentials() {
  const snapshot = await db.collection('credentials').where('verified', '==', 0).get();
  const creds = [];
  for (const doc of snapshot.docs) {
    const data = doc.data();
    const doctor = await getDoctorProfileById(data.doctor_id);
    creds.push({
      id: doc.id,
      ...data,
      doctor_name: doctor ? doctor.full_name : 'Doctor'
    });
  }
  return creds;
}

async function getContactMessages() {
  const snapshot = await db.collection('contact_messages').get();
  const msgs = [];
  snapshot.forEach(doc => {
    msgs.push({ id: doc.id, ...doc.data() });
  });
  msgs.sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
  return msgs;
}

async function verifyPmdc(id) {
  await db.collection('doctor_profiles').doc(id).update({ pmdc_verified: 1 });
}

async function verifyCredential(id) {
  await db.collection('credentials').doc(id).update({ verified: 1 });
}

async function createContactMessage(name, email, subject, message) {
  await db.collection('contact_messages').add({
    name,
    email,
    subject: subject || 'No Subject',
    message,
    created_at: new Date().toISOString()
  });
}

// -------------------------------------------------------------
// Courses & Success Stories
// -------------------------------------------------------------
async function getSuccessStories() {
  const snapshot = await db.collection('success_stories').get();
  const stories = [];
  snapshot.forEach(doc => {
    stories.push({ id: doc.id, ...doc.data() });
  });
  return stories;
}

const https = require('https');

const specialtyImages = {
  'General Practice': 'https://images.unsplash.com/photo-1576091160550-2173dba999ef?auto=format&fit=crop&w=600&q=80',
  'Gynecology': 'https://images.unsplash.com/photo-1551244072-5d12893278ab?auto=format&fit=crop&w=600&q=80',
  'Pediatrics': 'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?auto=format&fit=crop&w=600&q=80',
  'Psychiatry': 'https://images.unsplash.com/photo-1527137341206-1a0bd81d9d86?auto=format&fit=crop&w=600&q=80',
  'Dermatology': 'https://images.unsplash.com/photo-1512290923902-8a9f81dc236c?auto=format&fit=crop&w=600&q=80',
  'Internal Medicine': 'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?auto=format&fit=crop&w=600&q=80',
  'Cardiology': 'https://images.unsplash.com/photo-1559757175-5700dde675bc?auto=format&fit=crop&w=600&q=80',
  'Other': 'https://images.unsplash.com/photo-1582718980780-be8b49ca91c9?auto=format&fit=crop&w=600&q=80'
};

async function generateCoursesFromGemini() {
  const apiKey = 'Enter your Gemini API key here';


  const prompt = `Pass the list of our specific Primary Specialties (General Practice, Gynecology, Pediatrics, Psychiatry, Dermatology, Internal Medicine, Cardiology, Other) and dynamically return a clean JSON array containing at least 4 realistic medical courses for each specialty.
Each course object generated must include:
- title: string
- specialty: string (must be one of the provided list: General Practice, Gynecology, Pediatrics, Psychiatry, Dermatology, Internal Medicine, Cardiology, Other)
- instructor: string (e.g., "Dr. Aruna Chandran")
- duration: string (e.g., "15h" or "15 hours")
- lecturesCount: number

Return the output as a valid JSON array directly. Do not wrap it in markdown formatting like \`\`\`json.`;

  const payload = JSON.stringify({
    contents: [{
      parts: [{
        text: prompt
      }]
    }],
    generationConfig: {
      responseMimeType: "application/json"
    }
  });

  return new Promise((resolve, reject) => {
    const options = {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      }
    };

    const req = https.request(url, options, (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        if (res.statusCode !== 200) {
          return reject(new Error(`Gemini API returned status ${res.statusCode}: ${data}`));
        }
        try {
          const parsed = JSON.parse(data);
          const text = parsed.candidates[0].content.parts[0].text;
          const courses = JSON.parse(text);
          resolve(courses);
        } catch (err) {
          reject(err);
        }
      });
    });

    req.on('error', (e) => {
      reject(e);
    });

    req.write(payload);
    req.end();
  });
}

async function getCourses(forceRefresh = false) {
  try {
    const coursesCol = db.collection('courses');
    
    if (!forceRefresh) {
      const snapshot = await coursesCol.get();
      if (!snapshot.empty) {
        const courses = [];
        snapshot.forEach(doc => {
          courses.push({ id: doc.id, ...doc.data() });
        });
        return courses;
      }
    }
    
    console.log('[DocStep] Generating courses from Google Gemini API...');
    const generatedCourses = await generateCoursesFromGemini();
    
    if (Array.isArray(generatedCourses) && generatedCourses.length > 0) {
      // Clear existing courses first
      const snapshot = await coursesCol.get();
      const batch = db.batch();
      snapshot.docs.forEach(doc => {
        batch.delete(doc.ref);
      });
      await batch.commit();
      
      // Seed newly generated courses
      const addPromises = generatedCourses.map(course => {
        const matchingCatalogCourse = realCoursesCatalog.find(c => 
          c.title.toLowerCase().trim() === (course.title || '').toLowerCase().trim()
        );
        
        let instructor = course.instructor || 'Dr. Aruna Chandran';
        let provider = course.provider || 'DocStep Academy';
        let level = course.level || 'Intermediate';
        let price = course.price || 'Free';
        let description = course.description;

        if (matchingCatalogCourse) {
          instructor = matchingCatalogCourse.instructor;
          provider = matchingCatalogCourse.provider;
          level = matchingCatalogCourse.level;
          price = matchingCatalogCourse.price;
          description = matchingCatalogCourse.description;
        }

        if (instructor.toLowerCase().includes('taha')) {
          instructor = 'Dr. Aruna Chandran';
        }

        const cleanCourse = {
          title: course.title || 'Untitled Course',
          specialty: course.specialty || 'General Practice',
          instructor: instructor,
          duration: course.duration || '10 hours',
          duration_hours: parseFloat((course.duration || '').replace(/[^0-9.]/g, '')) || 10,
          lecturesCount: Number(course.lecturesCount) || 12,
          lectures_count: Number(course.lecturesCount) || 12,
          description: description || `Comprehensive guide and training course covering key topics in ${course.specialty || 'medicine'}.`,
          level: level,
          price: price,
          provider: provider,
          enrolled_count: course.enrolled_count || Math.floor(Math.random() * 1000) + 100,
          image: specialtyImages[course.specialty] || specialtyImages['Other'],
          created_at: new Date().toISOString()
        };
        return coursesCol.add(cleanCourse);
      });
      
      await Promise.all(addPromises);
      console.log(`[DocStep] Successfully generated and cached ${generatedCourses.length} courses from Gemini API.`);
      
      // Fetch and return the newly saved courses
      const newSnapshot = await coursesCol.get();
      const courses = [];
      newSnapshot.forEach(doc => {
        courses.push({ id: doc.id, ...doc.data() });
      });
      return courses;
    } else {
      console.error('[DocStep] Invalid courses format returned from Gemini:', generatedCourses);
      return [];
    }
  } catch (err) {
    console.error('getCourses error:', err);
    try {
      const snapshot = await db.collection('courses').get();
      const courses = [];
      snapshot.forEach(doc => {
        courses.push({ id: doc.id, ...doc.data() });
      });
      return courses;
    } catch (dbErr) {
      return [];
    }
  }
}

const realCoursesCatalog = [
  {
    "title": "Epidemiology in Public Health Practice",
    "specialty": "General Practice",
    "instructor": "Dr. Aruna Chandran",
    "lecturesCount": 15,
    "description": "Master the core principles of epidemiology and how they apply to everyday clinical and family practice.",
    "website": "https://www.coursera.org/learn/epidemiology-public-health-practice",
    "provider": "Johns Hopkins University",
    "level": "Intermediate",
    "price": "Free"
  },
  {
    "title": "Instructional Methods in Health Professions Education",
    "specialty": "General Practice",
    "instructor": "Dr. Sarah Jenkins",
    "lecturesCount": 18,
    "description": "Learn modern instructional design and clinical education methods for teaching junior doctors.",
    "website": "https://www.coursera.org/learn/instructional-methods-education",
    "provider": "University of Michigan",
    "level": "Intermediate",
    "price": "Free"
  },
  {
    "title": "Systems Science and Obesity",
    "specialty": "General Practice",
    "instructor": "Dr. Lisa Vance",
    "lecturesCount": 12,
    "description": "Understand systemic obesity prevention, lifestyle management, and therapeutic interventions in primary care.",
    "website": "https://www.coursera.org/learn/systems-science-obesity",
    "provider": "Johns Hopkins University",
    "level": "Intermediate",
    "price": "Free"
  },
  {
    "title": "Preventing Chronic Pain: A Human Systems Approach",
    "specialty": "General Practice",
    "instructor": "Dr. Rebecca Carter",
    "lecturesCount": 14,
    "description": "A comprehensive multidisciplinary approach to pain assessment, prevention, and non-pharmacological therapies.",
    "website": "https://www.coursera.org/learn/chronic-pain",
    "provider": "University of Minnesota",
    "level": "Advanced",
    "price": "Free"
  },
  {
    "title": "Introduction to Reproduction",
    "specialty": "Gynecology",
    "instructor": "Dr. Fatima Al-Hassan",
    "lecturesCount": 16,
    "description": "A deep dive into reproductive biology, endocrine feedback loops, and clinical applications in gynecology.",
    "website": "https://www.coursera.org/learn/reproductive-health",
    "provider": "Northwestern University",
    "level": "Beginner",
    "price": "Free"
  },
  {
    "title": "International Women's Health and Human Rights",
    "specialty": "Gynecology",
    "instructor": "Dr. Arifa Siddiqui",
    "lecturesCount": 20,
    "description": "Explore major global women's health issues, maternal mortality, reproductive rights, and health equity.",
    "website": "https://www.coursera.org/learn/womens-health-human-rights",
    "provider": "Stanford University",
    "level": "Beginner",
    "price": "Free"
  },
  {
    "title": "The Emergence of Oncofertility",
    "specialty": "Gynecology",
    "instructor": "Dr. Julia Vance",
    "lecturesCount": 12,
    "description": "An emerging field at the intersection of oncology and reproductive endocrinology to preserve fertility options.",
    "website": "https://www.coursera.org/learn/oncofertility-overview",
    "provider": "Northwestern University",
    "level": "Advanced",
    "price": "Free"
  },
  {
    "title": "Introduction to Breast Cancer",
    "specialty": "Gynecology",
    "instructor": "Dr. Maryam Khan",
    "lecturesCount": 15,
    "description": "A clinical overview of breast cancer screening, diagnostic pathology, staging, and modern treatment regimens.",
    "website": "https://www.coursera.org/learn/breast-cancer-causes-prevention",
    "provider": "Yale University",
    "level": "Intermediate",
    "price": "Free"
  },
  {
    "title": "Child Nutrition and Health",
    "specialty": "Pediatrics",
    "instructor": "Dr. Ayesha Malik",
    "lecturesCount": 14,
    "description": "Understand pediatric dietary needs, healthy child nutrition, and management of early childhood feeding disorders.",
    "website": "https://www.coursera.org/learn/child-nutrition-and-health",
    "provider": "Stanford University",
    "level": "Beginner",
    "price": "Free"
  },
  {
    "title": "Preventative Healthcare for the Newborn Baby",
    "specialty": "Pediatrics",
    "instructor": "Dr. Zainab Sheikh",
    "lecturesCount": 16,
    "description": "Guidelines on newborn assessment, neonatal screening, early feeding, and preventive care in pediatric practice.",
    "website": "https://www.coursera.org/learn/global-quality-maternal-and-newborn-care",
    "provider": "University of Colorado System",
    "level": "Intermediate",
    "price": "Free"
  },
  {
    "title": "Health Care and Promotion for Infants and Toddlers",
    "specialty": "Pediatrics",
    "instructor": "Dr. Kiran Bashir",
    "lecturesCount": 18,
    "description": "Growth monitoring, developmental screening, immunization schedules, and infant illness prevention protocols.",
    "website": "https://www.coursera.org/learn/health-care-and-promotion-for-infants-and-toddlers",
    "provider": "University of Colorado System",
    "level": "Intermediate",
    "price": "Free"
  },
  {
    "title": "Emergency Care: Pregnancy, Infants, and Children",
    "specialty": "Pediatrics",
    "instructor": "Dr. Sana Ahmed",
    "lecturesCount": 15,
    "description": "High-stress clinical workflows for maternal, neonatal, and pediatric emergency resuscitation and care.",
    "website": "https://www.coursera.org/learn/emergency-care-pregnancy-infants-children",
    "provider": "University of Colorado System",
    "level": "Advanced",
    "price": "Free"
  },
  {
    "title": "Positive Psychiatry and Mental Health",
    "specialty": "Psychiatry",
    "instructor": "Dr. Nida Jamil",
    "lecturesCount": 15,
    "description": "Focus on resilience, positive psychotherapeutic interventions, mental wellness, and recovery models.",
    "website": "https://www.coursera.org/learn/positive-psychiatry",
    "provider": "The University of Sydney",
    "level": "Beginner",
    "price": "Free"
  },
  {
    "title": "Schizophrenia",
    "specialty": "Psychiatry",
    "instructor": "Dr. Asma Riaz",
    "lecturesCount": 16,
    "description": "A clinical and neurological analysis of schizophrenia, psychotic disorders, and pharmacological management.",
    "website": "https://www.coursera.org/learn/schizophrenia",
    "provider": "Wesleyan University",
    "level": "Intermediate",
    "price": "Free"
  },
  {
    "title": "Major Depression in the Population: A Public Health Approach",
    "specialty": "Psychiatry",
    "instructor": "Dr. Shazia Rehman",
    "lecturesCount": 12,
    "description": "Public health frameworks for depression assessment, risk factors, prevention, and treatment at scale.",
    "website": "https://www.coursera.org/learn/public-health-depression",
    "provider": "Johns Hopkins University",
    "level": "Intermediate",
    "price": "Free"
  },
  {
    "title": "Understanding the Brain: The Neurobiology of Everyday Life",
    "specialty": "Psychiatry",
    "instructor": "Dr. Ambreen Zehra",
    "lecturesCount": 18,
    "description": "The neuroanatomy, cognitive circuits, and neurobiology underlying emotional regulation and behavior.",
    "website": "https://www.coursera.org/learn/neurobiology",
    "provider": "University of Chicago",
    "level": "Advanced",
    "price": "Free"
  },
  {
    "title": "Introduction to Cosmetic and Skincare Science",
    "specialty": "Dermatology",
    "instructor": "Dr. Mahnoor Shah",
    "lecturesCount": 14,
    "description": "Explore skin biology, dermal physiology, cosmetic formulation, and clinical skincare solutions.",
    "website": "https://www.coursera.org/learn/introduction-to-cosmetic-and-skin-care-science",
    "provider": "University of Cincinnati",
    "level": "Beginner",
    "price": "Free"
  },
  {
    "title": "Medical Terminology",
    "specialty": "Dermatology",
    "instructor": "Dr. Bushra Naz",
    "lecturesCount": 20,
    "description": "Master the terminology of dermatology, pathological lesions, skin disorders, and clinical reporting.",
    "website": "https://www.coursera.org/learn/clinical-terminology",
    "provider": "University of Pittsburgh",
    "level": "Beginner",
    "price": "Free"
  },
  {
    "title": "Telehealth: Dermatology Assessment",
    "specialty": "Dermatology",
    "instructor": "Dr. Hina Fatima",
    "lecturesCount": 16,
    "description": "Practical guidelines for obtaining and interpreting high-quality dermatological imagery in virtual clinics.",
    "website": "https://www.coursera.org/learn/telehealth-dermatology-assessment",
    "provider": "University of Colorado System",
    "level": "Intermediate",
    "price": "Free"
  },
  {
    "title": "Dermatology for Primary Care",
    "specialty": "Dermatology",
    "instructor": "Dr. Yasmin Ara",
    "lecturesCount": 15,
    "description": "Identify common skin lesions, treat dermatitis, and manage skin cancer screen protocols in primary care.",
    "website": "https://online-learning.harvard.edu/subject/dermatology",
    "provider": "Harvard Online",
    "level": "Intermediate",
    "price": "Free"
  },
  {
    "title": "Clinical Trials",
    "specialty": "Internal Medicine",
    "instructor": "Dr. Farah Naqvi",
    "lecturesCount": 15,
    "description": "Clinical trial design, GCP guidelines, ethical standards, data monitoring, and analysis in internal medicine.",
    "website": "https://www.coursera.org/learn/clinical-trials",
    "provider": "University of Cape Town",
    "level": "Intermediate",
    "price": "Free"
  },
  {
    "title": "Epigenetics",
    "specialty": "Internal Medicine",
    "instructor": "Dr. Uzma Qureshi",
    "lecturesCount": 16,
    "description": "Study chromatin modifications, environmental gene expression regulation, and clinical epigenetics applications.",
    "website": "https://www.coursera.org/learn/epigenetics",
    "provider": "University of Melbourne",
    "level": "Advanced",
    "price": "Free"
  },
  {
    "title": "Introduction to Systematic Reviews and Meta-Analyses",
    "specialty": "Internal Medicine",
    "instructor": "Dr. Sobia Ghias",
    "lecturesCount": 12,
    "description": "Learn systematic literature search strategy, quality appraisal, and statistical meta-analyses methods.",
    "website": "https://www.coursera.org/learn/systematic-review",
    "provider": "Johns Hopkins University",
    "level": "Intermediate",
    "price": "Free"
  },
  {
    "title": "Infectious Disease Transmission Models",
    "specialty": "Internal Medicine",
    "instructor": "Dr. Mehreen Lodhi",
    "lecturesCount": 18,
    "description": "Mathematical modeling, R0 computation, and epidemiological transmission patterns of major infectious diseases.",
    "website": "https://www.coursera.org/learn/infectious-disease-transmission-models-for-decision-makers",
    "provider": "Imperial College London",
    "level": "Advanced",
    "price": "Free"
  },
  {
    "title": "Cardiovascular System: Anatomy & Physiology",
    "specialty": "Cardiology",
    "instructor": "Dr. Sadia Khan",
    "lecturesCount": 15,
    "description": "Core cardiac anatomy, valvular functions, myocardial action potentials, and hemodynamic principles.",
    "website": "https://www.coursera.org/learn/lecturio-cardiovascular-system-anatomy-physiology",
    "provider": "Lecturio",
    "level": "Beginner",
    "price": "Free"
  },
  {
    "title": "Myocardial Infarction",
    "specialty": "Cardiology",
    "instructor": "Dr. Humaira Ali",
    "lecturesCount": 16,
    "description": "Pathophysiology, early triage, cardiac biomarkers, ECG findings, and guidelines for acute coronary syndrome.",
    "website": "https://www.coursera.org/learn/infarction",
    "provider": "University of Zurich",
    "level": "Intermediate",
    "price": "Free"
  },
  {
    "title": "Electrocardiogram (ECG)",
    "specialty": "Cardiology",
    "instructor": "Dr. Rabia Tariq",
    "lecturesCount": 18,
    "description": "Learn to record, analyze, and diagnose cardiac arrhythmias, blocks, and ischemia using electrocardiograms.",
    "website": "https://www.coursera.org/learn/lecturio-electrocardiogram-ecg",
    "provider": "Lecturio",
    "level": "Intermediate",
    "price": "Free"
  },
  {
    "title": "Cardiovascular Disease Prevention: Lifestyle and Risk Factor Management",
    "specialty": "Cardiology",
    "instructor": "Dr. Fauzia Tabassum",
    "lecturesCount": 14,
    "description": "Guidelines on lifestyle changes, diet, exercise, hypertension management, and lipid control.",
    "website": "https://www.coursera.org/learn/cardiovascular-disorders-medical-surgical-nursing",
    "provider": "Coursera",
    "level": "Beginner",
    "price": "Free"
  },
  {
    "title": "Medical Neuroscience",
    "specialty": "Other",
    "instructor": "Dr. Memoona Riaz",
    "lecturesCount": 20,
    "description": "Comprehensive study of neural transmission, sensory motor pathways, and neurological clinical localization.",
    "website": "https://www.coursera.org/learn/medical-neuroscience",
    "provider": "Duke University",
    "level": "Advanced",
    "price": "Free"
  },
  {
    "title": "Caring for Patients with Neurological Diseases",
    "specialty": "Other",
    "instructor": "Dr. Tahira Yasmin",
    "lecturesCount": 16,
    "description": "Managing chronic neurologic conditions like stroke, dementia, epilepsy, and developmental disorders.",
    "website": "https://www.coursera.org/learn/caring-for-patients-with-neurological-diseases",
    "provider": "Central South University",
    "level": "Intermediate",
    "price": "Free"
  },
  {
    "title": "The Emergence of Oncofertility",
    "specialty": "Other",
    "instructor": "Dr. Salma Malik",
    "lecturesCount": 12,
    "description": "Fertility preservation policies, ethical concerns, and clinical workflows for oncology patients.",
    "website": "https://www.coursera.org/learn/oncofertility-overview",
    "provider": "Northwestern University",
    "level": "Advanced",
    "price": "Free"
  },
  {
    "title": "Introduction to Breast Cancer",
    "specialty": "Other",
    "instructor": "Dr. Noreen Akhtar",
    "lecturesCount": 15,
    "description": "Study of breast cancer risk factors, pathology, clinical classification, and chemotherapy regimens.",
    "website": "https://www.coursera.org/learn/breast-cancer-causes-prevention",
    "provider": "Yale University",
    "level": "Intermediate",
    "price": "Free"
  }
];

async function recommendCoursesUsingGemini(specialty) {
  try {
    if (!specialty) {
      return [];
    }

    const apiKey = 'Enter your Gemini API key here';
  
    const prompt = `You are a medical course recommendation AI.
The user is looking for learning courses for the doctor Primary Specialty: "${specialty}".

Choose exactly 4 courses that are highly relevant to "${specialty}" from the following catalog of real, existing courses. You must ONLY recommend courses that are present in this catalog. Do not invent any new courses or URLs.

Catalog:
${JSON.stringify(realCoursesCatalog, null, 2)}

Return the output as a valid JSON array directly. Do not wrap it in markdown formatting like \`\`\`json.`;

    const payload = JSON.stringify({
      contents: [{
        parts: [{
          text: prompt
        }]
      }],
      generationConfig: {
        responseMimeType: "application/json"
      }
    });

    const recommended = await new Promise((resolve, reject) => {
      const options = {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        }
      };

      const req = https.request(url, options, (res) => {
        let data = '';
        res.on('data', (chunk) => {
          data += chunk;
        });
        res.on('end', () => {
          if (res.statusCode !== 200) {
            return reject(new Error(`Gemini API returned status ${res.statusCode}: ${data}`));
          }
          try {
            const parsed = JSON.parse(data);
            const text = parsed.candidates[0].content.parts[0].text;
            const courses = JSON.parse(text);
            resolve(courses);
          } catch (err) {
            reject(err);
          }
        });
      });

      req.on('error', (e) => {
        reject(e);
      });

      req.write(payload);
      req.end();
    });

    if (Array.isArray(recommended)) {
      return recommended.map(course => {
        const cleanSpecialty = course.specialty || specialty;
        const matchingCatalogCourse = realCoursesCatalog.find(c => 
          c.title.toLowerCase().trim() === (course.title || '').toLowerCase().trim()
        );
        
        let instructor = course.instructor || 'Dr. Aruna Chandran';
        let website = course.website;
        let provider = course.provider || 'DocStep Academy';
        let level = course.level || 'Intermediate';
        let price = course.price || 'Free';
        let description = course.description;

        if (matchingCatalogCourse) {
          instructor = matchingCatalogCourse.instructor;
          website = matchingCatalogCourse.website;
          provider = matchingCatalogCourse.provider;
          level = matchingCatalogCourse.level;
          price = matchingCatalogCourse.price;
          description = matchingCatalogCourse.description;
        }

        if (instructor.toLowerCase().includes('taha')) {
          instructor = 'Dr. Aruna Chandran';
        }

        return {
          title: course.title || 'Untitled Course',
          specialty: cleanSpecialty,
          instructor: instructor,
          duration: course.duration || '10 hours',
          duration_hours: parseFloat((course.duration || '').replace(/[^0-9.]/g, '')) || 10,
          lecturesCount: Number(course.lecturesCount) || 12,
          lectures_count: Number(course.lecturesCount) || 12,
          description: description || `Comprehensive guide and training course covering key topics in ${cleanSpecialty}.`,
          level: level,
          price: price,
          provider: provider,
          enrolled_count: course.enrolled_count || 150,
          image: specialtyImages[cleanSpecialty] || specialtyImages['Other'],
          website: website || `https://www.coursera.org/learn/clinical-terminology`
        };
      });
    }

    return [];
  } catch (err) {
    console.error('recommendCoursesUsingGemini error:', err);
    // Local fallback with smart keyword matching
    const query = specialty.toLowerCase().trim();
    let matches = realCoursesCatalog.filter(c => {
      const spec = c.specialty.toLowerCase();
      const title = c.title.toLowerCase();
      const desc = c.description.toLowerCase();
      
      if (query.includes('cardio') || query.includes('heart')) {
        return spec === 'cardiology';
      }
      if (query.includes('neuro') || query.includes('brain') || query.includes('stroke') || query.includes('nerv')) {
        return title.includes('neuro') || desc.includes('neuro') || title.includes('brain') || spec === 'other';
      }
      if (query.includes('pediatr') || query.includes('child') || query.includes('baby') || query.includes('infant')) {
        return spec === 'pediatrics';
      }
      if (query.includes('gyn') || query.includes('women') || query.includes('repro') || query.includes('breast') || query.includes('mater')) {
        return spec === 'gynecology';
      }
      if (query.includes('psych') || query.includes('mental') || query.includes('depress') || query.includes('schiz')) {
        return spec === 'psychiatry';
      }
      if (query.includes('derm') || query.includes('skin') || query.includes('cosmetic')) {
        return spec === 'dermatology';
      }
      if (query.includes('internal') || query.includes('infect') || query.includes('trial') || query.includes('epi')) {
        return spec === 'internal medicine' || spec === 'general practice';
      }
      
      return spec === query || title.includes(query) || desc.includes(query);
    });

    const fallbackList = matches.length > 0 ? matches : realCoursesCatalog;
    return fallbackList.slice(0, 4).map(c => ({
      ...c,
      image: specialtyImages[c.specialty] || specialtyImages['Other']
    }));
  }
}

// -------------------------------------------------------------
// Appointments
// -------------------------------------------------------------
async function getEmployerIdForDoctor(doctorId) {
  try {
    // Resolve doctorId to profile ID if it is a user ID
    let profileId = doctorId;
    const directProfile = await db.collection('doctor_profiles').doc(doctorId).get();
    if (!directProfile.exists) {
      let userProfileSnap = await db.collection('doctor_profiles').where('user_id', '==', doctorId).limit(1).get();
      if (userProfileSnap.empty) {
        userProfileSnap = await db.collection('doctor_profiles').where('userId', '==', doctorId).limit(1).get();
      }
      if (!userProfileSnap.empty) {
        profileId = userProfileSnap.docs[0].id;
      }
    }

    const snapshot = await db.collection('applications')
      .where('doctor_id', '==', profileId)
      .get();
    
    if (snapshot.empty) return null;
    
    const apps = [];
    snapshot.forEach(doc => {
      apps.push(doc.data());
    });
    
    // Prioritize application status: hired > interviewed > shortlisted > pending
    const statuses = ['hired', 'interviewed', 'shortlisted', 'pending'];
    for (const status of statuses) {
      const matchedApp = apps.find(a => a.status === status);
      if (matchedApp) {
        const job = await getJobById(matchedApp.job_id);
        if (job && job.employer_id) {
          const empProfile = await getEmployerProfileById(job.employer_id);
          if (empProfile && (empProfile.user_id || empProfile.userId)) {
            return empProfile.user_id || empProfile.userId;
          }
        }
      }
    }
  } catch (err) {
    console.error('Error in getEmployerIdForDoctor:', err);
  }
  return null;
}

async function createAppointment(appointmentData) {
  let employer_id = appointmentData.employer_id || null;
  if (!employer_id && appointmentData.doctor_id) {
    employer_id = await getEmployerIdForDoctor(appointmentData.doctor_id);
  }

  const docRef = await db.collection('appointments').add({
    doctor_id: appointmentData.doctor_id,
    employer_id: employer_id,
    doctor_name: appointmentData.doctor_name,
    patient_name: appointmentData.patient_name,
    date: appointmentData.date,
    day: appointmentData.day,
    time_slot: appointmentData.time_slot,
    primary_specialty: appointmentData.primary_specialty,
    doctor_availability: appointmentData.doctor_availability,
    status: appointmentData.status || 'scheduled',
    created_at: new Date().toISOString()
  });
  return docRef.id;
}

async function getAppointmentsByDoctor(doctorId) {
  // Get the doctor profile to find the user_id
  let userId = null;
  let profileId = doctorId;
  const docProfile = await db.collection('doctor_profiles').doc(doctorId).get();
  if (docProfile.exists) {
    userId = docProfile.data().user_id || docProfile.data().userId;
  } else {
    // If doctorId passed is actually the user_id, find the profile
    let snap = await db.collection('doctor_profiles').where('user_id', '==', doctorId).limit(1).get();
    if (snap.empty) {
      snap = await db.collection('doctor_profiles').where('userId', '==', doctorId).limit(1).get();
    }
    if (!snap.empty) {
      userId = doctorId;
      profileId = snap.docs[0].id;
    }
  }

  const snapshot = await db.collection('appointments').get();
  const list = [];
  snapshot.forEach(doc => {
    const data = doc.data();
    if (data.doctor_id === profileId || (userId && data.doctor_id === userId)) {
      list.push({ id: doc.id, ...data });
    }
  });
  list.sort((a, b) => new Date(b.date) - new Date(a.date));
  return list;
}

async function getAppointmentsByEmployer(userId) {
  const snapshot = await db.collection('appointments').get();
  const list = [];
  snapshot.forEach(doc => {
    list.push({ id: doc.id, ...doc.data() });
  });
  list.sort((a, b) => new Date(b.date) - new Date(a.date));
  return list;
}

async function getAppointmentById(id) {
  const doc = await db.collection('appointments').doc(id).get();
  if (!doc.exists) return null;
  return { id: doc.id, ...doc.data() };
}

async function updateAppointment(id, updateData) {
  const docRef = db.collection('appointments').doc(id);
  const doc = await docRef.get();
  if (doc.exists) {
    const existing = doc.data();
    
    // Resolve doctor ID (either updated or existing)
    const doctorId = updateData.doctor_id || existing.doctor_id;
    
    // If employer_id is not in updateData and not in existing, or if doctor changed, try to resolve it
    if ((!updateData.employer_id && !existing.employer_id) || (updateData.doctor_id && updateData.doctor_id !== existing.doctor_id)) {
      const resolvedEmployerId = await getEmployerIdForDoctor(doctorId);
      if (resolvedEmployerId) {
        updateData.employer_id = resolvedEmployerId;
      }
    }
  }
  await docRef.update(updateData);
}

async function deleteAppointment(id) {
  await db.collection('appointments').doc(id).delete();
}

// -------------------------------------------------------------
// Forum Community
// -------------------------------------------------------------
async function getCommunityPosts() {
  const snapshot = await db.collection('community_posts').get();
  const posts = [];
  for (const doc of snapshot.docs) {
    const data = doc.data();
    const u = await getUserById(data.user_id);
    posts.push({
      id: doc.id,
      ...data,
      author_name: u ? u.full_name : 'Doctor',
      replies_count: 0
    });
  }
  posts.sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
  return posts;
}

async function createCommunityPost(userId, title, content, category) {
  const docRef = await db.collection('community_posts').add({
    user_id: userId,
    title,
    content,
    category: category || 'General',
    created_at: new Date().toISOString()
  });
  return docRef.id;
}

async function getCommunityPostById(id) {
  const doc = await db.collection('community_posts').doc(id).get();
  if (!doc.exists) return null;
  const data = doc.data();
  const u = await getUserById(data.user_id);
  return {
    id: doc.id,
    ...data,
    author_name: u ? u.full_name : 'Doctor'
  };
}

async function getCommunityReplies(postId) {
  const snapshot = await db.collection('community_replies').where('post_id', '==', postId).get();
  const replies = [];
  for (const doc of snapshot.docs) {
    const data = doc.data();
    const u = await getUserById(data.user_id);
    replies.push({
      id: doc.id,
      ...data,
      author_name: u ? u.full_name : 'User'
    });
  }
  replies.sort((a, b) => new Date(a.created_at) - new Date(b.created_at));
  return replies;
}

async function createCommunityReply(postId, userId, content) {
  const docRef = await db.collection('community_replies').add({
    post_id: postId,
    user_id: userId,
    content,
    created_at: new Date().toISOString()
  });
  return docRef.id;
}

module.exports = {
  db,
  getUserCount,
  createUser,
  getUserByEmail,
  getUserById,
  updateUser,
  createDoctorProfile,
  getDoctorProfileByUserId,
  getDoctorProfileById,
  updateDoctorProfile,
  getRegisteredDoctors,
  updateDoctorCv,
  updateDoctorAvailability,
  createEmployerProfile,
  getEmployerProfileByUserId,
  getEmployerProfileById,
  updateEmployerProfile,
  createJob,
  getJobs,
  getJobById,
  getEmployerJobs,
  updateJob,
  deleteJob,
  getRelatedJobs,
  getJobsDistinctSpecialties,
  getJobsDistinctModes,
  createApplication,
  getApplicationsByDoctor,
  getEmployerApplications,
  updateApplicationStatus,
  hasDoctorApplied,
  createInterview,
  getInterviewsByDoctor,
  getEmployerInterviews,
  getCredentials,
  createCredential,
  deleteCredential,
  getCandidates,
  getCandidatesDistinctSpecialties,
  getCandidatesDistinctCities,
  getCandidateDetail,
  getStats,
  getUnverifiedDoctors,
  getUnverifiedCredentials,
  getContactMessages,
  verifyPmdc,
  verifyCredential,
  createContactMessage,
  getSuccessStories,
  getCourses,
  recommendCoursesUsingGemini,
  createAppointment,
  getAppointmentsByDoctor,
  getAppointmentsByEmployer,
  getAppointmentById,
  updateAppointment,
  deleteAppointment,
  getCommunityPosts,
  createCommunityPost,
  getCommunityPostById,
  getCommunityReplies,
  createCommunityReply,
  createPasswordResetToken,
  getPasswordResetToken,
  deletePasswordResetToken,
  updateUserPassword
};

// -------------------------------------------------------------
// Password Reset Tokens
// -------------------------------------------------------------
async function createPasswordResetToken(email, token, expiresAt) {
  const docRef = await db.collection('password_resets').add({
    email,
    token,
    expires_at: expiresAt,
    created_at: new Date().toISOString()
  });
  return docRef.id;
}

async function getPasswordResetToken(token) {
  const snapshot = await db.collection('password_resets').where('token', '==', token).limit(1).get();
  if (snapshot.empty) return null;
  const doc = snapshot.docs[0];
  return { id: doc.id, ...doc.data() };
}

async function deletePasswordResetToken(id) {
  await db.collection('password_resets').doc(id).delete();
}

async function updateUserPassword(userId, passwordHash) {
  await db.collection('users').doc(userId).update({
    password_hash: passwordHash
  });
}
