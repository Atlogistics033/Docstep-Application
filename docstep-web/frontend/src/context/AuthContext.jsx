import React, { createContext, useContext, useState, useEffect } from 'react';
import axios from 'axios';

const AuthContext = createContext(null);

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [flash, setFlash] = useState(null);

  const showFlash = (type, text) => {
    setFlash({ type, text });
    setTimeout(() => {
      setFlash(null);
    }, 5000);
  };

  const fetchCurrentUser = async () => {
    try {
      const res = await axios.get('/api/auth/me');
      if (res.data.success) {
        setUser(res.data.user);
      }
    } catch (err) {
      console.error('Failed to fetch user session:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchCurrentUser();
  }, []);

  const login = async (email, password) => {
    try {
      const res = await axios.post('/api/auth/login', { email, password });
      if (res.data.success) {
        setUser(res.data.user);
        // Firestore field 'full_name' ke mutabiq name access kiya
        showFlash('success', `Welcome back, ${res.data.user.full_name || res.data.user.name || 'User'}!`);
        return { success: true };
      }
      return { success: false, error: 'Login failed' };
    } catch (err) {
      const errMsg = err.response?.data?.error || 'Invalid credentials';
      showFlash('error', errMsg);
      return { success: false, error: errMsg };
    }
  };

  const register = async (formData) => {
    try {
      // Data mapping: ensure karte hain ke field names exact match karein
      const payload = {
        ...formData,
        full_name: formData.full_name || formData.name || formData.fullName,
        user_id: formData.user_id || formData.id,
      };

      const res = await axios.post('/api/auth/register', payload);
      if (res.data.success) {
        setUser(res.data.user);
        showFlash('success', 'Account created. Welcome to DocStep!');
        return { success: true };
      }
      return { success: false, error: 'Registration failed' };
    } catch (err) {
      const errMsg = err.response?.data?.error || 'Registration failed';
      showFlash('error', errMsg);
      return { success: false, error: errMsg };
    }
  };

  const logout = async () => {
    try {
      const res = await axios.post('/api/auth/logout');
      if (res.data.success) {
        setUser(null);
        showFlash('info', 'Logged out successfully.');
      }
    } catch (err) {
      console.error('Logout error:', err);
    }
  };

  return (
    <AuthContext.Provider value={{ user, loading, login, register, logout, flash, showFlash }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => useContext(AuthContext);