import React from 'react';
import { Link } from 'react-router-dom';

export default function Footer() {
  const currentYear = new Date().getFullYear();

  return (
    <footer className="footer mt-24">
      <div className="max-w-7xl mx-auto px-4 py-14 grid md:grid-cols-4 gap-10">
        <div>
          <div className="flex items-center gap-2 mb-4">
            <img src="/images/logo.png" alt="DocStep" className="h-9 brightness-0 invert" />
            <div className="font-display font-extrabold text-xl text-white">
              Doc<span className="text-teal-400">Step</span>
            </div>
          </div>
          <p className="text-sm text-slate-300 leading-relaxed">
            A platform helping women doctors restart their medical careers through flexible jobs, training, mentorship, and telemedicine opportunities.
          </p>
          <p className="text-xs text-slate-400 mt-4 italic">
            "Your medical journey doesn't end after a career break."
          </p>
        </div>

        <div>
          <h4 className="text-white font-semibold mb-3 text-sm uppercase tracking-wider">Platform</h4>
          <ul className="space-y-2 text-sm">
            <li><Link to="/opportunities">Book Appointment</Link></li>
            <li><Link to="/courses">Courses & Training</Link></li>
            <li><Link to="/community">Community</Link></li>
          </ul>
        </div>

        <div>
          <h4 className="text-white font-semibold mb-3 text-sm uppercase tracking-wider">Audience</h4>
          <ul className="space-y-2 text-sm">
            <li><Link to="/for-doctors">For Doctors</Link></li>
            <li><Link to="/for-employers">For Employers</Link></li>
            <li><Link to="/register?role=doctor">Doctor Sign-up</Link></li>
            <li><Link to="/register?role=employer">Employer Sign-up</Link></li>
          </ul>
        </div>

        <div>
          <h4 className="text-white font-semibold mb-3 text-sm uppercase tracking-wider">Company</h4>
          <ul className="space-y-2 text-sm">
            <li><Link to="/about">About DocStep</Link></li>
            <li><Link to="/contact">Contact</Link></li>
          </ul>
        </div>
      </div>

      <div className="border-t border-white/10">
        <div className="max-w-7xl mx-auto px-4 py-5 flex flex-col md:flex-row items-center justify-between gap-3 text-xs text-slate-400">
          <div>© {currentYear} DocStep. All rights reserved.</div>
          <div className="flex items-center gap-4">
            <span>Empowering Women in Healthcare</span>
          </div>
        </div>
      </div>
    </footer>
  );
}
