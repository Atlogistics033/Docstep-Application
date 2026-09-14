// DocStep middleware helpers
function isAuthed(req, res, next) {
  if (req.session && req.session.user) return next();
  req.session.flash = { type: 'error', text: 'Please login to continue.' };
  return res.redirect('/login');
}

function requireRole(role) {
  return (req, res, next) => {
    if (req.session && req.session.user && req.session.user.role === role) return next();
    req.session.flash = { type: 'error', text: `This area is for ${role}s only.` };
    return res.redirect('/login');
  };
}

function injectUser(req, res, next) {
  res.locals.user = (req.session && req.session.user) || null;
  res.locals.flash = req.session ? req.session.flash : null;
  if (req.session) req.session.flash = null;
  res.locals.currentPath = req.path;
  next();
}

module.exports = { isAuthed, requireRole, injectUser };
