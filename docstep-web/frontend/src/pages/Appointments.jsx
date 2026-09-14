import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { Link } from 'react-router-dom';
import Sidebar from '../components/Sidebar';

export default function Appointments() {
  const [appointments, setAppointments] = useState([]);
  const [filter, setFilter] = useState('all');
  const [dateVal, setDateVal] = useState('');
  const [loading, setLoading] = useState(true);

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

  const fetchAppointments = (currentFilter, currentDateVal) => {
    setLoading(true);
    let url = `/api/doctor/appointments?filter=${currentFilter}`;
    if (currentFilter === 'specific' && currentDateVal) {
      url += `&dateVal=${currentDateVal}`;
    }
    axios.get(url)
      .then((res) => {
        if (res.data.success) {
          setAppointments(res.data.appointments || []);
        }
      })
      .catch((err) => console.error('Failed to load appointments', err))
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    fetchAppointments(filter, dateVal);
  }, [filter, dateVal]);

  const handleFilterClick = (newFilter) => {
    setFilter(newFilter);
    if (newFilter !== 'specific') {
      setDateVal('');
    }
  };

  const handleDateChange = (e) => {
    const val = e.target.value;
    setDateVal(val);
    if (val) {
      setFilter('specific');
    }
  };

  return (
    <section className="max-w-7xl mx-auto px-4 py-10 text-left fade-in">
      <div className="grid lg:grid-cols-[260px_1fr] gap-6">
        <Sidebar activeSide="appointments" />

        <div>
          <h1 className="font-display font-extrabold text-3xl text-navy-800 mb-2">My Appointments</h1>
          <p className="text-slate-600 mb-6">Track and manage your scheduled patient consultation sessions.</p>

          {/* Day Filter Controls */}
          <div className="flex flex-wrap items-center gap-2 mb-6 bg-white p-3 rounded-2xl border border-slate-200 shadow-sm">
            <span className="text-xs font-bold text-slate-500 uppercase tracking-wider px-2">Day Filter:</span>
            <button
              onClick={() => handleFilterClick('all')}
              className={`btn text-xs py-1.5 px-3 rounded-lg ${filter === 'all' ? 'btn-primary' : 'btn-outline'}`}
            >
              All Appointments
            </button>
            <button
              onClick={() => handleFilterClick('today')}
              className={`btn text-xs py-1.5 px-3 rounded-lg ${filter === 'today' ? 'btn-primary' : 'btn-outline'}`}
            >
              Today
            </button>
            <button
              onClick={() => handleFilterClick('tomorrow')}
              className={`btn text-xs py-1.5 px-3 rounded-lg ${filter === 'tomorrow' ? 'btn-primary' : 'btn-outline'}`}
            >
              Tomorrow
            </button>

            <div className="inline-flex items-center gap-2 md:ml-auto">
              <span className="text-xs text-slate-500 font-semibold">Specific Day:</span>
              <input
                type="date"
                value={dateVal}
                onChange={handleDateChange}
                className="input text-xs py-1.5 px-2 border border-slate-200 rounded-lg"
              />
            </div>
          </div>

          <div className="card overflow-hidden bg-white">
            {loading ? (
              <div className="p-8 text-center text-slate-500">Loading appointments...</div>
            ) : appointments.length === 0 ? (
              <div className="p-12 text-center text-slate-500">
                No scheduled appointments found for this selection.
              </div>
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead className="bg-slate-50 text-slate-500 text-xs uppercase tracking-wider">
                    <tr>
                      <th className="p-4 text-left">Patient Name</th>
                      <th className="p-4 text-left">Date</th>
                      <th className="p-4 text-left">Day</th>
                      <th className="p-4 text-left">Time Slot</th>
                      <th className="p-4 text-left">Specialty</th>
                      <th className="p-4 text-left">Status</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100">
                    {appointments.map((a) => (
                      <tr key={a.id} className="hover:bg-slate-50/50 transition-colors">
                        <td className="p-4 font-semibold text-navy-800">{a.patient_name}</td>
                        <td className="p-4 text-slate-700 font-medium">{new Date(a.date).toLocaleDateString()}</td>
                        <td className="p-4">
                          <span className="badge badge-lavender">{a.day}</span>
                        </td>
                        <td className="p-4 text-slate-600 font-semibold">{a.time_slot}</td>
                        <td className="p-4 text-slate-500 text-xs">{a.primary_specialty}</td>
                        <td className="p-4">
                          {getStatusBadge(a.status)}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        </div>
      </div>
    </section>
  );
}
