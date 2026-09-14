import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/data_provider.dart';
import '../../providers/auth_provider.dart';

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rateController = TextEditingController();
  
  String _selectedAvailability = 'Flexible';
  bool _openToRemote = true;
  bool _saving = false;

  final List<String> _availabilityOptions = [
    'Flexible',
    'Weekdays 10am-2pm',
    'Evenings & Weekends',
    'Evenings',
    'Mornings only'
  ];

  @override
  void initState() {
    super.initState();
    _loadAvailabilityData();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final doctorId = authProvider.user?.userId;
      await Provider.of<DataProvider>(context, listen: false)
          .fetchDoctorDashboard(doctorId: doctorId);
      if (mounted) {
        setState(_loadAvailabilityData);
      }
    });
  }

  void _loadAvailabilityData() {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    if (dataProvider.doctorProfile != null) {
      final p = dataProvider.doctorProfile!;
      _rateController.text = p['hourly_rate']?.toString() ?? '0';
      _openToRemote = (p['open_to_remote'] as num?)?.toInt() == 1;
      
      final avail = p['availability'] ?? 'Flexible';
      if (_availabilityOptions.contains(avail)) {
        _selectedAvailability = avail;
      }
    }
  }

  @override
  void dispose() {
    _rateController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    final rate = double.tryParse(_rateController.text.trim()) ?? 0;
    
    setState(() {
      _saving = true;
    });

    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final doctorId = authProvider.user?.userId;
    final success = await dataProvider.saveAvailability(
      availability: _selectedAvailability,
      openToRemote: _openToRemote,
      hourlyRate: rate,
      doctorId: doctorId,
    );

    if (mounted) {
      setState(() {
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Availability saved successfully!' : 'Failed to save availability.'),
          backgroundColor: success ? AppTheme.primary : Colors.redAccent,
        ),
      );
      if (success) {
        dataProvider.fetchDoctorDashboard(doctorId: doctorId); // Reload profile cache
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);

    return Scaffold(
      body: dataProvider.isLoading && dataProvider.doctorProfile == null
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Manage Availability & Rates',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Configure your consultancy rates and general availability slots for appointment scheduling.',
                      style: TextStyle(color: AppTheme.textMedium),
                    ),
                    const SizedBox(height: 24),
                    
                    Container(
                      decoration: AppTheme.cardDecoration(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<String>(
                            initialValue: _selectedAvailability,
                            decoration: const InputDecoration(
                              labelText: 'Active Schedule Shift',
                              prefixIcon: Icon(Icons.timer_outlined),
                            ),
                            items: _availabilityOptions.map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s),
                            )).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedAvailability = val;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _rateController,
                            decoration: const InputDecoration(
                              labelText: 'Hourly Consultation Rate (PKR)',
                              hintText: 'e.g. 2000',
                              prefixIcon: Icon(Icons.payments_outlined),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'Consultation rate is required';
                              if (double.tryParse(val) == null) return 'Please enter a valid amount';
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          SwitchListTile(
                            title: const Text('Open to Remote Consultations', style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: const Text('Enable patients to book online video consults'),
                            value: _openToRemote,
                            activeThumbColor: AppTheme.primary,
                            onChanged: (val) {
                              setState(() {
                                _openToRemote = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _saving
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _handleSave,
                            child: const Text('Save Availability'),
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}