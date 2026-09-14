import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';

// Colors Definition
const Color kNavy = Color(0xFF1E3A8A);
const Color kWhite = Color(0xFFFFFFFF);
const Color kLavender = Color(0xFFE0E7FF);
const Color kSoftTeal = Color(0xFF14B8A6);

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboard();
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _loadDashboard() {
    Provider.of<DataProvider>(context, listen: false).fetchAdminDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final stats = dataProvider.adminDashboard;

    return Scaffold(
      backgroundColor: kLavender.withValues(alpha: 0.5),
      appBar: AppBar(
        backgroundColor: kNavy,
        title: const Text('Admin Dashboard', style: TextStyle(color: kWhite)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: kWhite),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: kSoftTeal,
          labelColor: kSoftTeal,
          unselectedLabelColor: kWhite.withValues(alpha: 0.7),
          tabs: const [
            Tab(text: 'Doctors', icon: Icon(Icons.how_to_reg, size: 18)),
            Tab(text: 'Docs', icon: Icon(Icons.document_scanner, size: 18)),
            Tab(text: 'Support', icon: Icon(Icons.support_agent, size: 18)),
          ],
        ),
      ),
      body: dataProvider.isLoading && stats == null
          ? const Center(child: CircularProgressIndicator(color: kNavy))
          : Column(
              children: [
                if (stats != null)
                  Container(
                    color: kWhite,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatBox('Doctors', stats['doctors'].toString()),
                        _buildStatBox('Employers', stats['employers'].toString()),
                        _buildStatBox('Jobs', stats['jobs'].toString()),
                      ],
                    ),
                  ),
                const Divider(height: 1, color: kNavy),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildVerifyDoctorsTab(dataProvider),
                      _buildVerifyCredentialsTab(dataProvider),
                      _buildSupportTab(dataProvider),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatBox(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: kNavy)),
        Text(label, style: const TextStyle(fontSize: 12, color: kNavy)),
      ],
    );
  }

  Widget _buildVerifyDoctorsTab(DataProvider dataProvider) {
    if (dataProvider.adminUnverifiedDoctors.isEmpty) return _buildEmptyTab('No pending verifications.');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dataProvider.adminUnverifiedDoctors.length,
      itemBuilder: (context, index) {
        final doc = dataProvider.adminUnverifiedDoctors[index];
        return Card(
          color: kWhite,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(doc['full_name'] ?? 'Doctor', style: const TextStyle(fontWeight: FontWeight.bold, color: kNavy)),
            subtitle: Text('License: ${doc['pmdc_number'] ?? '—'}\nSpecialty: ${doc['specialty'] ?? 'General Practice'}'),
            trailing: ElevatedButton.icon(
              onPressed: () => dataProvider.verifyDoctorPmdc(doc['id']),
              icon: const Icon(Icons.check, size: 14, color: kWhite),
              label: const Text('Verify', style: TextStyle(fontSize: 12, color: kWhite)),
              style: ElevatedButton.styleFrom(backgroundColor: kSoftTeal),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVerifyCredentialsTab(DataProvider dataProvider) {
    if (dataProvider.adminUnverifiedCredentials.isEmpty) return _buildEmptyTab('No pending documents.');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dataProvider.adminUnverifiedCredentials.length,
      itemBuilder: (context, index) {
        final cred = dataProvider.adminUnverifiedCredentials[index];
        return Card(
          color: kWhite,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(cred['title'] ?? 'Document', style: const TextStyle(fontWeight: FontWeight.bold, color: kNavy)),
            subtitle: Text('Doctor: ${cred['doctor_name'] ?? '—'}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.check_circle, color: kSoftTeal), onPressed: () => dataProvider.verifyCredential(cred['id'])),
                IconButton(icon: const Icon(Icons.cancel, color: Colors.redAccent), onPressed: () => dataProvider.rejectCredential(cred['id'])),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSupportTab(DataProvider dataProvider) {
    if (dataProvider.adminContactMessages.isEmpty) return _buildEmptyTab('No support tickets.');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dataProvider.adminContactMessages.length,
      itemBuilder: (context, index) {
        final msg = dataProvider.adminContactMessages[index];
        return Card(
          color: kWhite,
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(msg['name'] ?? 'Sender', style: const TextStyle(fontWeight: FontWeight.bold, color: kNavy)),
                const Divider(),
                Text('Subject: ${msg['subject'] ?? 'Query'}', style: const TextStyle(color: kSoftTeal, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(msg['message'] ?? '', style: const TextStyle(color: kNavy)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyTab(String msg) {
    return Center(child: Text(msg, style: const TextStyle(color: kNavy)));
  }
}