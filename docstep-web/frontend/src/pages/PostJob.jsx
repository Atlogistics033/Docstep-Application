import React, { useState, useEffect } from 'react';
import { useParams, useNavigate, Link } from 'react-router-dom';
import axios from 'axios';
import Sidebar from '../components/Sidebar';
import { useAuth } from '../context/AuthContext';
import { Save, PlusCircle } from 'lucide-react';

export default function PostJob() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { showFlash } = useAuth();

  const isEditMode = !!id;

  // Form states
  const [title, setTitle] = useState('');
  const [specialty, setSpecialty] = useState('General Practice');
  const [jobType, setJobType] = useState('Part-time');
  const [mode, setMode] = useState('Remote');
  const [city, setCity] = useState('');
  const [salaryRange, setSalaryRange] = useState('');
  const [description, setDescription] = useState('');
  const [requirements, setRequirements] = useState('');
  const [status, setStatus] = useState('open');
  const [loading, setLoading] = useState(isEditMode);
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    if (isEditMode) {
      axios.get(`/api/public/jobs/${id}`)
        .then((res) => {
          if (res.data.success && res.data.job) {
            const j = res.data.job;
            setTitle(j.title || '');
            setSpecialty(j.specialty || 'General Practice');
            setJobType(j.job_type || 'Part-time');
            setMode(j.mode || 'Remote');
            setCity(j.city || '');
            setSalaryRange(j.salary_range || '');
            setDescription(j.description || '');
            setRequirements(j.requirements || '');
            setStatus(j.status || 'open');
          }
        })
        .catch((err) => {
          console.error('Failed to load job details for edit', err);
          showFlash('error', 'Failed to load job details.');
          navigate('/employer/jobs');
        })
        .finally(() => setLoading(false));
    }
  }, [id, isEditMode]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!title || !description || !requirements) {
      showFlash('error', 'Please fill in all required fields.');
      return;
    }

    setSubmitting(true);
    const payload = {
      title,
      specialty,
      job_type: jobType,
      mode,
      city,
      salary_range: salaryRange,
      description,
      requirements,
      status
    };

    try {
      let res;
      if (isEditMode) {
        res = await axios.post(`/api/employer/jobs/${id}/edit`, payload);
      } else {
        res = await axios.post('/api/employer/jobs/new', payload);
      }

      if (res.data.success) {
        showFlash('success', isEditMode ? 'Job updated successfully.' : 'Job posted successfully.');
        navigate('/employer/jobs');
      } else {
        showFlash('error', res.data.error || 'Operation failed.');
      }
    } catch (err) {
      showFlash('error', err.response?.data?.error || 'Operation failed.');
    } finally {
      setSubmitting(false);
    }
  };

  if (loading) {
    return (
      <div className="max-w-7xl mx-auto px-4 py-20 text-center text-slate-500">
        Loading job details...
      </div>
    );
  }

  return (
    <section className="max-w-7xl mx-auto px-4 py-10 text-left fade-in">
      <div className="grid lg:grid-cols-[260px_1fr] gap-6">
        <Sidebar activeSide="jobs" />

        <div>
          <h1 className="font-display font-extrabold text-3xl text-navy-800 mb-2">
            {isEditMode ? 'Edit Job' : 'Post a New Job'}
          </h1>
          <p className="text-slate-600 mb-6">
            Fill in the details — your role will go live immediately.
          </p>

          <form onSubmit={handleSubmit} className="card card-pad space-y-4 max-w-3xl bg-white">
            <div>
              <label className="label">Job title</label>
              <input
                required
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                className="input"
                placeholder="e.g. Remote Pediatrician — Evening shift"
              />
            </div>

            <div className="grid md:grid-cols-2 gap-4">
              <div>
                <label className="label">Specialty</label>
                <select
                  value={specialty}
                  onChange={(e) => setSpecialty(e.target.value)}
                  className="select"
                >
                  {['Gynecology', 'Pediatrics', 'Psychiatry', 'Dermatology', 'General Practice', 'Internal Medicine', 'Cardiology'].map((s) => (
                    <option key={s} value={s}>
                      {s}
                    </option>
                  ))}
                </select>
              </div>
              <div>
                <label className="label">Job type</label>
                <select
                  value={jobType}
                  onChange={(e) => setJobType(e.target.value)}
                  className="select"
                >
                  {['Full-time', 'Part-time', 'Contract', 'Returnship'].map((t) => (
                    <option key={t} value={t}>
                      {t}
                    </option>
                  ))}
                </select>
              </div>
            </div>

            <div className="grid md:grid-cols-2 gap-4">
              <div>
                <label className="label">Mode</label>
                <select
                  value={mode}
                  onChange={(e) => setMode(e.target.value)}
                  className="select"
                >
                  {['Remote', 'Hybrid', 'Onsite'].map((m) => (
                    <option key={m} value={m}>
                      {m}
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
                  placeholder="e.g. Karachi or 'Anywhere in Pakistan'"
                />
              </div>
            </div>

            <div>
              <label className="label">Salary range</label>
              <input
                value={salaryRange}
                onChange={(e) => setSalaryRange(e.target.value)}
                className="input"
                placeholder="e.g. PKR 80,000 - 150,000 / month"
              />
            </div>

            <div>
              <label className="label">Description</label>
              <textarea
                required
                rows="5"
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                className="textarea"
                placeholder="Describe the job responsibilities, shift times..."
              ></textarea>
            </div>

            <div>
              <label className="label">Requirements</label>
              <textarea
                required
                rows="3"
                value={requirements}
                onChange={(e) => setRequirements(e.target.value)}
                className="textarea"
                placeholder="PMDC license valid, MBBS, years of experience..."
              ></textarea>
            </div>

            {isEditMode && (
              <div>
                <label className="label">Status</label>
                <select
                  value={status}
                  onChange={(e) => setStatus(e.target.value)}
                  className="select"
                >
                  <option value="open">Open</option>
                  <option value="closed">Closed</option>
                </select>
              </div>
            )}

            <div className="flex gap-3 pt-2">
              <button type="submit" disabled={submitting} className="btn btn-primary text-sm flex items-center">
                {isEditMode ? <Save className="w-4 h-4 mr-1.5" /> : <PlusCircle className="w-4 h-4 mr-1.5" />}
                {submitting ? 'Saving...' : isEditMode ? 'Save changes' : 'Post job'}
              </button>
              <Link to="/employer/jobs" className="btn btn-ghost text-sm">
                Cancel
              </Link>
            </div>
          </form>
        </div>
      </div>
    </section>
  );
}
