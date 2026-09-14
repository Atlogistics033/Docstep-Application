import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../providers/data_provider.dart';
import '../../providers/auth_provider.dart';

class SuggestDoctorScreen extends StatefulWidget {
  const SuggestDoctorScreen({super.key});

  @override
  State<SuggestDoctorScreen> createState() => _SuggestDoctorScreenState();
}

class _SuggestDoctorScreenState extends State<SuggestDoctorScreen> {
  String? _selectedLocation;

  final List<String> _locations = [
    'North Nazimabad',
    'Nazimabad',
    'FB area',
    'Gulshan-e-Iqbal',
    'Gulistan-e-Johar',
    'PCHS',
    'SADDAR',
    'Shah faisal',
    'shahrah-e-faisal',
    'Malir'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DataProvider>(context, listen: false).fetchAllRegisteredDoctors();
    });
  }

  void _showBookingBottomSheet(BuildContext context, Map<String, dynamic> doctor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DoctorBookingSheet(doctor: doctor);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final doctors = dataProvider.registeredDoctors;

    // Filter doctors by selected clinic location
    final filteredDoctors = _selectedLocation == null
        ? <Map<String, dynamic>>[]
        : doctors.where((d) {
            final target = _selectedLocation!.toLowerCase().trim();
            final clinicLoc = (d['clinic_location'] ?? d['clinicLocation'] ?? '').toString().toLowerCase().trim();
            final clinicAddr = (d['clinic_address'] ?? d['clinicAddress'] ?? '').toString().toLowerCase().trim();
            
            // Precise match for selected clinic location
            if (clinicLoc.isNotEmpty) {
              return clinicLoc == target;
            }
            
            // Fallback match for clinic address, explicitly preventing conflicts
            if (clinicAddr.isEmpty) return false;
            if (target == 'nazimabad') {
              if (clinicAddr.contains('north nazimabad') && !clinicAddr.replaceFirst('north nazimabad', '').contains('nazimabad')) {
                return false;
              }
            }
            if (target == 'shah faisal') {
              if (clinicAddr.contains('shahrah-e-faisal') && !clinicAddr.replaceFirst('shahrah-e-faisal', '').contains('shah faisal')) {
                return false;
              }
            }
            return clinicAddr.contains(target);
          }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => dataProvider.fetchAllRegisteredDoctors(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Karachi Clinic Locator Badge
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: AppTheme.primary,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Karachi Clinic Locator',
                          style: TextStyle(
                            color: AppTheme.primary.withValues(alpha: 0.9),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Main Title
                Text(
                  'Suggest Best Doctor',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.secondary,
                      ),
                ),
                const SizedBox(height: 10),

                // Subtitle
                Text(
                  'Find top-rated doctors by their physical clinic/hospital address and location in Karachi.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textLight,
                        height: 1.4,
                      ),
                ),
                const SizedBox(height: 24),

                // Filter Card Box
                Container(
                  decoration: AppTheme.cardDecoration(radius: 16),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.filter_list,
                            color: AppTheme.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Filter by Clinic Location / Area',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textDark,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.borderLight),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedLocation,
                                  hint: const Text(
                                    'Select location...',
                                    style: TextStyle(
                                      color: AppTheme.textLight,
                                      fontSize: 13,
                                    ),
                                  ),
                                  isExpanded: true,
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: AppTheme.textDark,
                                  ),
                                  items: _locations.map((loc) {
                                    return DropdownMenuItem<String>(
                                      value: loc,
                                      child: Text(
                                        loc,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.textDark,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedLocation = val;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: _selectedLocation == null
                                ? null
                                : () {
                                    setState(() {
                                      _selectedLocation = null;
                                    });
                                  },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              side: BorderSide(
                                color: _selectedLocation == null
                                    ? AppTheme.borderLight
                                    : AppTheme.primary,
                              ),
                            ),
                            child: Text(
                              'Reset Filters',
                              style: TextStyle(
                                fontSize: 13,
                                color: _selectedLocation == null
                                    ? AppTheme.textLight
                                    : AppTheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Doctor Listings
                if (dataProvider.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (filteredDoctors.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                    child: Column(
                      children: [
                        Icon(
                          _selectedLocation == null
                              ? Icons.map_outlined
                              : Icons.medical_services_outlined,
                          size: 48,
                          color: AppTheme.textLight.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _selectedLocation == null
                              ? 'Select a clinic location / area from above to suggest the best doctors nearby.'
                              : 'No registered doctors found in this area.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppTheme.textMedium,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredDoctors.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final doc = filteredDoctors[index];
                      final name = doc['full_name'] ?? 'Doctor';
                      final specialty = doc['specialty'] ?? 'General Practice';
                      final qualifications = doc['qualifications'] ?? 'MBBS';
                      final experience = doc['years_of_experience'] ?? doc['yearsOfExperience'] ?? doc['experience_years'] ?? doc['experienceYears'] ?? doc['experience'] ?? 0;
                      final bio = doc['short_bio'] ?? doc['shortBio'] ?? doc['bio'] ?? '';
                      final clinicName = doc['clinic_name'] ?? doc['clinicName'] ?? '';
                      final clinicLoc = doc['clinic_location'] ?? doc['clinicLocation'] ?? '';
                      final clinicAddr = doc['clinic_hospital_address'] ?? doc['clinicHospitalAddress'] ?? doc['clinic_address'] ?? doc['clinicAddress'] ?? '';
                      final phone = doc['phone'] ?? '';
                      final hourlyRate = doc['hourly_rate'] ?? 0;
                      final availability = doc['availability'] ?? 'Flexible';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(10),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Accent bar on the left edge
                              Container(
                                width: 4,
                                color: AppTheme.primary,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // Header Row
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Color(0xFF0F172A),
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  qualifications,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: AppTheme.textLight,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE6F4EA),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              specialty,
                                              style: const TextStyle(
                                                color: Color(0xFF137333),
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),

                                      // Experience Badge
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '$experience Years Exp',
                                            style: const TextStyle(
                                              color: Color(0xFF0F172A),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      // Bio
                                      if (bio.isNotEmpty) ...[
                                        Text(
                                          bio,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Color(0xFF334155),
                                            fontSize: 12,
                                            height: 1.4,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                      ],

                                      const Divider(color: Color(0xFFE2E8F0), height: 1),
                                      const SizedBox(height: 12),

                                      // Clinic details
                                      _buildDetailRow(
                                        Icons.business_outlined,
                                        'CLINIC / HOSPITAL',
                                        clinicName.isNotEmpty ? clinicName : 'Not Specified',
                                      ),
                                      const SizedBox(height: 8),
                                      _buildDetailRow(
                                        Icons.location_on_outlined,
                                        'LOCATION / AREA',
                                        clinicLoc.isNotEmpty ? clinicLoc : 'Not Specified',
                                      ),
                                      const SizedBox(height: 8),
                                      _buildDetailRow(
                                        Icons.location_on_outlined,
                                        'CLINIC / HOSPITAL ADDRESS',
                                        clinicAddr.isNotEmpty ? clinicAddr : 'Not Specified',
                                      ),
                                      const SizedBox(height: 8),
                                      _buildDetailRow(
                                        Icons.phone_outlined,
                                        'PHONE NUMBER',
                                        phone.isNotEmpty ? phone : 'Not Specified',
                                      ),
                                      const SizedBox(height: 14),

                                      // Fees & Availability Box
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8FAFC),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'HOURLY FEES',
                                                  style: TextStyle(
                                                    color: AppTheme.textLight,
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '${hourlyRate.toInt()} PKR',
                                                  style: const TextStyle(
                                                    color: Color(0xFF0F172A),
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                const Text(
                                                  'AVAILABILITY',
                                                  style: TextStyle(
                                                    color: AppTheme.textLight,
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  availability,
                                                  style: const TextStyle(
                                                    color: Color(0xFF0F172A),
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      // Book Consultation
                                      ElevatedButton(
                                        onPressed: () => _showBookingBottomSheet(context, doc),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.primary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Book Consultation',
                                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(width: 6),
                                            Icon(Icons.arrow_forward, size: 16),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData iconData, String label, String value) {
    final isLocation = label == 'LOCATION / AREA';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(iconData, color: AppTheme.primary, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: TextStyle(
                  color: isLocation ? const Color(0xFF0D9488) : const Color(0xFF1E3A8A),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Doctor Booking Bottom Sheet Implementation
class DoctorBookingSheet extends StatefulWidget {
  final Map<String, dynamic> doctor;
  const DoctorBookingSheet({super.key, required this.doctor});

  @override
  State<DoctorBookingSheet> createState() => _DoctorBookingSheetState();
}

class _DoctorBookingSheetState extends State<DoctorBookingSheet> {
  final _patientNameController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedSlot;
  List<String> _availableSlots = [];
  bool _loadingSlots = false;
  String _doctorAvailability = '';
  bool _booking = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _patientNameController.text = authProvider.user?.fullName ?? '';
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              onSurface: AppTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedSlot = null;
        _availableSlots = [];
        _loadingSlots = true;
      });

      final docId = widget.doctor['user_id'] ?? widget.doctor['userId'] ?? widget.doctor['id'] ?? '';
      final dateStr = DateFormat('yyyy-MM-dd').format(picked);

      final res = await dataProvider.fetchDoctorAvailability(docId, dateStr);

      if (mounted) {
        setState(() {
          _loadingSlots = false;
          if (res != null && res['success'] == true) {
            _availableSlots = List<String>.from(res['availableSlots'] ?? []);
            _doctorAvailability = res['availability'] ?? '';
          }
        });
      }
    }
  }

  void _handleConfirmBooking() async {
    if (_selectedDate == null || _selectedSlot == null || _patientNameController.text.trim().isEmpty) return;

    setState(() {
      _booking = true;
    });

    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final docId = widget.doctor['user_id'] ?? widget.doctor['userId'] ?? widget.doctor['id'] ?? '';
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    final success = await dataProvider.bookAppointment(
      doctorId: docId,
      patientName: _patientNameController.text.trim(),
      date: dateStr,
      timeSlot: _selectedSlot!,
    );

    if (mounted) {
      setState(() {
        _booking = false;
      });
      Navigator.pop(context); // Dismiss bottom sheet
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Appointment booked successfully!' : 'Failed to book appointment.'),
          backgroundColor: success ? AppTheme.primary : Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.doctor['full_name'] ?? 'Doctor';
    final specialty = widget.doctor['specialty'] ?? 'General Practice';

    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Text(
              'Book Consultation',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondary,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Schedule a slot with $name ($specialty)',
              style: const TextStyle(color: AppTheme.textMedium, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Patient Name Input
            const Text(
              'Patient Name',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textMedium),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _patientNameController,
              decoration: const InputDecoration(
                hintText: 'Enter patient full name',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),

            // Date Picker Select
            const Text(
              'Select Consultation Date',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textMedium),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: _booking ? null : _selectDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined, color: AppTheme.primary, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDate == null
                          ? 'Choose a date...'
                          : DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate!),
                      style: TextStyle(
                        fontSize: 14,
                        color: _selectedDate == null ? AppTheme.textLight : AppTheme.textDark,
                        fontWeight: _selectedDate == null ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_drop_down, color: AppTheme.textLight),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Time Slots Section
            if (_selectedDate != null) ...[
              const Text(
                'Available Slots',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textMedium),
              ),
              const SizedBox(height: 8),
              if (_loadingSlots)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_availableSlots.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    _doctorAvailability.isNotEmpty
                        ? 'No slots available for this date (Availability: $_doctorAvailability).'
                        : 'No slots available for this date.',
                    style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableSlots.map((slot) {
                    final isSelected = _selectedSlot == slot;
                    return ChoiceChip(
                      label: Text(
                        slot,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.textDark,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppTheme.primary,
                      backgroundColor: const Color(0xFFF1F5F9),
                      onSelected: (selected) {
                        setState(() {
                          _selectedSlot = selected ? slot : null;
                        });
                      },
                    );
                  }).toList(),
                ),
              const SizedBox(height: 24),
            ],

            // Confirm Booking Action Button
            _booking
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _selectedDate == null || _selectedSlot == null || _patientNameController.text.trim().isEmpty
                        ? null
                        : _handleConfirmBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Confirm Booking'),
                  ),
          ],
        ),
      ),
    );
  }
}
