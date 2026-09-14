import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import axios from 'axios';
import Sidebar from '../components/Sidebar';
import { Briefcase, Users, Calendar, PlusCircle } from 'lucide-react';

export default function EmployerDashboard() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    axios.get('/api/employer/dashboard')
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
        Loading Employer Portal...
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

  const { profile, jobs, appointments, stats } = data;

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
          <div className="flex items-end justify-between">
            <div>
              <h1 className="font-display font-extrabold text-3xl text-navy-800">
                {profile.organization_name}
              </h1>
              <p className="text-slate-600">Your hiring at a glance.</p>
            </div>
            <Link to="/employer/jobs/new" className="btn btn-primary hidden md:inline-flex text-sm flex items-center">
              <PlusCircle className="w-4 h-4 mr-1.5" /> Post a job
            </Link>
          </div>

          {/* Stats Cards */}
          <div className="grid sm:grid-cols-3 gap-4">
            <div className="card card-pad">
              <div className="stat-lab">Open jobs</div>
              <div className="stat-num">{stats.open}</div>
            </div>
            <div className="card card-pad">
              <div className="stat-lab">Total postings</div>
              <div className="stat-num">{stats.jobs}</div>
            </div>
            <div className="card card-pad">
              <div className="stat-lab">Appointments</div>
              <div className="stat-num">{stats.appointments}</div>
            </div>
          </div>

          {/* Recent Appointments */}
          <div className="card card-pad bg-white">
            <div className="flex items-center justify-between mb-4">
              <h2 className="font-display font-bold text-xl text-navy-800">Recent appointments</h2>
              <Link to="/employer/appointments" className="text-sm text-teal-700 font-semibold hover:underline">
                View all
              </Link>
            </div>
            {!appointments || appointments.length === 0 ? (
              <div className="text-sm text-slate-500">
                No appointments scheduled yet.
              </div>
            ) : (
              <div className="divide-y divide-slate-100">
                {appointments.map((a) => (
                  <div key={a.id} className="py-3 flex flex-col md:flex-row md:items-center md:justify-between gap-2">
                    <div>
                      <div className="font-semibold text-navy-800">{a.patient_name}</div>
                      <div className="text-xs text-slate-500">
                        Consultation with <span className="font-semibold text-navy-700">Dr. {a.doctor_name}</span> •{' '}
                        {a.primary_specialty} • {new Date(a.date).toLocaleDateString()} • {a.time_slot}
                      </div>
                    </div>
                    <div className="flex items-center gap-2 shrink-0">
                      {getStatusBadge(a.status)}
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>

          {/* Employer Job Postings */}
          <div className="card card-pad bg-white">
            <div className="flex items-center justify-between mb-4">
              <h2 className="font-display font-bold text-xl text-navy-800">My jobs</h2>
              <Link to="/employer/jobs" className="text-sm text-teal-700 font-semibold hover:underline">
                Manage
              </Link>
            </div>
            <div className="grid md:grid-cols-2 gap-3">
              {jobs.slice(0, 4).map((j) => (
                <div key={j.id} className="border border-slate-100 rounded-lg p-4">
                  <div className="flex items-start justify-between">
                    <div>
                      <div className="font-semibold text-navy-800">{j.title}</div>
                      <div className="text-xs text-slate-500">
                        {j.city} • {j.mode}
                      </div>
                    </div>
                    <span className={`badge ${j.status === 'open' ? 'badge-green' : 'badge-gray'}`}>
                      {j.status}
                    </span>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
