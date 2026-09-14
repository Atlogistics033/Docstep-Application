import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Sidebar from '../components/Sidebar';
import { useAuth } from '../context/AuthContext';
import { Upload, Trash2, Eye } from 'lucide-react';

export default function Credentials() {
  const { showFlash } = useAuth();
  const [creds, setCreds] = useState([]);
  const [loading, setLoading] = useState(true);

  // Upload form state
  const [credType, setCredType] = useState('PMDC Certificate');
  const [title, setTitle] = useState('');
  const [file, setFile] = useState(null);
  const [uploading, setUploading] = useState(false);

  const fetchCredentials = () => {
    setLoading(true);
    axios.get('/api/doctor/credentials')
      .then((res) => {
        if (res.data.success) {
          setCreds(res.data.creds || []);
        }
      })
      .catch((err) => console.error('Failed to load credentials', err))
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    fetchCredentials();
  }, []);

  const handleUpload = async (e) => {
    e.preventDefault();
    if (!file || !title) {
      showFlash('error', 'Please choose a file and provide a title.');
      return;
    }

    setUploading(true);
    const formData = new FormData();
    formData.append('cred_type', credType);
    formData.append('title', title);
    formData.append('file', file);

    try {
      const res = await axios.post('/api/doctor/credentials/upload', formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
      });
      if (res.data.success) {
        showFlash('success', 'Credential uploaded successfully — pending verification.');
        setTitle('');
        setFile(null);
        // Clear input file
        e.target.reset();
        fetchCredentials();
      } else {
        showFlash('error', res.data.error || 'Failed to upload credential.');
      }
    } catch (err) {
      showFlash('error', err.response?.data?.error || 'Failed to upload credential.');
    } finally {
      setUploading(false);
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm('Delete this credential?')) return;
    try {
      const res = await axios.post(`/api/doctor/credentials/${id}/delete`);
      if (res.data.success) {
        showFlash('success', 'Credential removed.');
        fetchCredentials();
      } else {
        showFlash('error', res.data.error || 'Failed to delete credential.');
      }
    } catch (err) {
      showFlash('error', err.response?.data?.error || 'Failed to delete credential.');
    }
  };

  return (
    <section className="max-w-7xl mx-auto px-4 py-10 text-left fade-in">
      <div className="grid lg:grid-cols-[260px_1fr] gap-6">
        <Sidebar activeSide="credentials" />

        <div>
          <h1 className="font-display font-extrabold text-3xl text-navy-800 mb-2">Credentials</h1>
          <p className="text-slate-600 mb-6">
            Upload PMDC certificate, degrees, and other documents. We verify them before showing to employers.
          </p>

          <div className="grid lg:grid-cols-[1fr_360px] gap-6">
            {/* List */}
            <div className="card card-pad bg-white">
              <h2 className="font-display font-bold text-lg text-navy-800 mb-4">My documents</h2>
              {loading ? (
                <div className="text-sm text-slate-500">Loading documents...</div>
              ) : creds.length === 0 ? (
                <div className="text-sm text-slate-500">No credentials uploaded yet.</div>
              ) : (
                <div className="divide-y divide-slate-100">
                  {creds.map((c) => (
                    <div key={c.id} className="py-3 flex items-center justify-between gap-3">
                      <div className="min-w-0">
                        <div className="font-semibold text-navy-800 truncate" title={c.title}>
                          {c.title}
                        </div>
                        <div className="text-xs text-slate-500">
                          {c.cred_type} • {new Date(c.uploaded_at).toDateString()}
                        </div>
                      </div>
                      <div className="flex items-center gap-2 shrink-0">
                        <span className={`badge ${c.verified === 1 ? 'badge-green' : 'badge-amber'}`}>
                          {c.verified === 1 ? 'Verified' : 'Pending'}
                        </span>
                        {c.file_path && (
                          <a
                            href={c.file_path}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="text-teal-700 text-sm font-semibold hover:underline flex items-center gap-0.5"
                          >
                            <Eye className="w-3.5 h-3.5" /> View
                          </a>
                        )}
                        <button
                          onClick={() => handleDelete(c.id)}
                          className="text-red-600 hover:text-red-800 text-sm font-semibold flex items-center gap-0.5 cursor-pointer"
                        >
                          <Trash2 className="w-3.5 h-3.5" /> Delete
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>

            {/* Upload form */}
            <div className="card card-pad bg-white h-fit">
              <h2 className="font-display font-bold text-lg text-navy-800 mb-4">Upload new</h2>
              <form onSubmit={handleUpload} className="space-y-3">
                <div>
                  <label className="label">Type</label>
                  <select
                    value={credType}
                    onChange={(e) => setCredType(e.target.value)}
                    className="select"
                    required
                  >
                    <option>PMDC Certificate</option>
                    <option>Medical Degree (MBBS)</option>
                    <option>Postgraduate (FCPS / MCPS / MRCOG)</option>
                    <option>Specialization Certificate</option>
                    <option>Other</option>
                  </select>
                </div>
                <div>
                  <label className="label">Title / description</label>
                  <input
                    required
                    value={title}
                    onChange={(e) => setTitle(e.target.value)}
                    className="input"
                    placeholder="e.g. PMDC Certificate 2020"
                  />
                </div>
                <div>
                  <label className="label">File (PDF, JPG, PNG — max 5MB)</label>
                  <input
                    type="file"
                    accept="application/pdf,image/*"
                    required
                    onChange={(e) => setFile(e.target.files[0])}
                    className="input text-sm file:mr-2 file:py-1 file:px-2 file:rounded file:border-0 file:text-xs file:font-semibold file:bg-teal-50 file:text-teal-700 hover:file:bg-teal-100"
                  />
                </div>
                <button type="submit" disabled={uploading} className="btn btn-primary w-full justify-center text-sm flex items-center">
                  <Upload className="w-4 h-4 mr-1.5" />
                  {uploading ? 'Uploading...' : 'Upload'}
                </button>
              </form>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
