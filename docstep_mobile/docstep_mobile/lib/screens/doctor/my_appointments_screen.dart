import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../providers/data_provider.dart';
import '../../providers/auth_provider.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  String _selectedFilter = 'All'; // 'All', 'Today', 'Tomorrow', 'Specific'
  DateTime? _specificDate;
  final _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAppointments();
    });
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  void _loadAppointments() {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final doctorId = authProvider.user?.userId;
    String? dateVal;
    
    if (_selectedFilter == 'Today') {
      dateVal = DateFormat('yyyy-MM-dd').format(DateTime.now());
    } else if (_selectedFilter == 'Tomorrow') {
      dateVal = DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 1)));
    } else if (_selectedFilter == 'Specific' && _specificDate != null) {
      dateVal = DateFormat('yyyy-MM-dd').format(_specificDate!);
    }

    dataProvider.fetchDoctorAppointments(dateVal: dateVal, doctorId: doctorId);
  }

  void _selectFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter != 'Specific') {
        _specificDate = null;
        _dateController.clear();
      }
    });
    _loadAppointments();
  }

  void _pickSpecificDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _specificDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _specificDate = picked;
        _dateController.text = DateFormat('MM/dd/yyyy').format(picked);
        _selectedFilter = 'Specific';
      });
      _loadAppointments();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final appointments = dataProvider.doctorAppointments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Appointments',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontSize: 26,
                        color: AppTheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Track and manage your scheduled patient consultation sessions.',
                  style: TextStyle(color: AppTheme.textMedium, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Day Filter Row
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Text(
                    'DAY FILTER: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: AppTheme.textLight,
                    ),
                  ),
                  const SizedBox(width: 6),
                  _buildFilterButton('All Appointments', 'All'),
                  const SizedBox(width: 8),
                  _buildFilterButton('Today', 'Today'),
                  const SizedBox(width: 8),
                  _buildFilterButton('Tomorrow', 'Tomorrow'),
                  const SizedBox(width: 12),
                  const Text(
                    'Specific Day: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: AppTheme.textLight,
                    ),
                  ),
                  const SizedBox(width: 6),
                  
                  // Date Field
                  InkWell(
                    onTap: _pickSpecificDate,
                    child: Container(
                      width: 130,
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _selectedFilter == 'Specific' ? AppTheme.primary : AppTheme.borderLight,
                          width: _selectedFilter == 'Specific' ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _dateController.text.isNotEmpty ? _dateController.text : 'mm/dd/yyyy',
                              style: TextStyle(
                                color: _dateController.text.isNotEmpty ? AppTheme.textDark : AppTheme.textLight,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Icon(Icons.calendar_today_outlined, size: 14, color: AppTheme.textMedium),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Appointments List Section
          Expanded(
            child: dataProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : appointments.isEmpty
                    ? Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        padding: const EdgeInsets.all(32),
                        decoration: AppTheme.cardDecoration(showBorder: true),
                        alignment: Alignment.center,
                        child: Text(
                          'No scheduled appointments found for this selection.',
                          style: TextStyle(
                            color: AppTheme.textLight.withValues(alpha: 0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          _loadAppointments();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          itemCount: appointments.length,
                          itemBuilder: (context, index) {
                            final app = appointments[index];
                            final isPending = app.status == 'pending';
                            final isCancelled = app.status == 'cancelled';
                            
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
                                          app.patientName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.secondary,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isCancelled
                                                ? Colors.red.shade50
                                                : isPending
                                                    ? AppTheme.borderLight.withValues(alpha: 0.4)
                                                    : AppTheme.primaryLight.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            app.status.toUpperCase(),
                                            style: TextStyle(
                                              color: isCancelled
                                                  ? Colors.red
                                                  : isPending
                                                      ? AppTheme.secondary
                                                      : AppTheme.primary,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_month, size: 16, color: AppTheme.textMedium),
                                        const SizedBox(width: 6),
                                        Text('Date: ${app.slotDate}', style: const TextStyle(color: AppTheme.textMedium)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time_outlined, size: 16, color: AppTheme.textMedium),
                                        const SizedBox(width: 6),
                                        Text('Time: ${app.slotTime}', style: const TextStyle(color: AppTheme.textMedium)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.assignment_ind_outlined, size: 16, color: AppTheme.textMedium),
                                        const SizedBox(width: 6),
                                        Text('Specialty: ${app.specialty}', style: const TextStyle(color: AppTheme.textMedium)),
                                      ],
                                    ),
                                    if (!isCancelled) ...[
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
                                                  TextButton(
                                                    onPressed: () => Navigator.of(context).pop(false),
                                                    child: const Text('No'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () => Navigator.of(context).pop(true),
                                                    child: const Text('Yes, Cancel', style: TextStyle(color: Colors.red)),
                                                  ),
                                                ],
                                              ),
                                            );
                                            
                                            if (confirm == true) {
                                              final success = await dataProvider.cancelAppointment(app.id);
                                              if (success) {
                                                _loadAppointments();
                                              }
                                            }
                                          },
                                          icon: const Icon(Icons.cancel_outlined, size: 16, color: Colors.red),
                                          label: const Text('Cancel Session', style: TextStyle(color: Colors.red, fontSize: 13)),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String text, String value) {
    final isSelected = _selectedFilter == value;
    return InkWell(
      onTap: () => _selectFilter(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.borderLight,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textDark,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}