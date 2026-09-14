import React, { useState, useEffect } from 'react';
import { Link, useNavigate, useSearchParams } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { UserPlus, Eye, EyeOff } from 'lucide-react';

export default function Register() {
  const { user, register } = useAuth();
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();

  // Role can be toggled
  const [role, setRole] = useState(searchParams.get('role') === 'employer' ? 'employer' : 'doctor');

  // Sync state if url query changes
  useEffect(() => {
    const urlRole = searchParams.get('role');
    if (urlRole === 'employer' || urlRole === 'doctor') {
      setRole(urlRole);
    }
  }, [searchParams]);

  // Form states
  const [fullName, setFullName] = useState('');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [password, setPassword] = useState('');
  const [city, setCity] = useState('');
  const [specialty, setSpecialty] = useState('General Practice');
  const [organizationName, setOrganizationName] = useState('');
  const [loading, setLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);

  // If user session exists, redirect
  useEffect(() => {
    if (user) {
      if (user.role === 'doctor') navigate('/doctor/dashboard');
      else if (user.role === 'employer') navigate('/employer/dashboard');
      else if (user.role === 'admin') navigate('/admin/dashboard');
      else navigate('/');
    }
  }, [user, navigate]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    const payload = {
      email,
      password,
      full_name: fullName,
      role,
      phone,
      city,
      ...(role === 'doctor' ? { specialty } : { organization_name: organizationName })
    };
    await register(payload);
    setLoading(false);
  };

  return (
    <section className="hero-gradient min-h-[80vh] py-12 text-left">
      <div className="max-w-3xl mx-auto px-4 w-full">
        <Link to="/" className="logo-mark mb-6 inline-flex" style={{ gap: '0.8rem' }}>
          <img src="/images/logo.png" alt="DocStep" className="h-[52px] w-auto" />
          <div className="wordmark" style={{ fontSize: '1.95rem' }}>Doc<span>Step</span></div>
        </Link>
        <h1 className="font-display font-extrabold text-3xl text-navy-800">Create your DocStep account</h1>
        <p className="text-slate-600 mt-2">Free, takes under a minute.</p>

        <div className="card card-pad mt-8 bg-white">
          <div className="flex bg-slate-100 rounded-lg p-1 mb-6 max-w-md">
            <button
              type="button"
              onClick={() => setRole('doctor')}
              className={`flex-1 text-center py-2 rounded-md text-sm font-semibold transition-all cursor-pointer ${
                role === 'doctor' ? 'bg-white shadow text-teal-700 font-bold' : 'text-slate-500'
              }`}
            >
              I'm a Doctor
            </button>
            <button
              type="button"
              onClick={() => setRole('employer')}
              className={`flex-1 text-center py-2 rounded-md text-sm font-semibold transition-all cursor-pointer ${
                role === 'employer' ? 'bg-white shadow text-lavender-700 font-bold' : 'text-slate-500'
              }`}
            >
              I'm an Employer
            </button>
          </div>

          <form onSubmit={handleSubmit} className="grid md:grid-cols-2 gap-4">
            <div className="md:col-span-2">
              <label className="label">
                {role === 'doctor' ? 'Full name' : 'Your name (HR contact)'}
              </label>
              <input
                required
                value={fullName}
                onChange={(e) => setFullName(e.target.value)}
                className="input"
              />
            </div>
            <div>
              <label className="label">Email</label>
              <input
                type="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="input"
              />
            </div>
            <div>
              <label className="label">Phone</label>
              <input
                value={phone}
                onChange={(e) => setPhone(e.target.value)}
                className="input"
                placeholder="+92-3XX-XXXXXXX"
              />
            </div>
            <div>
              <label className="label">Password</label>
              <div className="relative">
                <input
                  type={showPassword ? 'text' : 'password'}
                  required
                  minLength={6}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="input pr-10 w-full"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute inset-y-0 right-0 pr-3 flex items-center text-slate-400 hover:text-slate-600 focus:outline-none"
                >
                  {showPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
                </button>
              </div>
            </div>
            <div>
              <label className="label">City</label>
              <input
                value={city}
                onChange={(e) => setCity(e.target.value)}
                className="input"
                placeholder="e.g. Karachi"
              />
            </div>

            {role === 'doctor' ? (
              <div className="md:col-span-2">
                <label className="label">Primary specialty</label>
                <select
                  value={specialty}
                  onChange={(e) => setSpecialty(e.target.value)}
                  className="select"
                >
                  <option>General Practice</option>
                  <option>Gynecology</option>
                  <option>Pediatrics</option>
                  <option>Psychiatry</option>
                  <option>Dermatology</option>
                  <option>Internal Medicine</option>
                  <option>Cardiology</option>
                  <option>Other</option>
                </select>
              </div>
            ) : (
              <div className="md:col-span-2">
                <label className="label">Organization name</label>
                <input
                  required
                  value={organizationName}
                  onChange={(e) => setOrganizationName(e.target.value)}
                  className="input"
                />
              </div>
            )}

            <div className="md:col-span-2 flex items-center gap-3 mt-3">
              <button
                type="submit"
                disabled={loading}
                className={`btn text-sm ${role === 'doctor' ? 'btn-primary' : 'btn-lavender'}`}
              >
                <UserPlus className="w-4 h-4 mr-1.5" />
                {loading ? 'Creating...' : 'Create account'}
              </button>
              <Link to="/login" className="text-sm text-slate-500 hover:underline">
                Already have an account? <span className="text-teal-700 font-semibold">Login</span>
              </Link>
            </div>
          </form>
        </div>
      </div>
    </section>
  );
}
