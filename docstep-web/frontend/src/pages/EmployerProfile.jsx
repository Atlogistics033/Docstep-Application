import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Sidebar from '../components/Sidebar';
import { useAuth } from '../context/AuthContext';
import { Save } from 'lucide-react';

export default function EmployerProfile() {
  const { showFlash } = useAuth();
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

  // Form states
  const [fullName, setFullName] = useState('');
  const [phone, setPhone] = useState('');
  const [organizationName, setOrganizationName] = useState('');
  const [organizationType, setOrganizationType] = useState('Hospital');
  const [city, setCity] = useState('');
  const [website, setWebsite] = useState('');
  const [about, setAbout] = useState('');

  useEffect(() => {
    axios.get('/api/employer/dashboard')
      .then((res) => {
        if (res.data.success && res.data.profile) {
          const p = res.data.profile;
          setFullName(p.full_name || '');
          setPhone(p.phone || '');
          setOrganizationName(p.organization_name || '');
          setOrganizationType(p.organization_type || 'Hospital');
          setCity(p.city || '');
          setWebsite(p.website || '');
          setAbout(p.about || '');
        }
      })
      .catch((err) => console.error('Failed to load profile data', err))
      .finally(() => setLoading(false));
  }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setSaving(true);
    try {
      const payload = {
        full_name: fullName,
        phone,
        organization_name: organizationName,
        organization_type: organizationType,
        city,
        website,
        about
      };
      const res = await axios.post('/api/employer/profile', payload);
      if (res.data.success) {
        showFlash('success', 'Organization profile updated successfully.');
      } else {
        showFlash('error', res.data.error || 'Failed to update profile.');
      }
    } catch (err) {
      showFlash('error', err.response?.data?.error || 'Failed to update profile.');
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="max-w-7xl mx-auto px-4 py-20 text-center text-slate-500">
        Loading profile...
      </div>
    );
  }

  return (
    <section className="max-w-7xl mx-auto px-4 py-10 text-left fade-in">
      <div className="grid lg:grid-cols-[260px_1fr] gap-6">
        <Sidebar activeSide="profile" />

        <div>
          <h1 className="font-display font-extrabold text-3xl text-navy-800 mb-2">Organization Profile</h1>
          <p className="text-slate-600 mb-6">This is what candidates see when they view your jobs.</p>

          <form onSubmit={handleSubmit} className="card card-pad space-y-4 max-w-3xl bg-white">
            <div className="grid md:grid-cols-2 gap-4">
              <div>
                <label className="label">Your name (HR contact)</label>
                <input
                  value={fullName}
                  onChange={(e) => setFullName(e.target.value)}
                  className="input"
                  required
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
            </div>

            <div>
              <label className="label">Organization name</label>
              <input
                value={organizationName}
                onChange={(e) => setOrganizationName(e.target.value)}
                className="input"
                required
              />
            </div>

            <div className="grid md:grid-cols-2 gap-4">
              <div>
                <label className="label">Type</label>
                <select
                  value={organizationType}
                  onChange={(e) => setOrganizationType(e.target.value)}
                  className="select"
                >
                  {['Hospital', 'Clinic', 'Telemedicine Platform', 'Hospital Network', 'NGO', 'Other'].map((t) => (
                    <option key={t} value={t}>
                      {t}
                    </option>
                  ))}
                </select>
              </div>
              <div>
                <label className="label">City</label>
                <input
                  value={city}
                  onChange={(e) => setCity(e.target.value)}
                  className="input"
                  placeholder="e.g. Islamabad"
                />
              </div>
            </div>

            <div>
              <label className="label">Website</label>
              <input
                value={website}
                onChange={(e) => setWebsite(e.target.value)}
                className="input"
                placeholder="https://..."
              />
            </div>

            <div>
              <label className="label">About your organization</label>
              <textarea
                rows="4"
                value={about}
                onChange={(e) => setAbout(e.target.value)}
                className="textarea"
                placeholder="Tell candidates about your network, workspace environment, etc..."
              ></textarea>
            </div>

            <button type="submit" disabled={saving} className="btn btn-primary text-sm flex items-center">
              <Save className="w-4 h-4 mr-1.5" />
              {saving ? 'Saving...' : 'Save profile'}
            </button>
          </form>
        </div>
      </div>
    </section>
  );
}
