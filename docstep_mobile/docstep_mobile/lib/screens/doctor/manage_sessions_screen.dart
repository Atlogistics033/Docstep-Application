import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../providers/data_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/models.dart';

class ManageSessionsScreen extends StatefulWidget {
  const ManageSessionsScreen({super.key});

  @override
  State<ManageSessionsScreen> createState() => _ManageSessionsScreenState();
}

class _ManageSessionsScreenState extends State<ManageSessionsScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  // Tab 1: Book New Session controllers & variables
  final _searchDocController = TextEditingController();
  final _patientNameController = TextEditingController();
  User? _selectedDoctor;
  DateTime? _selectedDate;
  String? _selectedSlot;
  List<String> _availableSlots = [];
  bool _loadingSlots = false;
  String _doctorSpecialty = '';
  String _doctorAvailability = '';

  // Tab 2: Reschedule controllers & variables
  final _reschedPatientController = TextEditingController();
  List<Appointment> _reschedAppointments = [];
  bool _searchingResched = false;
  bool _hasSearchedResched = false;
  Appointment? _rescheduleSelectedAppointment;
  User? _reschedSelectedDoctor;
  DateTime? _reschedSelectedDate;
  String? _reschedSelectedSlot;
  List<String> _reschedAvailableSlots = [];
  bool _reschedLoadingSlots = false;
  String _reschedDoctorSpecialty = '';
  String _reschedDoctorAvailability = '';
  final _reschedSearchDocController = TextEditingController();
  final _reschedPatientNameController = TextEditingController();

  // Tab 3: Cancel controllers & variables
  final _cancelPatientController = TextEditingController();
  List<Appointment> _cancelAppointments = [];
  bool _searchingCancel = false;
  bool _hasSearchedCancel = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load doctors & set default patient name
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      dataProvider.searchCandidates(q: ''); // Load all doctor profiles

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final profileName =
          authProvider.user?.fullName ??
          dataProvider.doctorProfile?['full_name'] ??
          'Dr. Sara';
      _patientNameController.text = profileName;
      _reschedPatientController.text = profileName;
      _cancelPatientController.text = profileName;
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _searchDocController.dispose();
    _patientNameController.dispose();
    _reschedPatientController.dispose();
    _cancelPatientController.dispose();
    _reschedSearchDocController.dispose();
    _reschedPatientNameController.dispose();
    super.dispose();
  }

  void _onDoctorSelected(User doctor) async {
    setState(() {
      _selectedDoctor = doctor;
      _searchDocController.text = doctor.fullName;
      _doctorSpecialty = 'Loading...';
      _doctorAvailability = 'Loading...';
      _selectedSlot = null;
      _availableSlots = [];
    });

    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final res = await dataProvider.fetchDoctorAvailability(doctor.id, null);
    if (res != null && mounted) {
      setState(() {
        _doctorSpecialty = res['specialty'] ?? 'General Practice';
        _doctorAvailability = res['availability'] ?? 'Flexible';
      });
    }

    if (_selectedDate != null) {
      _loadAvailableSlots();
    }
  }

  void _onRescheduleSelected(Appointment app) async {
    setState(() {
      _rescheduleSelectedAppointment = app;
      _reschedSelectedDate = null;
      _reschedSelectedSlot = null;
      _reschedAvailableSlots = [];
      _reschedDoctorSpecialty = app.specialty;
      _reschedDoctorAvailability = 'Loading...';
      _reschedPatientNameController.text = app.patientName;
    });

    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    await dataProvider.searchCandidates(q: '');
    final docs = dataProvider.candidates;
    final doctor = docs.firstWhere(
      (d) => d.id == app.doctorId,
      orElse: () => User(
        userId: app.doctorId,
        email: '',
        role: 'doctor',
        fullName: app.doctorName,
      ),
    );

    setState(() {
      _reschedSelectedDoctor = doctor;
      _reschedSearchDocController.text = doctor.fullName;
    });

    final res = await dataProvider.fetchDoctorAvailability(doctor.id, null);
    if (res != null && mounted) {
      setState(() {
        _reschedDoctorSpecialty = res['specialty'] ?? app.specialty;
        _reschedDoctorAvailability = res['availability'] ?? 'Flexible';
      });
    }
  }

  void _reschedLoadAvailableSlots() async {
    if (_reschedSelectedDoctor == null || _reschedSelectedDate == null) return;

    setState(() {
      _reschedLoadingSlots = true;
      _reschedSelectedSlot = null;
      _reschedAvailableSlots = [];
    });

    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final dateStr = DateFormat('yyyy-MM-dd').format(_reschedSelectedDate!);
    final res = await dataProvider.fetchDoctorAvailability(
      _reschedSelectedDoctor!.id,
      dateStr,
    );

    if (mounted) {
      setState(() {
        _reschedLoadingSlots = false;
        if (res != null) {
          _reschedDoctorSpecialty = res['specialty'] ?? 'General Practice';
          _reschedDoctorAvailability = res['availability'] ?? 'Flexible';
          if (res['availableSlots'] != null) {
            _reschedAvailableSlots = List<String>.from(res['availableSlots']);
          }
        }
      });
    }
  }

  void _showReschedDoctorSearchSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final dataProvider = Provider.of<DataProvider>(context);
            final docsList = dataProvider.candidates;

            return Container(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
              height: (MediaQuery.of(context).size.height - MediaQuery.of(context).viewInsets.bottom) * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Text(
                        'Select Doctor',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.secondary,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const Divider(color: AppTheme.borderLight),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search doctor by name or specialty...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (val) {
                      setModalState(() {
                        dataProvider.searchCandidates(q: val);
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: dataProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : docsList.isEmpty
                        ? const Center(
                            child: Text(
                              'No doctors found.',
                              style: TextStyle(color: AppTheme.textMedium),
                            ),
                          )
                        : ListView.builder(
                            itemCount: docsList.length,
                            itemBuilder: (context, index) {
                              final doc = docsList[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppTheme.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: AppTheme.primary,
                                  ),
                                ),
                                title: Text(
                                  doc.fullName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  doc.phone ?? 'Verified Consultant',
                                ),
                                onTap: () {
                                  setState(() {
                                    _reschedSelectedDoctor = doc;
                                    _reschedSearchDocController.text =
                                        doc.fullName;
                                    _reschedDoctorSpecialty = 'Loading...';
                                    _reschedDoctorAvailability = 'Loading...';
                                    _reschedSelectedSlot = null;
                                    _reschedAvailableSlots = [];
                                  });
                                  dataProvider
                                      .fetchDoctorAvailability(doc.id, null)
                                      .then((res) {
                                        if (res != null && mounted) {
                                          setState(() {
                                            _reschedDoctorSpecialty =
                                                res['specialty'] ??
                                                'General Practice';
                                            _reschedDoctorAvailability =
                                                res['availability'] ??
                                                'Flexible';
                                          });
                                        }
                                        if (_reschedSelectedDate != null) {
                                          _reschedLoadAvailableSlots();
                                        }
                                      });
                                  Navigator.of(context).pop();
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Helper: Fetch Available Slots for selected doctor and date
  void _loadAvailableSlots() async {
    if (_selectedDoctor == null || _selectedDate == null) return;

    setState(() {
      _loadingSlots = true;
      _selectedSlot = null;
      _availableSlots = [];
    });

    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    final res = await dataProvider.fetchDoctorAvailability(
      _selectedDoctor!.id,
      dateStr,
    );

    if (mounted) {
      setState(() {
        _loadingSlots = false;
        if (res != null) {
          _doctorSpecialty = res['specialty'] ?? 'General Practice';
          _doctorAvailability = res['availability'] ?? 'Flexible';
          if (res['availableSlots'] != null) {
            _availableSlots = List<String>.from(res['availableSlots']);
          }
        }
      });
    }
  }

  // Tab 2: Search bookings to reschedule
  bool _isActiveAppointment(Appointment appointment) {
    final status = appointment.status.trim().toLowerCase();
    return status != 'cancelled' && status != 'canceled';
  }

  void _searchAppointmentsForReschedule() async {
    final name = _reschedPatientController.text.trim();
    if (name.isEmpty) return;

    setState(() {
      _searchingResched = true;
      _hasSearchedResched = true;
    });

    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final list = await dataProvider.searchAppointments(name);

    if (mounted) {
      setState(() {
        // Only show pending or scheduled (active) appointments for rescheduling
        _reschedAppointments = list.where(_isActiveAppointment).toList();
        _searchingResched = false;
      });
    }
  }

  // Tab 3: Search bookings to cancel
  void _searchAppointmentsForCancel() async {
    final name = _cancelPatientController.text.trim();
    if (name.isEmpty) return;

    setState(() {
      _searchingCancel = true;
      _hasSearchedCancel = true;
    });

    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final list = await dataProvider.searchAppointments(name);

    if (mounted) {
      setState(() {
        // Only show non-cancelled appointments for cancellation
        _cancelAppointments = list.where(_isActiveAppointment).toList();
        _searchingCancel = false;
      });
    }
  }

  // Open modal bottom sheet to search and select a doctor
  void _showDoctorSearchSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final dataProvider = Provider.of<DataProvider>(context);
            final docsList = dataProvider.candidates;

            return Container(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
              height: (MediaQuery.of(context).size.height - MediaQuery.of(context).viewInsets.bottom) * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Text(
                        'Select Doctor',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.secondary,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const Divider(color: AppTheme.borderLight),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search doctor by name or specialty...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (val) {
                      setModalState(() {
                        dataProvider.searchCandidates(q: val);
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: dataProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : docsList.isEmpty
                        ? const Center(
                            child: Text(
                              'No doctors found.',
                              style: TextStyle(color: AppTheme.textMedium),
                            ),
                          )
                        : ListView.builder(
                            itemCount: docsList.length,
                            itemBuilder: (context, index) {
                              final doc = docsList[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppTheme.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: AppTheme.primary,
                                  ),
                                ),
                                title: Text(
                                  doc.fullName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  doc.phone ?? 'Verified Consultant',
                                ),
                                onTap: () {
                                  _onDoctorSelected(doc);
                                  Navigator.of(context).pop();
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _getDayName(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        final y = int.parse(parts[0]);
        final m = int.parse(parts[1]);
        final d = int.parse(parts[2]);
        return DateFormat('EEEE').format(DateTime(y, m, d));
      } else {
        final slashParts = dateStr.split('/');
        if (slashParts.length == 3) {
          final m = int.parse(slashParts[0]);
          final d = int.parse(slashParts[1]);
          final y = int.parse(slashParts[2]);
          return DateFormat('EEEE').format(DateTime(y, m, d));
        }
      }
      return DateFormat('EEEE').format(DateTime.parse(dateStr));
    } catch (_) {
      return 'Day';
    }
  }

  String _formatDoctorName(String name) {
    var cleanName = name.trim();
    while (cleanName.toLowerCase().startsWith('dr.') ||
        cleanName.toLowerCase().startsWith('dr ')) {
      if (cleanName.toLowerCase().startsWith('dr.')) {
        cleanName = cleanName.substring(3).trim();
      } else if (cleanName.toLowerCase().startsWith('dr ')) {
        cleanName = cleanName.substring(3).trim();
      }
    }
    return 'Dr. $cleanName';
  }

  void _showCancelConfirmationDialog(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) {
        final dayName = _getDayName(appointment.slotDate);
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEF2F2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Cancel Appointment?',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure you want to cancel this appointment with ${_formatDoctorName(appointment.doctorName)} on ${appointment.slotDate} ($dayName) at ${appointment.slotTime}? This action cannot be undone.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.textMedium,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final dataProvider = Provider.of<DataProvider>(
                            context,
                            listen: false,
                          );
                          final success = await dataProvider.cancelAppointment(
                            appointment.id,
                          );
                          if (success && context.mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Appointment cancelled successfully.',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                            _searchAppointmentsForCancel();
                            _searchAppointmentsForReschedule();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Yes, Cancel',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textDark,
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          backgroundColor: const Color(0xFFF8FAFC),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'No, Keep It',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Consultations'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textMedium,
          tabs: const [
            Tab(text: 'Book New Session'),
            Tab(text: 'Reschedule Appointment'),
            Tab(text: 'Cancel Appointment'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ================= TAB 1: BOOK NEW SESSION =================
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              decoration: AppTheme.cardDecoration(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Session Details',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(color: AppTheme.borderLight, height: 24),

                  // Search/Select Doctor
                  const Text(
                    'Search/Select Doctor',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _searchDocController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      hintText: 'Search doctor by name...',
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: Icon(Icons.arrow_drop_down),
                    ),
                    onTap: _showDoctorSearchSelector,
                  ),
                  const SizedBox(height: 16),

                  // Row for Doctor Name and Primary Specialty
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Doctor Name',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.borderLight),
                              ),
                              child: Text(
                                _selectedDoctor != null
                                    ? _formatDoctorName(
                                        _selectedDoctor!.fullName,
                                      )
                                    : '',
                                style: const TextStyle(
                                  color: AppTheme.textDark,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Primary Specialty',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.borderLight),
                              ),
                              child: Text(
                                _selectedDoctor != null ? _doctorSpecialty : '',
                                style: const TextStyle(
                                  color: AppTheme.textDark,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // DOCTOR AVAILABILITY BOX
                  if (_selectedDoctor != null &&
                      _doctorAvailability.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF), // light blue
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: AppTheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'DOCTOR AVAILABILITY',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    color: AppTheme.secondary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _doctorAvailability,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textDark,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Patient Name
                  const Text(
                    'Patient Name (User booking appointment)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _patientNameController,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Enter patient name...',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Select Date & Day Name Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Select Date',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      _selectedDate ??
                                      DateTime.now().add(
                                        const Duration(days: 1),
                                      ),
                                  firstDate: DateTime.now().add(
                                    const Duration(days: 1),
                                  ),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 30),
                                  ),
                                );
                                if (picked != null) {
                                  setState(() {
                                    _selectedDate = picked;
                                  });
                                  _loadAvailableSlots();
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.borderLight,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _selectedDate != null
                                            ? DateFormat(
                                                'MM/dd/yyyy',
                                              ).format(_selectedDate!)
                                            : 'mm/dd/yyyy',
                                        style: TextStyle(
                                          color: _selectedDate != null
                                              ? AppTheme.textDark
                                              : AppTheme.textLight,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.calendar_today_outlined,
                                      size: 18,
                                      color: AppTheme.textMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Day Name',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.borderLight),
                              ),
                              child: Text(
                                _selectedDate != null
                                    ? DateFormat('EEEE').format(_selectedDate!)
                                    : 'Day Name',
                                style: TextStyle(
                                  color: _selectedDate != null
                                      ? AppTheme.textDark
                                      : AppTheme.textLight,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Select Time Slot Dropdown
                  const Text(
                    'Choose slot...',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _loadingSlots
                      ? const Center(child: LinearProgressIndicator())
                      : _selectedDoctor == null || _selectedDate == null
                      ? DropdownButtonFormField<String>(
                          initialValue: null,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          hint: const Text(
                            'Select doctor and date first',
                            style: TextStyle(fontSize: 14),
                          ),
                          items: const [],
                          onChanged: null,
                        )
                      : DropdownButtonFormField<String>(
                          key: ValueKey(
                            '${_selectedDoctor?.id}_${_selectedDate?.toIso8601String()}_${_availableSlots.join(',')}',
                          ),
                          initialValue: _selectedSlot,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          hint: Text(
                            _availableSlots.isEmpty
                                ? 'No slots available'
                                : 'Choose slot...',
                            style: const TextStyle(fontSize: 14),
                          ),
                          items: _availableSlots.map((slot) {
                            return DropdownMenuItem<String>(
                              value: slot,
                              child: Text(
                                slot,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: _availableSlots.isEmpty
                              ? null
                              : (val) {
                                  setState(() {
                                    _selectedSlot = val;
                                  });
                                },
                        ),
                  const SizedBox(height: 28),

                  // Action Buttons
                  ElevatedButton(
                    onPressed:
                        _selectedDoctor == null ||
                            _selectedDate == null ||
                            _selectedSlot == null ||
                            _patientNameController.text.trim().isEmpty
                        ? null
                        : () async {
                            final dateStr = DateFormat(
                              'yyyy-MM-dd',
                            ).format(_selectedDate!);
                            final success = await dataProvider.bookAppointment(
                              doctorId: _selectedDoctor!.id,
                              patientName: _patientNameController.text.trim(),
                              date: dateStr,
                              timeSlot: _selectedSlot!,
                            );

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success
                                        ? 'Appointment booked successfully!'
                                        : 'Failed to book appointment.',
                                  ),
                                  backgroundColor: success
                                      ? AppTheme.primary
                                      : Colors.redAccent,
                                ),
                              );
                              if (success) {
                                setState(() {
                                  _selectedDoctor = null;
                                  _selectedDate = null;
                                  _selectedSlot = null;
                                  _availableSlots = [];
                                  _searchDocController.clear();
                                  _doctorSpecialty = '';
                                  _doctorAvailability = '';
                                });
                              }
                            }
                          },
                    child: const Text('Booking'),
                  ),
                ],
              ),
            ),
          ),

          // ================= TAB 2: RESCHEDULE =================
          Padding(
            padding: const EdgeInsets.all(20),
            child: _rescheduleSelectedAppointment == null
                ? Column(
                    children: [
                      Container(
                        decoration: AppTheme.cardDecoration(),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Rescheduling Session Details',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: AppTheme.secondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const Divider(
                              color: AppTheme.borderLight,
                              height: 24,
                            ),
                            const Text(
                              'Find Appointment by Patient Name',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _reschedPatientController,
                                    decoration: const InputDecoration(
                                      hintText: 'Enter patient name...',
                                      prefixIcon: Icon(
                                        Icons.person_search_outlined,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: _searchAppointmentsForReschedule,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primary,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                  ),
                                  child: const Text('Search'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: _searchingResched
                            ? const Center(child: CircularProgressIndicator())
                            : !_hasSearchedResched
                            ? const SizedBox.shrink()
                            : _reschedAppointments.isEmpty
                            ? const Center(
                                child: Text(
                                  'No active bookings found for reschedule.',
                                  style: TextStyle(color: AppTheme.textMedium),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _reschedAppointments.length,
                                itemBuilder: (context, index) {
                                  final app = _reschedAppointments[index];
                                  String dayName = _getDayName(app.slotDate);

                                  return Container(
                                    decoration: AppTheme.cardDecoration(),
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _formatDoctorName(
                                                  app.doctorName,
                                                ),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                  color: AppTheme.secondary,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                app.specialty,
                                                style: const TextStyle(
                                                  color: AppTheme.textMedium,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.access_time_outlined,
                                                    size: 14,
                                                    color: AppTheme.primary,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      '${app.slotDate} ($dayName) • ${app.slotTime}',
                                                      style: const TextStyle(
                                                        color:
                                                            AppTheme.textDark,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                'Patient: ${app.patientName}',
                                                style: TextStyle(
                                                  color: Colors.grey.shade500,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        OutlinedButton(
                                          onPressed: () =>
                                              _onRescheduleSelected(app),
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(
                                              color: Color(0xFF2DD4BF),
                                              width: 1.5,
                                            ),
                                            backgroundColor: const Color(
                                              0xFFF0FDFA,
                                            ),
                                            foregroundColor: const Color(
                                              0xFF0F766E,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Text(
                                            'Reschedule',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  )
                : SingleChildScrollView(
                    child: Container(
                      decoration: AppTheme.cardDecoration(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Rescheduling Session Details',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppTheme.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const Divider(
                            color: AppTheme.borderLight,
                            height: 24,
                          ),

                          // SELECTED APPOINTMENT INFO CARD
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4), // light green
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFBBF7D0),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'SELECTED APPOINTMENT',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                          color: Color(0xFF16A34A),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${_rescheduleSelectedAppointment!.doctorName} • ${_rescheduleSelectedAppointment!.specialty}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: AppTheme.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Current Time: ${_rescheduleSelectedAppointment!.slotDate} (${_getDayName(_rescheduleSelectedAppointment!.slotDate)}) at ${_rescheduleSelectedAppointment!.slotTime}',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _rescheduleSelectedAppointment = null;
                                    });
                                  },
                                  child: const Text(
                                    'Change Selection',
                                    style: TextStyle(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Search/Select Doctor
                          const Text(
                            'Search/Select Doctor',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _reschedSearchDocController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              hintText: 'Search doctor by name...',
                              prefixIcon: Icon(Icons.search),
                              suffixIcon: Icon(Icons.arrow_drop_down),
                            ),
                            onTap: _showReschedDoctorSearchSelector,
                          ),
                          const SizedBox(height: 16),

                          // Row for Doctor Name and Primary Specialty
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Doctor Name',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppTheme.borderLight,
                                        ),
                                      ),
                                      child: Text(
                                        _reschedSelectedDoctor != null
                                            ? _formatDoctorName(
                                                _reschedSelectedDoctor!
                                                    .fullName,
                                              )
                                            : '',
                                        style: const TextStyle(
                                          color: AppTheme.textDark,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Primary Specialty',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppTheme.borderLight,
                                        ),
                                      ),
                                      child: Text(
                                        _reschedSelectedDoctor != null
                                            ? _reschedDoctorSpecialty
                                            : '',
                                        style: const TextStyle(
                                          color: AppTheme.textDark,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // DOCTOR AVAILABILITY BOX
                          if (_reschedSelectedDoctor != null &&
                              _reschedDoctorAvailability.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF), // light blue
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFBFDBFE),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    color: AppTheme.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'DOCTOR AVAILABILITY',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                            color: AppTheme.secondary,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _reschedDoctorAvailability,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppTheme.textDark,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),

                          // Patient Name
                          const Text(
                            'Patient Name (User booking appointment)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _reschedPatientNameController,
                            readOnly:
                                true, // Patient name is from the selected appointment
                            decoration: const InputDecoration(
                              hintText: 'Enter patient name...',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Select Date & Day Name Row
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Select Date',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    InkWell(
                                      onTap: () async {
                                        final picked = await showDatePicker(
                                          context: context,
                                          initialDate:
                                              _reschedSelectedDate ??
                                              DateTime.now().add(
                                                const Duration(days: 1),
                                              ),
                                          firstDate: DateTime.now().add(
                                            const Duration(days: 1),
                                          ),
                                          lastDate: DateTime.now().add(
                                            const Duration(days: 30),
                                          ),
                                        );
                                        if (picked != null) {
                                          setState(() {
                                            _reschedSelectedDate = picked;
                                          });
                                          _reschedLoadAvailableSlots();
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 14,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: AppTheme.borderLight,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                _reschedSelectedDate != null
                                                    ? DateFormat(
                                                        'MM/dd/yyyy',
                                                      ).format(
                                                        _reschedSelectedDate!,
                                                      )
                                                    : 'mm/dd/yyyy',
                                                style: TextStyle(
                                                  color:
                                                      _reschedSelectedDate !=
                                                          null
                                                      ? AppTheme.textDark
                                                      : AppTheme.textLight,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            const Icon(
                                              Icons.calendar_today_outlined,
                                              size: 18,
                                              color: AppTheme.textMedium,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Day Name',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 14,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppTheme.borderLight,
                                        ),
                                      ),
                                      child: Text(
                                        _reschedSelectedDate != null
                                            ? DateFormat(
                                                'EEEE',
                                              ).format(_reschedSelectedDate!)
                                            : 'Auto-calculated',
                                        style: TextStyle(
                                          color: _reschedSelectedDate != null
                                              ? AppTheme.textDark
                                              : AppTheme.textLight,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Select Time Slot Dropdown
                          const Text(
                            'Time Slot',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _reschedLoadingSlots
                              ? const Center(child: LinearProgressIndicator())
                              : DropdownButtonFormField<String>(
                                  key: ValueKey(
                                    '${_reschedSelectedDoctor?.id}_${_reschedSelectedDate?.toIso8601String()}_${_reschedAvailableSlots.join(',')}',
                                  ),
                                  initialValue: _reschedSelectedSlot,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  hint: const Text(
                                    'Choose slot...',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  items: _reschedAvailableSlots.map((slot) {
                                    return DropdownMenuItem<String>(
                                      value: slot,
                                      child: Text(
                                        slot,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppTheme.textDark,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      _reschedSelectedSlot = val;
                                    });
                                  },
                                ),
                          const SizedBox(height: 28),

                          // Action Buttons
                          ElevatedButton(
                            onPressed:
                                _reschedSelectedDoctor == null ||
                                    _reschedSelectedDate == null ||
                                    _reschedSelectedSlot == null
                                ? null
                                : () async {
                                    final dataProvider =
                                        Provider.of<DataProvider>(
                                          context,
                                          listen: false,
                                        );
                                    final dateStr = DateFormat(
                                      'yyyy-MM-dd',
                                    ).format(_reschedSelectedDate!);
                                    final success = await dataProvider
                                        .rescheduleAppointment(
                                          _rescheduleSelectedAppointment!.id,
                                          dateStr,
                                          _reschedSelectedSlot!,
                                          newDoctorId:
                                              _reschedSelectedDoctor!.id,
                                          newDoctorName:
                                              _reschedSelectedDoctor!.fullName,
                                          newSpecialty: _reschedDoctorSpecialty,
                                        );

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            success
                                                ? 'Appointment rescheduled successfully!'
                                                : 'Failed to reschedule appointment.',
                                          ),
                                          backgroundColor: success
                                              ? AppTheme.primary
                                              : Colors.redAccent,
                                        ),
                                      );
                                      if (success) {
                                        setState(() {
                                          _rescheduleSelectedAppointment = null;
                                        });
                                        _searchAppointmentsForReschedule();
                                        _searchAppointmentsForCancel();
                                      }
                                    }
                                  },
                            child: const Text('Confirm Reschedule'),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _rescheduleSelectedAppointment = null;
                              });
                            },
                            child: const Text('Back'),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),

          // ================= TAB 3: CANCEL =================
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  decoration: AppTheme.cardDecoration(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Cancel Appointment',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppTheme.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Divider(color: AppTheme.borderLight, height: 24),
                      const Text(
                        'Find Appointment to Cancel by Patient Name',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _cancelPatientController,
                              decoration: const InputDecoration(
                                hintText: 'Enter patient name...',
                                prefixIcon: Icon(Icons.person_search_outlined),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _searchAppointmentsForCancel,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
                            child: const Text('Search'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _searchingCancel
                      ? const Center(child: CircularProgressIndicator())
                      : !_hasSearchedCancel
                      ? const SizedBox.shrink()
                      : _cancelAppointments.isEmpty
                      ? const Center(
                          child: Text(
                            'No active bookings found to cancel.',
                            style: TextStyle(color: AppTheme.textMedium),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _cancelAppointments.length,
                          itemBuilder: (context, index) {
                            final app = _cancelAppointments[index];
                            String dayName = _getDayName(app.slotDate);

                            return Container(
                              decoration: AppTheme.cardDecoration(),
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _formatDoctorName(app.doctorName),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: AppTheme.secondary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          app.specialty,
                                          style: const TextStyle(
                                            color: AppTheme.textMedium,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.access_time_outlined,
                                              size: 14,
                                              color: AppTheme.primary,
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                '${app.slotDate} ($dayName) • ${app.slotTime}',
                                                style: const TextStyle(
                                                  color: AppTheme.textDark,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Patient: ${app.patientName}',
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  OutlinedButton(
                                    onPressed: () =>
                                        _showCancelConfirmationDialog(app),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: Colors.redAccent,
                                        width: 1.5,
                                      ),
                                      backgroundColor: const Color(0xFFFEF2F2),
                                      foregroundColor: Colors.red.shade900,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Cancel Appointment',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
