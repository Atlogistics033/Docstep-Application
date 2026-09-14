import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import 'courses_screen.dart';
import 'stories_screen.dart';
import 'book_appointment_screen.dart';
import 'contact_screen.dart';

class MoreOptionsScreen extends StatelessWidget {
  const MoreOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // White/slate tint layout background
      appBar: AppBar(
        title: const Text(
          'Explore DocStep',
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold), // Navy
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Session Header Card
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient, // Soft Teal layout combination
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authProvider.isAuthenticated
                        ? 'Hello, ${authProvider.user!.fullName}!'
                        : 'Explore DocStep Portals',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    authProvider.isAuthenticated
                        ? 'Role: ${authProvider.user!.role.toUpperCase()}'
                        : 'Sign in to access your doctor, employer, or administrator portal.',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (authProvider.isAuthenticated) {
                        final role = authProvider.user!.role;
                        Navigator.of(context).pushNamed('/$role/dashboard');
                      } else {
                        Navigator.of(context).pushNamed('/login');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // White Button background
                      foregroundColor: AppTheme.primary, // Soft Teal text actions
                    ),
                    child: Text(
                      authProvider.isAuthenticated ? 'Go to Dashboard' : 'Login / Register',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Grid of Options
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildGridItem(
                  context,
                  title: 'Medical Courses',
                  icon: Icons.school_outlined,
                  color: const Color(0xFFEEF2FF), // Lavender Tint background
                  iconColor: AppTheme.primary,    // Soft Teal Icon
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const CoursesScreen()),
                  ),
                ),
                _buildGridItem(
                  context,
                  title: 'Success Stories',
                  icon: Icons.auto_awesome_outlined,
                  color: const Color(0xFFE0E7FF), // Darker Lavender base
                  iconColor: const Color(0xFF0F172A), // Navy Icon
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const StoriesScreen()),
                  ),
                ),
                _buildGridItem(
                  context,
                  title: 'Book Appointment',
                  icon: Icons.calendar_month_outlined,
                  color: const Color(0xFFE0E7FF), // Lavender
                  iconColor: const Color(0xFF0F172A), // Navy Accent
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const BookAppointmentScreen()),
                  ),
                ),
                _buildGridItem(
                  context,
                  title: 'Contact Support',
                  icon: Icons.support_agent_outlined,
                  color: const Color(0xFFEEF2FF), // Soft Lavender
                  iconColor: AppTheme.primary,    // Soft Teal
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const ContactScreen()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // About us snippet
            Container(
              decoration: AppTheme.cardDecoration().copyWith(
                color: Colors.white, // Pure White Card
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About DocStep',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF0F172A), // Navy layout title
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'DocStep is dedicated to bridging the career gap for female medical professionals in Pakistan. We connect qualified doctors returning from breaks with healthcare employers offering remote-friendly teleconsultation, hybrid, or flexible onsite clinical roles.',
                    style: TextStyle(height: 1.5, color: Color(0xFF475569)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: AppTheme.cardDecoration().copyWith(
        color: Colors.white, // Clear structure base card
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF0F172A), // Core Navy label
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}