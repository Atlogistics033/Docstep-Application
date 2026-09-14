import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../providers/data_provider.dart';
import '../../models/models.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final _searchDocController = TextEditingController();
  final _searchPatientController = TextEditingController();
  
  String? _selectedSpecialty;
  String? _selectedCity;
  
  List<Appointment> _myAppointments = [];
  bool _searchingAppointments = false;

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
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchDoctors();
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _searchDocController.dispose();
    _searchPatientController.dispose();
    super.dispose();
  }

  void _searchDoctors() {
    String? spec = _selectedSpecialty == 'All Specialties' ? null : _selectedSpecialty;
    Provider.of<DataProvider>(context, listen: false).searchCandidates(
      q: _searchDocController.text.trim(),
      specialty: spec,
      city: _selectedCity,
    );
  }

  void _searchMyAppointments() async {
    final name = _searchPatientController.text.trim();
    if (name.isEmpty) return;
    
    setState(() {
      _searchingAppointments = true;
    });
    
    final list = await Provider.of<DataProvider>(context, listen: false).searchAppointments(name);
    
    if (mounted) {
      setState(() {
        _myAppointments = list;
        _searchingAppointments = false;
      });
    }
  }

  void _showDoctorBookingSheet(User doctor) {
    final patientNameController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    String? selectedSlot;
    List<String> availableSlots = [];
    bool loadingSlots = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            
            void loadSlots() async {
              setModalState(() {
                loadingSlots = true;
                selectedSlot = null;
              });
              final dataProvider = Provider.of<DataProvider>(context, listen: false);
              final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
              final res = await dataProvider.fetchDoctorAvailability(doctor.id, dateStr);
              if (mounted) {
                setModalState(() {
                  loadingSlots = false;
                  if (res != null && res['availableSlots'] != null) {
                    availableSlots = List<String>.from(res['availableSlots']);
                  } else {
                    availableSlots = [];
                  }
                });
              }
            }

            if (availableSlots.isEmpty && !loadingSlots && selectedSlot == null) {
              loadSlots();
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Text('Book Appointment', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.secondary)),
                        const Spacer(),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                      ],
                    ),
                    const Divider(color: AppTheme.borderLight),
                    const SizedBox(height: 12),
                    
                    // Doctor info
                    Text(
                      doctor.fullName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor.phone ?? 'Verified DocStep Consultant',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textMedium),
                    ),
                    const SizedBox(height: 16),
                    
                    // Patient Details
                    TextField(
                      controller: patientNameController,
                      decoration: const InputDecoration(
                        labelText: 'Patient Full Name',
                        hintText: 'Enter patient name...',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Date Selector
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Date: ${DateFormat('EEE, MMM d, yyyy').format(selectedDate)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now().add(const Duration(days: 1)),
                              lastDate: DateTime.now().add(const Duration(days: 30)),
                            );
                            if (picked != null) {
                              setModalState(() {
                                selectedDate = picked;
                              });
                              loadSlots();
                            }
                          },
                          icon: const Icon(Icons.calendar_month, size: 16),
                          label: const Text('Change'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Slot selection
                    const Text('Select Time Slot', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textMedium)),
                    const SizedBox(height: 8),
                    loadingSlots
                        ? const Center(child: CircularProgressIndicator())
                        : availableSlots.isEmpty
                            ? Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.borderLight.withValues(alpha: 0.3), // Light lavender background touch
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: const Text('No availability on this date.', style: TextStyle(color: AppTheme.textMedium)),
                              )
                            : Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: availableSlots.map((slot) {
                                  final isSelected = selectedSlot == slot;
                                  return ChoiceChip(
                                    label: Text(slot, style: TextStyle(color: isSelected ? Colors.white : AppTheme.textDark)),
                                    selected: isSelected,
                                    selectedColor: AppTheme.primary, // Soft Teal for active choice
                                    backgroundColor: Colors.white,
                                    onSelected: (val) {
                                      setModalState(() {
                                        selectedSlot = slot;
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                    const SizedBox(height: 24),
                    
                    ElevatedButton(
                      onPressed: selectedSlot == null || patientNameController.text.trim().isEmpty
                          ? null
                          : () async {
                              Navigator.of(context).pop();
                              final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
                              final dataProvider = Provider.of<DataProvider>(context, listen: false);
                              
                              final success = await dataProvider.bookAppointment(
                                doctorId: doctor.id,
                                patientName: patientNameController.text.trim(),
                                date: dateStr,
                                timeSlot: selectedSlot!,
                              );
                              
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success
                                          ? 'Appointment booked successfully!'
                                          : 'Failed to book appointment.'
                                    ),
                                    backgroundColor: success ? AppTheme.primary : Colors.redAccent,
                                  ),
                                );
                              }
                            },
                      child: const Text('Confirm Booking'),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
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
      appBar: AppBar(
        title: const Text('Consultations'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary, // Soft Teal indicator
          labelColor: AppTheme.primary,     // Soft Teal active label
          unselectedLabelColor: AppTheme.textMedium,
          tabs: const [
            Tab(text: 'Book Doctor'),
            Tab(text: 'My Bookings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: Search & Book Doctor
          Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchDocController,
                      decoration: const InputDecoration(
                        hintText: 'Search doctor by name...',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onSubmitted: (_) => _searchDoctors(),
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
                              child: Text(s, style: const TextStyle(fontSize: 13, color: AppTheme.textDark)),
                            )).toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedSpecialty = val;
                              });
                              _searchDoctors();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: dataProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : dataProvider.candidates.isEmpty
                        ? const Center(child: Text('No verified doctors found.', style: TextStyle(color: AppTheme.textMedium)))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: dataProvider.candidates.length,
                            itemBuilder: (context, index) {
                              final doctor = dataProvider.candidates[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                                    child: const Icon(Icons.person, color: AppTheme.primary),
                                  ),
                                  title: Text(doctor.fullName, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                                  subtitle: Text(doctor.email, style: const TextStyle(color: AppTheme.textMedium)),
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textLight),
                                  onTap: () => _showDoctorBookingSheet(doctor),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
          
          // TAB 2: My Bookings (Search & Manage)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchPatientController,
                        decoration: const InputDecoration(
                          labelText: 'Search by Patient Name',
                          hintText: 'Enter name used for booking...',
                          prefixIcon: Icon(Icons.person_search_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _searchMyAppointments,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      child: const Icon(Icons.search),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _searchingAppointments
                      ? const Center(child: CircularProgressIndicator())
                      : _myAppointments.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.calendar_today_outlined, size: 50, color: AppTheme.textLight.withValues(alpha: 0.5)),
                                  const SizedBox(height: 12),
                                  const Text('No bookings found. Enter patient name to search.', style: TextStyle(color: AppTheme.textLight)),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: _myAppointments.length,
                              itemBuilder: (context, index) {
                                final app = _myAppointments[index];
                                final isPending = app.status == 'pending';
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              app.doctorName,
                                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 16),
                                            ),
                                            const Spacer(),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                // Using soft Lavender accent tint for pending, and Light Soft Teal tint for active status
                                                color: isPending ? AppTheme.borderLight.withValues(alpha: 0.4) : AppTheme.primaryLight.withValues(alpha: 0.2),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                app.status.toUpperCase(),
                                                style: TextStyle(
                                                  color: isPending ? AppTheme.secondary : AppTheme.primary, // Navy blue for pending, Soft Teal for regular
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text('Patient: ${app.patientName}', style: const TextStyle(color: AppTheme.textDark)),
                                        const SizedBox(height: 4),
                                        Text('Date: ${app.slotDate}', style: const TextStyle(color: AppTheme.textMedium)),
                                        Text('Time: ${app.slotTime}', style: const TextStyle(color: AppTheme.textMedium)),
                                        const Divider(height: 20, color: AppTheme.borderLight),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton.icon(
                                            onPressed: () async {
                                              final confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text('Cancel Appointment'),
                                                  content: const Text('Are you sure you want to cancel this booking?'),
                                                  actions: [
                                                    TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('No')),
                                                    TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Yes, Cancel', style: TextStyle(color: Colors.red))),
                                                  ],
                                                ),
                                              );
                                              
                                              if (confirm == true) {
                                                final success = await dataProvider.cancelAppointment(app.id);
                                                if (success) {
                                                  _searchMyAppointments();
                                                }
                                              }
                                            },
                                            icon: const Icon(Icons.cancel_outlined, size: 16, color: Colors.red),
                                            label: const Text('Cancel Booking', style: TextStyle(color: Colors.red, fontSize: 13)),
                                          ),
                                        ),
                                      ],
                                    ),
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