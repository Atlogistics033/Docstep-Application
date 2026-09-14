import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/data_provider.dart';
import 'candidate_detail_screen.dart';

class CandidatesBrowseScreen extends StatefulWidget {
  const CandidatesBrowseScreen({super.key});

  @override
  State<CandidatesBrowseScreen> createState() => _CandidatesBrowseScreenState();
}

class _CandidatesBrowseScreenState extends State<CandidatesBrowseScreen> {
  final _searchController = TextEditingController();
  String? _selectedSpecialty;
  String? _selectedCity;

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _search();
    });
  }

  void _search() {
    String? spec = _selectedSpecialty == 'All Specialties' ? null : _selectedSpecialty;
    Provider.of<DataProvider>(context, listen: false).searchCandidates(
      q: _searchController.text.trim(),
      specialty: spec,
      city: _selectedCity,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // White/Slate canvas background
      body: Column(
        children: [
          // Filter card
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Color(0xFF0F172A)), // Navy text input
                  decoration: const InputDecoration(
                    hintText: 'Search candidates by name, bio...',
                    hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                    prefixIcon: Icon(Icons.search, color: AppTheme.primary), // Soft Teal icon
                  ),
                  onSubmitted: (_) => _search(),
                ),
                const SizedBox(height: 12),
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
                          child: Text(s, style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A))), // Navy option text
                        )).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedSpecialty = val;
                          });
                          _search();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedCity ?? 'All Cities',
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: ['All Cities', 'Karachi', 'Lahore', 'Islamabad', 'Rawalpindi', 'Multan'].map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c, style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A))), // Navy option text
                        )).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedCity = val == 'All Cities' ? null : val;
                          });
                          _search();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Results list
          Expanded(
            child: dataProvider.isLoading
                ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary)))
                : dataProvider.candidates.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.person_search_outlined, size: 60, color: Color(0xFF94A3B8)),
                            const SizedBox(height: 16),
                            const Text('No matching doctor CVs found.', style: TextStyle(color: Color(0xFF64748B))),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async => _search(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: dataProvider.candidates.length,
                          itemBuilder: (context, index) {
                            final candidate = dataProvider.candidates[index];
                            return _buildCandidateCard(context, candidate);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateCard(BuildContext context, final candidate) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cardDecoration().copyWith(
        color: Colors.white, // Pure White Card structural background
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE0E7FF), // Lavender Background
          child: Icon(Icons.person, color: AppTheme.primary), // Soft Teal Icon
        ),
        title: Text(
          candidate.fullName, 
          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)), // Navy Heading
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'Email: ${candidate.email}\nPhone: ${candidate.phone ?? 'Not provided'}',
            style: const TextStyle(color: Color(0xFF475569), height: 1.3, fontSize: 13), // Balanced slate-grey readability
          ),
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right, color: AppTheme.primary), // Soft Teal navigation arrow
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CandidateDetailScreen(candidateId: candidate.id),
            ),
          );
        },
      ),
    );
  }
}