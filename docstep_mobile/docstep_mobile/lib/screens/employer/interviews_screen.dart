import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/data_provider.dart';

class EmployerInterviewsScreen extends StatefulWidget {
  const EmployerInterviewsScreen({super.key});

  @override
  State<EmployerInterviewsScreen> createState() => _EmployerInterviewsScreenState();
}

class _EmployerInterviewsScreenState extends State<EmployerInterviewsScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _loadData() {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    dataProvider.fetchEmployerInterviews();
    dataProvider.fetchEmployerApplications();
  }

  void _showScheduleDialog(Map<String, dynamic> app) {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 2));
    TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);
    String mode = 'Remote';
    final locationController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setModalState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFFFFFFF), // White
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text(
                'Schedule Interview',
                style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold), // Navy
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Candidate: ${app['candidate_name']}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)), // Navy
                    ),
                    Text('Position: ${app['job_title']}', style: const TextStyle(color: Color(0xFF1E3A8A))), // Navy
                    const Divider(height: 20, color: Color(0xFFE0E7FF)), // Lavender
                    
                    // Date picker row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)), // Navy
                          ),
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF14B8A6)), // Soft Teal
                            foregroundColor: const Color(0xFF14B8A6), // Soft Teal
                          ),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now().add(const Duration(days: 1)),
                              lastDate: DateTime.now().add(const Duration(days: 30)),
                            );
                            if (picked != null) {
                              setModalState(() => selectedDate = picked);
                            }
                          },
                          child: const Text('Select Date', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    
                    // Time picker row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Time: ${selectedTime.format(context)}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)), // Navy
                          ),
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF14B8A6)), // Soft Teal
                            foregroundColor: const Color(0xFF14B8A6), // Soft Teal
                          ),
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                            );
                            if (picked != null) {
                              setModalState(() => selectedTime = picked);
                            }
                          },
                          child: const Text('Select Time', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    DropdownButtonFormField<String>(
                      initialValue: mode,
                      decoration: const InputDecoration(
                        labelText: 'Interview Mode',
                        labelStyle: TextStyle(color: Color(0xFF1E3A8A)), // Navy
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF14B8A6))), // Soft Teal
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Remote', child: Text('Remote Video')),
                        DropdownMenuItem(value: 'Onsite', child: Text('Onsite / In-Person')),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => mode = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    if (mode == 'Onsite') ...[
                      TextField(
                        controller: locationController,
                        decoration: const InputDecoration(
                          labelText: 'Office Address / Location',
                          hintText: 'Enter office location...',
                          labelStyle: TextStyle(color: Color(0xFF1E3A8A)), // Navy
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF14B8A6))), // Soft Teal
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes for Candidate',
                        hintText: 'e.g. Please bring your CV...',
                        labelStyle: TextStyle(color: Color(0xFF1E3A8A)), // Navy
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF14B8A6))), // Soft Teal
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF1E3A8A))), // Navy
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF14B8A6), // Soft Teal
                    foregroundColor: const Color(0xFFFFFFFF), // White
                  ),
                  onPressed: () async {
                    Navigator.of(dialogContext).pop();
                    
                    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
                    final timeStr = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
                    
                    final dataProvider = Provider.of<DataProvider>(context, listen: false);
                    final success = await dataProvider.scheduleInterview(
                      applicationId: app['id'],
                      scheduledAt: '$dateStr $timeStr',
                      mode: mode,
                      location: mode == 'Onsite' ? locationController.text.trim() : 'Telehealth Platform',
                      notes: notesController.text.trim(),
                    );
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success ? 'Interview scheduled successfully!' : 'Failed to schedule interview.'),
                          backgroundColor: success ? const Color(0xFF1E3A8A) : const Color(0xFF14B8A6), // Navy or Soft Teal fallback
                        ),
                      );
                      if (success) {
                        _loadData();
                      }
                    }
                  },
                  child: const Text('Schedule'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFE0E7FF).withValues(alpha: 0.5), // Lavender background shade
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          color: const Color(0xFFFFFFFF), // White
          child: TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFF14B8A6), // Soft Teal
            labelColor: const Color(0xFF14B8A6), // Soft Teal
            unselectedLabelColor: const Color(0xFF1E3A8A), // Navy
            tabs: const [
              Tab(text: 'Interviews'),
              Tab(text: 'Applications'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: Scheduled Interviews
          dataProvider.isLoading && dataProvider.employerInterviews.isEmpty
              ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF14B8A6))))
              : dataProvider.employerInterviews.isEmpty
                  ? _buildEmptyView('No scheduled interviews.')
                  : RefreshIndicator(
                      color: const Color(0xFF14B8A6), // Soft Teal
                      onRefresh: () async => _loadData(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: dataProvider.employerInterviews.length,
                        itemBuilder: (context, index) {
                          final interview = dataProvider.employerInterviews[index];
                          return Card(
                            color: const Color(0xFFFFFFFF), // White
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: const Icon(Icons.forum, color: Color(0xFF14B8A6)), // Soft Teal
                              title: Text(interview.candidateName, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))), // Navy
                              subtitle: Text(
                                'Job: ${interview.jobTitle}\nScheduled: ${interview.scheduledAt}\nMode: ${interview.mode}',
                                style: const TextStyle(color: Color(0xFF1E3A8A)), // Navy text details
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
                    ),
          
          // TAB 2: Applications Received
          dataProvider.isLoading && dataProvider.employerApplications.isEmpty
              ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF14B8A6))))
              : dataProvider.employerApplications.isEmpty
                  ? _buildEmptyView('No applications received yet.')
                  : RefreshIndicator(
                      color: const Color(0xFF14B8A6), // Soft Teal
                      onRefresh: () async => _loadData(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: dataProvider.employerApplications.length,
                        itemBuilder: (context, index) {
                          final app = dataProvider.employerApplications[index];
                          return _buildApplicationCard(context, app);
                        },
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _buildApplicationCard(BuildContext context, Map<String, dynamic> app) {
    final status = app['status']?.toString() ?? 'pending';
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    return Card(
      color: const Color(0xFFFFFFFF), // White
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  app['candidate_name'] ?? 'Doctor',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E3A8A)), // Navy
                ),
                const Spacer(),
                _buildStatusBadge(status),
              ],
            ),
            const SizedBox(height: 6),
            Text('Job Position: ${app['job_title']}', style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E3A8A))), // Navy
            Text('Specialty: ${app['candidate_specialty'] ?? 'General Practice'}', style: const TextStyle(color: Color(0xFF1E3A8A))), // Navy
            const SizedBox(height: 8),
            
            // Cover letter
            if (app['cover_letter'] != null && (app['cover_letter'] as String).isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E7FF).withValues(alpha: 0.3), // Soft Lavender tint
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE0E7FF)), // Lavender
                ),
                child: Text(
                  'Cover Letter: "${app['cover_letter']}"',
                  style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: Color(0xFF1E3A8A)), // Navy
                ),
              ),
              const SizedBox(height: 12),
            ],
            
            const Divider(color: Color(0xFFE0E7FF), height: 10), // Lavender
            const SizedBox(height: 6),
            
            // Application Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (status == 'pending') ...[
                  TextButton(
                    onPressed: () async {
                      await dataProvider.updateApplicationStatus(app['id'], 'rejected');
                      _loadData();
                    },
                    child: const Text('Reject', style: TextStyle(color: Color(0xFF1E3A8A))), // Kept inside palette (Navy)
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      await dataProvider.updateApplicationStatus(app['id'], 'shortlisted');
                      _loadData();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF14B8A6), // Soft Teal
                      foregroundColor: const Color(0xFFFFFFFF), // White
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Shortlist', style: TextStyle(fontSize: 13)),
                  ),
                ] else if (status == 'shortlisted') ...[
                  ElevatedButton.icon(
                    onPressed: () => _showScheduleDialog(app),
                    icon: const Icon(Icons.calendar_month, size: 14),
                    label: const Text('Schedule Interview', style: TextStyle(fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A), // Navy
                      foregroundColor: const Color(0xFFFFFFFF), // White
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ] else ...[
                  const Text(
                    'No actions required',
                    style: TextStyle(color: Color(0xFF1E3A8A), fontSize: 12, fontStyle: FontStyle.italic), // Navy
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor = const Color(0xFFE0E7FF); // Default Lavender
    Color textColor = const Color(0xFF1E3A8A); // Default Navy

    if (status == 'pending') {
      bgColor = const Color(0xFFE0E7FF); // Lavender
      textColor = const Color(0xFF1E3A8A); // Navy
    } else if (status == 'shortlisted') {
      bgColor = const Color(0xFF14B8A6).withValues(alpha: 0.2); // Soft Teal Tint
      textColor = const Color(0xFF14B8A6); // Soft Teal
    } else if (status == 'accepted') {
      bgColor = const Color(0xFF14B8A6); // Soft Teal
      textColor = const Color(0xFFFFFFFF); // White
    } else if (status == 'rejected') {
      bgColor = const Color(0xFF1E3A8A); // Navy
      textColor = const Color(0xFFFFFFFF); // White
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEmptyView(String msg) {
    return Center(
      child: Text(msg, style: const TextStyle(color: Color(0xFF1E3A8A))), // Navy
    );
  }
}