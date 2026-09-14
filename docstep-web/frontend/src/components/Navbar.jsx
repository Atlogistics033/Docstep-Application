import React, { useState } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { Menu, X, LogOut, ChevronDown, User, Shield } from 'lucide-react';

export default function Navbar() {
  const { user, logout } = useAuth();
  const [isOpen, setIsOpen] = useState(false);
  const location = useLocation();
  const navigate = useNavigate();

  const currentPath = location.pathname;

  const handleLogout = async () => {
    await logout();
    navigate('/');
  };

  const navLinks = [
    { label: 'Home', path: '/' },
    { label: 'About', path: '/about' },
    { label: 'Book Appointment', path: '/opportunities' },
    { label: 'Suggest Best Doctor', path: '/suggest-best-doctor' },
    { label: 'For Doctors', path: '/for-doctors' },
    { label: 'For Employers', path: '/for-employers' },
    { label: 'Community', path: '/community' },
    { label: 'Courses', path: '/courses' },
    { label: 'Contact', path: '/contact' },
  ];

  return (
    <header className="bg-white/85 backdrop-blur border-b border-slate-200 sticky top-0 z-40">
      <div className="max-w-[90rem] mx-auto px-4 py-3 flex items-center justify-between md:grid md:grid-cols-[1fr_auto_1fr]">
        <div className="flex justify-start">
          <Link to="/" className="logo-mark">
            <img src="/images/logo.png" alt="DocStep logo" className="h-[38px] w-auto" />
            <div className="wordmark">Doc<span>Step</span></div>
          </Link>
        </div>

        {/* Desktop Links */}
        <nav className="nav-links-desktop hidden md:flex items-center justify-center gap-1.5 lg:gap-2 xl:gap-3">
          {navLinks.map((link) => (
            <Link
              key={link.path}
              to={link.path}
              className={`nav-link ${currentPath === link.path ? 'active' : ''}`}
            >
              {link.label}
            </Link>
          ))}
        </nav>

        {/* Buttons / Actions */}
        <div className="flex items-center justify-end gap-2">
          {user ? (
            <div className="flex items-center gap-2">
              {user.role === 'doctor' && (
                <Link to="/doctor/dashboard" className="btn btn-outline text-sm">Dashboard</Link>
              )}
              {user.role === 'employer' && (
                <Link to="/employer/dashboard" className="btn btn-outline text-sm">Dashboard</Link>
              )}
              {user.role === 'admin' && (
                <Link to="/admin/dashboard" className="btn btn-outline text-sm">Admin</Link>
              )}
              <button onClick={handleLogout} className="btn btn-ghost hidden md:inline-flex text-sm">
                <LogOut className="w-4 h-4 mr-1" /> Logout
              </button>
            </div>
          ) : (
            <div className="flex items-center gap-2">
              <Link to="/login" className="btn btn-ghost hidden md:inline-flex text-sm">Login</Link>
              <Link to="/register" className="btn btn-primary text-sm">Get Started</Link>
            </div>
          )}

          {/* Burger Menu for Mobile */}
          <button
            onClick={() => setIsOpen(!isOpen)}
            className="md:hidden p-2 rounded-md hover:bg-slate-100"
            aria-label="Toggle menu"
          >
            {isOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
          </button>
        </div>
      </div>

      {/* Mobile Navigation Panel */}
      {isOpen && (
        <div id="mobile-nav" className="md:hidden border-t border-slate-200 bg-white">
          <div className="px-4 py-3 flex flex-col gap-1 text-sm">
            {navLinks.map((link) => (
              <Link
                key={link.path}
                to={link.path}
                onClick={() => setIsOpen(false)}
                className={`py-2 text-slate-700 font-medium ${currentPath === link.path ? 'text-teal-600 font-bold' : ''}`}
              >
                {link.label}
              </Link>
            ))}

            {/* User Session options in mobile */}
            {!user ? (
              <div className="border-t border-slate-200 pt-3 mt-2 flex gap-2">
                <Link
                  to="/login"
                  onClick={() => setIsOpen(false)}
                  className="btn btn-outline flex-1 justify-center"
                >
                  Login
                </Link>
                <Link
                  to="/register"
                  onClick={() => setIsOpen(false)}
                  className="btn btn-primary flex-1 justify-center"
                >
                  Get Started
                </Link>
              </div>
            ) : (
              <div className="border-t border-slate-200 pt-3 mt-2 flex flex-col gap-2">
                {user.role === 'doctor' && (
                  <Link
                    to="/doctor/dashboard"
                    onClick={() => setIsOpen(false)}
                    className="btn btn-outline justify-center"
                  >
                    Doctor Dashboard
                  </Link>
                )}
                {user.role === 'employer' && (
                  <Link
                    to="/employer/dashboard"
                    onClick={() => setIsOpen(false)}
                    className="btn btn-outline justify-center"
                  >
                    Employer Dashboard
                  </Link>
                )}
                {user.role === 'admin' && (
                  <Link
                    to="/admin/dashboard"
                    onClick={() => setIsOpen(false)}
                    className="btn btn-outline justify-center"
                  >
                    Admin Dashboard
                  </Link>
                )}
                <button
                  onClick={() => {
                    setIsOpen(false);
                    handleLogout();
                  }}
                  className="btn btn-ghost text-red-600 justify-center w-full"
                >
                  <LogOut className="w-4 h-4 mr-1" /> Logout
                </button>
              </div>
            )}
          </div>
        </div>
      )}
    </header>
  );
}
