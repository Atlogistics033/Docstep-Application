import React, { useState, useEffect } from 'react';
import { useSearchParams, Link, useNavigate } from 'react-router-dom';
import axios from 'axios';
import { useAuth } from '../context/AuthContext';
import { ArrowLeft, CheckCircle2, AlertCircle } from 'lucide-react';

export default function Opportunities() {
  const [searchParams] = useSearchParams();
  const initialDoctorId = searchParams.get('doctor_id') || '';
  const navigate = useNavigate();
  const { user, showFlash } = useAuth();

  const [doctorsList, setDoctorsList] = useState([]);
  const [selectedDoctorId, setSelectedDoctorId] = useState(initialDoctorId);
  const [searchQuery, setSearchQuery] = useState('');
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);

  const [doctor, setDoctor] = useState(null);
  const [patientName, setPatientName] = useState('');
  const [date, setDate] = useState('');
  const [day, setDay] = useState('');
  const [timeSlot, setTimeSlot] = useState('');
  const [availableSlots, setAvailableSlots] = useState([]);

  const [loading, setLoading] = useState(!!initialDoctorId);
  const [submitting, setSubmitting] = useState(false);
  const [submitted, setSubmitted] = useState(false);
  const [error, setError] = useState('');

  // Rescheduling states
  const [bookingMode, setBookingMode] = useState('book'); // 'book', 'reschedule', or 'cancel'
  const [rescheduleSearchName, setRescheduleSearchName] = useState('');
  const [rescheduleSearchLoading, setRescheduleSearchLoading] = useState(false);
  const [matchedAppointments, setMatchedAppointments] = useState([]);
  const [selectedAppointment, setSelectedAppointment] = useState(null);
  const [hasSearched, setHasSearched] = useState(false);

  // Cancellation states
  const [cancelSearchName, setCancelSearchName] = useState('');
  const [cancelSearchLoading, setCancelSearchLoading] = useState(false);
  const [matchedCancelAppointments, setMatchedCancelAppointments] = useState([]);
  const [appointmentToCancel, setAppointmentToCancel] = useState(null);
  const [hasCancelSearched, setHasCancelSearched] = useState(false);
  const [isCancelModalOpen, setIsCancelModalOpen] = useState(false);
  const [cancelling, setCancelling] = useState(false);

  const dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

  // Fetch list of all doctors for the search dropdown
  useEffect(() => {
    axios.get('/api/public/doctors')
      .then((res) => {
        if (res.data.success) {
          setDoctorsList(res.data.doctors);
        }
      })
      .catch((err) => {
        console.error('Failed to fetch doctors list:', err);
      });
  }, []);

  // Fetch selected doctor's profile and details
  useEffect(() => {
    if (!selectedDoctorId) {
      setDoctor(null);
      setAvailableSlots([]);
      setTimeSlot('');
      setSearchQuery('');
      setLoading(false);
      return;
    }

    axios.get(`/api/public/doctors/${selectedDoctorId}/availability`)
      .then((res) => {
        if (res.data.success) {
          setDoctor(res.data.doctor);
          setSearchQuery(res.data.doctor.name);
          setError('');
        } else {
          setError(res.data.error || 'Doctor profile not found.');
        }
      })
      .catch((err) => {
        setError(err.response?.data?.error || 'Failed to fetch doctor details.');
      })
      .finally(() => setLoading(false));
  }, [selectedDoctorId]);

  // Fetch specific slots on doctor or date changes
  useEffect(() => {
    if (!selectedDoctorId || !date) {
      setAvailableSlots([]);
      setTimeSlot('');
      return;
    }

    axios.get(`/api/public/doctors/${selectedDoctorId}/availability?date=${date}`)
      .then((res) => {
        if (res.data.success) {
          setAvailableSlots(res.data.availableSlots || []);
        } else {
          setAvailableSlots([]);
        }
      })
      .catch((err) => {
        console.error('Failed to fetch slots:', err);
        setAvailableSlots([]);
      });
  }, [selectedDoctorId, date]);

  // Pre-fill patient name with current user's name if logged in
  useEffect(() => {
    if (user && user.full_name && !patientName) {
      setPatientName(user.full_name);
      if (!rescheduleSearchName) {
        setRescheduleSearchName(user.full_name);
      }
      if (!cancelSearchName) {
        setCancelSearchName(user.full_name);
      }
    }
  }, [user, patientName]);

  // Handle outside clicks to close the custom dropdown
  useEffect(() => {
    const handleOutsideClick = (e) => {
      if (!e.target.closest('.select-container')) {
        setIsDropdownOpen(false);
      }
    };
    document.addEventListener('click', handleOutsideClick);
    return () => document.removeEventListener('click', handleOutsideClick);
  }, []);

  const handleDateChange = (e) => {
    const val = e.target.value;
    setDate(val);
    if (val) {
      const parts = val.split('-');
      const localDate = new Date(parts[0], parts[1] - 1, parts[2]);
      setDay(dayNames[localDate.getDay()]);
    } else {
      setDay('');
    }
  };

  const handleRescheduleSearch = async (e) => {
    e?.preventDefault();
    if (!rescheduleSearchName.trim()) return;
    setRescheduleSearchLoading(true);
    setHasSearched(true);
    try {
      const res = await axios.get(`/api/public/appointments/search?patient_name=${encodeURIComponent(rescheduleSearchName)}`);
      if (res.data.success) {
        setMatchedAppointments(res.data.appointments);
      } else {
        setMatchedAppointments([]);
      }
    } catch (err) {
      console.error('Failed to search appointments:', err);
      showFlash('error', 'Failed to retrieve appointments. Please try again.');
    } finally {
      setRescheduleSearchLoading(false);
    }
  };

  const selectAppointmentToReschedule = (app) => {
    setSelectedAppointment(app);
    setSelectedDoctorId(app.doctor_id);
    setPatientName(app.patient_name);
    setDate(app.date);
    setTimeSlot(app.time_slot);
  };

  const handleCancelSearch = async (e) => {
    e?.preventDefault();
    if (!cancelSearchName.trim()) return;
    setCancelSearchLoading(true);
    setHasCancelSearched(true);
    try {
      const res = await axios.get(`/api/public/appointments/search?patient_name=${encodeURIComponent(cancelSearchName)}`);
      if (res.data.success) {
        setMatchedCancelAppointments(res.data.appointments);
      } else {
        setMatchedCancelAppointments([]);
      }
    } catch (err) {
      console.error('Failed to search appointments for cancellation:', err);
      showFlash('error', 'Failed to retrieve appointments. Please try again.');
    } finally {
      setCancelSearchLoading(false);
    }
  };

  const executeCancellation = async () => {
    if (!appointmentToCancel) return;
    setCancelling(true);
    try {
      const res = await axios.post(`/api/public/appointments/${appointmentToCancel.id}/cancel`);
      if (res.data.success) {
        setIsCancelModalOpen(false);
        setAppointmentToCancel(null);
        showFlash('success', 'Appointment successfully cancelled!');
        // Reset states
        setMatchedCancelAppointments([]);
        setHasCancelSearched(false);
        setCancelSearchName('');
        setBookingMode('book');
      } else {
        showFlash('error', res.data.error || 'Failed to cancel appointment.');
      }
    } catch (err) {
      showFlash('error', err.response?.data?.error || 'Failed to cancel appointment.');
    } finally {
      setCancelling(false);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (bookingMode === 'reschedule') {
      if (!selectedAppointment) {
        showFlash('error', 'Please select an appointment to reschedule.');
        return;
      }
      if (!date || !timeSlot) {
        showFlash('error', 'New date and time slot are required.');
        return;
      }

      setSubmitting(true);
      try {
        const res = await axios.post(`/api/public/appointments/${selectedAppointment.id}/reschedule`, {
          doctor_id: selectedDoctorId,
          date,
          time_slot: timeSlot
        });
        if (res.data.success) {
          setSubmitted(true);
          showFlash('success', 'Appointment successfully rescheduled!');
        } else {
          showFlash('error', res.data.error || 'Failed to reschedule appointment.');
        }
      } catch (err) {
        showFlash('error', err.response?.data?.error || 'Failed to reschedule appointment.');
      } finally {
        setSubmitting(false);
      }
    } else {
      // Standard Book Mode
      if (!selectedDoctorId || !patientName || !date || !timeSlot) {
        showFlash('error', 'All fields are required.');
        return;
      }

      setSubmitting(true);
      try {
        const res = await axios.post('/api/public/appointments', {
          doctor_id: selectedDoctorId,
          patient_name: patientName,
          date,
          time_slot: timeSlot
        });
        if (res.data.success) {
          setSubmitted(true);
          showFlash('success', 'Appointment successfully booked!');
        } else {
          showFlash('error', res.data.error || 'Failed to book appointment.');
        }
      } catch (err) {
        showFlash('error', err.response?.data?.error || 'Failed to book appointment.');
      } finally {
        setSubmitting(false);
      }
    }
  };

  const filteredDoctors = doctorsList.filter(doc =>
    doc.name.toLowerCase().includes(searchQuery.toLowerCase())
  );

  if (loading) {
    return (
      <div className="max-w-4xl mx-auto px-4 py-20 text-center text-slate-500 font-display">
        Loading booking details...
      </div>
    );
  }

  if (error && selectedDoctorId) {
    return (
      <div className="max-w-4xl mx-auto px-4 py-20 text-center">
        <div className="w-16 h-16 rounded-full bg-red-100 text-red-700 flex items-center justify-center mx-auto mb-4">
          <AlertCircle className="w-8 h-8" />
        </div>
        <h2 className="font-display font-bold text-2xl text-navy-800">{error}</h2>
        <Link to="/" className="btn btn-outline mt-6 inline-flex">
          Back to Home
        </Link>
      </div>
    );
  }

  return (
    <div className="fade-in text-left">
      <section className="hero-gradient py-12 bg-slate-50 border-b border-slate-100">
        <div className="max-w-4xl mx-auto px-4">
          <Link to="/" className="text-sm text-slate-500 hover:text-teal-700 flex items-center gap-1 font-medium">
            <ArrowLeft className="w-4 h-4" /> Back to Home
          </Link>
          <h1 className="font-display font-extrabold text-3xl md:text-4xl text-navy-800 mt-4">
            {bookingMode === 'reschedule' ? 'Reschedule Appointment' : 'Book an Appointment'}
          </h1>
          <p className="text-slate-600 mt-2">
            {bookingMode === 'reschedule' 
              ? 'Update your existing appointment date or time slot with our medical professionals.'
              : 'Schedule a consulting session or clinical appointment with our verified medical professionals.'}
          </p>
        </div>
      </section>

      <section className="max-w-4xl mx-auto px-4 py-12">
        <div className="card card-pad bg-white max-w-2xl mx-auto shadow-sm border border-slate-100 rounded-2xl p-6 md:p-8">
          {submitted ? (
            <div className="text-center py-8">
              <div className="w-16 h-16 rounded-full bg-teal-100 text-teal-700 flex items-center justify-center mx-auto mb-4">
                <CheckCircle2 className="w-8 h-8" />
              </div>
              <h2 className="font-display font-bold text-2xl text-navy-800">
                {bookingMode === 'reschedule' ? 'Appointment Rescheduled!' : 'Appointment Booked!'}
              </h2>
              <p className="text-slate-600 mt-2">
                Your appointment with <strong>Dr. {doctor?.name}</strong> has been successfully {bookingMode === 'reschedule' ? 'rescheduled' : 'scheduled'}.
              </p>
              <div className="mt-6 flex justify-center gap-3">
                <Link to="/" className="btn btn-primary">
                  Back to home
                </Link>
                {user?.role === 'employer' && (
                  <Link to="/employer/appointments" className="btn btn-outline">
                    Go to Portal
                  </Link>
                )}
              </div>
            </div>
          ) : (
            <>
              {/* Modern Mode Toggle Tabs */}
              <div className="flex p-1 bg-slate-100 rounded-xl mb-6">
                <button
                  type="button"
                  onClick={() => {
                    setBookingMode('book');
                    setSelectedAppointment(null);
                  }}
                  className={`flex-1 py-2 text-center text-sm font-semibold rounded-lg transition-all ${bookingMode === 'book' ? 'bg-white shadow-sm text-teal-700' : 'text-slate-500 hover:text-slate-700'}`}
                >
                  Book New Session
                </button>
                <button
                  type="button"
                  onClick={() => {
                    setBookingMode('reschedule');
                    setSelectedAppointment(null);
                  }}
                  className={`flex-1 py-2 text-center text-sm font-semibold rounded-lg transition-all ${bookingMode === 'reschedule' ? 'bg-white shadow-sm text-teal-700' : 'text-slate-500 hover:text-slate-700'}`}
                >
                  Reschedule Appointment
                </button>
                <button
                  type="button"
                  onClick={() => {
                    setBookingMode('cancel');
                    setSelectedAppointment(null);
                  }}
                  className={`flex-1 py-2 text-center text-sm font-semibold rounded-lg transition-all ${bookingMode === 'cancel' ? 'bg-white shadow-sm text-teal-700' : 'text-slate-500 hover:text-slate-700'}`}
                >
                  Cancel Appointment
                </button>
              </div>

              <h2 className="font-display font-bold text-xl text-navy-800 mb-6 border-b border-slate-100 pb-3">
                {bookingMode === 'reschedule' 
                  ? 'Rescheduling Session Details' 
                  : bookingMode === 'cancel' 
                    ? 'Cancel Appointment' 
                    : 'Session Details'}
              </h2>

              {bookingMode === 'reschedule' && !selectedAppointment ? (
                /* Reschedule search mode */
                <div className="space-y-4">
                  <div className="flex flex-col gap-1">
                    <label className="label block text-sm font-semibold text-slate-700 mb-1">Find Appointment by Patient Name</label>
                    <div className="flex gap-2">
                      <input
                        type="text"
                        className="input w-full px-4 py-2 border border-slate-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-teal-500 focus:border-teal-500"
                        placeholder="Enter patient name..."
                        value={rescheduleSearchName}
                        onChange={(e) => setRescheduleSearchName(e.target.value)}
                      />
                      <button
                        type="button"
                        onClick={handleRescheduleSearch}
                        disabled={rescheduleSearchLoading}
                        className="bg-teal-600 hover:bg-teal-700 text-white font-semibold px-5 py-2 rounded-xl transition-colors shrink-0"
                      >
                        {rescheduleSearchLoading ? 'Searching...' : 'Search'}
                      </button>
                    </div>
                  </div>

                  {rescheduleSearchLoading && (
                    <div className="text-center text-sm text-slate-500 py-6">Searching appointments...</div>
                  )}

                  {!rescheduleSearchLoading && hasSearched && matchedAppointments.length === 0 && (
                    <div className="text-center bg-slate-50 rounded-xl p-6 border border-dashed border-slate-200">
                      <p className="text-sm text-slate-500">No active appointments found for "{rescheduleSearchName}".</p>
                    </div>
                  )}

                  {!rescheduleSearchLoading && matchedAppointments.length > 0 && (
                    <div className="space-y-3">
                      <h3 className="text-sm font-semibold text-navy-800">Select Appointment to Reschedule</h3>
                      <div className="grid gap-3 max-h-72 overflow-y-auto pr-1">
                        {matchedAppointments.map((app) => (
                          <div 
                            key={app.id} 
                            className="p-4 border border-slate-200 rounded-2xl hover:border-teal-400 hover:shadow-sm transition-all flex justify-between items-center bg-slate-50/50"
                          >
                            <div className="text-left">
                              <h4 className="font-semibold text-navy-800 text-sm">Dr. {app.doctor_name}</h4>
                              <p className="text-xs text-slate-500">{app.primary_specialty}</p>
                              <p className="text-xs text-teal-700 font-semibold mt-1">
                                🕒 {app.date} ({app.day}) &bull; {app.time_slot}
                              </p>
                              <p className="text-[11px] text-slate-400 mt-0.5">Patient: {app.patient_name}</p>
                            </div>
                            <button
                              type="button"
                              onClick={() => selectAppointmentToReschedule(app)}
                              className="bg-teal-50 hover:bg-teal-100 text-teal-700 border border-teal-200 text-xs font-semibold px-3 py-1.5 rounded-xl transition-colors shrink-0"
                            >
                              Reschedule
                            </button>
                          </div>
                        ))}
                      </div>
                    </div>
                  )}
                </div>
              ) : bookingMode === 'cancel' ? (
                /* Cancel search mode */
                <div className="space-y-4">
                  <div className="flex flex-col gap-1">
                    <label className="label block text-sm font-semibold text-slate-700 mb-1">Find Appointment to Cancel by Patient Name</label>
                    <div className="flex gap-2">
                      <input
                        type="text"
                        className="input w-full px-4 py-2 border border-slate-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-teal-500 focus:border-teal-500"
                        placeholder="Enter patient name..."
                        value={cancelSearchName}
                        onChange={(e) => setCancelSearchName(e.target.value)}
                      />
                      <button
                        type="button"
                        onClick={handleCancelSearch}
                        disabled={cancelSearchLoading}
                        className="bg-red-600 hover:bg-red-700 text-white font-semibold px-5 py-2 rounded-xl transition-colors shrink-0"
                      >
                        {cancelSearchLoading ? 'Searching...' : 'Search'}
                      </button>
                    </div>
                  </div>

                  {cancelSearchLoading && (
                    <div className="text-center text-sm text-slate-500 py-6">Searching appointments...</div>
                  )}

                  {!cancelSearchLoading && hasCancelSearched && matchedCancelAppointments.length === 0 && (
                    <div className="text-center bg-slate-50 rounded-xl p-6 border border-dashed border-slate-200">
                      <p className="text-sm text-slate-500">No active appointments found for "{cancelSearchName}".</p>
                    </div>
                  )}

                  {!cancelSearchLoading && matchedCancelAppointments.length > 0 && (
                    <div className="space-y-3">
                      <h3 className="text-sm font-semibold text-navy-800">Select Appointment to Cancel</h3>
                      <div className="grid gap-3 max-h-72 overflow-y-auto pr-1">
                        {matchedCancelAppointments.map((app) => (
                          <div 
                            key={app.id} 
                            className="p-4 border border-slate-200 rounded-2xl hover:border-red-400 hover:shadow-sm transition-all flex justify-between items-center bg-slate-50/50"
                          >
                            <div className="text-left">
                              <h4 className="font-semibold text-navy-800 text-sm">Dr. {app.doctor_name}</h4>
                              <p className="text-xs text-slate-500">{app.primary_specialty}</p>
                              <p className="text-xs text-red-600 font-semibold mt-1">
                                🕒 {app.date} ({app.day}) &bull; {app.time_slot}
                              </p>
                              <p className="text-[11px] text-slate-400 mt-0.5">Patient: {app.patient_name}</p>
                            </div>
                            <button
                              type="button"
                              onClick={() => {
                                setAppointmentToCancel(app);
                                setIsCancelModalOpen(true);
                              }}
                              className="bg-red-50 hover:bg-red-100 text-red-700 border border-red-200 text-xs font-semibold px-3 py-1.5 rounded-xl transition-colors shrink-0"
                            >
                              Cancel Appointment
                            </button>
                          </div>
                        ))}
                      </div>
                    </div>
                  )}
                </div>
              ) : (
                /* Standard Form / Form pre-filled for reschedule */
                <form onSubmit={handleSubmit} className="space-y-4">
                  {bookingMode === 'reschedule' && selectedAppointment && (
                    <div className="bg-teal-50/50 border border-teal-100 rounded-xl p-4 mb-4 relative">
                      <div className="text-xs uppercase tracking-wider text-teal-800 font-bold">Selected Appointment</div>
                      <div className="text-navy-800 font-semibold text-sm mt-1">
                        Dr. {selectedAppointment.doctor_name} &bull; {selectedAppointment.primary_specialty}
                      </div>
                      <div className="text-xs text-slate-600 mt-0.5">
                        Current Time: {selectedAppointment.date} ({selectedAppointment.day}) at {selectedAppointment.time_slot}
                      </div>
                      <button
                        type="button"
                        onClick={() => setSelectedAppointment(null)}
                        className="absolute top-4 right-4 text-xs font-semibold text-teal-600 hover:text-teal-800 underline"
                      >
                        Change Selection
                      </button>
                    </div>
                  )}

                  {/* Searchable Doctor Selection Dropdown */}
                  <div className="relative select-container w-full">
                    <label className="label block text-sm font-semibold text-slate-700 mb-1">Search/Select Doctor</label>
                    <input
                      type="text"
                      id="doctor-search-input"
                      className="input w-full px-4 py-2 border border-slate-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-teal-500 focus:border-teal-500"
                      placeholder="Search doctor by name..."
                      value={searchQuery}
                      onChange={(e) => {
                        setSearchQuery(e.target.value);
                        setIsDropdownOpen(true);
                        if (!e.target.value) {
                          setSelectedDoctorId('');
                          setDoctor(null);
                        }
                      }}
                      onFocus={() => setIsDropdownOpen(true)}
                      autoComplete="off"
                      required
                    />
                    
                    {isDropdownOpen && filteredDoctors.length > 0 && (
                      <div 
                        id="doctor-dropdown-menu" 
                        className="absolute z-50 w-full mt-1 bg-white border border-slate-200 rounded-xl shadow-lg max-h-60 overflow-y-auto"
                      >
                        {filteredDoctors.map(doc => (
                          <div
                            key={doc.id}
                            className="doctor-opt p-3 hover:bg-slate-50 cursor-pointer border-b border-slate-100 last:border-b-0"
                            onClick={() => {
                              setSelectedDoctorId(doc.id);
                              setSearchQuery(doc.name);
                              setIsDropdownOpen(false);
                            }}
                          >
                            <div className="font-semibold text-navy-800 text-sm">Dr. {doc.name}</div>
                            <div className="text-xs text-slate-500">{doc.specialty} • 🕒 {doc.availability}</div>
                          </div>
                        ))}
                      </div>
                    )}
                  </div>

                  <div className="grid md:grid-cols-2 gap-4">
                    <div>
                      <label className="label block text-sm font-semibold text-slate-700 mb-1">Doctor Name</label>
                      <input 
                        type="text" 
                        id="doctor-name-locked"
                        value={doctor ? `Dr. ${doctor.name}` : ''} 
                        readOnly 
                        className="input w-full px-4 py-2 border border-slate-200 bg-slate-50 cursor-not-allowed text-slate-600 font-semibold rounded-xl" 
                        placeholder="Choose doctor..."
                      />
                    </div>
                    <div>
                      <label className="label block text-sm font-semibold text-slate-700 mb-1">Primary Specialty</label>
                      <input 
                        type="text" 
                        id="doctor-specialty-locked"
                        value={doctor ? doctor.specialty : ''} 
                        readOnly 
                        className="input w-full px-4 py-2 border border-slate-200 bg-slate-50 cursor-not-allowed text-slate-600 rounded-xl" 
                        placeholder="Choose doctor..."
                      />
                    </div>
                  </div>

                  {doctor && (
                    <div id="availability-box" className="bg-teal-50/50 border border-teal-100 rounded-xl p-4 my-2">
                      <div className="text-xs uppercase tracking-wider text-teal-800 font-bold">Doctor Availability</div>
                      <div id="availability-text" className="text-navy-800 font-semibold text-sm mt-1">🕒 {doctor.availability}</div>
                    </div>
                  )}

                  <div>
                    <label className="label block text-sm font-semibold text-slate-700 mb-1">Patient Name (User booking appointment)</label>
                    <input 
                      type="text" 
                      required 
                      value={patientName}
                      onChange={(e) => setPatientName(e.target.value)}
                      className="input w-full px-4 py-2 border border-slate-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-teal-500 focus:border-teal-500" 
                      placeholder="Enter patient name" 
                    />
                  </div>

                  <div className="grid md:grid-cols-3 gap-4">
                    <div>
                      <label className="label block text-sm font-semibold text-slate-700 mb-1">Select Date</label>
                      <input 
                        type="date" 
                        id="appointment-date"
                        required 
                        value={date}
                        onChange={handleDateChange}
                        className="input w-full px-4 py-2 border border-slate-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-teal-500 focus:border-teal-500" 
                        min={new Date().toISOString().split('T')[0]}
                      />
                    </div>
                    <div>
                      <label className="label block text-sm font-semibold text-slate-700 mb-1">Day Name</label>
                      <input 
                        type="text" 
                        id="appointment-day"
                        readOnly 
                        value={day}
                        className="input w-full px-4 py-2 border border-slate-200 bg-slate-50 cursor-not-allowed font-semibold text-slate-500 rounded-xl" 
                        placeholder="Auto-calculated" 
                      />
                    </div>
                    <div>
                      <label className="label block text-sm font-semibold text-slate-700 mb-1">Time Slot</label>
                      <select 
                        id="appointment-time-slot"
                        required 
                        value={timeSlot}
                        onChange={(e) => setTimeSlot(e.target.value)}
                        className="select w-full px-4 py-2 border border-slate-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-teal-500 focus:border-teal-500"
                      >
                        <option value="">Choose slot...</option>
                        {availableSlots.map(slot => (
                          <option key={slot} value={slot}>{slot}</option>
                        ))}
                        {doctor && date && availableSlots.length === 0 && (
                          <option value="" disabled>No slots available on this day</option>
                        )}
                      </select>
                    </div>
                  </div>

                  <div className="pt-4 border-t border-slate-100 flex gap-3">
                    <button 
                      type="submit" 
                      disabled={submitting} 
                      className="btn btn-primary flex-1 justify-center bg-teal-600 hover:bg-teal-700 text-white font-semibold py-2 px-4 rounded-xl transition-colors"
                    >
                      {submitting 
                        ? (bookingMode === 'reschedule' ? 'Rescheduling...' : 'Booking...') 
                        : (bookingMode === 'reschedule' ? 'Confirm Reschedule' : 'Confirm Appointment Booking')}
                    </button>
                    {bookingMode === 'reschedule' && selectedAppointment ? (
                      <button 
                        type="button" 
                        onClick={() => setSelectedAppointment(null)}
                        className="btn btn-outline px-4 py-2 border border-slate-300 text-slate-700 font-semibold rounded-xl hover:bg-slate-50 transition-colors"
                      >
                        Back
                      </button>
                    ) : (
                      <Link to="/" className="btn btn-outline px-4 py-2 border border-slate-300 text-slate-700 font-semibold rounded-xl hover:bg-slate-50 transition-colors">Cancel</Link>
                    )}
                  </div>
                </form>
              )}
            </>
          )}
        </div>
      </section>

      {/* Premium Cancel Confirmation Modal */}
      {isCancelModalOpen && appointmentToCancel && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/60 backdrop-blur-sm transition-opacity duration-300">
          <div className="bg-white rounded-2xl max-w-md w-full p-6 shadow-2xl border border-slate-100 transform scale-100 transition-all duration-300 animate-in fade-in zoom-in-95 duration-200">
            <div className="flex items-center justify-center w-12 h-12 mx-auto bg-red-100 text-red-600 rounded-full mb-4">
              <AlertCircle className="w-6 h-6" />
            </div>
            <h3 className="text-center font-display font-bold text-lg text-navy-800">Cancel Appointment?</h3>
            <p className="text-center text-sm text-slate-500 mt-2 mb-6 leading-relaxed">
              Are you sure you want to cancel this appointment with <strong className="text-navy-800">Dr. {appointmentToCancel.doctor_name}</strong> on <span className="font-semibold text-slate-700">{appointmentToCancel.date} ({appointmentToCancel.day}) at {appointmentToCancel.time_slot}</span>? This action cannot be undone.
            </p>
            <div className="flex gap-3">
              <button
                type="button"
                onClick={executeCancellation}
                disabled={cancelling}
                className="flex-1 bg-red-600 hover:bg-red-700 text-white font-semibold py-2.5 rounded-xl transition-colors text-sm"
              >
                {cancelling ? 'Cancelling...' : 'Yes, Cancel'}
              </button>
              <button
                type="button"
                onClick={() => {
                  setIsCancelModalOpen(false);
                  setAppointmentToCancel(null);
                }}
                className="flex-1 bg-slate-100 hover:bg-slate-200 text-slate-700 font-semibold py-2.5 rounded-xl transition-colors text-sm border border-slate-200"
              >
                No, Keep It
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
