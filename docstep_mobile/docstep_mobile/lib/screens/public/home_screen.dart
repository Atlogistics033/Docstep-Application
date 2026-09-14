import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white, // White background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Image.asset(
          'assets/images/logo.png',
          height: 32,
          errorBuilder: (context, error, stackTrace) => const Text('DocStep', style: TextStyle(color: Color(0xFF0F172A))),
        ),
        actions: [
          authProvider.isAuthenticated
              ? IconButton(
                  icon: const Icon(Icons.logout, color: Color(0xFF0F172A)),
                  onPressed: () => authProvider.logout(),
                )
              : IconButton(
                  icon: const Icon(Icons.login, color: Color(0xFF0F172A)),
                  onPressed: () => Navigator.of(context).pushNamed('/login'),
                ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/hero_doctors.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primary.withValues(alpha: 0.9), // Soft Teal
                      const Color(0xFF0F172A).withValues(alpha: 0.8), // Navy
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Restart Your Medical Career',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Flexible, telemedicine, and hybrid jobs designed for women doctors in Pakistan.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                    ),
                  ],
                ),
              ),
            ),
            
            // Statistics banner
            Container(
              color: const Color(0xFFE0E7FF), // Lavender Background for Stats
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(context, '150+', 'Doctors Registered'),
                  _buildDivider(),
                  _buildStatItem(context, '50+', 'Active Employers'),
                  _buildDivider(),
                  _buildStatItem(context, '120+', 'Successful Placements'),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildPortalCTA(
                    context,
                    title: 'For Doctors',
                    description: 'Explore part-time, remote, or hybrid medical opportunities.',
                    buttonText: 'Find Job Opportunities',
                    icon: Icons.health_and_safety_outlined,
                    onPressed: () {},
                  ),
                  const SizedBox(height: 20),
                  _buildPortalCTA(
                    context,
                    title: 'For Employers',
                    description: 'Post medical jobs and match with verified female doctors.',
                    buttonText: 'Post a New Job',
                    icon: Icons.business_center_outlined,
                    onPressed: () {
                      if (authProvider.isAuthenticated && authProvider.user!.role == 'employer') {
                        Navigator.of(context).pushNamed('/employer/dashboard');
                      } else {
                        Navigator.of(context).pushNamed('/login');
                      }
                    },
                  ),
                ],
              ),
            ),

            Container(
              color: const Color(0xFFF8FAFC), // Very light grey/white
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Why DocStep?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  const SizedBox(height: 20),
                  _buildFeatureRow(context, Icons.lock_clock_outlined, 'Flexible Shifts', 'Balance family commitments.'),
                  _buildFeatureRow(context, Icons.verified_user_outlined, 'PMDC Verification', 'Verified profiles for trust.'),
                  _buildFeatureRow(context, Icons.school_outlined, 'Academy & Courses', 'Free clinical training.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String count, String label) {
    return Column(
      children: [
        Text(count, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 4),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A))),
      ],
    );
  }

  Widget _buildDivider() => Container(height: 40, width: 1, color: const Color(0xFFCBD5E1));

  Widget _buildPortalCTA(BuildContext context, {required String title, required String description, required String buttonText, required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: AppTheme.cardDecoration().copyWith(color: Colors.white),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: AppTheme.primary, size: 28), const SizedBox(width: 12), Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))]),
          const SizedBox(height: 12),
          Text(description, style: const TextStyle(color: Color(0xFF475569))),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: onPressed, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary), child: Text(buttonText)),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(BuildContext context, IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFE0E7FF), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: AppTheme.primary)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))), Text(description, style: const TextStyle(color: Color(0xFF475569)))])),
        ],
      ),
    );
  }
}