import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/data_provider.dart';
import 'job_detail_screen.dart';

class OpportunitiesScreen extends StatefulWidget {
  const OpportunitiesScreen({super.key});

  @override
  State<OpportunitiesScreen> createState() => _OpportunitiesScreenState();
}

class _OpportunitiesScreenState extends State<OpportunitiesScreen> {
  final _searchController = TextEditingController();
  String? _selectedSpecialty;
  String? _selectedMode;

  final List<String> _specialties = [
    'All Specialties',
    'General Practice',
    'Gynecology',
    'Pediatrics',
    'Psychiatry',
    'Dermatology',
    'Internal Medicine',
    'Cardiology',
    'Other'
  ];

  final List<String> _modes = [
    'All Modes',
    'Remote',
    'Hybrid',
    'Onsite'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchJobs();
    });
  }

  void _fetchJobs() {
    String? spec = _selectedSpecialty == 'All Specialties' ? null : _selectedSpecialty;
    String? mode = _selectedMode == 'All Modes' ? null : _selectedMode;
    Provider.of<DataProvider>(context, listen: false).fetchPublicJobs(
      specialty: spec,
      mode: mode,
      q: _searchController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Clean canvas background
      appBar: AppBar(
        title: const Text(
          'Job Opportunities',
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold), // Navy
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF0F172A)),
            onPressed: _fetchJobs,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search field
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Color(0xFF0F172A)),
                  decoration: InputDecoration(
                    hintText: 'Search jobs, hospitals...',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.search, color: AppTheme.primary), // Soft Teal
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Color(0xFF475569)),
                            onPressed: () {
                              _searchController.clear();
                              _fetchJobs();
                            },
                          )
                        : null,
                  ),
                  onSubmitted: (_) => _fetchJobs(),
                ),
                const SizedBox(height: 12),
                
                // Dropdowns for Specialty & Mode
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedSpecialty ?? 'All Specialties',
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _specialties.map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s, style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A))),
                        )).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedSpecialty = val;
                          });
                          _fetchJobs();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedMode ?? 'All Modes',
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _modes.map((m) => DropdownMenuItem(
                          value: m,
                          child: Text(m, style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A))),
                        )).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedMode = val;
                          });
                          _fetchJobs();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Job list
          Expanded(
            child: dataProvider.isLoading
                ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary)))
                : dataProvider.jobs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.work_off_outlined, size: 60, color: const Color(0xFFCBD5E1)),
                            const SizedBox(height: 16),
                            const Text('No matching job opportunities found.', style: TextStyle(color: Color(0xFF475569))),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: AppTheme.primary,
                        onRefresh: () async => _fetchJobs(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: dataProvider.jobs.length,
                          itemBuilder: (context, index) {
                            final job = dataProvider.jobs[index];
                            return _buildJobCard(context, job);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(BuildContext context, final job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppTheme.cardDecoration().copyWith(
        color: Colors.white, // White Card base
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => JobDetailScreen(jobId: job.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.primary, // Soft Teal primary link
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          job.organizationName,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF0F172A), // Navy core text
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildBadge(job.jobType, const Color(0xFFEEF2FF), AppTheme.primary), // Lavender base & Soft Teal text
                ],
              ),
              const SizedBox(height: 12),
              
              // Meta details
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text(
                    '${job.city} (${job.mode})',
                    style: const TextStyle(color: Color(0xFF475569), fontSize: 13),
                  ),
                  const Spacer(),
                  const Icon(Icons.payments_outlined, size: 16, color: Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text(
                    job.salaryRange,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A), // Navy Text
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              if (job.employerPhone != null && job.employerPhone!.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.phone_outlined, size: 16, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Text(
                      'Employer Contact: ${job.employerPhone}',
                      style: const TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: Color(0xFFE2E8F0)), // Light integrated boundary line
              ),
              
              Row(
                children: [
                  _buildBadge(job.specialty, const Color(0xFFE0E7FF), const Color(0xFF0F172A)), // Lavender & Navy structural contrast
                  const Spacer(),
                  const Text(
                    'Apply Now',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.chevron_right, size: 16, color: AppTheme.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}