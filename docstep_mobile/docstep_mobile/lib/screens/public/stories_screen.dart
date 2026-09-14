import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/data_provider.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DataProvider>(context, listen: false).fetchStories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // White/Slate clean canvas background
      appBar: AppBar(
        title: const Text(
          'Success Stories',
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold), // Navy
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: dataProvider.isLoading && dataProvider.stories.isEmpty
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary)))
          : dataProvider.stories.isEmpty
              ? const Center(
                  child: Text(
                    'No success stories available yet.',
                    style: TextStyle(color: Color(0xFF475569)),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: dataProvider.stories.length,
                  itemBuilder: (context, index) {
                    final story = dataProvider.stories[index];
                    return _buildStoryCard(context, story);
                  },
                ),
    );
  }

  Widget _buildStoryCard(BuildContext context, Map<String, dynamic> story) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: AppTheme.cardDecoration().copyWith(
        color: Colors.white, // Pure White Card base
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFE0E7FF), // Lavender Background
                  child: Text(
                    story['doctor_name']?.substring(0, 2) ?? 'DR',
                    style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold), // Soft Teal
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        story['doctor_name'] ?? 'Doctor Name',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.primary, // Soft Teal for identity
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        story['title'] ?? 'Role Placement',
                        style: const TextStyle(
                          color: Color(0xFF0F172A), // Navy role title
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Quotes and experience content
            const Icon(Icons.format_quote, color: AppTheme.primary, size: 28), // Soft Teal Quotes accent
            const SizedBox(height: 4),
            Text(
              story['story_content'] ?? story['content'] ?? '',
              style: const TextStyle(
                height: 1.5,
                fontStyle: FontStyle.italic,
                color: Color(0xFF475569), // Subtle dark grey text
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFFE2E8F0)), // Light slate separator
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.handshake_outlined, size: 16, color: Color(0xFF64748B)),
                const SizedBox(width: 6),
                Text(
                  'Placed at: ${story['placement_org'] ?? 'DocStep Partner'}',
                  style: const TextStyle(
                    color: Color(0xFF0F172A), // Navy core text contrast
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Text(
                  story['date'] ?? '',
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}