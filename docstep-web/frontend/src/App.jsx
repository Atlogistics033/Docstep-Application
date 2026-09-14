import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate, useLocation } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';

// Common Components
import Navbar from './components/Navbar';
import Footer from './components/Footer';

// Public Pages
import Home from './pages/Home';
import About from './pages/About';
import ForDoctors from './pages/ForDoctors';
import ForEmployers from './pages/ForEmployers';
import Contact from './pages/Contact';
import Courses from './pages/Courses';
import Opportunities from './pages/Opportunities';
import JobDetail from './pages/JobDetail';
import CommunityForum from './pages/CommunityForum';
import CommunityPost from './pages/CommunityPost';
import Login from './pages/Login';
import Register from './pages/Register';
import ForgotPassword from './pages/ForgotPassword';
import ResetPassword from './pages/ResetPassword';
import SuggestBestDoctor from './pages/SuggestBestDoctor';

// Doctor Dashboard Pages
import DoctorDashboard from './pages/DoctorDashboard';
import DoctorProfile from './pages/DoctorProfile';
import Credentials from './pages/Credentials';
import CVBuilder from './pages/CVBuilder';
import Appointments from './pages/Appointments';
import Availability from './pages/Availability';
import BookAppointment from './pages/BookAppointment';

// Employer Dashboard Pages
import EmployerDashboard from './pages/EmployerDashboard';
import Jobs from './pages/Jobs';
import PostJob from './pages/PostJob';
import Candidates from './pages/Candidates';
import CandidateDetail from './pages/CandidateDetail';
import EmployerAppointments from './pages/EmployerAppointments';
import EmployerProfile from './pages/EmployerProfile';

// Admin Pages
import AdminDashboard from './pages/AdminDashboard';

// Protected Route Guard
function ProtectedRoute({ children, allowedRoles }) {
  const { user, loading } = useAuth();

  if (loading) {
    return (
      <div className="min-h-[60vh] flex items-center justify-center text-slate-500">
        Loading Portal...
      </div>
    );
  }

  if (!user) {
    return <Navigate to="/login" replace />;
  }

  if (allowedRoles && !allowedRoles.includes(user.role)) {
    return <Navigate to="/" replace />;
  }

  return children;
}

// Flash Message Banner
function FlashBanner() {
  const { flash } = useAuth();
  if (!flash) return null;

  return (
    <div className="max-w-7xl mx-auto px-4 pt-4 print:hidden">
      <div className={`flash flash-${flash.type}`}>{flash.text}</div>
    </div>
  );
}

function AppContent() {
  const { loading } = useAuth();
  const location = useLocation();
  const hideNavbarAndFooter = ['/login', '/register', '/forgot-password'].includes(location.pathname);

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-slate-50 text-slate-500 font-display">
        Loading DocStep...
      </div>
    );
  }

  return (
    <div className="flex flex-col min-h-screen bg-slate-50 text-slate-800 font-sans antialiased">
      {!hideNavbarAndFooter && <Navbar />}
      <FlashBanner />
      <main className="flex-1 min-h-[60vh]">
        <Routes>
          {/* Public Routes */}
          <Route path="/" element={<Home />} />
          <Route path="/about" element={<About />} />
          <Route path="/opportunities" element={<Opportunities />} />
          <Route path="/jobs/:id" element={<JobDetail />} />
          <Route path="/for-doctors" element={<ForDoctors />} />
          <Route path="/for-employers" element={<ForEmployers />} />
          <Route path="/community" element={<CommunityForum />} />
          <Route path="/community/:id" element={<CommunityPost />} />
          <Route path="/courses" element={<Courses />} />
          <Route path="/contact" element={<Contact />} />
          <Route path="/book-appointment" element={<BookAppointment />} />
          <Route path="/suggest-best-doctor" element={<SuggestBestDoctor />} />

          {/* Auth Routes */}
          <Route path="/login" element={<Login />} />
          <Route path="/register" element={<Register />} />
          <Route path="/forgot-password" element={<ForgotPassword />} />
          <Route path="/reset-password" element={<ResetPassword />} />

          {/* Doctor Portal Routes */}
          <Route
            path="/doctor/dashboard"
            element={
              <ProtectedRoute allowedRoles={['doctor']}>
                <DoctorDashboard />
              </ProtectedRoute>
            }
          />
          <Route
            path="/doctor/profile"
            element={
              <ProtectedRoute allowedRoles={['doctor']}>
                <DoctorProfile />
              </ProtectedRoute>
            }
          />
          <Route
            path="/doctor/credentials"
            element={
              <ProtectedRoute allowedRoles={['doctor']}>
                <Credentials />
              </ProtectedRoute>
            }
          />
          <Route
            path="/doctor/cv-builder"
            element={
              <ProtectedRoute allowedRoles={['doctor']}>
                <CVBuilder />
              </ProtectedRoute>
            }
          />
          <Route
            path="/doctor/appointments"
            element={
              <ProtectedRoute allowedRoles={['doctor']}>
                <Appointments />
              </ProtectedRoute>
            }
          />
          <Route
            path="/doctor/availability"
            element={
              <ProtectedRoute allowedRoles={['doctor']}>
                <Availability />
              </ProtectedRoute>
            }
          />

          {/* Employer Portal Routes */}
          <Route
            path="/employer/dashboard"
            element={
              <ProtectedRoute allowedRoles={['employer']}>
                <EmployerDashboard />
              </ProtectedRoute>
            }
          />
          <Route
            path="/employer/jobs"
            element={
              <ProtectedRoute allowedRoles={['employer']}>
                <Jobs />
              </ProtectedRoute>
            }
          />
          <Route
            path="/employer/jobs/new"
            element={
              <ProtectedRoute allowedRoles={['employer']}>
                <PostJob />
              </ProtectedRoute>
            }
          />
          <Route
            path="/employer/jobs/:id/edit"
            element={
              <ProtectedRoute allowedRoles={['employer']}>
                <PostJob />
              </ProtectedRoute>
            }
          />
          <Route
            path="/employer/candidates"
            element={
              <ProtectedRoute allowedRoles={['employer']}>
                <Candidates />
              </ProtectedRoute>
            }
          />
          <Route
            path="/employer/candidates/:id"
            element={
              <ProtectedRoute allowedRoles={['employer']}>
                <CandidateDetail />
              </ProtectedRoute>
            }
          />
          <Route
            path="/employer/appointments"
            element={
              <ProtectedRoute allowedRoles={['employer']}>
                <EmployerAppointments />
              </ProtectedRoute>
            }
          />

          <Route
            path="/employer/profile"
            element={
              <ProtectedRoute allowedRoles={['employer']}>
                <EmployerProfile />
              </ProtectedRoute>
            }
          />

          {/* Admin Routes */}
          <Route
            path="/admin/dashboard"
            element={
              <ProtectedRoute allowedRoles={['admin']}>
                <AdminDashboard />
              </ProtectedRoute>
            }
          />

          {/* Fallback Catch-all redirect to Home */}
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </main>
      {!hideNavbarAndFooter && <Footer />}
    </div>
  );
}

export default function App() {
  return (
    <AuthProvider>
      <Router>
        <AppContent />
      </Router>
    </AuthProvider>
  );
}
