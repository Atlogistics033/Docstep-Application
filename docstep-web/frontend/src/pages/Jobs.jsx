import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import axios from 'axios';
import Sidebar from '../components/Sidebar';
import { useAuth } from '../context/AuthContext';
import { PlusCircle, Edit, Trash2 } from 'lucide-react';

export default function Jobs() {
  const { showFlash } = useAuth();
  const [jobs, setJobs] = useState([]);
  const [loading, setLoading] = useState(true);

  const fetchJobs = () => {
    setLoading(true);
    axios.get('/api/employer/jobs')
      .then((res) => {
        if (res.data.success) {
          setJobs(res.data.jobs || []);
        }
      })
      .catch((err) => console.error('Failed to load jobs', err))
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    fetchJobs();
  }, []);

  const handleDelete = async (id) => {
    if (!window.confirm('Delete this job?')) return;
    try {
      const res = await axios.post(`/api/employer/jobs/${id}/delete`);
      if (res.data.success) {
        showFlash('success', 'Job deleted successfully.');
        fetchJobs();
      } else {
        showFlash('error', res.data.error || 'Failed to delete job.');
      }
    } catch (err) {
      showFlash('error', err.response?.data?.error || 'Failed to delete job.');
    }
  };

  return (
    <section className="max-w-7xl mx-auto px-4 py-10 text-left fade-in">
      <div className="grid lg:grid-cols-[260px_1fr] gap-6">
        <Sidebar activeSide="jobs" />

        <div>
          <div className="flex items-center justify-between mb-6">
            <div>
              <h1 className="font-display font-extrabold text-3xl text-navy-800">My Job Postings</h1>
              <p className="text-slate-600">Manage your open and closed roles.</p>
            </div>
            <Link to="/employer/jobs/new" className="btn btn-primary text-sm flex items-center">
              <PlusCircle className="w-4 h-4 mr-1.5" /> Post a job
            </Link>
          </div>

          <div className="card overflow-hidden bg-white">
            {loading ? (
              <div className="p-8 text-center text-slate-500">Loading job postings...</div>
            ) : jobs.length === 0 ? (
              <div className="p-8 text-center text-slate-500">
                No jobs yet.{' '}
                <Link to="/employer/jobs/new" className="text-teal-700 font-semibold hover:underline">
                  Post your first job
                </Link>
                .
              </div>
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead className="bg-slate-50 text-slate-500 text-xs uppercase tracking-wider">
                    <tr>
                      <th className="p-4 text-left">Title</th>
                      <th className="p-4 text-center">Mode</th>
                      <th className="p-4 text-center">Specialty</th>
                      <th className="p-4 text-center">Applications</th>
                      <th className="p-4 text-center">Status</th>
                      <th className="p-4 text-right">Actions</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100">
                    {jobs.map((j) => (
                      <tr key={j.id}>
                        <td className="p-4">
                          <Link to={`/jobs/${j.id}`} className="font-semibold text-navy-800 hover:text-teal-700 hover:underline">
                            {j.title}
                          </Link>
                          <div className="text-xs text-slate-500">
                            {j.city} • {j.salary_range}
                          </div>
                        </td>
                        <td className="p-4 text-center">
                          <span className="badge badge-teal">{j.mode}</span>
                        </td>
                        <td className="p-4 text-center">
                          <span className="badge badge-lavender">{j.specialty}</span>
                        </td>
                        <td className="p-4 text-center font-semibold text-navy-800">
                          {j.app_count}
                        </td>
                        <td className="p-4 text-center">
                          <span className={`badge ${j.status === 'open' ? 'badge-green' : 'badge-gray'}`}>
                            {j.status}
                          </span>
                        </td>
                        <td className="p-4 text-right whitespace-nowrap">
                          <Link
                            to={`/employer/jobs/${j.id}/edit`}
                            className="text-teal-700 font-semibold text-xs inline-flex items-center mr-3 hover:underline"
                          >
                            <Edit className="w-3.5 h-3.5 mr-0.5" /> Edit
                          </Link>
                          <button
                            onClick={() => handleDelete(j.id)}
                            className="text-red-600 font-semibold text-xs inline-flex items-center hover:underline cursor-pointer"
                          >
                            <Trash2 className="w-3.5 h-3.5 mr-0.5" /> Delete
                          </button>
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
