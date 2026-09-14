import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import axios from 'axios';
import { ArrowLeft } from 'lucide-react';

export default function ForgotPassword() {
  const [email, setEmail] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [resetLink, setResetLink] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    setResetLink('');

    try {
      const res = await axios.post('/api/auth/forgot-password', { email });
      if (res.data.success) {
        setResetLink(res.data.resetLink);
      } else {
        setError(res.data.error || 'Failed to generate reset link.');
      }
    } catch (err) {
      setError(err.response?.data?.error || 'An error occurred during password reset.');
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
          <h1 className="font-display font-extrabold text-3xl text-navy-800">Forgot Password</h1>
          <p className="text-slate-600 mt-2 text-sm">Enter your email and we'll help you reset your password.</p>
        </div>

        <div className="card card-pad bg-white shadow-sm border border-slate-100 rounded-2xl p-6">
          {error && (
            <div className="mb-4 p-3 bg-red-50 border border-red-200 text-red-700 text-sm rounded-xl">
              {error}
            </div>
          )}

          {resetLink && (
            <div className="mb-6 p-4 bg-teal-50 border border-teal-200 text-teal-800 rounded-xl text-center">
              <p className="font-semibold text-sm mb-2">Password reset link generated!</p>
              <p className="text-xs text-slate-500 mb-3">For demo & testing purposes, you can click the button below directly to set your new password:</p>
              <Link to={resetLink} className="btn btn-primary w-full justify-center text-sm py-2 bg-teal-600 hover:bg-teal-700 text-white font-semibold rounded-xl">
                Reset Password Now
              </Link>
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="label block text-sm font-semibold text-slate-700 mb-1">Email Address</label>
              <input
                type="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="name@example.com"
                className="input w-full px-4 py-2 border border-slate-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-teal-500 focus:border-teal-500"
              />
            </div>
            <button
              type="submit"
              disabled={loading}
              className="btn btn-primary w-full justify-center py-2 px-4 rounded-xl font-semibold text-white bg-teal-600 hover:bg-teal-700 transition-colors"
            >
              {loading ? 'Sending...' : 'Send Reset Link'}
            </button>
          </form>

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
