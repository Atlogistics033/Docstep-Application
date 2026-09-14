import React, { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import axios from 'axios';
import Sidebar from '../components/Sidebar';
import { ArrowLeft, CheckCircle2, Award, Mail, Phone, MapPin } from 'lucide-react';

export default function CandidateDetail() {
  const { id } = useParams();
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    axios.get(`/api/employer/candidates/${id}`)
      .then((res) => {
        if (res.data.success) {
          setData(res.data);
        } else {
          setError(res.data.error || 'Candidate not found.');
        }
      })
      .catch((err) => {
        setError(err.response?.data?.error || 'Failed to fetch candidate details.');
      })
      .finally(() => setLoading(false));
  }, [id]);

  if (loading) {
    return (
      <div className="max-w-7xl mx-auto px-4 py-20 text-center text-slate-500">
        Loading candidate details...
      </div>
    );
  }

  if (error || !data) {
    return (
      <div className="max-w-7xl mx-auto px-4 py-20 text-center text-red-500">
        {error || 'An error occurred.'}
      </div>
    );
  }

  const { cand, creds } = data;

  return (
    <section className="max-w-7xl mx-auto px-4 py-10 text-left fade-in">
      <div className="grid lg:grid-cols-[260px_1fr] gap-6">
        <Sidebar activeSide="candidates" />

        <div>
          <Link to="/employer/candidates" className="text-sm text-slate-500 hover:text-teal-700 flex items-center gap-1">
            <ArrowLeft className="w-4 h-4" /> Back to candidates
          </Link>

          <div className="card card-pad mt-3 bg-white">
            {/* Header info */}
            <div className="flex items-center justify-between gap-4 flex-wrap">
              <div className="flex items-center gap-4">
                <div className="w-20 h-20 rounded-full bg-gradient-to-br from-teal-400 to-lavender-300 flex items-center justify-center text-white font-bold text-2xl shrink-0">
                  {cand.full_name
                    .split(' ')
                    .map((p) => p[0])
                    .slice(0, 2)
                    .join('')}
                </div>
                <div>
                  <h1 className="font-display font-extrabold text-2xl text-navy-800">{cand.full_name}</h1>
                  <div className="text-slate-600">
                    {cand.specialty} • {cand.experience_years} years • {cand.city}
                  </div>
                  <div className="flex flex-wrap gap-2 mt-2">
                    {cand.pmdc_verified === 1 && (
                      <span className="badge badge-green flex items-center gap-0.5 text-xs">
                        <CheckCircle2 className="w-3.5 h-3.5" /> PMDC Verified — {cand.pmdc_number}
                      </span>
                    )}
                    <span className="badge badge-teal">{cand.availability}</span>
                    {cand.open_to_remote === 1 && (
                      <span className="badge badge-lavender">Remote OK</span>
                    )}
                  </div>
                </div>
              </div>
              <Link to={`/book-appointment?doctor_id=${cand.id}`} className="btn btn-primary">
                Book Appointment
              </Link>
            </div>

            {/* Bio & Contact */}
            <div className="grid md:grid-cols-2 gap-6 mt-6 pt-6 border-t border-slate-100">
              <div>
                <div className="text-xs uppercase tracking-wider font-bold text-teal-700 mb-1">Bio</div>
                <p className="text-sm text-slate-700 leading-relaxed">{cand.bio || 'No bio yet.'}</p>
              </div>
              <div className="space-y-1.5">
                <div className="text-xs uppercase tracking-wider font-bold text-teal-700 mb-1">Contact</div>
                <div className="text-sm flex items-center gap-1.5">
                  <Mail className="w-4 h-4 text-slate-400" /> <span className="text-slate-500">Email:</span> {cand.email}
                </div>
                {cand.phone && (
                  <div className="text-sm flex items-center gap-1.5">
                    <Phone className="w-4 h-4 text-slate-400" /> <span className="text-slate-500">Phone:</span> {cand.phone}
                  </div>
                )}
                <div className="text-sm flex items-center gap-1.5">
                  <MapPin className="w-4 h-4 text-slate-400" /> <span className="text-slate-500">Languages:</span> {cand.languages || '—'}
                </div>
                <div className="text-sm flex items-center gap-1.5">
                  <Award className="w-4 h-4 text-slate-400" /> <span className="text-slate-500">Qualifications:</span> {cand.qualifications || '—'}
                </div>
              </div>
            </div>

            {/* CV Section */}
            {(cand.cv_summary || cand.cv_experience || cand.cv_education) && (
              <div className="mt-6 pt-6 border-t border-slate-100 space-y-4">
                <h2 className="font-display font-bold text-lg text-navy-800">CV</h2>
                {cand.cv_summary && (
                  <div>
                    <div className="text-xs uppercase font-bold text-slate-500">Summary</div>
                    <p className="text-sm text-slate-700 whitespace-pre-line leading-relaxed mt-1">{cand.cv_summary}</p>
                  </div>
                )}
                {cand.cv_skills && (
                  <div>
                    <div className="text-xs uppercase font-bold text-slate-500">Skills</div>
                    <div className="flex flex-wrap gap-1 mt-1">
                      {cand.cv_skills.split(',').map((s, idx) => (
                        <span key={idx} className="badge badge-lavender">
                          {s.trim()}
                        </span>
                      ))}
                    </div>
                  </div>
                )}
                {cand.cv_experience && (
                  <div>
                    <div className="text-xs uppercase font-bold text-slate-500">Experience</div>
                    <p className="text-sm text-slate-700 whitespace-pre-line leading-relaxed mt-1">{cand.cv_experience}</p>
                  </div>
                )}
                {cand.cv_education && (
                  <div>
                    <div className="text-xs uppercase font-bold text-slate-500">Education</div>
                    <p className="text-sm text-slate-700 whitespace-pre-line leading-relaxed mt-1">{cand.cv_education}</p>
                  </div>
                )}
                {cand.cv_certifications && (
                  <div>
                    <div className="text-xs uppercase font-bold text-slate-500">Certifications</div>
                    <p className="text-sm text-slate-700 whitespace-pre-line leading-relaxed mt-1">{cand.cv_certifications}</p>
                  </div>
                )}
              </div>
            )}

            {/* Credentials Section */}
            {creds.length > 0 && (
              <div className="mt-6 pt-6 border-t border-slate-100">
                <h2 className="font-display font-bold text-lg text-navy-800 mb-3">Credentials</h2>
                <div className="divide-y divide-slate-100">
                  {creds.map((c) => (
                    <div key={c.id} className="py-2 flex items-center justify-between">
                      <div>
                        <div className="font-semibold text-navy-800 text-sm">{c.title}</div>
                        <div className="text-xs text-slate-500">{c.cred_type}</div>
                      </div>
                      <span className={`badge ${c.verified === 1 ? 'badge-green' : 'badge-amber'}`}>
                        {c.verified === 1 ? 'Verified' : 'Pending'}
                      </span>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </section>
  );
}
