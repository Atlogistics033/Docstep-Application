import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import axios from 'axios';
import { ArrowRight, User, CheckCircle2, ShieldAlert, BookOpen, Users, Compass, ExternalLink, Building } from 'lucide-react';

export default function Home() {
  const [stats, setStats] = useState({ doctors: 0, jobs: 0, employers: 0 });
  const [featuredJobs, setFeaturedJobs] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    Promise.all([
      axios.get('/api/public/stats'),
      axios.get('/api/public/jobs')
    ])
      .then(([statsRes, jobsRes]) => {
        if (statsRes.data.success) setStats(statsRes.data.stats);
        if (jobsRes.data.success) setFeaturedJobs(jobsRes.data.jobs.slice(0, 4));
      })
      .catch((err) => console.error('Error loading home page content', err))
      .finally(() => setLoading(false));
  }, []);

  return (
    <div className="fade-in">
      {/* Hero Section */}
      <section className="hero-gradient relative overflow-hidden" style={{ marginTop: '-73px' }}>
        {/* Background Image Layer */}
        <div className="absolute inset-0 z-0">
          <img src="/images/hero_doctors.jpg" alt="Medical Team" className="w-full h-full object-cover object-[right_center] lg:object-[80%_center]" />
        </div>

        {/* Gradient Overlay Layer */}
        {/* On desktop: fades light teal from left to right to create clean space for text */}
        <div className="absolute inset-y-0 left-0 w-3/5 z-10 bg-gradient-to-r from-[#E0F4F3] via-[#E0F4F3]/90 to-transparent pointer-events-none hidden lg:block"></div>
        {/* On desktop: soft fade at the bottom to transition to the next section */}
        <div className="absolute inset-x-0 bottom-0 z-10 h-24 bg-gradient-to-t from-[#F4F8FA] to-transparent pointer-events-none hidden lg:block"></div>
        {/* On mobile: solid light teal semi-transparent background to ensure text readability */}
        <div className="absolute inset-0 z-10 bg-[#E0F4F3]/92 pointer-events-none lg:hidden"></div>

        {/* Content Layer */}
        <div className="max-w-7xl mx-auto px-4 grid lg:grid-cols-2 gap-12 items-center relative z-20">
          <div className="pt-24 lg:pt-36 pb-20 flex flex-col justify-center">
            <div className="brand-pill bg-teal-50 text-teal-800 border border-teal-100 px-4 py-1.5 rounded-full inline-flex items-center gap-2 mb-6 text-sm font-semibold self-start">
              <svg className="w-4 h-4 text-teal-600 animate-pulse" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"/></svg>
              Empowering Women in Healthcare
            </div>
            <h1 className="font-display font-extrabold text-4xl md:text-5xl lg:text-6xl text-navy-800 leading-tight">
              Your medical journey <br className="hidden lg:block" />
              doesn't end after a <br className="hidden lg:block" />
              <span className="bg-gradient-to-r from-teal-600 to-teal-800 bg-clip-text text-transparent">career break.</span>
            </h1>
            <p className="text-lg text-slate-600 mt-6 leading-relaxed max-w-xl">
              DocStep helps women doctors return to practice through flexible jobs, structured training, mentorship, and verified telemedicine opportunities — on your schedule, on your terms.
            </p>
            
            <div className="flex flex-wrap gap-4 mt-8">
              <Link to="/register?role=doctor" className="btn btn-primary text-sm flex items-center shadow-lg shadow-teal-500/20">
                I'm a Doctor — Get Started
                <ArrowRight className="w-4 h-4 ml-1.5" />
              </Link>
              <Link to="/register?role=employer" className="btn btn-outline text-sm border-slate-300 hover:border-teal-500">
                I'm Hiring Doctors
              </Link>
            </div>

            <div className="bg-white/80 backdrop-blur-md border border-slate-200/50 rounded-2xl p-4 shadow-xl shadow-navy-800/5 mt-12 max-w-lg grid grid-cols-3 gap-4">
              <div className="text-center border-r border-slate-100 last:border-0">
                <div className="stat-num text-2xl lg:text-3xl text-teal-600 font-extrabold">{stats.doctors || 0}+</div>
                <div className="stat-lab text-xs text-slate-500 font-semibold mt-1">Verified Doctors</div>
              </div>
              <div className="text-center border-r border-slate-100 last:border-0">
                <div className="stat-num text-2xl lg:text-3xl text-teal-600 font-extrabold">{stats.jobs || 0}</div>
                <div className="stat-lab text-xs text-slate-500 font-semibold mt-1">Open Roles</div>
              </div>
              <div className="text-center last:border-0">
                <div className="stat-num text-2xl lg:text-3xl text-teal-600 font-extrabold">{stats.employers || 0}+</div>
                <div className="stat-lab text-xs text-slate-500 font-semibold mt-1">Hiring Partners</div>
              </div>
            </div>
          </div>
          <div className="hidden lg:block"></div>
        </div>
      </section>

      {/* Who it's for */}
      <section className="max-w-7xl mx-auto px-4 py-20">
        <div className="text-center max-w-2xl mx-auto mb-12">
          <div className="brand-pill mb-3">Who DocStep is for</div>
          <h2 className="font-display font-bold text-3xl md:text-4xl text-navy-800">
            Built for every step of your medical journey
          </h2>
        </div>
        <div className="grid md:grid-cols-3 gap-6">
          <div className="card card-pad flex flex-col justify-between">
            <div>
              <div className="w-12 h-12 bg-teal-50 rounded-xl flex items-center justify-center text-teal-600 mb-4">
                <CheckCircle2 className="w-6 h-6" />
              </div>
              <h3 className="font-display font-bold text-xl text-navy-800 mb-2">Women Doctors</h3>
              <p className="text-slate-600 text-sm leading-relaxed">
                Returning after a career gap? Seeking remote or flexible roles? Rebuild your confidence with training, mentorship, and verified opportunities.
              </p>
            </div>
            <Link to="/for-doctors" className="text-teal-600 font-semibold text-sm mt-4 inline-flex items-center gap-1 self-start">
              For Doctors →
            </Link>
          </div>
          <div className="card card-pad flex flex-col justify-between">
            <div>
              <div className="w-12 h-12 bg-lavender-100 rounded-xl flex items-center justify-center text-lavender-700 mb-4">
                <Building className="w-6 h-6" />
              </div>
              <h3 className="font-display font-bold text-xl text-navy-800 mb-2">Hospitals & Clinics</h3>
              <p className="text-slate-600 text-sm leading-relaxed">
                Hire verified women doctors for flexible, hybrid, or remote roles. Build a compassionate team without compromising on quality of care.
              </p>
            </div>
            <Link to="/for-employers" className="text-lavender-700 font-semibold text-sm mt-4 inline-flex items-center gap-1 self-start">
              For Employers →
            </Link>
          </div>
          <div className="card card-pad flex flex-col justify-between">
            <div>
              <div className="w-12 h-12 bg-navy-800/10 rounded-xl flex items-center justify-center text-navy-800 mb-4">
                <Compass className="w-6 h-6" />
              </div>
              <h3 className="font-display font-bold text-xl text-navy-800 mb-2">Training Partners & NGOs</h3>
              <p className="text-slate-600 text-sm leading-relaxed">
                Training institutes, telehealth companies, and NGOs collaborate with us to deliver returnship programs, courses, and community outreach.
              </p>
            </div>
            <Link to="/about" className="text-navy-800 font-semibold text-sm mt-4 inline-flex items-center gap-1 self-start">
              Partner with us →
            </Link>
          </div>
        </div>
      </section>

      {/* Core Features */}
      <section className="section-soft py-20">
        <div className="max-w-7xl mx-auto px-4">
          <div className="text-center max-w-2xl mx-auto mb-12">
            <div className="brand-pill mb-3">Core Features</div>
            <h2 className="font-display font-bold text-3xl md:text-4xl text-navy-800">
              Everything you need to restart, hire, and grow
            </h2>
          </div>
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-5">
            {[
              { title: 'Smart AI Job Matching', desc: 'Recommend roles by specialty, availability, mode, and career stage.', color: '#8E7AC9' },
              { title: 'Resume / CV Builder', desc: 'A guided builder tailored for women returning to clinical practice.', color: '#1F7B79' },
              { title: 'Mentorship & Community', desc: 'Peer threads, mentor connects, and supportive returnship circles.', color: '#5C4A98' },
              { title: 'Telemedicine Integration', desc: 'Hooks into video tools so consultations can happen securely from home.', color: '#2BA3A0' },
              { title: 'Notifications & Messaging', desc: 'Real-time updates on applications, interviews, and replies.', color: '#16243F' },
            ].map((f, i) => (
              <div key={i} className="card card-pad">
                <div
                  className="w-10 h-10 rounded-lg mb-4 flex items-center justify-center"
                  style={{ backgroundColor: `${f.color}15`, color: f.color }}
                >
                  <CheckCircle2 className="w-5 h-5" />
                </div>
                <h3 className="font-semibold text-lg text-navy-800 mb-1">{f.title}</h3>
                <p className="text-sm text-slate-600 leading-relaxed">{f.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>


      {/* CTA */}
      <section className="section-teal py-20">
        <div className="max-w-5xl mx-auto px-4 text-center">
          <h2 className="font-display font-extrabold text-3xl md:text-5xl">
            Restart your career. Reshape healthcare.
          </h2>
          <p className="text-lg text-teal-50 mt-5 max-w-2xl mx-auto">
            Join hundreds of women doctors who are practising again — on flexible, supportive, verified terms.
          </p>
          <div className="flex flex-wrap gap-3 justify-center mt-8">
            <Link to="/register?role=doctor" className="btn bg-white text-teal-700 hover:bg-teal-50">
              Create your free doctor profile
            </Link>
            <Link to="/register?role=employer" className="btn btn-lavender">
              Hire on DocStep
            </Link>
          </div>
        </div>
      </section>
    </div>
  );
}
