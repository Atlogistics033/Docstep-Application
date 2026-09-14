import React from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { 
  Home, 
  User, 
  Award, 
  FileText, 
  FolderClosed, 
  Clock, 
  Search, 
  Calendar, 
  Building,
  PlusCircle,
  MessageSquare
} from 'lucide-react';

export default function Sidebar({ activeSide }) {
  const { user } = useAuth();

  if (!user) return null;

  if (user.role === 'doctor') {
    return (
      <aside className="card p-4 lg:sticky lg:top-24 self-start">
        <div className="px-2 mb-3">
          <div className="text-xs uppercase tracking-wider text-slate-500 font-bold">Doctor Portal</div>
          <div className="font-display font-bold text-navy-800 text-base truncate" title={user.full_name}>
            {user.full_name}
          </div>
        </div>
        <nav className="space-y-1">
          <Link to="/doctor/dashboard" className={`side-link ${activeSide === 'home' ? 'active' : ''}`}>
            <Home /> Dashboard
          </Link>
          <Link to="/doctor/profile" className={`side-link ${activeSide === 'profile' ? 'active' : ''}`}>
            <User /> My Profile
          </Link>
          <Link to="/doctor/credentials" className={`side-link ${activeSide === 'credentials' ? 'active' : ''}`}>
            <Award /> Credentials
          </Link>
          <Link to="/doctor/cv-builder" className={`side-link ${activeSide === 'cv' ? 'active' : ''}`}>
            <FileText /> CV Builder
          </Link>
          <Link to="/doctor/appointments" className={`side-link ${activeSide === 'appointments' ? 'active' : ''}`}>
            <FolderClosed /> My Appointments
          </Link>
          <Link to="/doctor/availability" className={`side-link ${activeSide === 'availability' ? 'active' : ''}`}>
            <Clock /> Availability
          </Link>
        </nav>
        <div className="divider my-4"></div>
        <Link to="/opportunities" className="side-link">
          <Calendar /> Book Appointment
        </Link>
        <Link to="/community" className="side-link">
          <MessageSquare /> Community
        </Link>
      </aside>
    );
  }

  if (user.role === 'employer') {
    return (
      <aside className="card p-4 lg:sticky lg:top-24 self-start">
        <div className="px-2 mb-3">
          <div className="text-xs uppercase tracking-wider text-slate-500 font-bold">Employer Portal</div>
          <div className="font-display font-bold text-navy-800 text-base truncate" title={user.full_name}>
            {user.full_name}
          </div>
        </div>
        <nav className="space-y-1">
          <Link to="/employer/dashboard" className={`side-link ${activeSide === 'home' ? 'active' : ''}`}>
            <Home /> Dashboard
          </Link>
          <Link to="/employer/jobs" className={`side-link ${activeSide === 'jobs' ? 'active' : ''}`}>
            <FileText /> My Job Postings
          </Link>
          <Link to="/employer/candidates" className={`side-link ${activeSide === 'candidates' ? 'active' : ''}`}>
            <Search /> Search Candidates
          </Link>
          <Link to="/employer/appointments" className={`side-link ${activeSide === 'appointments' ? 'active' : ''}`}>
            <FolderClosed /> My Appointments
          </Link>
          <Link to="/employer/profile" className={`side-link ${activeSide === 'profile' ? 'active' : ''}`}>
            <Building /> Organization
          </Link>
        </nav>
        <div className="divider my-4"></div>
        <Link to="/employer/jobs/new" className="btn btn-primary w-full justify-center text-sm">
          <PlusCircle className="w-4 h-4 mr-1" /> + Post a job
        </Link>
      </aside>
    );
  }

  return null;
}
