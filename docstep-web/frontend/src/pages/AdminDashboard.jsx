import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { useAuth } from '../context/AuthContext';
import { Check, X, Shield, Users, Briefcase, FileText, CheckCircle2, AlertTriangle, MessageSquare, ExternalLink } from 'lucide-react';

export default function AdminDashboard() {
  const { showFlash } = useAuth();
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const [verifyingPmdcId, setVerifyingPmdcId] = useState(null);
  const [approvingCredId, setApprovingCredId] = useState(null);
  const [rejectingCredId, setRejectingCredId] = useState(null);

  const fetchAdminData = () => {
    setLoading(true);
    axios.get('/api/admin/dashboard')
      .then((res) => {
        if (res.data.success) {
          setData(res.data);
        } else {
          setError(res.data.error || 'Failed to load admin dashboard.');
        }
      })
      .catch((err) => {
        setError(err.response?.data?.error || 'Failed to load admin dashboard.');
      })
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    fetchAdminData();
  }, []);

  const handleVerifyPmdc = async (id) => {
    setVerifyingPmdcId(id);
    try {
      const res = await axios.post(`/api/admin/verify-pmdc/${id}`);
      if (res.data.success) {
        showFlash('success', 'Doctor PMDC verified successfully.');
        fetchAdminData();
      } else {
        showFlash('error', res.data.error || 'Failed to verify PMDC.');
      }
    } catch (err) {
      showFlash('error', err.response?.data?.error || 'Failed to verify PMDC.');
    } finally {
      setVerifyingPmdcId(null);
    }
  };

  const handleApproveCredential = async (id) => {
    setApprovingCredId(id);
    try {
      const res = await axios.post(`/api/admin/verify-credential/${id}`);
      if (res.data.success) {
        showFlash('success', 'Credential approved successfully.');
        fetchAdminData();
      } else {
        showFlash('error', res.data.error || 'Failed to approve credential.');
      }
    } catch (err) {
      showFlash('error', err.response?.data?.error || 'Failed to approve credential.');
    } finally {
      setApprovingCredId(null);
    }
  };

  const handleRejectCredential = async (id) => {
    if (!window.confirm('Reject and delete this credential document?')) return;
    setRejectingCredId(id);
    try {
      const res = await axios.post(`/api/admin/delete-credential/${id}`);
      if (res.data.success) {
        showFlash('success', 'Credential document rejected and deleted.');
        fetchAdminData();
      } else {
        showFlash('error', res.data.error || 'Failed to reject credential.');
      }
    } catch (err) {
      showFlash('error', err.response?.data?.error || 'Failed to reject credential.');
    } finally {
      setRejectingCredId(null);
    }
  };

  if (loading) {
    return (
      <div className="max-w-7xl mx-auto px-4 py-20 text-center text-slate-500">
        Loading Admin Portal...
      </div>
    );
  }

  if (error || !data) {
    return (
      <div className="max-w-7xl mx-auto px-4 py-20 text-center text-red-500">
        {error || 'An error occurred loading the dashboard.'}
      </div>
    );
  }

  const { stats, unverifiedDocs, unverifiedCreds, contacts } = data;

  return (
    <section className="max-w-7xl mx-auto px-4 py-10 text-left fade-in">
      {/* Welcome and Title */}
      <div className="mb-10">
        <div className="brand-pill mb-2 flex items-center gap-1.5 w-fit">
          <Shield className="w-4 h-4 text-lavender-700" /> Admin Portal
        </div>
        <h1 className="font-display font-extrabold text-3xl md:text-4xl text-navy-800">
          Administrative Overview
        </h1>
        <p className="text-slate-600 mt-2">
          Manage doctor verifications, credential approvals, and check patient/employer support tickets.
        </p>
      </div>

      {/* KPI Stats Cards */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-6 mb-12">
        <div className="card card-pad bg-gradient-to-br from-teal-50 to-white border-teal-100">
          <div className="stat-num text-teal-600 flex items-center gap-1.5 justify-between">
            {stats.doctors} <Users className="w-6 h-6 text-teal-500 opacity-60" />
          </div>
          <div className="stat-lab font-semibold mt-1">Total Doctors</div>
        </div>
        <div className="card card-pad bg-gradient-to-br from-lavender-50 to-white border-lavender-100">
          <div className="stat-num text-lavender-700 flex items-center gap-1.5 justify-between">
            {stats.employers} <Users className="w-6 h-6 text-lavender-500 opacity-60" />
          </div>
          <div className="stat-lab font-semibold mt-1">Hiring Employers</div>
        </div>
        <div className="card card-pad bg-gradient-to-br from-slate-50 to-white">
          <div className="stat-num text-navy-700 flex items-center gap-1.5 justify-between">
            {stats.jobs} <Briefcase className="w-6 h-6 text-navy-500 opacity-60" />
          </div>
          <div className="stat-lab font-semibold mt-1">Active Job Posts</div>
        </div>
        <div className="card card-pad bg-gradient-to-br from-teal-50/50 to-white">
          <div className="stat-num text-slate-800 flex items-center gap-1.5 justify-between">
            {stats.stories} <FileText className="w-6 h-6 text-slate-500 opacity-60" />
          </div>
          <div className="stat-lab font-semibold mt-1">Success Stories</div>
        </div>
      </div>

      <div className="grid lg:grid-cols-3 gap-8">
        {/* Left Column: Pending Verifications */}
        <div className="lg:col-span-2 space-y-8">
          {/* 1. Doctor PMDC Verifications */}
          <div className="card card-pad bg-white">
            <h2 className="font-display font-bold text-xl text-navy-800 mb-5 flex items-center gap-2">
              <span className="w-2.5 h-2.5 rounded-full bg-amber-500"></span>
              Pending Doctor PMDC Verifications
              <span className="ml-auto badge badge-amber">{unverifiedDocs.length} pending</span>
            </h2>

            {unverifiedDocs.length === 0 ? (
              <div className="text-center py-8 text-slate-500 text-sm">
                No doctors awaiting PMDC number verification.
              </div>
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full text-left border-collapse text-sm">
                  <thead>
                    <tr className="border-b border-slate-100 text-slate-400 font-semibold uppercase text-xs">
                      <th className="py-3 px-2">Doctor</th>
                      <th className="py-3 px-2">PMDC Number</th>
                      <th className="py-3 px-2">Specialty</th>
                      <th className="py-3 px-2 text-right">Actions</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-50">
                    {unverifiedDocs.map((d) => (
                      <tr key={d.id} className="hover:bg-slate-50/50 transition">
                        <td className="py-3.5 px-2">
                          <div className="font-semibold text-navy-800">{d.full_name}</div>
                          <div className="text-xs text-slate-400">{d.email}</div>
                        </td>
                        <td className="py-3.5 px-2 font-mono text-slate-600">
                          {d.pmdc_number || 'Not Provided'}
                        </td>
                        <td className="py-3.5 px-2">
                          <span className="badge badge-teal">{d.specialty}</span>
                        </td>
                        <td className="py-3.5 px-2 text-right">
                          {d.pmdc_number ? (
                            <button
                              onClick={() => handleVerifyPmdc(d.id)}
                              disabled={verifyingPmdcId === d.id}
                              className="btn btn-primary text-xs py-1.5 px-3 flex items-center justify-center ml-auto cursor-pointer"
                            >
                              <CheckCircle2 className="w-3.5 h-3.5 mr-1" />
                              {verifyingPmdcId === d.id ? '...' : 'Verify'}
                            </button>
                          ) : (
                            <span className="text-xs text-slate-400 italic">No number</span>
                          )}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </div>

          {/* 2. Credential Document Approvals */}
          <div className="card card-pad bg-white">
            <h2 className="font-display font-bold text-xl text-navy-800 mb-5 flex items-center gap-2">
              <span className="w-2.5 h-2.5 rounded-full bg-amber-500"></span>
              Pending Credentials Documents
              <span className="ml-auto badge badge-amber">{unverifiedCreds.length} pending</span>
            </h2>

            {unverifiedCreds.length === 0 ? (
              <div className="text-center py-8 text-slate-500 text-sm">
                No credential documents awaiting verification.
              </div>
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full text-left border-collapse text-sm">
                  <thead>
                    <tr className="border-b border-slate-100 text-slate-400 font-semibold uppercase text-xs">
                      <th className="py-3 px-2">Doctor</th>
                      <th className="py-3 px-2">Credential Details</th>
                      <th className="py-3 px-2">File</th>
                      <th className="py-3 px-2 text-right">Actions</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-50">
                    {unverifiedCreds.map((c) => (
                      <tr key={c.id} className="hover:bg-slate-50/50 transition">
                        <td className="py-3.5 px-2 font-semibold text-navy-800">{c.doctor_name}</td>
                        <td className="py-3.5 px-2">
                          <div className="font-medium text-slate-700">{c.title}</div>
                          <div className="text-xs text-slate-400">{c.cred_type}</div>
                        </td>
                        <td className="py-3.5 px-2">
                          {c.file_path ? (
                            <a
                              href={c.file_path}
                              target="_blank"
                              rel="noopener noreferrer"
                              className="text-teal-600 hover:text-teal-800 hover:underline flex items-center gap-1 font-semibold text-xs"
                            >
                              View PDF/Doc <ExternalLink className="w-3.5 h-3.5" />
                            </a>
                          ) : (
                            <span className="text-slate-400 text-xs italic">No file</span>
                          )}
                        </td>
                        <td className="py-3.5 px-2 text-right">
                          <div className="flex items-center justify-end gap-2">
                            <button
                              onClick={() => handleApproveCredential(c.id)}
                              disabled={approvingCredId === c.id}
                              className="btn btn-primary text-xs py-1.5 px-3 flex items-center cursor-pointer"
                            >
                              <Check className="w-3 h-3 mr-1" />
                              {approvingCredId === c.id ? '...' : 'Approve'}
                            </button>
                            <button
                              onClick={() => handleRejectCredential(c.id)}
                              disabled={rejectingCredId === c.id}
                              className="btn btn-outline border-red-200 text-red-600 hover:bg-red-50 hover:text-red-700 text-xs py-1.5 px-3 flex items-center cursor-pointer"
                            >
                              <X className="w-3 h-3 mr-1" />
                              {rejectingCredId === c.id ? '...' : 'Reject'}
                            </button>
                          </div>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        </div>

        {/* Right Column: Contact Us Tickets */}
        <div>
          <div className="card card-pad bg-white h-full">
            <h2 className="font-display font-bold text-xl text-navy-800 mb-5 flex items-center gap-2 border-b border-slate-100 pb-3">
              <MessageSquare className="w-5 h-5 text-teal-600" />
              Support Tickets
            </h2>

            {contacts.length === 0 ? (
              <div className="text-center py-12 text-slate-400 text-sm italic">
                No contact queries received.
              </div>
            ) : (
              <div className="space-y-4 max-h-[600px] overflow-y-auto pr-2">
                {contacts.map((msg) => (
                  <div
                    key={msg.id}
                    className="border border-slate-100 rounded-lg p-4 bg-slate-50/50 hover:bg-white transition duration-200"
                  >
                    <div className="flex items-start justify-between gap-2">
                      <div>
                        <div className="font-bold text-navy-800 text-sm">{msg.name}</div>
                        <div className="text-slate-400 text-xs font-medium">{msg.email}</div>
                      </div>
                      <div className="text-[10px] text-slate-400 text-right">
                        {new Date(msg.created_at).toLocaleDateString()}
                      </div>
                    </div>
                    <div className="mt-2 text-xs border-t border-slate-100 pt-2">
                      <div className="font-bold text-slate-700">{msg.subject}</div>
                      <p className="text-slate-600 mt-1 whitespace-pre-wrap leading-relaxed">
                        {msg.message}
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    </section>
  );
}
