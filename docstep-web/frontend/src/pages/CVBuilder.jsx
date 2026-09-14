import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Sidebar from '../components/Sidebar';
import { useAuth } from '../context/AuthContext';
import { Save, Printer, FileText } from 'lucide-react';

export default function CVBuilder() {
  const { user, showFlash } = useAuth();
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

  // Profile info for preview
  const [profile, setProfile] = useState({});

  // CV section states
  const [summary, setSummary] = useState('');
  const [skills, setSkills] = useState('');
  const [experience, setExperience] = useState('');
  const [education, setEducation] = useState('');
  const [certifications, setCertifications] = useState('');

  useEffect(() => {
    axios.get('/api/doctor/cv-builder')
      .then((res) => {
        if (res.data.success && res.data.profile) {
          const p = res.data.profile;
          setProfile(p);
          setSummary(p.cv_summary || '');
          setSkills(p.cv_skills || '');
          setExperience(p.cv_experience || '');
          setEducation(p.cv_education || '');
          setCertifications(p.cv_certifications || '');
        }
      })
      .catch((err) => console.error('Failed to fetch CV data', err))
      .finally(() => setLoading(false));
  }, []);

  const handleSave = async (e) => {
    e.preventDefault();
    setSaving(true);
    try {
      const payload = {
        cv_summary: summary,
        cv_skills: skills,
        cv_experience: experience,
        cv_education: education,
        cv_certifications: certifications
      };
      const res = await axios.post('/api/doctor/cv-builder', payload);
      if (res.data.success) {
        showFlash('success', 'CV saved successfully.');
        // Update profile in local state for live preview sync
        setProfile((prev) => ({
          ...prev,
          ...payload
        }));
      } else {
        showFlash('error', res.data.error || 'Failed to save CV.');
      }
    } catch (err) {
      showFlash('error', err.response?.data?.error || 'Failed to save CV.');
    } finally {
      setSaving(false);
    }
  };

  const handlePrint = () => {
    window.print();
  };

  if (loading) {
    return (
      <div className="max-w-7xl mx-auto px-4 py-20 text-center text-slate-500">
        Loading CV Builder...
      </div>
    );
  }

  return (
    <section className="max-w-7xl mx-auto px-4 py-10 text-left fade-in print:p-0 print:m-0 print:max-w-none">
      <div className="grid lg:grid-cols-[260px_1fr] gap-6 print:block">
        <div className="print:hidden">
          <Sidebar activeSide="cv" />
        </div>

        <div>
          <div className="print:hidden">
            <h1 className="font-display font-extrabold text-3xl text-navy-800 mb-2">CV Builder</h1>
            <p className="text-slate-600 mb-6">Build a professional CV tailored for doctors returning to clinical practice.</p>
          </div>

          <div className="grid lg:grid-cols-2 gap-6 print:block print:w-full">
            {/* Edit form */}
            <form onSubmit={handleSave} className="card card-pad space-y-4 bg-white print:hidden">
              <h2 className="font-display font-bold text-lg text-navy-800 flex items-center gap-1.5">
                <FileText className="w-5 h-5 text-teal-600" /> Edit sections
              </h2>
              <div>
                <label className="label">Professional summary</label>
                <textarea
                  value={summary}
                  onChange={(e) => setSummary(e.target.value)}
                  rows="3"
                  className="textarea"
                  placeholder="2-3 lines about your background, career break, and goals."
                ></textarea>
              </div>
              <div>
                <label className="label">Core skills</label>
                <textarea
                  value={skills}
                  onChange={(e) => setSkills(e.target.value)}
                  rows="2"
                  className="textarea"
                  placeholder="Comma-separated: Antenatal care, Telemedicine, CBT..."
                ></textarea>
              </div>
              <div>
                <label className="label">Experience</label>
                <textarea
                  value={experience}
                  onChange={(e) => setExperience(e.target.value)}
                  rows="4"
                  className="textarea"
                  placeholder="One role per line: Title — Hospital (years)"
                ></textarea>
              </div>
              <div>
                <label className="label">Education</label>
                <textarea
                  value={education}
                  onChange={(e) => setEducation(e.target.value)}
                  rows="3"
                  className="textarea"
                  placeholder="One entry per line: Degree — Institution (year)"
                ></textarea>
              </div>
              <div>
                <label className="label">Certifications</label>
                <textarea
                  value={certifications}
                  onChange={(e) => setCertifications(e.target.value)}
                  rows="2"
                  className="textarea"
                  placeholder="One certification per line: Title — Provider (year)"
                ></textarea>
              </div>
              <button type="submit" disabled={saving} className="btn btn-primary text-sm flex items-center">
                <Save className="w-4 h-4 mr-1.5" />
                {saving ? 'Saving...' : 'Save CV'}
              </button>
            </form>

            {/* Live Preview Card */}
            <div className="card card-pad bg-white print:border-0 print:shadow-none print:p-0">
              <div className="text-xs uppercase tracking-wider text-slate-500 font-bold mb-2 print:hidden">
                Live Preview
              </div>
              <div className="border border-slate-200 rounded-lg p-6 print:border-0 print:p-0">
                <div className="border-b border-slate-200 pb-4 mb-4">
                  <div className="font-display font-extrabold text-2xl text-navy-800">
                    {user?.full_name}
                  </div>
                  <div className="text-sm text-slate-500">
                    {profile.specialty} • {profile.city}
                  </div>
                  <div className="text-xs text-slate-500 mt-1">
                    {user?.email}
                    {profile.languages && ` • ${profile.languages}`}
                  </div>
                </div>

                {summary && (
                  <div className="mb-4">
                    <div className="text-xs uppercase tracking-wider font-bold text-teal-700 mb-1">
                      Summary
                    </div>
                    <p className="text-sm text-slate-700 whitespace-pre-line leading-relaxed">{summary}</p>
                  </div>
                )}

                {skills && (
                  <div className="mb-4">
                    <div className="text-xs uppercase tracking-wider font-bold text-teal-700 mb-1">
                      Core Skills
                    </div>
                    <div className="flex flex-wrap gap-1 print:flex-wrap">
                      {skills.split(',').map((s, idx) => (
                        <span key={idx} className="badge badge-lavender mr-1 mb-1 print:bg-slate-100 print:text-slate-800">
                          {s.trim()}
                        </span>
                      ))}
                    </div>
                  </div>
                )}

                {experience && (
                  <div className="mb-4">
                    <div className="text-xs uppercase tracking-wider font-bold text-teal-700 mb-1">
                      Experience
                    </div>
                    <p className="text-sm text-slate-700 whitespace-pre-line leading-relaxed">{experience}</p>
                  </div>
                )}

                {education && (
                  <div className="mb-4">
                    <div className="text-xs uppercase tracking-wider font-bold text-teal-700 mb-1">
                      Education
                    </div>
                    <p className="text-sm text-slate-700 whitespace-pre-line leading-relaxed">{education}</p>
                  </div>
                )}

                {certifications && (
                  <div>
                    <div className="text-xs uppercase tracking-wider font-bold text-teal-700 mb-1">
                      Certifications
                    </div>
                    <p className="text-sm text-slate-700 whitespace-pre-line leading-relaxed">{certifications}</p>
                  </div>
                )}
              </div>
              <div className="mt-4 text-center print:hidden">
                <button onClick={handlePrint} className="btn btn-outline text-sm flex items-center justify-center mx-auto">
                  <Printer className="w-4 h-4 mr-1.5" /> Print / Save as PDF
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
