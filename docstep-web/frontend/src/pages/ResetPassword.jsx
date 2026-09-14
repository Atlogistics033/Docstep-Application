import React, { useState } from 'react';
import { useSearchParams, Link, useNavigate } from 'react-router-dom';
import axios from 'axios';
import { useAuth } from '../context/AuthContext';
import { ArrowLeft, Eye, EyeOff } from 'lucide-react';

export default function ResetPassword() {
  const [searchParams] = useSearchParams();
  const token = searchParams.get('token') || '';
  const navigate = useNavigate();
  const { showFlash } = useAuth();

  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [showPassword, setShowPassword] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!token) {
      setError('Missing token. Please request a new password reset link.');
      return;
    }
    if (password.length < 6) {
      setError('Password must be at least 6 characters.');
      return;
    }

    setLoading(true);
    setError('');

    try {
      const res = await axios.post('/api/auth/reset-password', { token, password });
      if (res.data.success) {
        showFlash('success', 'Your password has been reset successfully. Please log in.');
        navigate('/login');
      } else {
        setError(res.data.error || 'Failed to reset password.');
      }
    } catch (err) {
      setError(err.response?.data?.error || 'An error occurred. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <section className="hero-gradient min-h-[80vh] flex items-center py-12 text-left">
      <div className="max-w-md mx-auto px-4 w-full">
        <div className="text-center mb-6">
          <Link to="/" className="logo-mark inline-flex justify-center mb-4" style={{ gap: '0.8rem' }}>
            <img src="/images/logo.png" alt="DocStep" className="h-[52px] w-auto" />
            <div className="wordmark" style={{ fontSize: '1.95rem' }}>Doc<span>Step</span></div>
          </Link>
          <h1 className="font-display font-extrabold text-3xl text-navy-800">Reset Password</h1>
          <p className="text-slate-600 mt-2 text-sm">Please set your new password below.</p>
        </div>

        <div className="card card-pad bg-white shadow-sm border border-slate-100 rounded-2xl p-6">
          {!token && (
            <div className="mb-4 p-3 bg-red-50 border border-red-200 text-red-700 text-sm rounded-xl text-center">
              Invalid or missing password reset token. Please request a new link.
              <div className="mt-3">
                <Link to="/forgot-password" className="btn btn-outline text-xs">Forgot Password</Link>
              </div>
            </div>
          )}

          {token && (
            <>
              {error && (
                <div className="mb-4 p-3 bg-red-50 border border-red-200 text-red-700 text-sm rounded-xl">
                  {error}
                </div>
              )}

              <form onSubmit={handleSubmit} className="space-y-4">
                <div>
                  <label className="label block text-sm font-semibold text-slate-700 mb-1">New Password</label>
                  <div className="relative">
                    <input
                      type={showPassword ? 'text' : 'password'}
                      required
                      value={password}
                      onChange={(e) => setPassword(e.target.value)}
                      placeholder="Min 6 characters"
                      minLength={6}
                      className="input w-full px-4 py-2 pr-10 border border-slate-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-teal-500 focus:border-teal-500"
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
                <button
                  type="submit"
                  disabled={loading}
                  className="btn btn-primary w-full justify-center py-2 px-4 rounded-xl font-semibold text-white bg-teal-600 hover:bg-teal-700 transition-colors"
                >
                  {loading ? 'Resetting...' : 'Reset Password'}
                </button>
              </form>
            </>
          )}

          <div className="text-center text-sm text-slate-500 mt-5 pt-4 border-t border-slate-100">
            <Link to="/login" className="text-teal-700 font-semibold hover:underline flex items-center justify-center gap-1">
              <ArrowLeft className="w-4 h-4" /> Back to Login
            </Link>
          </div>
        </div>
      </div>
    </section>
  );
}
