import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/data_provider.dart';

class CandidateDetailScreen extends StatefulWidget {
  final String candidateId;
  const CandidateDetailScreen({super.key, required this.candidateId});

  @override
  State<CandidateDetailScreen> createState() => _CandidateDetailScreenState();
}

class _CandidateDetailScreenState extends State<CandidateDetailScreen> {
  bool _loading = true;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  void _loadDetails() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final data = await dataProvider.getCandidateDetails(widget.candidateId);
    if (mounted) {
      setState(() {
        _data = data;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final rawCand = _data != null ? (_data!['profile'] ?? _data!['cand'] ?? {}) : {};
    final Map<String, dynamic> cand = {
      'user_id': rawCand['user_id'] ?? rawCand['userId'] ?? rawCand['id'] ?? '',
      'full_name': rawCand['name'] ?? rawCand['full_name'] ?? rawCand['fullName'] ?? 'Doctor Name',
      'email': rawCand['email'] ?? rawCand['emailAddress'] ?? 'Not provided',
      'phone': rawCand['phone'] ?? rawCand['phoneNumber'] ?? 'Not provided',
      'specialty': rawCand['specialty'] ?? rawCand['speciality'] ?? 'General Practice',
      'city': rawCand['city'] ?? 'Karachi',
      'experience_years': rawCand['years_of_experience'] ?? rawCand['yearsOfExperience'] ?? rawCand['experience_years'] ?? rawCand['experienceYears'] ?? rawCand['experience'] ?? 0,
      'pmdc_verified': rawCand['pmdc_verified'] ?? rawCand['pmdcVerified'] ?? 0,
      'availability': rawCand['availability'] ?? 'Flexible',
      'open_to_remote': rawCand['open_to_remote'] ?? rawCand['openToRemote'] ?? 0,
      'hourly_rate': rawCand['hourly_rate'] ?? rawCand['hourlyRate'] ?? 0.0,
      'bio': rawCand['short_bio'] ?? rawCand['shortBio'] ?? rawCand['bio'] ?? '',
      'qualifications': rawCand['qualifications'] ?? rawCand['qualification'] ?? 'MBBS',
      'languages': rawCand['languages'] ?? rawCand['language'] ?? 'English, Urdu',
      'clinic_name': rawCand['clinic_name'] ?? rawCand['clinicName'] ?? '',
      'clinic_location': rawCand['clinic_location'] ?? rawCand['clinicLocation'] ?? '',
      'clinic_address': rawCand['clinic_address'] ?? rawCand['clinicAddress'] ?? '',
    };
    final name = cand['full_name'];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          name,
          style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary)))
          : _data == null
              ? const Center(child: Text('Failed to load doctor profile.', style: TextStyle(color: Color(0xFF475569))))
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Doctor Header Card
                      _buildDoctorHeaderCard(cand),
                      const SizedBox(height: 20),

                      // Bio Section
                      _buildBioCard(cand),
                      const SizedBox(height: 20),

                      // Info Details Grid
                      _buildProfessionalDetailsCard(cand),
                      const SizedBox(height: 20),

                      // Clinic Details Section
                      _buildClinicDetailsCard(cand),
                      const SizedBox(height: 20),

                      // Credentials List Section
                      _buildDocumentsCard(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildDoctorHeaderCard(Map<String, dynamic> cand) {
    final name = cand['full_name'] ?? 'Doctor Name';
    final initials = name.isNotEmpty ? name[0] : 'D';
    final specialty = cand['specialty'] ?? 'General Practice';
    final city = cand['city'] ?? 'Karachi';
    final experience = cand['experience_years'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Circular Avatar with Gradient
          Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF0D9488), Color(0xFF6366F1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              initials.toUpperCase(),
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Name and Specialty
          Text(
            name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.medical_services_outlined, size: 14, color: AppTheme.primary),
              const SizedBox(width: 6),
              Text(
                specialty,
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Chips Info Row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildBadge(
                cand['pmdc_verified'] == 1 ? 'PMDC VERIFIED' : 'PENDING PMDC VERIFICATION',
                cand['pmdc_verified'] == 1 ? const Color(0xFFE6F4EA) : const Color(0xFFFFF3CD),
                cand['pmdc_verified'] == 1 ? const Color(0xFF137333) : const Color(0xFF856404),
              ),
              _buildBadge(
                cand['availability'] ?? 'Flexible',
                const Color(0xFFE0F2FE),
                const Color(0xFF0369A1),
              ),
              if (cand['open_to_remote'] == 1)
                _buildBadge(
                  'Remote OK',
                  const Color(0xFFF3E8FF),
                  const Color(0xFF7E22CE),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF1F5F9)),
          const SizedBox(height: 8),

          // Experience & Location mini stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat(Icons.work_history_outlined, '$experience Yrs', 'Experience'),
              _buildMiniStat(Icons.location_on_outlined, city, 'Location'),
              _buildMiniStat(
                Icons.payments_outlined,
                cand['hourly_rate'] != null && cand['hourly_rate'] > 0
                    ? '\$${cand['hourly_rate']}/hr'
                    : 'Not Set',
                'Hourly Rate',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF64748B), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildBioCard(Map<String, dynamic> cand) {
    final bio = cand['bio'];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Professional Biography',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF0F172A),
            ),
          ),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),
          Text(
            bio != null && bio.toString().isNotEmpty ? bio : 'No biography provided yet.',
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalDetailsCard(Map<String, dynamic> cand) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Qualifications & Contact Info',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF0F172A),
            ),
          ),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),
          _buildDetailRow(Icons.email_outlined, 'Email Address', cand['email'] ?? 'Not provided'),
          _buildDetailRow(Icons.phone_outlined, 'Phone Number', cand['phone'] ?? 'Not provided'),
          _buildDetailRow(Icons.language_outlined, 'Spoken Languages', cand['languages'] ?? 'English, Urdu'),
          _buildDetailRow(Icons.school_outlined, 'Medical Degree', cand['qualifications'] ?? 'MBBS'),
        ],
      ),
    );
  }

  Widget _buildClinicDetailsCard(Map<String, dynamic> cand) {
    final clinicName = cand['clinic_name'] ?? '';
    final clinicLoc = cand['clinic_location'] ?? '';
    final clinicAddr = cand['clinic_address'] ?? '';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Clinic / Hospital Details',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF0F172A),
            ),
          ),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),
          _buildDetailRow(
            Icons.business_outlined,
            'Clinic / Hospital Name',
            clinicName.isNotEmpty ? clinicName : 'Not Specified',
          ),
          _buildDetailRow(
            Icons.location_city_outlined,
            'Location / Area',
            clinicLoc.isNotEmpty ? clinicLoc : 'Not Specified',
          ),
          _buildDetailRow(
            Icons.location_on_outlined,
            'Clinic / Hospital Address',
            clinicAddr.isNotEmpty ? clinicAddr : 'Not Specified',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF475569), size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsCard() {
    final List creds = _data!['creds'] ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Verified Credentials & Documents',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF0F172A),
            ),
          ),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),
          if (creds.isEmpty)
            const Text(
              'No verified documents uploaded.',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: creds.length,
              itemBuilder: (context, index) {
                final cred = creds[index];
                final verified = cred['verified'] == 1;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        verified ? Icons.verified : Icons.pending_actions,
                        color: verified ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cred['title'] ?? 'Credential Document',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF334155),
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              'TYPE: ${(cred['cred_type'] ?? 'degree').toString().toUpperCase()}',
                              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}