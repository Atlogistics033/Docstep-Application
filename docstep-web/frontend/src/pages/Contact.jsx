import React, { useState } from 'react';
import axios from 'axios';
import { Mail, Phone, MapPin, Send, CheckCircle2 } from 'lucide-react';
import { Link } from 'react-router-dom';

export default function Contact() {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [subject, setSubject] = useState('');
  const [message, setMessage] = useState('');
  const [submitted, setSubmitted] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!name || !email || !message) {
      setError('Name, email, and message are required.');
      return;
    }
    setLoading(true);
    setError('');
    try {
      const res = await axios.post('/api/public/contact', { name, email, subject, message });
      if (res.data.success) {
        setSubmitted(true);
      } else {
        setError(res.data.error || 'Failed to send message.');
      }
    } catch (err) {
      setError(err.response?.data?.error || 'Failed to send message.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fade-in text-left">
      {/* Hero Header */}
      <section className="hero-gradient">
        <div className="max-w-6xl mx-auto px-4 pt-14 pb-10">
          <div className="brand-pill mb-3">Contact</div>
          <h1 className="font-display font-extrabold text-3xl md:text-5xl text-navy-800">Let's talk</h1>
          <p className="text-slate-600 mt-3 max-w-2xl">
            Questions about returning to practice, hiring, or partnerships? We'd love to hear from you.
          </p>
        </div>
      </section>

      {/* Main Grid */}
      <section className="max-w-6xl mx-auto px-4 py-12 grid lg:grid-cols-3 gap-8">
        <div className="lg:col-span-2 card card-pad bg-white">
          {submitted ? (
            <div className="text-center py-8">
              <div className="w-16 h-16 rounded-full bg-teal-100 text-teal-700 flex items-center justify-center mx-auto mb-4">
                <CheckCircle2 className="w-8 h-8" />
              </div>
              <h2 className="font-display font-bold text-2xl text-navy-800">Thanks for reaching out!</h2>
              <p className="text-slate-600 mt-2">We'll get back to you within 1–2 business days.</p>
              <Link to="/" className="btn btn-outline mt-6 inline-flex">
                Back to home
              </Link>
            </div>
          ) : (
            <>
              <h2 className="font-display font-bold text-xl text-navy-800 mb-4">Send us a message</h2>
              {error && (
                <div className="flash flash-error mb-4">
                  {error}
                </div>
              )}
              <form onSubmit={handleSubmit} className="space-y-4">
                <div className="grid md:grid-cols-2 gap-3">
                  <div>
                    <label className="label">Full name</label>
                    <input
                      name="name"
                      required
                      value={name}
                      onChange={(e) => setName(e.target.value)}
                      className="input"
                    />
                  </div>
                  <div>
                    <label className="label">Email</label>
                    <input
                      type="email"
                      name="email"
                      required
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      className="input"
                    />
                  </div>
                </div>
                <div>
                  <label className="label">Subject</label>
                  <input
                    name="subject"
                    value={subject}
                    onChange={(e) => setSubject(e.target.value)}
                    className="input"
                    placeholder="e.g. Partnership enquiry"
                  />
                </div>
                <div>
                  <label className="label">Message</label>
                  <textarea
                    name="message"
                    required
                    rows="5"
                    value={message}
                    onChange={(e) => setMessage(e.target.value)}
                    className="textarea"
                  ></textarea>
                </div>
                <button type="submit" disabled={loading} className="btn btn-primary inline-flex">
                  <Send className="w-4 h-4 mr-1.5" />
                  {loading ? 'Sending...' : 'Send message'}
                </button>
              </form>
            </>
          )}
        </div>

        <aside className="space-y-4">
          <div className="card card-pad bg-white">
            <h3 className="font-semibold text-navy-800 mb-3">Reach the team</h3>
            <div className="space-y-3 text-sm">
              <div>
                <div className="text-xs uppercase tracking-wider text-slate-500 flex items-center gap-1">
                  <Mail className="w-3.5 h-3.5" /> Email
                </div>
                <div className="text-navy-800 font-semibold mt-0.5">hello@docstep.pk</div>
              </div>
              <div>
                <div className="text-xs uppercase tracking-wider text-slate-500 flex items-center gap-1">
                  <Phone className="w-3.5 h-3.5" /> Phone
                </div>
                <div className="text-navy-800 font-semibold mt-0.5">+92-21-XXXX-XXXX</div>
              </div>
              <div>
                <div className="text-xs uppercase tracking-wider text-slate-500 flex items-center gap-1">
                  <MapPin className="w-3.5 h-3.5" /> Office
                </div>
                <div className="text-navy-800 font-semibold mt-0.5">
                  DocStep Headquarters
                </div>
                <div className="text-xs text-slate-500 mt-0.5">Karachi, Pakistan</div>
              </div>
            </div>
          </div>
        </aside>
      </section>
    </div>
  );
}
