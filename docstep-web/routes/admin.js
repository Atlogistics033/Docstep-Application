// Admin dashboard routes - direct Firebase Firestore
const express = require('express');
const router = express.Router();
const dbService = require('../db/dbService');
const { requireRole } = require('../middleware/auth');

router.use(requireRole('admin'));

router.get('/', (req, res) => res.redirect('/admin/dashboard'));

router.get('/dashboard', async (req, res) => {
  try {
    const stats = await dbService.getStats();
    const unverifiedDocs = await dbService.getUnverifiedDoctors();
    const unverifiedCreds = await dbService.getUnverifiedCredentials();
    const contacts = await dbService.getContactMessages();
    
    res.render('admin/dashboard', {
      title: 'Admin Dashboard',
      stats,
      unverifiedDocs,
      unverifiedCreds,
      contacts,
      layout: 'layout'
    });
  } catch (err) {
    console.error('Admin dashboard error:', err);
    res.redirect('/');
  }
});

router.post('/verify-pmdc/:id', async (req, res) => {
  try {
    await dbService.verifyPmdc(req.params.id);
    req.session.flash = { type: 'success', text: 'Doctor PMDC verified successfully.' };
  } catch (err) {
    console.error('Verify PMDC error:', err);
    req.session.flash = { type: 'error', text: 'Failed to verify PMDC.' };
  }
  res.redirect('/admin/dashboard');
});

router.post('/verify-credential/:id', async (req, res) => {
  try {
    await dbService.verifyCredential(req.params.id);
    req.session.flash = { type: 'success', text: 'Credential approved successfully.' };
  } catch (err) {
    console.error('Verify credential error:', err);
    req.session.flash = { type: 'error', text: 'Failed to verify credential.' };
  }
  res.redirect('/admin/dashboard');
});

router.post('/delete-credential/:id', async (req, res) => {
  try {
    // We pass null for doctorId in dbService since we delete by document ID directly in Firestore
    await dbService.deleteCredential(req.params.id, null);
    req.session.flash = { type: 'success', text: 'Credential rejected and deleted.' };
  } catch (err) {
    console.error('Delete credential error:', err);
    req.session.flash = { type: 'error', text: 'Failed to delete credential.' };
  }
  res.redirect('/admin/dashboard');
});

module.exports = router;
