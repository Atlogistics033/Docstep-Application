import React, { useState, useEffect } from 'react';
import { Link, useSearchParams } from 'react-router-dom';
import axios from 'axios';
import Sidebar from '../components/Sidebar';
import { Search, MapPin, CheckCircle2 } from 'lucide-react';

export default function Candidates() {
  const [searchParams, setSearchParams] = useSearchParams();
  const [q, setQ] = useState(searchParams.get('q') || '');
  const [specialty, setSpecialty] = useState(searchParams.get('specialty') || '');
  const [city, setCity] = useState(searchParams.get('city') || '');

  const [candidates, setCandidates] = useState([]);
  const [specialties, setSpecialties] = useState([]);
  const [cities, setCities] = useState([]);
  const [loading, setLoading] = useState(true);

  const fetchCandidates = (searchQuery, specQuery, cityQuery) => {
    setLoading(true);
    axios.get('/api/employer/candidates', {
      params: { q: searchQuery, specialty: specQuery, city: cityQuery }
    })
      .then((res) => {
        if (res.data.success) {
          setCandidates(res.data.candidates || []);
          setSpecialties(res.data.specialties || []);
          setCities(res.data.cities || []);
        }
      })
      .catch((err) => console.error('Failed to search candidates', err))
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    const urlQ = searchParams.get('q') || '';
    const urlSpec = searchParams.get('specialty') || '';
    const urlCity = searchParams.get('city') || '';
    setQ(urlQ);
    setSpecialty(urlSpec);
    setCity(urlCity);
    fetchCandidates(urlQ, urlSpec, urlCity);
  }, [searchParams]);

  const handleSearch = (e) => {
    e.preventDefault();
    const params = {};
    if (q) params.q = q;
    if (specialty) params.specialty = specialty;
    if (city) params.city = city;
    setSearchParams(params);
  };

  const handleClear = () => {
    setQ('');
    setSpecialty('');
    setCity('');
    setSearchParams({});
  };

  return (
    <section className="max-w-7xl mx-auto px-4 py-10 text-left fade-in">
      <div className="grid lg:grid-cols-[260px_1fr] gap-6">
        <Sidebar activeSide="candidates" />

        <div>
          <h1 className="font-display font-extrabold text-3xl text-navy-800 mb-2">Search Candidates</h1>
          <p className="text-slate-600 mb-6">Browse PMDC-verified women doctors open to flexible work.</p>

          <form onSubmit={handleSearch} className="card card-pad mb-6 grid md:grid-cols-4 gap-3 bg-white">
            <div className="md:col-span-2 relative">
              <input
                value={q}
                onChange={(e) => setQ(e.target.value)}
                className="input"
                placeholder="Search by name or bio..."
              />
            </div>
            <select
              value={specialty}
              onChange={(e) => setSpecialty(e.target.value)}
              className="select"
            >
              <option value="">All specialties</option>
              {specialties.map((s) => (
                <option key={s} value={s}>
                  {s}
                </option>
              ))}
            </select>
            <select
              value={city}
              onChange={(e) => setCity(e.target.value)}
              className="select"
            >
              <option value="">All cities</option>
              {cities.map((c) => (
                <option key={c} value={c}>
                  {c}
                </option>
              ))}
            </select>
            <div className="md:col-span-4 flex justify-end gap-2">
              <button type="button" onClick={handleClear} className="btn btn-ghost text-sm">
                Clear
              </button>
              <button type="submit" className="btn btn-primary text-sm flex items-center">
                <Search className="w-4 h-4 mr-1.5" /> Filter
              </button>
            </div>
          </form>

          <div className="text-sm text-slate-500 mb-3">
            <span className="font-semibold text-navy-800">{candidates.length}</span> candidates
          </div>

          {loading ? (
            <div className="text-center py-10 text-slate-500">Loading candidates...</div>
          ) : candidates.length === 0 ? (
            <div className="card card-pad text-center text-slate-500">
              No candidates found matching your filters.{' '}
              <button onClick={handleClear} className="text-teal-700 font-semibold cursor-pointer">
                Reset
              </button>
            </div>
          ) : (
            <div className="grid md:grid-cols-2 gap-4">
              {candidates.map((c) => (
                <Link key={c.id} to={`/employer/candidates/${c.id}`} className="card card-pad block hover:no-underline">
                  <div className="flex items-center gap-3">
                    <div className="w-12 h-12 rounded-full bg-gradient-to-br from-teal-400 to-lavender-300 flex items-center justify-center text-white font-bold">
                      {c.full_name
                        .split(' ')
                        .map((p) => p[0])
                        .slice(0, 2)
                        .join('')}
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="font-semibold text-navy-800 truncate">{c.full_name}</div>
                      <div className="text-xs text-slate-500">
                        {c.specialty} • {c.experience_years} yrs • {c.city}
                      </div>
                    </div>
                    {c.pmdc_verified === 1 && (
                      <span className="badge badge-green flex items-center gap-0.5 shrink-0 text-xs">
                        <CheckCircle2 className="w-3.5 h-3.5" /> PMDC ✓
                      </span>
                    )}
                  </div>
                  <p className="text-sm text-slate-600 line-clamp-2 mt-3">{c.bio || 'No bio yet.'}</p>
                  <div className="flex flex-wrap gap-2 mt-3">
                    <span className="badge badge-teal">{c.availability}</span>
                    {c.open_to_remote === 1 && (
                      <span className="badge badge-lavender">Open to remote</span>
                    )}
                  </div>
                </Link>
              ))}
            </div>
          )}
        </div>
      </div>
    </section>
  );
}
