import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Sidebar from '../components/Sidebar';
import { useAuth } from '../context/AuthContext';
import { Save } from 'lucide-react';

export default function Availability() {
  const { showFlash } = useAuth();
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

  const [availability, setAvailability] = useState('Flexible');
  const [hourlyRate, setHourlyRate] = useState(0);
  const [openToRemote, setOpenToRemote] = useState(false);

  useEffect(() => {
    axios.get('/api/doctor/dashboard')
      .then((res) => {
        if (res.data.success && res.data.profile) {
          const p = res.data.profile;
          setAvailability(p.availability || 'Flexible');
          setHourlyRate(p.hourly_rate || 0);
          setOpenToRemote(p.open_to_remote === 1);
        }
      })
      .catch((err) => console.error('Failed to load availability data', err))
      .finally(() => setLoading(false));
  }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setSaving(true);
    try {
      const payload = {
        availability,
        hourly_rate: Number(hourlyRate),
        open_to_remote: openToRemote ? 1 : 0
      };
      const res = await axios.post('/api/doctor/availability', payload);
      if (res.data.success) {
        showFlash('success', 'Availability updated successfully.');
      } else {
        showFlash('error', res.data.error || 'Failed to update availability.');
      }
    } catch (err) {
      showFlash('error', err.response?.data?.error || 'Failed to update availability.');
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="max-w-7xl mx-auto px-4 py-20 text-center text-slate-500">
        Loading availability...
      </div>
    );
  }

  return (
    <section className="max-w-7xl mx-auto px-4 py-10 text-left fade-in">
      <div className="grid lg:grid-cols-[260px_1fr] gap-6">
        <Sidebar activeSide="availability" />

        <div>
          <h1 className="font-display font-extrabold text-3xl text-navy-800 mb-2">Availability</h1>
          <p className="text-slate-600 mb-6">
            Set when and how you're open to work. Employers use this to match you.
          </p>

          <form onSubmit={handleSubmit} className="card card-pad space-y-5 max-w-2xl bg-white">
            <div>
              <label className="label">Working schedule</label>
              <select
                value={availability}
                onChange={(e) => setAvailability(e.target.value)}
                className="select"
              >
                {['Flexible', 'Mornings only', 'Evenings & Weekends', 'Weekdays 10am-2pm', 'Weekday afternoons', 'Evenings', 'Weekends only'].map((a) => (
                  <option key={a} value={a}>
                    {a}
                  </option>
                ))}
              </select>
            </div>
            <div>
              <label className="label">Hourly rate (PKR)</label>
              <input
                type="number"
                min="0"
                value={hourlyRate}
                onChange={(e) => setHourlyRate(e.target.value)}
                className="input"
              />
              <div className="text-xs text-slate-500 mt-1">Set 0 to keep it private.</div>
            </div>
            <div>
              <label className="inline-flex items-center gap-2 cursor-pointer select-none">
                <input
                  type="checkbox"
                  checked={openToRemote}
                  onChange={(e) => setOpenToRemote(e.target.checked)}
                  className="w-4 h-4 accent-teal-600 cursor-pointer"
                />
                <span className="text-sm font-semibold text-navy-800">
                  Open to remote / telemedicine roles
                </span>
              </label>
            </div>
            <button type="submit" disabled={saving} className="btn btn-primary text-sm flex items-center">
              <Save className="w-4 h-4 mr-1.5" />
              {saving ? 'Saving...' : 'Save availability'}
            </button>
          </form>
        </div>
      </div>
    </section>
  );
}
