import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../providers/data_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/models.dart';
import '../patient/academy_screen.dart';
import '../public/job_detail_screen.dart';
import '../public/opportunities_screen.dart';
import 'my_appointments_screen.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboard();
    });
  }

  void _loadDashboard() {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final doctorId = authProvider.user?.userId;
    dataProvider.fetchDoctorDashboard(doctorId: doctorId);
    dataProvider.fetchDoctorCredentials(doctorId: doctorId);
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final stats = dataProvider.doctorDashboard != null ? dataProvider.doctorDashboard!['stats'] : null;
    final appointments = dataProvider.doctorAppointments.where((app) => app.status.toLowerCase() != 'cancelled').toList();
    final recommendedJobs =
        (dataProvider.doctorDashboard?['recommended'] as List?) ?? [];

    return Scaffold(
      body: dataProvider.isLoading && dataProvider.doctorDashboard == null
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary)))
          : RefreshIndicator(
              onRefresh: () async => _loadDashboard(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Welcome Back Header
                    Text(
                      'Welcome back, ${(() {
                        final rawName = dataProvider.doctorProfile?['name'] ?? dataProvider.doctorProfile?['full_name'] ?? dataProvider.doctorProfile?['fullName'] ?? '';
                        if (rawName.isEmpty) return 'Doctor';
                        if (rawName.toLowerCase().startsWith('dr.')) return rawName;
                        if (rawName.toLowerCase().startsWith('dr')) return 'Dr. ${rawName.substring(2).trim()}';
                        return 'Dr. $rawName';
                      })()}!',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontSize: 26,
                            color: AppTheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Here\'s your career-restart snapshot.',
                      style: TextStyle(color: AppTheme.textMedium, fontSize: 13),
                    ),
                    const SizedBox(height: 20),

                    // Doctor PMDC Verification Banner (Robust check)
                    if (dataProvider.doctorProfile != null) ...[
                      (() {
                        final pmdcVerified = dataProvider.doctorProfile?['pmdc_verified'] ?? dataProvider.doctorProfile?['pmdcVerified'] ?? 0;
                        if (pmdcVerified == 1) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.verified, color: Colors.green.shade900),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Your PMDC License is verified! Credentials verified successfully.',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, color: Colors.amber.shade900),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Your PMDC License verification is pending. Please upload your credentials.',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      })(),
                    ],
                    
                    // Stats Grid Section
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            title: 'Appointments',
                            value: stats != null ? stats['appointments'].toString() : '0',
                            icon: Icons.calendar_month,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            title: 'Jobs',
                            value: recommendedJobs.length.toString(),
                            icon: Icons.work_outline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            title: 'Credentials',
                            value: stats != null ? stats['credentials'].toString() : '0',
                            icon: Icons.workspace_premium_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            title: 'Verified Lic.',
                            value: stats != null ? stats['verifiedCredentials'].toString() : '0',
                            icon: Icons.verified_user_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Container(
                      decoration: AppTheme.cardDecoration(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Recommended for you',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.secondary,
                                    ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const OpportunitiesScreen(),
                                    ),
                                  );
                                },
                                child: const Text('View All'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (recommendedJobs.isEmpty)
                            const Text(
                              'No employer jobs posted yet.',
                              style: TextStyle(color: AppTheme.textLight, fontSize: 13),
                            )
                          else
                            Column(
                              children: recommendedJobs.take(3).map<Widget>((rawJob) {
                                final job = rawJob as Map<String, dynamic>;
                                final title = job['title'] ?? 'Medical role';
                                final org = job['organization_name'] ?? job['organizationName'] ?? 'DocStep Partner';
                                final mode = job['mode'] ?? 'Remote';
                                final city = job['city'] ?? 'Anywhere';
                                final phone = job['employer_phone'] ?? job['employerPhone'] ?? '';
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => JobDetailScreen(jobId: job['id']?.toString() ?? ''),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.work_outline, color: AppTheme.primary, size: 20),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  title.toString(),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    color: AppTheme.textDark,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  phone.toString().isNotEmpty
                                                      ? '$org - $mode - $city\nContact: $phone'
                                                      : '$org - $mode - $city',
                                                  maxLines: 3,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: AppTheme.textMedium,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AcademyScreen(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: AppTheme.cardDecoration(),
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.school_outlined,
                                color: AppTheme.primary,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Course Recommendations',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppTheme.secondary,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Open AI-powered clinical course suggestions by specialty.',
                                    style: TextStyle(
                                      color: AppTheme.textMedium,
                                      fontSize: 12,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: AppTheme.textLight,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // CARD 2: Upcoming Appointments/Consultations
                    InkWell(
                      onTap: () {
                        if (appointments.isNotEmpty) {
                          _showAppointmentsBottomSheet(context, appointments);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No appointments booked yet.')),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: AppTheme.cardDecoration(),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Upcoming consultations',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.secondary,
                                      ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => const MyAppointmentsScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text('View All'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (appointments.isEmpty)
                              const Text(
                                'No appointments scheduled yet.',
                                style: TextStyle(color: AppTheme.textLight, fontSize: 13),
                              )
                            else
                              Column(
                                children: appointments.take(2).map((app) {
                                  String dayName = 'Day';
                                  try {
                                    dayName = DateFormat('EEEE').format(DateTime.parse(app.slotDate));
                                  } catch (_) {}

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10.0),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_month, color: AppTheme.primary, size: 20),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Patient: ${app.patientName}',
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark),
                                              ),
                                              Text(
                                                'Date: ${app.slotDate} ($dayName) | Time: ${app.slotTime}',
                                                style: const TextStyle(color: AppTheme.textMedium, fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  void _showAppointmentsBottomSheet(BuildContext context, List<Appointment> appointments) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Upcoming Consultations',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.secondary),
              ),
              const Divider(color: AppTheme.borderLight, height: 24),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final app = appointments[index];
                    String dayName = 'Day';
                    try {
                      dayName = DateFormat('EEEE').format(DateTime.parse(app.slotDate));
                    } catch (_) {}
                    final isCancelled = app.status.toLowerCase() == 'cancelled';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const Icon(Icons.calendar_month, color: AppTheme.primary),
                        title: Text('Patient: ${app.patientName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Date: ${app.slotDate} ($dayName)\nTime: ${app.slotTime}'),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isCancelled ? Colors.red.shade50 : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            app.status.toUpperCase(),
                            style: TextStyle(
                              color: isCancelled ? Colors.red.shade800 : Colors.green.shade800,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      decoration: AppTheme.cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primary, size: 24),
              const Spacer(),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textMedium,
            ),
          ),
        ],
      ),
    );
  }
}
