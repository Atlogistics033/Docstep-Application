// Tiny client helpers
document.addEventListener('DOMContentLoaded', () => {
  const burger = document.getElementById('burger');
  const mobileNav = document.getElementById('mobile-nav');
  if (burger && mobileNav) {
    burger.addEventListener('click', () => mobileNav.classList.toggle('hidden'));
  }
  // Auto-hide flash after 5s
  document.querySelectorAll('.flash').forEach(el => setTimeout(() => el.style.display = 'none', 6000));
});
