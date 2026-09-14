import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Sidebar from '../components/Sidebar';
import { useAuth } from '../context/AuthContext';
import { Save } from 'lucide-react';

export default function DoctorProfile() {
  const { user, showFlash } = useAuth();
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

  // Form states
  const [fullName, setFullName] = useState('');
  const [phone, setPhone] = useState('');
  const [specialty, setSpecialty] = useState('General Practice');
  const [experienceYears, setExperienceYears] = useState(0);
  const [pmdcNumber, setPmdcNumber] = useState('');
  const [city, setCity] = useState('');
  const [languages, setLanguages] = useState('');
  const [qualifications, setQualifications] = useState('');
  const [bio, setBio] = useState('');
  const [availability, setAvailability] = useState('Flexible');
  const [hourlyRate, setHourlyRate] = useState(0);
  const [openToRemote, setOpenToRemote] = useState(false);
  const [clinicName, setClinicName] = useState('');
  const [clinicAddress, setClinicAddress] = useState('');
  const [clinicHospitalAddress, setClinicHospitalAddress] = useState('');

  useEffect(() => {
    axios.get('/api/doctor/dashboard')
      .then((res) => {
        if (res.data.success && res.data.profile) {
          const p = res.data.profile;
          setFullName(p.full_name || '');
          setPhone(p.phone || '');
          setSpecialty(p.specialty || 'General Practice');
          setExperienceYears(p.experience_years || 0);
          setPmdcNumber(p.pmdc_number || '');
          setCity(p.city || '');
          setLanguages(p.languages || '');
          setQualifications(p.qualifications || '');
          setBio(p.bio || '');
          setAvailability(p.availability || 'Flexible');
          setHourlyRate(p.hourly_rate || 0);
          setOpenToRemote(p.open_to_remote === 1);
          setClinicName(p.clinic_name || '');
          setClinicAddress(p.clinic_address || '');
          setClinicHospitalAddress(p.clinic_hospital_address || '');
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
        specialty,
        experience_years: Number(experienceYears),
        pmdc_number: pmdcNumber,
        city,
        languages,
        qualifications,
        bio,
        availability,
        hourly_rate: Number(hourlyRate),
        open_to_remote: openToRemote ? 1 : 0,
        clinic_name: clinicName,
        clinic_address: clinicAddress,
        clinic_hospital_address: clinicHospitalAddress
      };
      const res = await axios.post('/api/doctor/profile', payload);
      if (res.data.success) {
        showFlash('success', 'Profile updated successfully!');
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
          <h1 className="font-display font-extrabold text-3xl text-navy-800 mb-2">My Profile</h1>
          <p className="text-slate-600 mb-6">Keep your profile up to date — employers see this first.</p>

          <form onSubmit={handleSubmit} className="card card-pad space-y-5 bg-white">
            <div className="grid md:grid-cols-2 gap-4">
              <div>
                <label className="label">Full name</label>
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

            <div className="grid md:grid-cols-2 gap-4">
              <div>
                <label className="label">Primary specialty</label>
                <select
                  value={specialty}
                  onChange={(e) => setSpecialty(e.target.value)}
                  className="select"
                >
                  {['General Practice', 'Gynecology', 'Pediatrics', 'Psychiatry', 'Dermatology', 'Internal Medicine', 'Cardiology', 'Other'].map((s) => (
                    <option key={s} value={s}>
                      {s}
                    </option>
                  ))}
                </select>
              </div>
              <div>
                <label className="label">Years of experience</label>
                <input
                  type="number"
                  min="0"
                  value={experienceYears}
                  onChange={(e) => setExperienceYears(e.target.value)}
                  className="input"
                />
              </div>
            </div>

            <div className="grid md:grid-cols-2 gap-4">
              <div>
                <label className="label">PMDC number</label>
                <input
                  value={pmdcNumber}
                  onChange={(e) => setPmdcNumber(e.target.value)}
                  className="input"
                  placeholder="e.g. PMDC-12345"
                />
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
            </div>

            <div className="grid md:grid-cols-2 gap-4">
              <div>
                <label className="label">Clinic / Hospital Name</label>
                <input
                  value={clinicName}
                  onChange={(e) => setClinicName(e.target.value)}
                  className="input"
                  placeholder="e.g. Al-Khidmat Clinic / Aga Khan Hospital"
                />
              </div>
              <div>
                <label className="label">Clinic Location / Area</label>
                <select
                  value={clinicAddress}
                  onChange={(e) => setClinicAddress(e.target.value)}
                  className="select"
                >
                  <option value="">Select Location</option>
                  {['North Nazimabad', 'Nazimabad', 'FB Area', 'Gulshan-e-Iqbal', 'Gulistan-e-Johar', 'PCHS', 'Saddar', 'Shah Faisal', 'Shahrah-e-Faisal', 'Malir'].map((loc) => (
                    <option key={loc} value={loc}>
                      {loc}
                    </option>
                  ))}
                </select>
              </div>
              <div className="md:col-span-2">
                <label className="label">Clinic / Hospital Address</label>
                <input
                  value={clinicHospitalAddress}
                  onChange={(e) => setClinicHospitalAddress(e.target.value)}
                  className="input"
                  placeholder="e.g. Block H, North Nazimabad, Karachi"
                />
              </div>
            </div>

            <div className="grid md:grid-cols-2 gap-4">
              <div>
                <label className="label">Languages</label>
                <input
                  value={languages}
                  onChange={(e) => setLanguages(e.target.value)}
                  className="input"
                  placeholder="Urdu, English, Punjabi"
                />
              </div>
              <div>
                <label className="label">Qualifications</label>
                <input
                  value={qualifications}
                  onChange={(e) => setQualifications(e.target.value)}
                  className="input"
                  placeholder="MBBS, FCPS, MRCOG..."
                />
              </div>
            </div>

            <div>
              <label className="label">Short bio</label>
              <textarea
                rows="4"
                value={bio}
                onChange={(e) => setBio(e.target.value)}
                className="textarea"
                placeholder="Tell employers about your background and what you're looking for next."
              ></textarea>
            </div>

            <div className="grid md:grid-cols-3 gap-4">
              <div>
                <label className="label">Availability</label>
                <select
                  value={availability}
                  onChange={(e) => setAvailability(e.target.value)}
                  className="select"
                >
                  {['Flexible', 'Mornings only', 'Evenings & Weekends', 'Weekdays 10am-2pm', 'Weekday afternoons', 'Evenings'].map((a) => (
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
                  value={hourlyRate}
                  onChange={(e) => setHourlyRate(e.target.value)}
                  className="input"
                />
              </div>
              <div className="flex items-end pb-3">
                <label className="inline-flex items-center gap-2 cursor-pointer select-none">
                  <input
                    type="checkbox"
                    checked={openToRemote}
                    onChange={(e) => setOpenToRemote(e.target.checked)}
                    className="w-4 h-4 accent-teal-600 cursor-pointer"
                  />
                  <span className="text-sm font-semibold text-navy-800">Open to remote work</span>
                </label>
              </div>
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
