import React, { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { LogIn, Eye, EyeOff } from 'lucide-react';

export default function Login() {
  const { user, login } = useAuth();
  const navigate = useNavigate();

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);

  // If already logged in, redirect
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
    const res = await login(email, password);
    setLoading(false);
  };

  return (
    <section className="hero-gradient min-h-[80vh] flex items-center py-12 text-left">
      <div className="max-w-5xl mx-auto px-4 grid lg:grid-cols-2 gap-10 items-center w-full">
        <div>
          <Link to="/" className="logo-mark mb-6 inline-flex" style={{ gap: '0.8rem' }}>
            <img src="/images/logo.png" alt="DocStep" className="h-[52px] w-auto" />
            <div className="wordmark" style={{ fontSize: '1.95rem' }}>Doc<span>Step</span></div>
          </Link>
          <h1 className="font-display font-extrabold text-4xl text-navy-800">Welcome back.</h1>
          <p className="text-slate-600 mt-3">Login to manage your appointments, jobs, profile, and conversations.</p>
        </div>

        <div className="card card-pad bg-white">
          <h2 className="font-display font-bold text-2xl text-navy-800 mb-5">Login</h2>
          <form onSubmit={handleSubmit} className="space-y-4">
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
              <div className="flex justify-between items-center mb-1">
                <label className="label mb-0">Password</label>
                <Link to="/forgot-password" style={{ fontSize: '0.75rem' }} className="text-teal-600 hover:text-teal-700 font-semibold hover:underline">
                  Forgot password?
                </Link>
              </div>
              <div className="relative">
                <input
                  type={showPassword ? 'text' : 'password'}
                  required
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
            <button type="submit" disabled={loading} className="btn btn-primary w-full justify-center text-sm">
              <LogIn className="w-4 h-4 mr-1.5" />
              {loading ? 'Logging in...' : 'Login'}
            </button>
          </form>
          <div className="text-center text-sm text-slate-500 mt-5">
            New to DocStep? <Link to="/register" className="text-teal-700 font-semibold hover:underline">Create an account</Link>
          </div>
        </div>
      </div>
    </section>
  );
}
