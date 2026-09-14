import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { Link } from 'react-router-dom';
import { MapPin, Building, Calendar, ArrowRight, ShieldAlert, Award, Phone } from 'lucide-react';

export default function SuggestBestDoctor() {
  const [doctors, setDoctors] = useState([]);
  const [selectedLocation, setSelectedLocation] = useState('');
  const [loading, setLoading] = useState(true);

  const locations = [
    'North Nazimabad',
    'Nazimabad',
    'FB Area',
    'Gulshan-e-Iqbal',
    'Gulistan-e-Johar',
    'PCHS',
    'Saddar',
    'Shah Faisal',
    'Shahrah-e-Faisal',
    'Malir'
  ];

  const fetchDoctors = (loc) => {
    setLoading(true);
    const url = loc ? `/api/suggest-best-doctor?location=${encodeURIComponent(loc)}` : '/api/suggest-best-doctor';
    axios.get(url)
      .then((res) => {
        if (res.data.success) {
          setDoctors(res.data.doctors || []);
        }
      })
      .catch((err) => console.error('Failed to fetch doctors', err))
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    if (selectedLocation) {
      fetchDoctors(selectedLocation);
    } else {
      setDoctors([]);
      setLoading(false);
    }
  }, [selectedLocation]);

  const handleLocationChange = (e) => {
    setSelectedLocation(e.target.value);
  };

  const handleReset = () => {
    setSelectedLocation('');
  };

  return (
    <div className="fade-in text-left">
      {/* Hero Section */}
      <section class="hero-gradient py-12 md:py-16 bg-slate-50 border-b border-slate-100">
        <div className="max-w-7xl mx-auto px-4 text-center">
          <div className="brand-pill bg-teal-50 text-teal-800 border border-teal-100 px-4 py-1.5 rounded-full inline-flex items-center gap-2 mb-4 text-sm font-semibold">
            <MapPin className="w-4 h-4 text-teal-600 animate-pulse" />
            Karachi Clinic Locator
          </div>
          <h1 className="font-display font-extrabold text-3xl md:text-5xl text-navy-800 leading-tight">
            Suggest Best Doctor
          </h1>
          <p className="text-slate-600 mt-3 max-w-2xl mx-auto text-base md:text-lg">
            Find top-rated women doctors by their physical clinic/hospital address and location in Karachi.
          </p>
        </div>
      </section>

      {/* Filter & Search Section */}
      <section className="max-w-7xl mx-auto px-4 -mt-8 relative z-30">
        <div className="card card-pad bg-white shadow-xl shadow-navy-800/5 border border-slate-100 rounded-3xl p-6">
          <div className="grid md:grid-cols-[1fr_auto] gap-4 items-end">
            <div className="space-y-1">
              <label className="block text-sm font-bold text-navy-800 mb-1.5 flex items-center gap-1.5">
                <MapPin className="w-4 h-4 text-teal-600" />
                Filter by Clinic Location / Area
              </label>
              <select
                value={selectedLocation}
                onChange={handleLocationChange}
                className="select border-slate-300 h-[46px] rounded-xl focus:border-teal-500 focus:ring-2 focus:ring-teal-100 text-slate-800 font-semibold"
              >
                <option value="">All Locations / Areas</option>
                {locations.map((loc) => (
                  <option key={loc} value={loc}>
                    {loc}
                  </option>
                ))}
              </select>
            </div>
            <div className="flex gap-2">
              {selectedLocation && (
                <button
                  onClick={handleReset}
                  className="btn btn-outline border-slate-300 text-slate-600 h-[46px] flex items-center px-4 rounded-xl font-semibold hover:bg-slate-50 transition-colors"
                >
                  Reset Filters
                </button>
              )}
            </div>
          </div>
        </div>
      </section>

      {/* Doctor List Section */}
      <section className="max-w-7xl mx-auto px-4 py-12">
        {!selectedLocation ? (
          /* Prompt to select location */
          <div className="card card-pad bg-white border border-dashed border-slate-200 rounded-3xl text-center py-16 max-w-xl mx-auto">
            <div className="w-16 h-16 bg-teal-50 border border-teal-100 rounded-full flex items-center justify-center text-teal-600 mx-auto mb-4">
              <MapPin className="w-8 h-8" />
            </div>
            <h3 className="font-display font-bold text-xl text-navy-800 mb-1">Select a Location</h3>
            <p className="text-slate-500 text-sm max-w-sm mx-auto">
              Please choose a clinic location or area from the dropdown above to view suggested doctors.
            </p>
          </div>
        ) : loading ? (
          <div className="text-center py-20 text-slate-500 font-medium">
            Fetching registered doctors...
          </div>
        ) : doctors.length === 0 ? (
          /* Empty State */
          <div className="card card-pad bg-white border border-dashed border-slate-200 rounded-3xl text-center py-16 max-w-xl mx-auto">
            <div className="w-16 h-16 bg-slate-50 border border-slate-100 rounded-full flex items-center justify-center text-slate-400 mx-auto mb-4">
              <ShieldAlert className="w-8 h-8" />
            </div>
            <h3 className="font-display font-bold text-xl text-navy-800 mb-1">No Doctors Found</h3>
            <p className="text-slate-500 text-sm max-w-sm mx-auto mb-6">
              We couldn't find any registered doctors practicing at '{selectedLocation}' right now. Please select another location.
            </p>
            <button onClick={handleReset} className="btn btn-teal text-white bg-teal-600 hover:bg-teal-700 font-bold px-6 py-2.5 rounded-xl transition-colors">
              Browse All Locations
            </button>
          </div>
        ) : (
          /* Grid Container */
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
            {doctors.map((doc) => (
              <div key={doc.id} className="card bg-white border border-slate-100 rounded-2xl p-6 flex flex-col justify-between transition-all duration-300 hover:-translate-y-1 hover:shadow-xl hover:border-teal-400 relative overflow-hidden group">
                
                {/* Left Glow Indicator */}
                <div className="absolute left-0 top-0 bottom-0 w-1 bg-gradient-to-b from-teal-500 to-teal-700 opacity-80 rounded-l-2xl group-hover:w-1.5 transition-all"></div>

                <div>
                  {/* Header Row */}
                  <div className="flex items-start justify-between gap-2 mb-3">
                    <div>
                      <h3 className="font-display font-extrabold text-navy-800 text-lg group-hover:text-teal-700 transition-colors">
                        {doc.full_name?.startsWith('Dr.') ? doc.full_name : `Dr. ${doc.full_name}`}
                      </h3>
                      <div className="text-xs text-slate-500 font-semibold mt-0.5">{doc.qualifications}</div>
                    </div>
                    <span className="badge badge-teal shrink-0 py-1 px-3 text-xs font-bold rounded-lg shadow-sm">{doc.specialty}</span>
                  </div>

                  {/* Experience & Bio */}
                  <div className="flex items-center gap-2 mb-4">
                    <span className="badge badge-navy bg-navy-800/5 text-navy-800 py-0.5 px-2 rounded text-xs font-semibold">
                      {doc.experience_years} Years Exp
                    </span>
                    {doc.pmdc_verified === 1 && (
                      <span className="badge badge-green bg-green-50 text-green-700 py-0.5 px-2 rounded text-xs font-semibold flex items-center gap-0.5">
                        <Award className="w-3.5 h-3.5 text-green-600" />
                        PMDC Verified
                      </span>
                    )}
                  </div>

                  <p className="text-slate-600 text-sm line-clamp-3 mb-6 leading-relaxed">
                    {doc.bio || 'No professional bio provided yet. Rest assured, this medical professional is registered and verified on DocStep.'}
                  </p>

                  <div className="divider my-4 bg-slate-100"></div>

                  {/* Clinic Information */}
                  <div className="space-y-2.5 mb-6">
                    <div className="flex items-start gap-2.5">
                      <div className="w-5 h-5 bg-teal-50 rounded-md flex items-center justify-center shrink-0 mt-0.5 text-teal-600">
                        <Building className="w-3.5 h-3.5" />
                      </div>
                      <div>
                        <div className="text-[11px] font-bold uppercase tracking-wider text-slate-400 leading-none">Clinic / Hospital</div>
                        <div className="text-sm font-semibold text-navy-800 mt-0.5">
                          {doc.clinic_name || 'Not Available'}
                        </div>
                      </div>
                    </div>

                    <div className="flex items-start gap-2.5">
                      <div className="w-5 h-5 bg-teal-50 rounded-md flex items-center justify-center shrink-0 mt-0.5 text-teal-600">
                        <MapPin className="w-3.5 h-3.5" />
                      </div>
                      <div>
                        <div className="text-[11px] font-bold uppercase tracking-wider text-slate-400 leading-none">Location / Area</div>
                        <div className="text-sm font-semibold text-teal-700 mt-0.5">
                          {doc.clinic_address || 'Not Available'}
                        </div>
                      </div>
                    </div>

                    {doc.clinic_hospital_address && (
                      <div className="flex items-start gap-2.5">
                        <div className="w-5 h-5 bg-teal-50 rounded-md flex items-center justify-center shrink-0 mt-0.5 text-teal-600">
                          <MapPin className="w-3.5 h-3.5" />
                        </div>
                        <div>
                          <div className="text-[11px] font-bold uppercase tracking-wider text-slate-400 leading-none">Clinic / Hospital Address</div>
                          <div className="text-sm font-semibold text-navy-800 mt-0.5">
                            {doc.clinic_hospital_address}
                          </div>
                        </div>
                      </div>
                    )}

                    {doc.phone && (
                      <div className="flex items-start gap-2.5">
                        <div className="w-5 h-5 bg-teal-50 rounded-md flex items-center justify-center shrink-0 mt-0.5 text-teal-600">
                          <Phone className="w-3.5 h-3.5" />
                        </div>
                        <div>
                          <div className="text-[11px] font-bold uppercase tracking-wider text-slate-400 leading-none">Phone Number</div>
                          <div className="text-sm font-semibold text-navy-800 mt-0.5">
                            {doc.phone}
                          </div>
                        </div>
                      </div>
                    )}
                  </div>
                </div>

                {/* Footer Details & Call to Action */}
                <div className="mt-auto">
                  <div className="bg-slate-50 rounded-xl p-3 flex items-center justify-between gap-2 mb-4 border border-slate-100">
                    <div>
                      <div className="text-[10px] font-bold uppercase tracking-wider text-slate-400 leading-none">Hourly Fees</div>
                      <div className="text-sm font-extrabold text-navy-800 mt-1">
                        {doc.hourly_rate > 0 ? `${doc.hourly_rate} PKR` : 'Consultation Fee'}
                      </div>
                    </div>
                    <div className="text-right">
                      <div className="text-[10px] font-bold uppercase tracking-wider text-slate-400 leading-none">Availability</div>
                      <div className="text-xs font-semibold text-slate-600 mt-1">
                        {doc.availability || 'Flexible'}
                      </div>
                    </div>
                  </div>

                  <Link to={`/opportunities?doctor_id=${doc.id}`} className="btn btn-primary w-full justify-center py-2.5 rounded-xl font-bold transition-all shadow-md group-hover:shadow-teal-500/10">
                    Book Consultation
                    <ArrowRight className="w-4 h-4 ml-1.5 transform group-hover:translate-x-0.5 transition-transform" />
                  </Link>
                </div>

              </div>
            ))}
          </div>
        )}
      </section>
    </div>
  );
}
