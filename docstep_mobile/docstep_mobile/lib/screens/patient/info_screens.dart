import 'package:flutter/material.dart';
import '../../core/theme.dart';

class ForDoctorsInfoScreen extends StatelessWidget {
  const ForDoctorsInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('For Doctors'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                gradient: AppTheme.accentGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'For Doctors',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'A platform built around your reality.',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Whether you took a break for marriage, motherhood, relocation, or burnout — DocStep helps you re-enter clinical practice on flexible, dignified terms.',
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Redesigned Paragraph Section about Doctors
            const Text(
              'Vetted Clinical Professionals',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.secondary),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: AppTheme.cardDecoration(),
              padding: const EdgeInsets.all(20),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DocStep connects you with highly qualified, PMDC-verified female medical professionals who are returning to clinical practice. Our network includes experienced Gynecologists, Pediatricians, Psychiatrists, General Physicians, and clinical specialists. These doctors are vetted, certified, and ready to assist with remote consultations, telehealth, clinic shifts, and digital healthcare operations.',
                    style: TextStyle(color: AppTheme.textDark, fontSize: 14, height: 1.5),
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Whether you need full-time clinical support or part-time consultations, our doctors offer flexible availability tailored to modern clinic schedules, providing high-quality, compassionate patient care on demand.',
                    style: TextStyle(color: AppTheme.textMedium, fontSize: 13, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class ForEmployersInfoScreen extends StatelessWidget {
  const ForEmployersInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('For Employers'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                gradient: AppTheme.accentGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'For Employers',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Hire verified women doctors — on flexible terms.',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tap into a vetted pool of returning gynecologists, pediatricians, psychiatrists, and GPs ready for remote, hybrid, and part-time roles.',
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            const Text(
              'How it works',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.secondary),
            ),
            const SizedBox(height: 16),

            _buildEmployerStep(
              number: '1',
              title: 'Post a role in minutes',
              description: 'Specialty, mode, salary, requirements — done in 60 seconds.',
            ),
            _buildEmployerStep(
              number: '2',
              title: 'Browse verified candidates',
              description: 'PMDC-verified profiles, with CVs and credentials at your fingertips.',
            ),
            _buildEmployerStep(
              number: '3',
              title: 'Interview & hire',
              description: 'Schedule interviews, track applications, and hire — all from your dashboard.',
            ),
            const SizedBox(height: 24),

            // Redesigned Pricing Section matching the mockup
            const Divider(color: AppTheme.borderLight, height: 40),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF), // light purple
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Pricing — coming soon',
                  style: TextStyle(color: Color(0xFF7E22CE), fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Simple, transparent plans',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.secondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            _buildPlanCard(
              title: 'Free',
              price: 'PKR 0',
              subtitle: 'Post up to 1 job. Browse public profiles.',
              features: ['1 active job posting', 'Basic candidate search', 'Email notifications'],
              badgeBg: const Color(0xFFF1F5F9), // light grey
              badgeText: const Color(0xFF64748B),
            ),
            const SizedBox(height: 16),
            _buildPlanCard(
              title: 'Growth',
              price: 'PKR 9,900/mo',
              subtitle: 'Most popular for clinics & telehealth.',
              features: [
                '10 active job postings',
                'Full candidate search & filters',
                'Interview scheduling tools',
                'Featured listing badges'
              ],
              badgeBg: const Color(0xFFE6F4EA), // light green/teal
              badgeText: const Color(0xFF137333),
            ),
            const SizedBox(height: 16),
            _buildPlanCard(
              title: 'Enterprise',
              price: 'Custom',
              subtitle: 'Hospital networks & telehealth platforms.',
              features: [
                'Unlimited postings & seats',
                'Returnship program co-design',
                'API & ATS integrations',
                'Dedicated success manager'
              ],
              badgeBg: const Color(0xFFF3E8FF), // light purple
              badgeText: const Color(0xFF7E22CE),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployerStep({required String number, required String title, required String description}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.secondary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: const TextStyle(color: AppTheme.secondary, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.secondary),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: AppTheme.textMedium, fontSize: 13, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String subtitle,
    required List<String> features,
    required Color badgeBg,
    required Color badgeText,
  }) {
    return Container(
      decoration: AppTheme.cardDecoration().copyWith(
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              title,
              style: TextStyle(color: badgeText, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          // Price
          Text(
            price,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 26, color: AppTheme.secondary),
          ),
          const SizedBox(height: 4),
          // Subtitle
          Text(
            subtitle,
            style: const TextStyle(color: AppTheme.textMedium, fontSize: 13, height: 1.4),
          ),
          const Divider(height: 24, color: AppTheme.borderLight),
          // Features
          ...features.map((f) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    const Text(
                      '✓ ',
                      style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        f,
                        style: const TextStyle(fontSize: 13, color: AppTheme.textDark),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
