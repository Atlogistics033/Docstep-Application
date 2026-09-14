import React, { useState } from 'react';
import axios from 'axios';
import { BookOpen, Sparkles, ArrowRight } from 'lucide-react';

const specialties = [
  'General Practice',
  'Gynecology',
  'Pediatrics',
  'Psychiatry',
  'Dermatology',
  'Internal Medicine',
  'Cardiology',
  'Other'
];

export default function Courses() {
  const [courses, setCourses] = useState([]);
  const [selectedSpecialty, setSelectedSpecialty] = useState('');
  const [aiLoading, setAiLoading] = useState(false);

  const handleRecommendation = async (spec) => {
    if (!spec.trim()) {
      setCourses([]);
      return;
    }

    setAiLoading(true);
    try {
      const res = await axios.get('/api/public/courses/recommend', { params: { specialty: spec } });
      if (res.data.success) {
        setCourses(res.data.courses || []);
      }
    } catch (err) {
      console.error('Failed to match courses using AI', err);
    } finally {
      setAiLoading(false);
    }
  };

  const handleDropdownChange = (e) => {
    const val = e.target.value;
    setSelectedSpecialty(val);
    handleRecommendation(val);
  };

  return (
    <div className="fade-in text-left">
      {/* Hero Header */}
      <section className="hero-gradient">
        <div className="max-w-7xl mx-auto px-4 pt-14 pb-10">
          <div className="brand-pill mb-3">Courses & Training</div>
          <h1 className="font-display font-extrabold text-3xl md:text-5xl text-navy-800">
            Rebuild your skills, refresh your knowledge
          </h1>
          <p className="text-slate-600 mt-3 max-w-2xl">
            Short, self-paced courses from DocStep Academy and our training partners — designed for doctors returning to practice.
          </p>
        </div>
      </section>

      {/* AI Recommendation Controls */}
      <div className="max-w-7xl mx-auto px-4 pt-8">
        <div className="card card-pad bg-white max-w-xl mx-auto p-6 shadow-sm border border-slate-100 rounded-2xl mb-6 text-left">
          <div className="flex items-center gap-2 mb-4">
            <span className="inline-flex items-center justify-center bg-teal-50 text-teal-700 w-8 h-8 rounded-lg">
              <Sparkles className="w-4 h-4 text-teal-600" />
            </span>
            <div>
              <h3 className="font-display font-bold text-base text-navy-800">Course Recommendations</h3>
              <p className="text-xs text-slate-500">Select any doctor Primary Specialty, and our AI will dynamically recommend the most relevant learning courses.</p>
            </div>
          </div>
          
          <div>
            <label className="block text-xs font-bold uppercase tracking-wider mb-1.5 text-slate-500">Select Primary Specialty</label>
            <select 
              value={selectedSpecialty}
              onChange={handleDropdownChange}
              className="w-full px-4 py-2.5 border border-slate-200 bg-white rounded-xl focus:outline-none focus:ring-2 focus:ring-teal-500 focus:border-teal-500 text-sm font-semibold text-slate-700 cursor-pointer"
            >
              <option value="">-- Choose Specialty --</option>
              {specialties.map(spec => (
                <option key={spec} value={spec}>{spec}</option>
              ))}
            </select>
          </div>
          
          {aiLoading && (
            <div className="mt-4 text-xs font-semibold text-teal-700 bg-teal-50 border border-teal-100 rounded-xl p-3 flex items-center gap-2">
              <div className="animate-spin rounded-full h-3.5 w-3.5 border-b-2 border-teal-600"></div>
              <span>Gemini AI is generating recommendations for specialty: "{selectedSpecialty}"...</span>
            </div>
          )}
        </div>
      </div>

      {/* Courses Grid */}
      <section className="max-w-7xl mx-auto px-4 py-6">
        {courses.length === 0 ? (
          <div className="text-center py-16 bg-white rounded-2xl border border-slate-100 shadow-sm max-w-lg mx-auto">
            <div className="w-16 h-16 bg-slate-100 rounded-full flex items-center justify-center mx-auto mb-4 text-slate-400">
              <BookOpen className="w-8 h-8" />
            </div>
            <h3 className="font-display font-bold text-xl text-navy-800 mb-1">
              {selectedSpecialty ? 'No courses found' : 'No courses loaded'}
            </h3>
            <p className="text-slate-500 text-sm">
              {selectedSpecialty 
                ? "We couldn't generate courses in this category at the moment. Try selecting another specialty!" 
                : "Please select a Primary Specialty from the dropdown to load courses."}
            </p>
          </div>
        ) : (
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
            {courses.map((c) => {
              const url = c.website || `https://www.google.com/search?q=${encodeURIComponent(c.title + ' course')}`;
              const lecturesCount = c.lecturesCount || c.lectures_count || 12;
              return (
                <a 
                  key={c.id || c.title} 
                  href={url}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="course-card card overflow-hidden flex flex-col transition-all duration-500 transform hover:shadow-2xl hover:-translate-y-1.5 border border-slate-100 bg-white no-underline text-slate-700 cursor-pointer"
                >
                  {/* Cover Image */}
                  <div className="h-48 relative overflow-hidden group">
                    {c.image ? (
                      <img 
                        src={c.image} 
                        alt={c.title} 
                        className="w-full h-full object-cover transition-transform duration-500 group-hover:scale-105" 
                      />
                    ) : (
                      <div className="w-full h-full bg-gradient-to-br from-teal-400 via-lavender-300 to-navy-800"></div>
                    )}
                    <div className="absolute top-3 left-3 flex flex-wrap gap-1.5 z-10">
                      <span className="badge bg-white/95 text-navy-800 backdrop-blur-sm shadow-sm font-semibold text-xs py-1 px-2.5 rounded-full">
                        {c.level || 'Intermediate'}
                      </span>
                      <span className="badge bg-teal-600 text-white shadow-sm font-semibold text-xs py-1 px-2.5 rounded-full">
                        {c.specialty}
                      </span>
                    </div>
                    <div className="absolute bottom-3 left-3 bg-navy-900/60 text-white px-2 py-0.5 rounded text-xxs backdrop-blur-xs">
                      {c.provider || 'DocStep Academy'}
                    </div>
                  </div>

                  {/* Details */}
                  <div className="p-6 flex-1 flex flex-col">
                    <h3 className="font-display font-bold text-lg text-navy-800 leading-snug mb-1 hover:text-teal-700 transition-colors">
                      {c.title}
                    </h3>
                    <div className="text-xs text-teal-600 font-semibold mb-3">
                      {c.instructor}
                    </div>
                    <p className="text-sm text-slate-600 line-clamp-3 mb-4 leading-relaxed flex-1">
                      {c.description}
                    </p>

                    {/* Key Stats (Lectures Only) */}
                    <div className="bg-slate-50 p-3 rounded-xl border border-slate-100/50 mb-5 text-center text-xs flex justify-center items-center gap-2">
                      <BookOpen className="w-3.5 h-3.5 text-slate-400" />
                      <span className="font-bold text-navy-800">{lecturesCount} Lectures</span>
                    </div>

                    {/* Price & CTA */}
                    <div className="mt-auto pt-4 border-t border-slate-100 flex items-center justify-between">
                      <span className="text-base font-bold text-teal-700">
                        {c.price || 'Free'}
                      </span>
                      <span 
                        className="btn btn-primary px-5 py-2.5 text-xs font-semibold hover:shadow-md transition-shadow inline-flex items-center gap-1"
                      >
                        Explore Course <ArrowRight className="w-3 h-3" />
                      </span>
                    </div>
                  </div>
                </a>
              );
            })}
          </div>
        )}
      </section>

      {/* Suggest Topic Section */}
      <section className="section-soft py-16 text-center">
        <div className="max-w-4xl mx-auto px-4">
          <div className="brand-pill mb-3">DocStep Academy</div>
          <h2 className="font-display font-bold text-3xl text-navy-800">More courses coming soon</h2>
          <p className="text-slate-600 mt-3">
            Suggest a course topic you'd love to see — we partner with PMDC-accredited institutes to roll out new programs each quarter.
          </p>
          <a href="/contact" className="btn btn-outline mt-6 inline-flex text-sm">
            Suggest a course
          </a>
        </div>
      </section>
    </div>
  );
}
