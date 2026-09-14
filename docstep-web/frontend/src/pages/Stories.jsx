import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { Link } from 'react-router-dom';

export default function Stories() {
  const [stories, setStories] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    axios.get('/api/public/stories')
      .then((res) => {
        if (res.data.success) {
          setStories(res.data.stories);
        }
      })
      .catch((err) => console.error('Failed to load success stories', err))
      .finally(() => setLoading(false));
  }, []);

  return (
    <div className="fade-in text-left">
      {/* Hero Header */}
      <section className="hero-gradient">
        <div className="max-w-6xl mx-auto px-4 pt-14 pb-10">
          <div className="brand-pill mb-3">Success Stories</div>
          <h1 className="font-display font-extrabold text-3xl md:text-5xl text-navy-800">
            Real journeys. Real returns.
          </h1>
          <p className="text-slate-600 mt-3 max-w-2xl">
            Stories from women doctors who restarted their careers on DocStep — on their own terms.
          </p>
        </div>
      </section>

      {/* Stories Listing */}
      <section className="max-w-6xl mx-auto px-4 py-12 space-y-6">
        {loading ? (
          <div className="text-center py-10 text-slate-500">Loading stories...</div>
        ) : stories.length === 0 ? (
          <div className="text-center py-10 text-slate-500">No stories found.</div>
        ) : (
          stories.map((s) => (
            <div key={s.id} className="card card-pad grid md:grid-cols-[200px_1fr] gap-6 items-start">
              <div className="text-center">
                <div className="w-32 h-32 rounded-full mx-auto bg-gradient-to-br from-teal-400 to-lavender-300 flex items-center justify-center text-white font-display font-extrabold text-4xl">
                  {s.doctor_name
                    .split(' ')
                    .map((p) => p[0])
                    .slice(0, 2)
                    .join('')}
                </div>
                <div className="font-semibold text-navy-800 mt-3">{s.doctor_name}</div>
                <div className="text-xs text-slate-500">
                  {s.specialty} • {s.city}
                </div>
                {s.featured === 1 && <span className="badge badge-teal mt-2">Featured</span>}
              </div>
              <div>
                <h2 className="font-display font-bold text-2xl text-navy-800 leading-snug">
                  "{s.headline}"
                </h2>
                <p className="text-slate-700 leading-relaxed mt-4 whitespace-pre-line">{s.story}</p>
              </div>
            </div>
          ))
        )}
      </section>

      {/* CTA Section */}
      <section className="section-teal py-16 text-center">
        <div className="max-w-3xl mx-auto px-4">
          <h2 className="font-display font-extrabold text-3xl">Have a story to share?</h2>
          <p className="text-teal-50 mt-3">
            If you've restarted your career through DocStep, we'd love to feature you.
          </p>
          <Link to="/contact" className="btn bg-white text-teal-700 hover:bg-teal-50 mt-6 inline-flex">
            Share your story
          </Link>
        </div>
      </section>
    </div>
  );
}
