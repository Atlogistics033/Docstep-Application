import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import axios from 'axios';
import Sidebar from '../components/Sidebar';
import { AlertTriangle, Clock, Calendar, CheckSquare, Sparkles } from 'lucide-react';

export default function DoctorDashboard() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    axios.get('/api/doctor/dashboard')
      .then((res) => {
        if (res.data.success) {
          setData(res.data);
        } else {
          setError(res.data.error || 'Failed to load dashboard.');
        }
      })
      .catch((err) => {
        setError(err.response?.data?.error || 'Failed to load dashboard.');
      })
      .finally(() => setLoading(false));
  }, []);

  if (loading) {
    return (
      <div className="max-w-7xl mx-auto px-4 py-20 text-center text-slate-500">
        Loading Doctor Portal...
      </div>
    );
  }

  if (error || !data) {
    return (
      <div className="max-w-7xl mx-auto px-4 py-20 text-center text-red-500">
        {error || 'An error occurred loading the dashboard.'}
      </div>
    );
  }

  const { profile, appointments, recommended, stats } = data;
  const firstName = data.profile?.full_name ? data.profile.full_name.split(' ')[0] : 'Doctor';

  const getStatusBadge = (status) => {
    const s = (status || 'scheduled').toLowerCase();
    if (s === 'cancelled' || s === 'cancel' || s === 'canceled') {
      return <span className="badge badge-red">Cancelled</span>;
    }
    if (s === 'rescheduled' || s === 'reschedule') {
      return <span className="badge badge-amber">Rescheduled</span>;
    }
    return <span className="badge badge-green">Scheduled</span>;
  };

  return (
    <section className="max-w-7xl mx-auto px-4 py-10 text-left fade-in">
      <div className="grid lg:grid-cols-[260px_1fr] gap-6">
        <Sidebar activeSide="home" />

        <div className="space-y-6">
          <div>
            <h1 className="font-display font-extrabold text-3xl text-navy-800">
              Welcome back, {firstName}!
            </h1>
            <p className="text-slate-600">Here's your career-restart snapshot.</p>
          </div>

          {/* Stats Cards */}
          <div className="grid sm:grid-cols-3 gap-4">
            <div className="card card-pad">
              <div className="stat-lab">Appointments</div>
              <div className="stat-num">{stats.appointments}</div>
            </div>
            <div className="card card-pad">
              <div className="stat-lab">Verified Credentials</div>
              <div className="stat-num">{stats.verifiedCredentials}</div>
            </div>
            <div className="card card-pad">
              <div className="stat-lab">Credentials</div>
              <div className="stat-num">{stats.credentials}</div>
            </div>
          </div>

          {/* Warning Card */}
          {!profile.pmdc_number && (
            <div className="card card-pad border border-amber-300 bg-amber-50/60">
              <div className="flex items-start gap-3">
                <div className="w-10 h-10 rounded-full bg-amber-100 text-amber-700 flex items-center justify-center shrink-0 font-bold">
                  !
                </div>
                <div className="flex-1">
                  <div className="font-semibold text-navy-800">Complete your profile to get matched</div>
                  <p className="text-sm text-slate-600 mt-1">
                    Add your PMDC number, specialty, and upload credentials to start receiving job matches.
                  </p>
                  <Link to="/doctor/profile" className="btn btn-primary mt-3 text-sm">
                    Complete profile
                  </Link>
                </div>
              </div>
            </div>
          )}

          {/* Recent Appointments Panel */}
          <div className="card card-pad bg-white">
            <div className="flex items-center justify-between mb-4">
              <h2 className="font-display font-bold text-xl text-navy-800">Recent appointments</h2>
              <Link to="/doctor/appointments" className="text-sm text-teal-700 font-semibold hover:underline">
                View all
              </Link>
            </div>
            {!appointments || appointments.length === 0 ? (
              <div className="text-sm text-slate-500">
                You have no scheduled appointments yet.
              </div>
            ) : (
              <div className="divide-y divide-slate-100">
                {appointments.map((a) => (
                  <div key={a.id} className="py-3 flex items-center justify-between gap-3">
                    <div className="min-w-0">
                      <div className="font-semibold text-navy-800 truncate">{a.patient_name}</div>
                      <div className="text-xs text-slate-500">
                        {new Date(a.date).toLocaleDateString()} • {a.time_slot}
                      </div>
                    </div>
                    {getStatusBadge(a.status)}
                  </div>
                ))}
              </div>
            )}
          </div>

          {/* Recommended Jobs */}
          <div className="card card-pad bg-white">
            <div className="flex items-center justify-between mb-4">
              <h2 className="font-display font-bold text-xl text-navy-800 flex items-center gap-1.5">
                <Sparkles className="w-5 h-5 text-teal-500" /> Recommended for you
              </h2>
            </div>
            {recommended.length === 0 ? (
              <div className="text-sm text-slate-500">
                No recommended jobs yet. Add details to your profile to get matches.
              </div>
            ) : (
              <div className="grid md:grid-cols-2 gap-3">
                {recommended.map((j) => (
                  <Link
                    key={j.id}
                    to={`/jobs/${j.id}`}
                    className="border border-slate-100 hover:border-teal-300 rounded-lg p-4 block transition hover:no-underline"
                  >
                    <div className="font-semibold text-navy-800">{j.title}</div>
                    <div className="text-xs text-slate-500">
                      {j.organization_name} • {j.city}
                    </div>
                    <div className="flex gap-2 mt-2">
                      <span className="badge badge-teal">{j.mode}</span>
                      <span className="badge badge-lavender">{j.job_type}</span>
                    </div>
                  </Link>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    </section>
  );
}
