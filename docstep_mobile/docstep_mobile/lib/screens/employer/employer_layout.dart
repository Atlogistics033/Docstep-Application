import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import 'dashboard_screen.dart';
import 'jobs_manager_screen.dart';
import 'candidates_browse_screen.dart';

class EmployerLayout extends StatefulWidget {
  const EmployerLayout({super.key});

  @override
  State<EmployerLayout> createState() => _EmployerLayoutState();
}

class _EmployerLayoutState extends State<EmployerLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const EmployerDashboardScreen(),
    const JobsManagerScreen(),
    const CandidatesBrowseScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // White/Slate canvas background
      appBar: AppBar(
        title: Text(
          _currentIndex == 0
              ? 'Employer Portal'
              : _currentIndex == 1
                  ? 'Manage Jobs'
                  : 'Find Candidates',
          style: const TextStyle(
            color: Color(0xFF0F172A), // Navy Heading Text
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_currentIndex == 0)
            IconButton(
              icon: const Icon(Icons.logout, color: Color(0xFF0F172A)),
              onPressed: () async {
                await context.read<AuthProvider>().logout();
                if (context.mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/login', (route) => false);
                }
              },
            ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.primary, // Soft Teal Active State
        unselectedItemColor: const Color(0xFF94A3B8), // Subtle Slate grey
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold, 
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            activeIcon: Icon(Icons.work),
            label: 'My Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_search_outlined),
            activeIcon: Icon(Icons.person_search),
            label: 'Candidates',
          ),
        ],
      ),
    );
  }
}
