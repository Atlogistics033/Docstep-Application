// Seed DocStep database with realistic demo data on Firebase Firestore
const dbService = require('./dbService');
const bcrypt = require('bcryptjs');

const hash = (pw) => bcrypt.hashSync(pw, 10);

async function deleteCollection(db, collectionName) {
  const snapshot = await db.collection(collectionName).get();
  const batch = db.batch();
  snapshot.docs.forEach(doc => {
    batch.delete(doc.ref);
  });
  await batch.commit();
  console.log(`[DocStep Seed] Cleared collection: ${collectionName}`);
}

async function runSeed() {
  console.log('[DocStep Seed] Starting Firestore database seeding...');
  const db = dbService.db;
  const force = process.argv.includes('--force');

  if (force) {
    console.log('[DocStep Seed] Force flag detected. Clearing previous collections...');
    const collections = [
      'users', 'doctor_profiles', 'employer_profiles', 'jobs', 'courses', 
      'success_stories', 'community_posts', 'community_replies', 
      'applications', 'interviews', 'credentials', 'contact_messages', 
      'notifications', 'appointments'
    ];
    for (const col of collections) {
      try {
        await deleteCollection(db, col);
      } catch (err) {
        console.warn(`[DocStep Seed] Failed to clear collection ${col}:`, err.message);
      }
    }
  } else {
    try {
      const userCount = await dbService.getUserCount();
      if (userCount > 0) {
        console.log('[DocStep Seed] Database already contains users. Skipping seed. (Use --force to clear and re-seed)');
        return;
      }
    } catch (err) {
      console.error('[DocStep Seed] Failed to check users collection:', err.message);
      process.exit(1);
    }
  }

  // ---- Admin ----
  console.log('[DocStep Seed] Creating Admin...');
  const adminId = await dbService.createUser('admin@docstep.pk', hash('admin123'), 'admin', 'DocStep Admin', '+92-300-0000000');

  // ---- Doctors ----
  console.log('[DocStep Seed] Creating Doctors...');
  const doctors = [
    {
      email: 'ayesha.khan@docstep.pk',
      full_name: 'Dr. Ayesha Khan',
      specialty: 'Gynecology',
      experience_years: 8,
      pmdc_number: 'PMDC-45821',
      pmdc_verified: 1,
      city: 'Karachi',
      languages: 'Urdu, English',
      qualifications: 'MBBS (Dow Medical College), FCPS Gynae',
      availability: 'Weekdays 10am-2pm',
      hourly_rate: 2500,
      open_to_remote: 1,
      cv_summary: 'Gynecologist with 8 years of clinical experience, returning to practice after a 3-year career break for motherhood. Passionate about women\'s reproductive health.',
      cv_skills: 'Antenatal care, Ultrasound, Family planning, Telemedicine',
      cv_experience: 'Senior Registrar — Aga Khan Hospital (2017-2021); Medical Officer — JPMC (2015-2017)',
      cv_education: 'MBBS — Dow Medical College (2015); FCPS Gynecology — CPSP (2020)',
      cv_certifications: 'BLS Certified, Telemedicine Practitioner (2024)',
      clinic_name: 'Ayesha Gyne Care & Clinic',
      clinic_address: 'North Nazimabad',
      clinic_hospital_address: 'Block H, Near Five Star Roundabout, North Nazimabad'
    },
    {
      email: 'sara.ali@docstep.pk',
      full_name: 'Dr. Sara Ali',
      specialty: 'Pediatrics',
      experience_years: 6,
      pmdc_number: 'PMDC-39122',
      pmdc_verified: 1,
      city: 'Lahore',
      languages: 'Urdu, English, Punjabi',
      qualifications: 'MBBS (KEMU), MCPS Pediatrics',
      availability: 'Evenings & Weekends',
      hourly_rate: 2000,
      open_to_remote: 1,
      cv_summary: 'Pediatrician with focus on neonatal care. Looking for flexible remote consultations to balance with my two children.',
      cv_skills: 'Newborn care, Vaccination, Growth monitoring, Parental counseling',
      cv_experience: 'Consultant Pediatrician — Children\'s Hospital Lahore (2018-2022)',
      cv_education: 'MBBS — King Edward Medical University (2017); MCPS Peds (2020)',
      cv_certifications: 'IMNCI Certified, NRP Certified'
    },
    {
      email: 'hina.malik@docstep.pk',
      full_name: 'Dr. Hina Malik',
      specialty: 'Psychiatry',
      experience_years: 5,
      pmdc_number: 'PMDC-50122',
      pmdc_verified: 1,
      city: 'Islamabad',
      languages: 'Urdu, English',
      qualifications: 'MBBS, Diploma in Psychiatry',
      availability: 'Flexible',
      hourly_rate: 3000,
      open_to_remote: 1,
      cv_summary: 'Clinical psychiatrist specializing in women\'s mental health, postpartum depression, and anxiety. Strong focus on culturally-sensitive teletherapy.',
      cv_skills: 'CBT, Postpartum care, Anxiety disorders, Trauma counseling',
      cv_experience: 'Psychiatrist — Shifa International (2019-2023)',
      cv_education: 'MBBS — Rawalpindi Medical University; Diploma in Psychiatry',
      cv_certifications: 'CBT Certified Therapist'
    },
    {
      email: 'fatima.raza@docstep.pk',
      full_name: 'Dr. Fatima Raza',
      specialty: 'Dermatology',
      experience_years: 7,
      pmdc_number: 'PMDC-41200',
      pmdc_verified: 1,
      city: 'Karachi',
      languages: 'Urdu, English',
      qualifications: 'MBBS, FCPS Dermatology',
      availability: 'Weekday afternoons',
      hourly_rate: 2800,
      open_to_remote: 1,
      cv_summary: 'Returning dermatologist after a 4-year gap. Interested in tele-dermatology and acne/eczema teleconsultations.',
      cv_skills: 'Acne management, Pediatric dermatology, Cosmetic dermatology',
      cv_experience: 'Consultant Dermatologist — Liaquat National Hospital (2016-2020)',
      cv_education: 'MBBS — SMBBMU; FCPS Derm (2019)',
      cv_certifications: 'Laser Therapy Certified',
      clinic_name: 'Raza Skin & Laser Clinic',
      clinic_address: 'Gulshan-e-Iqbal',
      clinic_hospital_address: 'Block 13-C, University Road, Gulshan-e-Iqbal'
    },
    {
      email: 'mariam.shah@docstep.pk',
      full_name: 'Dr. Mariam Shah',
      specialty: 'General Practice',
      experience_years: 4,
      pmdc_number: 'PMDC-55300',
      pmdc_verified: 1,
      city: 'Rawalpindi',
      languages: 'Urdu, English',
      qualifications: 'MBBS',
      availability: 'Mornings only',
      hourly_rate: 1500,
      open_to_remote: 1,
      cv_summary: 'General practitioner restarting career after a 5-year break. Comfortable with online consultations for adult and women\'s primary care.',
      cv_skills: 'Primary care, Chronic disease management, Women\'s health screening',
      cv_experience: 'Medical Officer — Holy Family Hospital (2018-2020)',
      cv_education: 'MBBS — Rawalpindi Medical College (2018)',
      cv_certifications: 'BLS, ACLS'
    },
    {
      email: 'noor.ahmed@docstep.pk',
      full_name: 'Dr. Noor Ahmed',
      specialty: 'Gynecology',
      experience_years: 10,
      pmdc_number: 'PMDC-32100',
      pmdc_verified: 1,
      city: 'Multan',
      languages: 'Urdu, English, Saraiki',
      qualifications: 'MBBS, FCPS Gynae, MRCOG',
      availability: 'Evenings',
      hourly_rate: 3500,
      open_to_remote: 1,
      cv_summary: 'Senior consultant gynecologist with international training. Now offering remote consultations after relocating.',
      cv_skills: 'High-risk pregnancy, Infertility, Laparoscopic surgery',
      cv_experience: 'Consultant — Nishtar Hospital (2014-2023); RCOG Training (UK)',
      cv_education: 'MBBS — Nishtar Medical College; MRCOG (UK)',
      cv_certifications: 'RCOG Member, Laparoscopy Certified'
    }
  ];

  const doctorProfileIds = [];
  const doctorUserIds = [];
  for (let d of doctors) {
    const uid = await dbService.createUser(d.email, hash('password123'), 'doctor', d.full_name, '+92-300-0000000');
    doctorUserIds.push(uid);
    const did = await dbService.createDoctorProfile({
      user_id: uid,
      specialty: d.specialty,
      experience_years: d.experience_years,
      pmdc_number: d.pmdc_number,
      pmdc_verified: d.pmdc_verified,
      city: d.city,
      languages: d.languages,
      qualifications: d.qualifications,
      availability: d.availability,
      hourly_rate: d.hourly_rate,
      open_to_remote: d.open_to_remote,
      cv_summary: d.cv_summary,
      cv_skills: d.cv_skills,
      cv_experience: d.cv_experience,
      cv_education: d.cv_education,
      cv_certifications: d.cv_certifications,
      clinic_name: d.clinic_name || '',
      clinic_address: d.clinic_address || '',
      clinic_hospital_address: d.clinic_hospital_address || ''
    });
    doctorProfileIds.push(did);
  }

  // ---- Employers ----
  console.log('[DocStep Seed] Creating Employers...');
  const employers = [
    {
      email: 'hello@shifahealth.pk',
      full_name: 'Shifa HR Manager',
      organization_name: 'Shifa Health Network',
      organization_type: 'Hospital Network',
      city: 'Islamabad',
      website: 'https://shifa.com.pk',
      about: 'A leading multi-specialty hospital network committed to inclusive hiring and remote-friendly medical roles.'
    },
    {
      email: 'hr@sehattele.pk',
      full_name: 'SehatTele HR',
      organization_name: 'SehatTele',
      organization_type: 'Telemedicine Platform',
      city: 'Karachi',
      website: 'https://sehattele.pk',
      about: 'Pakistan\'s growing telemedicine company connecting patients with verified online doctors.'
    },
    {
      email: 'careers@kidscarepk.com',
      full_name: 'KidsCare Recruiter',
      organization_name: 'KidsCare Clinic',
      organization_type: 'Pediatric Clinic Chain',
      city: 'Lahore',
      website: 'https://kidscare.pk',
      about: 'Specialised pediatric care chain with a strong focus on women-led practice.'
    }
  ];

  const employerProfileIds = [];
  for (let e of employers) {
    const uid = await dbService.createUser(e.email, hash('password123'), 'employer', e.full_name, '+92-300-1111111');
    const eid = await dbService.createEmployerProfile({
      user_id: uid,
      organization_name: e.organization_name,
      organization_type: e.organization_type,
      city: e.city,
      website: e.website,
      about: e.about,
      logo: null
    });
    employerProfileIds.push(eid);
  }

  // ---- Jobs ----
  console.log('[DocStep Seed] Creating Jobs...');
  const jobs = [
    {
      employer_id: employerProfileIds[0],
      title: 'Remote Gynecology Teleconsultant',
      specialty: 'Gynecology',
      job_type: 'Part-time',
      mode: 'Remote',
      city: 'Anywhere in Pakistan',
      salary_range: 'PKR 80,000 - 150,000 / month',
      description: 'Provide 4-hour online consultations daily for our women-only telehealth service. Flexible shift selection.',
      requirements: 'FCPS / MCPS in Gynecology. Comfortable with video consultations.'
    },
    {
      employer_id: employerProfileIds[1],
      title: 'Pediatrician — Evening Shift (Online)',
      specialty: 'Pediatrics',
      job_type: 'Part-time',
      mode: 'Remote',
      city: 'Anywhere',
      salary_range: 'PKR 60,000 - 120,000 / month',
      description: 'Conduct evening pediatric video consults from home. Onboarding & training provided.',
      requirements: 'MBBS + 2 yrs Peds experience. PMDC valid.'
    },
    {
      employer_id: employerProfileIds[2],
      title: 'Hybrid GP — Mother & Child Wing',
      specialty: 'General Practice',
      job_type: 'Part-time',
      mode: 'Hybrid',
      city: 'Lahore',
      salary_range: 'PKR 100,000 / month',
      description: '3 days clinic + 2 days remote. Designed for returning mothers.',
      requirements: 'MBBS, PMDC, willingness to do telemedicine.'
    },
    {
      employer_id: employerProfileIds[0],
      title: 'Mental Health Therapist (Online)',
      specialty: 'Psychiatry',
      job_type: 'Full-time',
      mode: 'Remote',
      city: 'Anywhere',
      salary_range: 'PKR 150,000+',
      description: 'Provide CBT and counseling sessions to female patients via secure video.',
      requirements: 'Diploma/FCPS Psychiatry, fluent Urdu/English.'
    },
    {
      employer_id: employerProfileIds[1],
      title: 'Dermatologist — Teleconsultation',
      specialty: 'Dermatology',
      job_type: 'Part-time',
      mode: 'Remote',
      city: 'Anywhere',
      salary_range: 'PKR 90,000 / month',
      description: 'Review patient images and conduct short video calls. Choose your own hours.',
      requirements: 'FCPS Dermatology preferred.'
    },
    {
      employer_id: employerProfileIds[2],
      title: 'Pediatrician Mentor (Part-time)',
      specialty: 'Pediatrics',
      job_type: 'Part-time',
      mode: 'Hybrid',
      city: 'Lahore',
      salary_range: 'PKR 70,000 / month',
      description: 'Mentor returning pediatricians while practising 2 days/week.',
      requirements: '5+ yrs experience. FCPS preferred.'
    },
    {
      employer_id: employerProfileIds[0],
      title: 'Women\'s Health GP — Returnship Program',
      specialty: 'General Practice',
      job_type: 'Full-time',
      mode: 'Onsite',
      city: 'Islamabad',
      salary_range: 'PKR 120,000 / month',
      description: '6-month structured return-to-work program with mentor + flexible hours.',
      requirements: 'MBBS, career gap of 2-7 yrs welcomed.'
    },
    {
      employer_id: employerProfileIds[1],
      title: 'Senior Telemedicine Lead',
      specialty: 'Gynecology',
      job_type: 'Full-time',
      mode: 'Remote',
      city: 'Anywhere',
      salary_range: 'PKR 200,000+',
      description: 'Lead and quality-check tele-gynae consultations across the platform.',
      requirements: 'FCPS + 5 yrs clinical + leadership experience.'
    }
  ];

  const jobIds = [];
  for (let j of jobs) {
    const jid = await dbService.createJob(j.employer_id, j);
    jobIds.push(jid);
  }

  // ---- Courses ----
  console.log('[DocStep Seed] Creating Courses...');
  const courses = [
    // 1. General Practice
    {
      title: 'Primary Care Refresher & Updates',
      specialty: 'General Practice',
      instructor: 'By Dr. Aruna Chandran',
      duration_hours: 15,
      lectures_count: 30,
      enrolled_count: 1250,
      price: 'Free',
      description: 'Essential updates in primary care medicine, including updated guidelines for common chronic illnesses.',
      image: 'https://images.unsplash.com/photo-1576091160550-2173dba999ef?auto=format&fit=crop&w=600&q=80',
      level: 'Intermediate',
      provider: 'DocStep Academy',
      tags: 'general practice,primary care'
    },
    {
      title: 'Family Medicine Principles in Telehealth',
      specialty: 'General Practice',
      instructor: 'By Dr. Sarah Fatima',
      duration_hours: 10,
      lectures_count: 20,
      enrolled_count: 980,
      price: 'PKR 4,000',
      description: 'How to apply family medicine protocols in online and remote settings safely.',
      image: 'https://images.unsplash.com/photo-1584981424278-f762f14c024f?auto=format&fit=crop&w=600&q=80',
      level: 'Beginner',
      provider: 'DocStep Academy',
      tags: 'general practice,telemedicine'
    },
    {
      title: 'Common Infectious Diseases in Pakistan',
      specialty: 'General Practice',
      instructor: 'By Dr. Zainab Alvi',
      duration_hours: 18,
      lectures_count: 36,
      enrolled_count: 1450,
      price: 'Free',
      description: 'Diagnosis and management protocols for typhoid, dengue, malaria, and other regional endemic conditions.',
      image: 'https://images.unsplash.com/photo-1579684389782-64d84b5e901f?auto=format&fit=crop&w=600&q=80',
      level: 'Intermediate',
      provider: 'National Health Inst.',
      tags: 'general practice,infections'
    },
    {
      title: 'Emergency First Responder Training',
      specialty: 'General Practice',
      instructor: 'By Dr. Bilal Rehman',
      duration_hours: 12,
      lectures_count: 24,
      enrolled_count: 860,
      price: 'PKR 6,500',
      description: 'Critical updates in basic life support, trauma response, and emergency medicine management.',
      image: 'https://images.unsplash.com/photo-1582718980780-be8b49ca91c9?auto=format&fit=crop&w=600&q=80',
      level: 'Advanced',
      provider: 'DocStep Partners',
      tags: 'general practice,emergency'
    },

    // 2. Gynecology
    {
      title: 'Obstetric Ultrasound Refresher',
      specialty: 'Gynecology',
      instructor: 'By Dr. Ayesha Khan',
      duration_hours: 20,
      lectures_count: 40,
      enrolled_count: 1100,
      price: 'PKR 12,000',
      description: 'Hands-on virtual simulation and video training for identifying fetal anomalies and obstetric scans.',
      image: 'https://images.unsplash.com/photo-1516549655169-df83a0774514?auto=format&fit=crop&w=600&q=80',
      level: 'Intermediate',
      provider: 'PakGynae College',
      tags: 'gynecology,ultrasound'
    },
    {
      title: 'Contraception and Family Planning',
      specialty: 'Gynecology',
      instructor: 'By Dr. Huma Jamil',
      duration_hours: 8,
      lectures_count: 15,
      enrolled_count: 750,
      price: 'Free',
      description: 'Comprehensive overview of contraceptive methods, counseling strategies, and patient choices.',
      image: 'https://images.unsplash.com/photo-1551244072-5d12893278ab?auto=format&fit=crop&w=600&q=80',
      level: 'Beginner',
      provider: 'DocStep Academy',
      tags: 'gynecology,family planning'
    },
    {
      title: 'Management of High-Risk Pregnancies',
      specialty: 'Gynecology',
      instructor: 'By Dr. Noor Ahmed',
      duration_hours: 24,
      lectures_count: 48,
      enrolled_count: 920,
      price: 'PKR 15,000',
      description: 'Advanced guidelines for managing gestational diabetes, pre-eclampsia, and other prenatal complications.',
      image: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&w=600&q=80',
      level: 'Advanced',
      provider: 'Aga Khan Univ.',
      tags: 'gynecology,pregnancy'
    },
    {
      title: 'Menopause and Hormone Replacement',
      specialty: 'Gynecology',
      instructor: 'By Dr. Fatima Raza',
      duration_hours: 14,
      lectures_count: 28,
      enrolled_count: 630,
      price: 'PKR 8,000',
      description: 'A physiological and therapeutic approach to menopause management and HRT protocols.',
      image: 'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?auto=format&fit=crop&w=600&q=80',
      level: 'Intermediate',
      provider: 'DocStep Partners',
      tags: 'gynecology,menopause'
    },

    // 3. Pediatrics
    {
      title: 'Neonatal Resuscitation Program (NRP)',
      specialty: 'Pediatrics',
      instructor: 'By Dr. Sara Ali',
      duration_hours: 16,
      lectures_count: 32,
      enrolled_count: 1200,
      price: 'PKR 10,000',
      description: 'Step-by-step resuscitation techniques for newborns, highlighting emergency management.',
      image: 'https://images.unsplash.com/photo-1502086223501-7ea6ecd79368?auto=format&fit=crop&w=600&q=80',
      level: 'Advanced',
      provider: 'Children\'s Hospital Lahore',
      tags: 'pediatrics,neonatal'
    },
    {
      title: 'Developmental Milestones & Monitoring',
      specialty: 'Pediatrics',
      instructor: 'By Dr. Maryam Shah',
      duration_hours: 12,
      lectures_count: 24,
      enrolled_count: 1040,
      price: 'Free',
      description: 'Learn to track and evaluate physical and cognitive growth milestones in early childhood.',
      image: 'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?auto=format&fit=crop&w=600&q=80',
      level: 'Beginner',
      provider: 'DocStep Academy',
      tags: 'pediatrics,milestones'
    },
    {
      title: 'Pediatric Immunization Schedules',
      specialty: 'Pediatrics',
      instructor: 'By Dr. Aftab Hussain',
      duration_hours: 6,
      lectures_count: 12,
      enrolled_count: 1550,
      price: 'Free',
      description: 'A comprehensive guide to the EPI and recommended vaccine schedules in Pakistan.',
      image: 'https://images.unsplash.com/photo-1581594693702-fbdc51b2763b?auto=format&fit=crop&w=600&q=80',
      level: 'Beginner',
      provider: 'National Pediatric Assoc.',
      tags: 'pediatrics,vaccines'
    },
    {
      title: 'Common Pediatric Infections & Therapy',
      specialty: 'Pediatrics',
      instructor: 'By Dr. Saad Rafique',
      duration_hours: 15,
      lectures_count: 30,
      enrolled_count: 940,
      price: 'PKR 5,000',
      description: 'Effective prescribing and diagnosis guidelines for childhood respiratory and gastrointestinal illnesses.',
      image: 'https://images.unsplash.com/photo-1542810634-71277d95dcbb?auto=format&fit=crop&w=600&q=80',
      level: 'Intermediate',
      provider: 'KEMU Lahore',
      tags: 'pediatrics,infections'
    },

    // 4. Psychiatry
    {
      title: 'Cognitive Behavioral Therapy (CBT) Basics',
      specialty: 'Psychiatry',
      instructor: 'By Dr. Hina Malik',
      duration_hours: 22,
      lectures_count: 45,
      enrolled_count: 1800,
      price: 'PKR 15,000',
      description: 'Fundamentals of CBT tools and structure for treating common mood disorders.',
      image: 'https://images.unsplash.com/photo-1527137341206-1a0bd81d9d86?auto=format&fit=crop&w=600&q=80',
      level: 'Intermediate',
      provider: 'PsychCare Institute',
      tags: 'psychiatry,cbt'
    },
    {
      title: 'Postpartum Depression & Women\'s Mental Health',
      specialty: 'Psychiatry',
      instructor: 'By Dr. Saima Iqbal',
      duration_hours: 14,
      lectures_count: 28,
      enrolled_count: 1150,
      price: 'Free',
      description: 'Recognizing and managing psychological distress in new mothers, with a focus on therapy and support.',
      image: 'https://images.unsplash.com/photo-1518609878373-06d740f60d8b?auto=format&fit=crop&w=600&q=80',
      level: 'Beginner',
      provider: 'DocStep Academy',
      tags: 'psychiatry,women'
    },
    {
      title: 'Childhood Behavior & ADHD Management',
      specialty: 'Psychiatry',
      instructor: 'By Dr. Asif Mehmood',
      duration_hours: 18,
      lectures_count: 36,
      enrolled_count: 780,
      price: 'PKR 9,000',
      description: 'Diagnosis and behavior modification plans for pediatric patients with ADHD and autism.',
      image: 'https://images.unsplash.com/photo-1503919545889-aef636e10ad4?auto=format&fit=crop&w=600&q=80',
      level: 'Advanced',
      provider: 'Mental Health Assoc.',
      tags: 'psychiatry,adhd'
    },
    {
      title: 'Managing Stress and Burnout in Medical Staff',
      specialty: 'Psychiatry',
      instructor: 'By Dr. Kamran Shah',
      duration_hours: 8,
      lectures_count: 16,
      enrolled_count: 2200,
      price: 'Free',
      description: 'A self-paced mindfulness and resilience building course specifically tailored for doctors returning to work.',
      image: 'https://images.unsplash.com/photo-1474418386616-3d234c9c1b1c?auto=format&fit=crop&w=600&q=80',
      level: 'Beginner',
      provider: 'DocStep Academy',
      tags: 'psychiatry,mindfulness'
    },

    // 5. Dermatology
    {
      title: 'Clinical Dermatology Essentials',
      specialty: 'Dermatology',
      instructor: 'By Dr. Fatima Raza',
      duration_hours: 16,
      lectures_count: 32,
      enrolled_count: 1400,
      price: 'PKR 7,500',
      description: 'Diagnosis and management protocols for eczema, psoriasis, acne, and common hair loss.',
      image: 'https://images.unsplash.com/photo-1512290923902-8a9f81dc236c?auto=format&fit=crop&w=600&q=80',
      level: 'Intermediate',
      provider: 'Derm Association',
      tags: 'dermatology,clinical'
    },
    {
      title: 'Tele-Dermatology Practices',
      specialty: 'Dermatology',
      instructor: 'By Dr. Zoya Hamid',
      duration_hours: 10,
      lectures_count: 20,
      enrolled_count: 950,
      price: 'Free',
      description: 'Guidelines for conducting virtual skin assessments using digital photographs and live video feeds.',
      image: 'https://images.unsplash.com/photo-1629909613654-28e377c37b09?auto=format&fit=crop&w=600&q=80',
      level: 'Beginner',
      provider: 'DocStep Academy',
      tags: 'dermatology,telemedicine'
    },
    {
      title: 'Pediatric Skin Conditions Refresher',
      specialty: 'Dermatology',
      instructor: 'By Dr. Nabila Yasmin',
      duration_hours: 12,
      lectures_count: 24,
      enrolled_count: 830,
      price: 'PKR 6,000',
      description: 'Identifying and treating eczema, skin rashes, and viral exanthems in infants and young children.',
      image: 'https://images.unsplash.com/photo-1579684389782-64d84b5e901f?auto=format&fit=crop&w=600&q=80',
      level: 'Intermediate',
      provider: 'Aga Khan Univ.',
      tags: 'dermatology,pediatric'
    },
    {
      title: 'Cosmetic Dermatology & Topical Agents',
      specialty: 'Dermatology',
      instructor: 'By Dr. Harris Mahmood',
      duration_hours: 20,
      lectures_count: 40,
      enrolled_count: 1600,
      price: 'PKR 18,000',
      description: 'Comprehensive analysis of chemical peels, retinoids, anti-aging therapies, and aesthetic medicine.',
      image: 'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=600&q=80',
      level: 'Advanced',
      provider: 'Skin Institute Karachi',
      tags: 'dermatology,aesthetic'
    },

    // 6. Internal Medicine
    {
      title: 'Diabetes Mellitus Management Guidelines',
      specialty: 'Internal Medicine',
      instructor: 'By Dr. Farah Naqvi',
      duration_hours: 14,
      lectures_count: 28,
      enrolled_count: 1500,
      price: 'Free',
      description: 'Latest pharmacological options, insulin regimens, and complication management guidelines for diabetes.',
      image: 'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?auto=format&fit=crop&w=600&q=80',
      level: 'Intermediate',
      provider: 'DocStep Academy',
      tags: 'internal medicine,diabetes'
    },
    {
      title: 'Hypertension & Cardiovascular Risk Assessment',
      specialty: 'Internal Medicine',
      instructor: 'By Dr. Sohail Akhtar',
      duration_hours: 12,
      lectures_count: 24,
      enrolled_count: 1100,
      price: 'PKR 4,500',
      description: 'Diagnostic categories, therapy choices, and risk factors associated with elevated arterial pressures.',
      image: 'https://images.unsplash.com/photo-1518152006812-edab29b069ac?auto=format&fit=crop&w=600&q=80',
      level: 'Beginner',
      provider: 'National Health Inst.',
      tags: 'internal medicine,hypertension'
    },
    {
      title: 'Thyroid Disorders: Diagnosis & Treatment',
      specialty: 'Internal Medicine',
      instructor: 'By Dr. Amina Lodhi',
      duration_hours: 10,
      lectures_count: 20,
      enrolled_count: 980,
      price: 'Free',
      description: 'Evaluating hypo- and hyper-thyroidism, interpreting lab results, and adjusting dosages of levothyroxine.',
      image: 'https://images.unsplash.com/photo-1530026405186-ed1ea0ac7a63?auto=format&fit=crop&w=600&q=80',
      level: 'Intermediate',
      provider: 'DocStep Academy',
      tags: 'internal medicine,thyroid'
    },
    {
      title: 'Gastrointestinal Disorders & Pharmacotherapy',
      specialty: 'Internal Medicine',
      instructor: 'By Dr. Tariq Mahmood',
      duration_hours: 18,
      lectures_count: 36,
      enrolled_count: 870,
      price: 'PKR 6,000',
      description: 'Diagnosing and treating GERD, peptic ulcers, IBS, and chronic inflammatory bowel diseases.',
      image: 'https://images.unsplash.com/photo-1532187863486-abf9d39d66e8?auto=format&fit=crop&w=600&q=80',
      level: 'Advanced',
      provider: 'Dow University',
      tags: 'internal medicine,gi'
    },

    // 7. Cardiology
    {
      title: 'ECG Interpretation Bootcamp',
      specialty: 'Cardiology',
      instructor: 'By Dr. Sadia Khan',
      duration_hours: 20,
      lectures_count: 40,
      enrolled_count: 2300,
      price: 'PKR 9,000',
      description: 'Mastering the reading of normal and abnormal electrocardiograms, including blocks and ischemia.',
      image: 'https://images.unsplash.com/photo-1559757175-5700dde675bc?auto=format&fit=crop&w=600&q=80',
      level: 'Intermediate',
      provider: 'NICVD Karachi',
      tags: 'cardiology,ecg'
    },
    {
      title: 'Heart Failure Diagnosis & Management',
      specialty: 'Cardiology',
      instructor: 'By Dr. Asad Ullah',
      duration_hours: 15,
      lectures_count: 30,
      enrolled_count: 1050,
      price: 'Free',
      description: 'Understand stages of heart failure, guideline-directed medical therapy (GDMT), and device selection.',
      image: 'https://images.unsplash.com/photo-1628177142898-93e36e4e3a50?auto=format&fit=crop&w=600&q=80',
      level: 'Advanced',
      provider: 'DocStep Academy',
      tags: 'cardiology,heart failure'
    },
    {
      title: 'Valvular Heart Disease Essentials',
      specialty: 'Cardiology',
      instructor: 'By Dr. Ayesha Jamil',
      duration_hours: 12,
      lectures_count: 24,
      enrolled_count: 760,
      price: 'PKR 8,000',
      description: 'Pathophysiology, echocardiographic evaluation, and timing of intervention for common valve disorders.',
      image: 'https://images.unsplash.com/photo-1518152006812-edab29b069ac?auto=format&fit=crop&w=600&q=80',
      level: 'Intermediate',
      provider: 'NICVD Karachi',
      tags: 'cardiology,valves'
    },
    {
      title: 'Arrhythmias and Electrophysiology',
      specialty: 'Cardiology',
      instructor: 'By Dr. Zubair Ahmed',
      duration_hours: 18,
      lectures_count: 36,
      enrolled_count: 620,
      price: 'PKR 14,000',
      description: 'Advanced study of atrial fibrillation, tachycardias, bradycardias, and cardiac ablation procedures.',
      image: 'https://images.unsplash.com/photo-1516549655169-df83a0774514?auto=format&fit=crop&w=600&q=80',
      level: 'Advanced',
      provider: 'Punjab Inst of Cardiology',
      tags: 'cardiology,arrhythmias'
    }
  ];

  for (let c of courses) {
    await db.collection('courses').add(c);
  }

  // ---- Success Stories ----
  console.log('[DocStep Seed] Creating Success Stories...');
  const stories = [
    { doctor_name: 'Dr. Amna Tariq', specialty: 'Gynecology', city: 'Karachi', headline: 'From a 6-year career gap to 200 online patients a month', story: 'After leaving practice to raise my children, I never thought I would return to medicine. DocStep helped me rebuild my confidence through their returnship program, verified my credentials, and connected me with a teleclinic that fit my schedule. Today I see over 200 women patients a month — entirely from home.', image: null, featured: 1, created_at: new Date().toISOString() },
    { doctor_name: 'Dr. Saima Iqbal', specialty: 'Psychiatry', city: 'Islamabad', headline: 'How telepsychiatry let me serve rural women patients', story: 'I always wanted to serve women in interior Sindh and southern Punjab who can\'t access mental health care. DocStep\'s telemedicine training and verified employer pool made it possible. I now do 4 video sessions a day from my home in Islamabad.', image: null, featured: 1, created_at: new Date().toISOString() },
    { doctor_name: 'Dr. Rabia Anwar', specialty: 'Pediatrics', city: 'Lahore', headline: 'Restarting my career after a 4-year break — on my own terms', story: 'When I tried to return to a hospital job, the rigid hours didn\'t work for my family. DocStep matched me with a hybrid pediatric clinic that values returning mothers. I am back to medicine, on my own terms.', image: null, featured: 1, created_at: new Date().toISOString() },
    { doctor_name: 'Dr. Zoya Hamid', specialty: 'Dermatology', city: 'Karachi', headline: 'Built a full tele-dermatology practice in 6 months', story: 'The AI matching on DocStep paired me with three tele-dermatology employers. Within 6 months I had a sustainable online practice and no longer worry about commuting.', image: null, featured: 0, created_at: new Date().toISOString() }
  ];

  for (let s of stories) {
    await db.collection('success_stories').add(s);
  }

  // ---- Forum Community Posts ----
  console.log('[DocStep Seed] Creating Community Posts...');
  const posts = [
    { title: 'How did you regain confidence after your career break?', content: 'I took a 4-year break and feel nervous about returning to clinical decisions. Would love to hear how others handled the first few weeks back.', category: 'Returning to Practice' },
    { title: 'Best telemedicine setup at home?', content: 'Looking for advice on lighting, mic, and a secure video platform for online consultations from home.', category: 'Telemedicine' },
    { title: 'Recommended CBT certifications in Pakistan?', content: 'Are there any short, recognized CBT certifications I can do online while caring for my toddler?', category: 'Mental Health' },
    { title: 'Sharing my returnship experience at Shifa', content: 'Just completed the 6-month return-to-work program. Happy to answer any questions for other doctors thinking of applying.', category: 'Returnship' }
  ];

  for (let i = 0; i < posts.length; i++) {
    const doctorUserId = doctorUserIds[i % doctorUserIds.length];
    await dbService.createCommunityPost(doctorUserId, posts[i].title, posts[i].content, posts[i].category);
  }

  // ---- Sample Applications & Interviews ----
  console.log('[DocStep Seed] Creating Applications & Interviews...');
  const a1 = await dbService.createApplication(jobIds[0], doctorProfileIds[0], 'I am very interested in your tele-gynae role and have 8 years of clinical experience.');
  await dbService.updateApplicationStatus(a1, 'shortlisted');
  
  const a2 = await dbService.createApplication(jobIds[1], doctorProfileIds[1], 'Excited about the evening pediatric role — fits my family schedule perfectly.');
  
  const a3 = await dbService.createApplication(jobIds[3], doctorProfileIds[2], 'CBT-trained psychiatrist eager to join your women-only mental health team.');
  
  const a4 = await dbService.createApplication(jobIds[4], doctorProfileIds[3], 'Tele-dermatology is exactly where I want to take my career next.');

  await dbService.createInterview({
    application_id: a1,
    scheduled_at: '2026-06-12T14:00:00Z',
    mode: 'Video',
    location: 'Zoom link in email',
    notes: 'First-round interview with Dr. Hassan'
  });

  await dbService.createInterview({
    application_id: a3,
    scheduled_at: '2026-06-10T11:00:00Z',
    mode: 'Video',
    location: 'Google Meet',
    notes: 'Final round'
  });

  console.log('[DocStep Seed] Firestore seeding successfully completed!');
  console.log(' - Admin: admin@docstep.pk / admin123');
  console.log(' - Doctor: ayesha.khan@docstep.pk / password123');
  console.log(' - Employer: hello@shifahealth.pk / password123');
}

module.exports = { runSeed };

// Execute if run directly from terminal
if (require.main === module) {
  runSeed().then(() => process.exit(0)).catch(e => {
    console.error('Seed run failed:', e);
    process.exit(1);
  });
}
