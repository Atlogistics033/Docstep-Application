import React from 'react';
import { Link } from 'react-router-dom';
import { CheckCircle2 } from 'lucide-react';

export default function ForEmployers() {
  const steps = [
    { num: 'Step 1', title: 'Post a role in minutes', desc: 'Specialty, mode, salary, requirements — done in 60 seconds.', color: 'text-lavender-700' },
    { num: 'Step 2', title: 'Browse verified candidates', desc: 'PMDC-verified profiles, with CVs and credentials at your fingertips.', color: 'text-teal-700' },
    { num: 'Step 3', title: 'Interview & hire', desc: 'Schedule interviews, track applications, and hire — all from your dashboard.', color: 'text-navy-800' }
  ];

  const benefits = [
    { title: 'PMDC-verified only', desc: 'We verify every doctor against their PMDC registration before publishing their profile.' },
    { title: 'Flexible-first talent', desc: 'Every doctor on DocStep is open to remote, hybrid, or part-time arrangements.' },
    { title: 'Highly experienced', desc: 'Average 5+ years of clinical experience across gynae, peds, psychiatry, and GP.' },
    { title: 'Faster matching', desc: 'Smart filters and AI matching surface only the most relevant candidates.' },
    { title: 'Diversity-positive hiring', desc: 'Strengthen your gender balance with returning women medical leaders.' },
    { title: 'CSR-aligned partnerships', desc: "Co-design returnship programs and women's-health initiatives with us." }
  ];

  return (
    <div className="fade-in">
      {/* Hero Header */}
      <section className="hero-gradient">
        <div className="max-w-7xl mx-auto px-4 pt-16 pb-20 grid lg:grid-cols-2 gap-12 items-center">
          <div className="text-left">
            <div className="brand-pill mb-4">For Employers</div>
            <h1 className="font-display font-extrabold text-4xl md:text-5xl text-navy-800 leading-tight">
              Hire verified women doctors — <span className="text-lavender-700">on flexible terms.</span>
            </h1>
            <p className="text-lg text-slate-600 mt-5 leading-relaxed">
              Tap into a vetted pool of returning gynecologists, pediatricians, psychiatrists, and GPs ready for remote, hybrid, and part-time roles.
            </p>
            <div className="flex gap-3 mt-7">
              <Link to="/register?role=employer" className="btn btn-lavender text-sm">
                Post your first job
              </Link>
              <Link to="/contact" className="btn btn-outline text-sm">
                Talk to our team
              </Link>
            </div>
          </div>
          <div className="space-y-3 text-left">
            {steps.map((s, idx) => (
              <div key={idx} className="card card-pad bg-white">
                <div className={`text-xs uppercase tracking-wider font-bold ${s.color}`}>
                  {s.num}
                </div>
                <div className="font-display font-bold text-lg text-navy-800 mt-1">{s.title}</div>
                <div className="text-sm text-slate-600 mt-1">{s.desc}</div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Benefits */}
      <section className="max-w-7xl mx-auto px-4 py-20 text-left">
        <div className="text-center mb-12">
          <div className="brand-pill mb-3">Why hire on DocStep</div>
          <h2 className="font-display font-bold text-3xl text-navy-800">
            A pool you can't reach anywhere else
          </h2>
        </div>
        <div className="grid md:grid-cols-3 gap-5">
          {benefits.map((b, idx) => (
            <div key={idx} className="card card-pad">
              <div className="w-10 h-10 rounded-lg bg-lavender-100 text-lavender-700 flex items-center justify-center mb-3">
                <CheckCircle2 className="w-5 h-5" />
              </div>
              <div className="font-semibold text-navy-800 mb-1">{b.title}</div>
              <div className="text-sm text-slate-600">{b.desc}</div>
            </div>
          ))}
        </div>
      </section>

      {/* Pricing */}
      <section className="section-lavender py-20 text-left">
        <div className="max-w-5xl mx-auto px-4">
          <div className="text-center mb-10">
            <div className="brand-pill mb-3">Pricing — coming soon</div>
            <h2 className="font-display font-bold text-3xl text-navy-800">
              Simple, transparent plans
            </h2>
          </div>
          <div className="grid md:grid-cols-3 gap-5">
            <div className="card card-pad bg-white">
              <span className="badge badge-gray mb-2">Free</span>
              <div className="stat-num">PKR 0</div>
              <div className="text-sm text-slate-500">Post up to 1 job. Browse public profiles.</div>
              <ul className="text-sm text-slate-600 mt-4 space-y-2">
                <li>✓ 1 active job posting</li>
                <li>✓ Basic candidate search</li>
                <li>✓ Email notifications</li>
              </ul>
            </div>
            <div className="card card-pad bg-white border-2 border-teal-500">
              <span className="badge badge-teal mb-2">Growth</span>
              <div className="stat-num">
                PKR 9,900<span className="text-sm font-medium">/mo</span>
              </div>
              <div className="text-sm text-slate-500">Most popular for clinics & telehealth.</div>
              <ul className="text-sm text-slate-600 mt-4 space-y-2">
                <li>✓ 10 active job postings</li>
                <li>✓ Full candidate search & filters</li>
                <li>✓ Interview scheduling tools</li>
                <li>✓ Featured listing badges</li>
              </ul>
            </div>
            <div className="card card-pad bg-white">
              <span className="badge badge-lavender mb-2">Enterprise</span>
              <div className="stat-num">Custom</div>
              <div className="text-sm text-slate-500">Hospital networks & telehealth platforms.</div>
              <ul className="text-sm text-slate-600 mt-4 space-y-2">
                <li>✓ Unlimited postings & seats</li>
                <li>✓ Returnship program co-design</li>
                <li>✓ API & ATS integrations</li>
                <li>✓ Dedicated success manager</li>
              </ul>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
}
