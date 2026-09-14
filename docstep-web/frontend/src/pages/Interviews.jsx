import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Sidebar from '../components/Sidebar';
import { useAuth } from '../context/AuthContext';
import { Calendar, Video, Phone, MapPin, Send } from 'lucide-react';

export default function Interviews() {
  const { showFlash } = useAuth();
  const [interviews, setInterviews] = useState([]);
  const [pendingApps, setPendingApps] = useState([]);
  const [loading, setLoading] = useState(true);

  // Form states
  const [appId, setAppId] = useState('');
  const [scheduledAt, setScheduledAt] = useState('');
  const [mode, setMode] = useState('Video');
  const [location, setLocation] = useState('');
  const [notes, setNotes] = useState('');
  const [submitting, setSubmitting] = useState(false);

  const fetchInterviewsData = () => {
    setLoading(true);
    axios.get('/api/employer/interviews')
      .then((res) => {
        if (res.data.success) {
          setInterviews(res.data.interviews || []);
          const pending = res.data.pendingApps || [];
          setPendingApps(pending);
          if (pending.length > 0) {
            setAppId(pending[0].id);
          }
        }
      })
      .catch((err) => console.error('Failed to load interviews', err))
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    fetchInterviewsData();
  }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!appId || !scheduledAt) {
      showFlash('error', 'Please select a candidate and scheduled time.');
      return;
    }

    setSubmitting(true);
    try {
      const res = await axios.post('/api/employer/interviews/new', {
        application_id: appId,
        scheduled_at: scheduledAt,
        mode,
        location,
        notes
      });
      if (res.data.success) {
        showFlash('success', 'Interview scheduled successfully.');
        setScheduledAt('');
        setLocation('');
        setNotes('');
        fetchInterviewsData();
      } else {
        showFlash('error', res.data.error || 'Failed to schedule interview.');
      }
    } catch (err) {
      showFlash('error', err.response?.data?.error || 'Failed to schedule interview.');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <section className="max-w-7xl mx-auto px-4 py-10 text-left fade-in">
      <div className="grid lg:grid-cols-[260px_1fr] gap-6">
        <Sidebar activeSide="interviews" />

        <div>
          <h1 className="font-display font-extrabold text-3xl text-navy-800 mb-2">Interviews</h1>
          <p className="text-slate-600 mb-6">Schedule and manage interviews with candidates.</p>

          <div className="grid lg:grid-cols-[1fr_380px] gap-6">
            {/* List of interviews */}
            <div className="card card-pad bg-white">
              <h2 className="font-display font-bold text-lg text-navy-800 mb-4">Scheduled</h2>
              {loading ? (
                <div className="text-sm text-slate-500">Loading interviews...</div>
              ) : interviews.length === 0 ? (
                <div className="text-sm text-slate-500">No interviews scheduled yet.</div>
              ) : (
                <div className="divide-y divide-slate-100">
                  {interviews.map((i) => (
                    <div key={i.id} className="py-3">
                      <div className="font-semibold text-navy-800">
                        {i.doctor_name} — {i.job_title}
                      </div>
                      <div className="text-xs text-slate-500 mt-1 flex flex-wrap gap-2 items-center">
                        <span className="flex items-center gap-0.5">
                          <Calendar className="w-3.5 h-3.5 text-slate-400" />{' '}
                          {new Date(i.scheduled_at).toLocaleString()}
                        </span>
                        <span>•</span>
                        <span className="flex items-center gap-0.5">
                          {i.mode === 'Video' ? (
                            <Video className="w-3.5 h-3.5 text-teal-600" />
                          ) : i.mode === 'Phone' ? (
                            <Phone className="w-3.5 h-3.5 text-lavender-700" />
                          ) : (
                            <MapPin className="w-3.5 h-3.5 text-navy-800" />
                          )}{' '}
                          {i.mode}
                        </span>
                        {i.location && (
                          <>
                            <span>•</span>
                            <span className="truncate max-w-[200px]" title={i.location}>
                              {i.location}
                            </span>
                          </>
                        )}
                      </div>
                      {i.notes && (
                        <div className="text-xs text-slate-500 italic mt-1.5 pl-2 border-l border-slate-200">
                          "{i.notes}"
                        </div>
                      )}
                    </div>
                  ))}
                </div>
              )}
            </div>

            {/* Schedule new Form */}
            <div className="card card-pad bg-white h-fit">
              <h2 className="font-display font-bold text-lg text-navy-800 mb-4">Schedule new</h2>
              {loading ? (
                <div className="text-sm text-slate-500">Loading form options...</div>
              ) : pendingApps.length === 0 ? (
                <div className="text-sm text-slate-500">
                  No pending or shortlisted candidates to schedule.
                </div>
              ) : (
                <form onSubmit={handleSubmit} className="space-y-3">
                  <div>
                    <label className="label">Candidate</label>
                    <select
                      value={appId}
                      onChange={(e) => setAppId(e.target.value)}
                      className="select"
                      required
                    >
                      {pendingApps.map((p) => (
                        <option key={p.id} value={p.id}>
                          {p.doctor_name} — {p.job_title}
                        </option>
                      ))}
                    </select>
                  </div>
                  <div>
                    <label className="label">Date & time</label>
                    <input
                      type="datetime-local"
                      value={scheduledAt}
                      onChange={(e) => setScheduledAt(e.target.value)}
                      className="input"
                      required
                    />
                  </div>
                  <div>
                    <label className="label">Mode</label>
                    <select
                      value={mode}
                      onChange={(e) => setMode(e.target.value)}
                      className="select"
                    >
                      <option>Video</option>
                      <option>Phone</option>
                      <option>In-person</option>
                    </select>
                  </div>
                  <div>
                    <label className="label">Location / link</label>
                    <input
                      value={location}
                      onChange={(e) => setLocation(e.target.value)}
                      className="input"
                      placeholder="Zoom link or address"
                    />
                  </div>
                  <div>
                    <label className="label">Notes</label>
                    <textarea
                      rows="3"
                      value={notes}
                      onChange={(e) => setNotes(e.target.value)}
                      className="textarea"
                      placeholder="e.g. First-round interview with HR"
                    ></textarea>
                  </div>
                  <button type="submit" disabled={submitting} className="btn btn-primary w-full justify-center text-sm flex items-center">
                    <Send className="w-4 h-4 mr-1.5" />
                    {submitting ? 'Scheduling...' : 'Schedule interview'}
                  </button>
                </form>
              )}
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
