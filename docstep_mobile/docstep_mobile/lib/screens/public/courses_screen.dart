import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/data_provider.dart';
import '../../models/models.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  final List<String> _specialties = [
    'General Practice',
    'Gynecology',
    'Pediatrics',
    'Psychiatry',
    'Dermatology',
    'Internal Medicine',
    'Cardiology',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DataProvider>(context, listen: false).fetchCourses().then((_) {
        if (mounted) {
          setState(() {
            _tabController = TabController(length: _specialties.length, vsync: this);
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // White/Soft tint mix background
      appBar: AppBar(
        title: const Text(
          'DocStep Academy',
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold), // Navy Title
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: _tabController == null
            ? null
            : TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: const Color(0xFF0F172A), // Navy active label
                unselectedLabelColor: AppTheme.textMedium,
                indicatorColor: AppTheme.primary, // Soft teal indicator
                tabs: _specialties.map((s) => Tab(text: s)).toList(),
              ),
      ),
      body: dataProvider.isLoading
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary)))
          : _tabController == null
              ? const Center(child: Text('Initializing courses...'))
              : TabBarView(
                  controller: _tabController,
                  children: _specialties.map((spec) {
                    final specCourses = dataProvider.courses
                        .where((c) => c.specialty.toLowerCase() == spec.toLowerCase())
                        .toList();

                    if (specCourses.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.menu_book_outlined, size: 50, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              'No courses available in $spec yet.',
                              style: const TextStyle(color: AppTheme.textMedium),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: specCourses.length,
                      itemBuilder: (context, index) {
                        final course = specCourses[index];
                        return _buildCourseCard(context, course);
                      },
                    );
                  }).toList(),
                ),
    );
  }

  Widget _buildCourseCard(BuildContext context, Course course) {
    final bool isFree = course.price.toLowerCase() == 'free';

    return Card(
      color: Colors.white, // White Card Background
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    course.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF0F172A), // Navy color for Title
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isFree 
                        ? const Color(0xFFE0E7FF) // Soft Lavender for Free
                        : const Color(0xFFEEF2FF), // Alternate soft tint for Paid
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    course.price,
                    style: TextStyle(
                      color: isFree 
                          ? const Color(0xFF4338CA) // Darker Navy-Lavender text contrast
                          : AppTheme.primary, // Soft Teal text
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              course.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF475569), // Readable body text
              ),
            ),
            const SizedBox(height: 16),
            
            // Meta details (Lectures, Duration, Provider)
            Row(
              children: [
                _buildMetaItem(Icons.play_circle_outline, '${course.lecturesCount} lectures'),
                const SizedBox(width: 16),
                _buildMetaItem(Icons.schedule_outlined, course.duration),
                const SizedBox(width: 16),
                _buildMetaItem(Icons.workspace_premium_outlined, course.level),
              ],
            ),
            const Divider(height: 24, color: AppTheme.borderLight),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: AppTheme.textMedium),
                const SizedBox(width: 4),
                Text(
                  course.instructor,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A), // Navy
                  ),
                ),
                const Spacer(),
                Text(
                  course.provider,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.primary, // Soft Teal
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.textLight),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: AppTheme.textMedium)),
      ],
    );
  }
}