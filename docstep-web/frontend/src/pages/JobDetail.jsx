import React, { useState, useEffect } from 'react';
import { useParams, Link, useNavigate } from 'react-router-dom';
import axios from 'axios';
import { useAuth } from '../context/AuthContext';
import { ArrowLeft, CheckCircle2, AlertCircle, Briefcase, Clock, MapPin, Phone, Calendar, Heart } from 'lucide-react';

export default function JobDetail() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { user, showFlash } = useAuth();

  const [job, setJob] = useState(null);
  const [related, setRelated] = useState([]);
  const [applied, setApplied] = useState(false);
  const [coverLetter, setCoverLetter] = useState('');
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState('');

  const fetchJobDetails = () => {
    setLoading(true);
    axios.get(`/api/public/jobs/${id}`)
      .then((res) => {
        if (res.data.success) {
          setJob(res.data.job);
          setRelated(res.data.related || []);
          setApplied(res.data.applied || false);
        } else {
          setError(res.data.error || 'Job not found.');
        }
      })
      .catch((err) => {
        setError(err.response?.data?.error || 'Failed to fetch job details.');
      })
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    fetchJobDetails();
  }, [id]);

  const handleApply = async (e) => {
    e.preventDefault();
    if (!user) {
      navigate('/login');
      return;
    }
    setSubmitting(true);
    try {
      const res = await axios.post(`/api/doctor/apply/${id}`, { cover_letter: coverLetter });
      if (res.data.success) {
        setApplied(true);
        showFlash('success', 'Application submitted successfully!');
      } else {
        showFlash('error', res.data.error || 'Failed to submit application.');
      }
    } catch (err) {
      showFlash('error', err.response?.data?.error || 'Failed to submit application.');
    } finally {
      setSubmitting(false);
    }
  };

  if (loading) {
    return (
      <div className="max-w-5xl mx-auto px-4 py-20 text-center text-slate-500">
        Loading job details...
      </div>
    );
  }

  if (error || !job) {
    return (
      <div className="max-w-5xl mx-auto px-4 py-20 text-center">
        <div className="w-16 h-16 rounded-full bg-red-100 text-red-700 flex items-center justify-center mx-auto mb-4">
          <AlertCircle className="w-8 h-8" />
        </div>
        <h2 className="font-display font-bold text-2xl text-navy-800">{error || 'Job not found'}</h2>
        <Link to="/doctor/dashboard" className="btn btn-outline mt-6 inline-flex">
          Back to Dashboard
        </Link>
      </div>
    );
  }

  return (
    <div className="fade-in text-left max-w-5xl mx-auto px-4 py-8">
      {/* Back Button */}
      <Link
        to="/doctor/dashboard"
        className="w-10 h-10 rounded-full bg-white border border-slate-100 flex items-center justify-center text-slate-600 hover:text-teal-700 hover:border-teal-300 transition-all shadow-sm mb-6 inline-flex"
      >
        <ArrowLeft className="w-5 h-5" />
      </Link>

      <div className="grid lg:grid-cols-3 gap-8">
        {/* Left/Main Column */}
        <div className="lg:col-span-2 space-y-6">
          {/* Header Info */}
          <div>
            <h1 className="font-display font-extrabold text-3xl md:text-4xl text-navy-800">
              {job.title}
            </h1>
            <div className="flex items-center gap-2 mt-2 text-slate-500 text-sm">
              <span className="font-semibold text-navy-700">{job.organization_name}</span>
              <span>•</span>
              <span className="flex items-center gap-1">
                <MapPin className="w-3.5 h-3.5 text-slate-400" /> {job.city}
              </span>
            </div>
            
            {/* Tag Pills */}
            <div className="flex flex-wrap gap-2 mt-4">
              <span className="inline-flex items-center gap-1.5 px-3.5 py-1.5 rounded-full text-xs font-semibold bg-sky-50 text-sky-700 border border-sky-100">
                <Briefcase className="w-3.5 h-3.5" /> {job.mode}
              </span>
              <span className="inline-flex items-center gap-1.5 px-3.5 py-1.5 rounded-full text-xs font-semibold bg-teal-50 text-teal-700 border border-teal-100">
                <Heart className="w-3.5 h-3.5" /> {job.specialty}
              </span>
              <span className="inline-flex items-center gap-1.5 px-3.5 py-1.5 rounded-full text-xs font-semibold bg-violet-50 text-violet-700 border border-violet-100">
                <Clock className="w-3.5 h-3.5" /> {job.job_type}
              </span>
            </div>
          </div>

          {/* Compensation Card */}
          <div className="card card-pad bg-white border border-slate-100 shadow-sm">
            <div className="text-xs uppercase tracking-wider text-slate-400 font-bold">
              Compensation
            </div>
            <div className="font-display font-extrabold text-3xl text-navy-800 mt-2">
              {job.salary_range}
            </div>
          </div>

          {/* Job Specifications Card */}
          <div className="card card-pad bg-white border border-slate-100 shadow-sm">
            <h3 className="font-display font-bold text-lg text-navy-800 mb-4">Job Specifications</h3>
            <div className="divide-y divide-slate-100">
              <div className="flex items-center justify-between py-3">
                <span className="flex items-center gap-2.5 text-sm text-slate-500 font-medium">
                  <Briefcase className="w-4 h-4 text-slate-400" /> Work Mode
                </span>
                <span className="text-sm font-semibold text-navy-800">{job.mode}</span>
              </div>
              <div className="flex items-center justify-between py-3">
                <span className="flex items-center gap-2.5 text-sm text-slate-500 font-medium">
                  <Heart className="w-4 h-4 text-slate-400" /> Specialty
                </span>
                <span className="text-sm font-semibold text-navy-800">{job.specialty}</span>
              </div>
              <div className="flex items-center justify-between py-3">
                <span className="flex items-center gap-2.5 text-sm text-slate-500 font-medium">
                  <Clock className="w-4 h-4 text-slate-400" /> Job Type
                </span>
                <span className="text-sm font-semibold text-navy-800">{job.job_type}</span>
              </div>
              <div className="flex items-center justify-between py-3">
                <span className="flex items-center gap-2.5 text-sm text-slate-500 font-medium">
                  <MapPin className="w-4 h-4 text-slate-400" /> City
                </span>
                <span className="text-sm font-semibold text-navy-800 capitalize">{job.city}</span>
              </div>
              <div className="flex items-center justify-between py-3">
                <span className="flex items-center gap-2.5 text-sm text-slate-500 font-medium">
                  <AlertCircle className="w-4 h-4 text-slate-400" /> Status
                </span>
                <span className="badge badge-green text-xs font-bold uppercase">{job.status || 'OPEN'}</span>
              </div>
              <div className="flex items-center justify-between py-3">
                <span className="flex items-center gap-2.5 text-sm text-slate-500 font-medium">
                  <Calendar className="w-4 h-4 text-slate-400" /> Posted Date
                </span>
                <span className="text-sm font-semibold text-navy-800">
                  {job.posted_at ? new Date(job.posted_at).toISOString().split('T')[0] : 'N/A'}
                </span>
              </div>
            </div>
          </div>

          {/* Contact Information Card */}
          <div className="card card-pad bg-white border border-slate-100 shadow-sm">
            <h3 className="font-display font-bold text-lg text-navy-800 mb-3">Contact Information</h3>
            <div className="flex items-center justify-between animate-pulse-subtle">
              <span className="flex items-center gap-2.5 text-sm text-slate-500 font-medium">
                <Phone className="w-4 h-4 text-slate-400" /> Employer Phone
              </span>
              <a
                href={job.organization_phone ? `tel:${job.organization_phone}` : '#'}
                className="inline-flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-semibold bg-emerald-50 text-emerald-700 hover:bg-emerald-100 transition-colors"
              >
                <Phone className="w-3.5 h-3.5" /> {job.organization_phone || 'Not Provided'}
              </a>
            </div>
          </div>

          {/* About the Role */}
          <div className="card card-pad bg-white border border-slate-100 shadow-sm">
            <h3 className="font-display font-bold text-lg text-navy-800 mb-3">About the role</h3>
            <p className="text-slate-600 leading-relaxed text-sm whitespace-pre-line">{job.description}</p>
          </div>

          {/* Requirements */}
          <div className="card card-pad bg-white border border-slate-100 shadow-sm">
            <h3 className="font-display font-bold text-lg text-navy-800 mb-3">Requirements</h3>
            <p className="text-slate-600 leading-relaxed text-sm whitespace-pre-line">{job.requirements}</p>
          </div>

          {/* Employer Info Card */}
          <div className="card card-pad bg-white border border-slate-100 shadow-sm">
            <h3 className="font-display font-bold text-lg text-navy-800 mb-3">
              About {job.organization_name}
            </h3>
            <div className="text-xs text-slate-400 mb-3 font-semibold uppercase">
              {job.organization_type || 'Healthcare Partner'}
              {job.website && (
                <>
                  {' • '}
                  <a href={job.website} target="_blank" rel="noopener noreferrer" className="text-teal-700 hover:underline">
                    Website
                  </a>
                </>
              )}
            </div>
            <p className="text-slate-600 text-sm leading-relaxed">{job.organization_about || 'No details provided.'}</p>
          </div>
        </div>

        {/* Right Column / Sidebar */}
        <div className="space-y-6">

          {/* Similar Roles */}
          {related.length > 0 && (
            <div className="card card-pad bg-white border border-slate-100 shadow-sm">
              <h3 className="font-semibold text-navy-800 mb-3">Similar roles</h3>
              <div className="space-y-4">
                {related.map((r) => (
                  <Link key={r.id} to={`/jobs/${r.id}`} className="block group">
                    <div className="font-semibold text-navy-800 group-hover:text-teal-700 transition-colors text-sm">{r.title}</div>
                    <div className="text-xs text-slate-500 mt-1 flex items-center gap-1.5">
                      <span>{r.city}</span>
                      <span>•</span>
                      <span>{r.mode}</span>
                    </div>
                  </Link>
                ))}
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
