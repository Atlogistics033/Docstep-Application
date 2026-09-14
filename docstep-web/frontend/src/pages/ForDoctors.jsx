import React from 'react';
import { Link } from 'react-router-dom';
import { ArrowRight, CheckCircle2 } from 'lucide-react';

export default function ForDoctors() {
  const steps = [
    { title: 'Sign up & verify', desc: 'Create your free account, upload your PMDC certificate and medical degrees.' },
    { title: 'Build your CV', desc: 'Use our guided builder — designed for doctors with career gaps.' },
    { title: 'Match & apply', desc: 'Get matched to flexible, hybrid, and remote roles from verified employers.' },
    { title: 'Practice on your terms', desc: 'Set your availability, conduct telemedicine, and grow your career.' }
  ];

  const benefits = [
    { title: 'Verified PMDC profile', desc: 'We verify your license and qualifications so employers can trust your profile instantly.' },
    { title: 'Guided CV builder', desc: 'Pre-built sections for career gaps, returnship programs, and refresher training.' },
    { title: 'Flexible jobs only', desc: 'Remote, hybrid, part-time, and returnship roles — never the rigid 9–9 grind.' },
    { title: 'Free training courses', desc: 'Refresher courses on telemedicine, CBT, ultrasound, and licensing.' },
    { title: 'Private community', desc: 'Discuss returning to practice with peers who genuinely understand.' },
    { title: 'Interview & messaging', desc: 'Direct messages, interview scheduling, and notifications — all in one dashboard.' }
  ];

  return (
    <div className="fade-in">
      {/* Hero Header */}
      <section className="hero-gradient">
        <div className="max-w-7xl mx-auto px-4 pt-16 pb-20 grid lg:grid-cols-2 gap-12 items-center">
          <div className="text-left">
            <div className="brand-pill mb-4">For Doctors</div>
            <h1 className="font-display font-extrabold text-4xl md:text-5xl text-navy-800 leading-tight">
              A platform built around <span className="text-teal-600">your reality.</span>
            </h1>
            <p className="text-lg text-slate-600 mt-5 leading-relaxed">
              Whether you took a break for marriage, motherhood, relocation, or burnout — DocStep helps you re-enter clinical practice on flexible, dignified terms.
            </p>
            <div className="flex gap-3 mt-7">
              <Link to="/register?role=doctor" className="btn btn-primary text-sm">
                Create your free profile
              </Link>
              <Link to="/opportunities" className="btn btn-outline text-sm">
                Browse jobs
              </Link>
            </div>
          </div>
          <div className="card card-pad bg-white text-left">
            <h3 className="font-display font-bold text-lg text-navy-800 mb-4">In 4 simple steps</h3>
            <ol className="space-y-4">
              {steps.map((s, idx) => (
                <li key={idx} className="flex gap-4">
                  <div className="w-9 h-9 rounded-full bg-teal-600 text-white font-bold flex items-center justify-center shrink-0">
                    {idx + 1}
                  </div>
                  <div>
                    <div className="font-semibold text-navy-800">{s.title}</div>
                    <div className="text-sm text-slate-600">{s.desc}</div>
                  </div>
                </li>
              ))}
            </ol>
          </div>
        </div>
      </section>

      {/* Benefits Section */}
      <section className="max-w-7xl mx-auto px-4 py-20 text-left">
        <div className="text-center mb-12">
          <div className="brand-pill mb-3">What you get</div>
          <h2 className="font-display font-bold text-3xl text-navy-800">
            Built for returning, balancing, and growing
          </h2>
        </div>
        <div className="grid md:grid-cols-3 gap-5">
          {benefits.map((b, idx) => (
            <div key={idx} className="card card-pad">
              <div className="w-10 h-10 rounded-lg bg-teal-50 text-teal-600 flex items-center justify-center mb-3">
                <CheckCircle2 className="w-5 h-5" />
              </div>
              <div className="font-semibold text-navy-800 mb-1">{b.title}</div>
              <div className="text-sm text-slate-600">{b.desc}</div>
            </div>
          ))}
        </div>
      </section>

      {/* CTA Section */}
      <section className="section-teal py-20">
        <div className="max-w-4xl mx-auto px-4 text-center">
          <h2 className="font-display font-extrabold text-3xl md:text-4xl">
            Your medical journey doesn't end here.
          </h2>
          <p className="text-teal-50 mt-4 max-w-2xl mx-auto">
            Join the women rebuilding their careers — one consultation, one course, one connection at a time.
          </p>
          <Link to="/register?role=doctor" className="btn bg-white text-teal-700 hover:bg-teal-50 mt-7">
            Get started — it's free
          </Link>
        </div>
      </section>
    </div>
  );
}
