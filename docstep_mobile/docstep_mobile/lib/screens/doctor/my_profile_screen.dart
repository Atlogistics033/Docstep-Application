import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/data_provider.dart';
import '../../providers/auth_provider.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _experienceController = TextEditingController();
  final _pmdcController = TextEditingController();
  final _cityController = TextEditingController();
  final _languagesController = TextEditingController();
  final _qualificationsController = TextEditingController();
  final _bioController = TextEditingController();
  final _rateController = TextEditingController();
  final _clinicNameController = TextEditingController();
  final _clinicAddressController = TextEditingController();
  String? _selectedClinicLocation;

  final List<String> _clinicLocations = [
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

  String _selectedSpecialty = 'Dermatology';
  String _selectedAvailability = 'Mornings only';
  bool _openToRemote = true;
  bool _saving = false;

  final List<String> _specialties = [
    'General Practice',
    'Gynecology',
    'Pediatrics',
    'Psychiatry',
    'Dermatology',
    'Internal Medicine',
    'Cardiology',
    'Other'
  ];

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
    // Load cached profile data immediately if available
    _loadProfileData();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final doctorId = authProvider.user?.userId;
      await Provider.of<DataProvider>(context, listen: false)
          .fetchDoctorDashboard(doctorId: doctorId);
      if (mounted) {
        setState(_loadProfileData);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _experienceController.dispose();
    _pmdcController.dispose();
    _cityController.dispose();
    _languagesController.dispose();
    _qualificationsController.dispose();
    _bioController.dispose();
    _rateController.dispose();
    _clinicNameController.dispose();
    _clinicAddressController.dispose();
    super.dispose();
  }

  void _loadProfileData() {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final p = dataProvider.doctorProfile;
    if (p != null) {
      _nameController.text = p['full_name'] ?? p['fullName'] ?? p['name'] ?? '';
      _phoneController.text = p['phone'] ?? p['phoneNumber'] ?? '';
      _experienceController.text =
          (p['experience_years'] ?? p['experienceYears'] ?? p['years_of_experience'] ?? p['yearsOfExperience'] ?? 0).toString();
      _pmdcController.text = p['pmdc_number'] ?? p['pmdcNumber'] ?? '';
      _cityController.text = p['city'] ?? '';
      _languagesController.text = p['languages'] ?? 'Urdu, English, Punjabi';
      _qualificationsController.text = p['qualifications'] ?? 'MBBS, FCPS';
      _bioController.text = p['bio'] ?? p['short_bio'] ?? p['shortBio'] ?? '';
      _rateController.text =
          (p['hourly_rate'] ?? p['hourlyRate'] ?? 1500).toString();

      final spec = p['specialty'] ?? 'Dermatology';
      if (_specialties.contains(spec)) {
        _selectedSpecialty = spec;
      }
      
      final avail = p['availability'] ?? 'Mornings only';
      if (_availabilityOptions.contains(avail)) {
        _selectedAvailability = avail;
      }

      // 1 or true/false check
      final remoteVal = p['open_to_remote'] ?? p['openToRemote'];
      if (remoteVal is bool) {
        _openToRemote = remoteVal;
      } else if (remoteVal is num) {
        _openToRemote = remoteVal.toInt() == 1;
      }

      _clinicNameController.text = p['clinic_name'] ?? p['clinicName'] ?? '';
      _clinicAddressController.text = p['clinic_hospital_address'] ?? p['clinicHospitalAddress'] ?? p['clinic_address'] ?? p['clinicAddress'] ?? '';
      
      final loc = p['clinic_address'] ?? p['clinicAddress'] ?? p['clinic_location'] ?? p['clinicLocation'];
      if (loc != null && _clinicLocations.contains(loc)) {
        _selectedClinicLocation = loc;
      } else {
        _selectedClinicLocation = null;
      }
    }
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
    });

    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    
    final updatedProfile = {
      'full_name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'specialty': _selectedSpecialty,
      'experience_years': int.tryParse(_experienceController.text.trim()) ?? 0,
      'years_of_experience': int.tryParse(_experienceController.text.trim()) ?? 0,
      'pmdc_number': _pmdcController.text.trim(),
      'city': _cityController.text.trim(),
      'languages': _languagesController.text.trim(),
      'qualifications': _qualificationsController.text.trim(),
      'bio': _bioController.text.trim(),
      'short_bio': _bioController.text.trim(),
      'availability': _selectedAvailability,
      'hourly_rate': double.tryParse(_rateController.text.trim()) ?? 0.0,
      'open_to_remote': _openToRemote ? 1 : 0,
      'clinic_name': _clinicNameController.text.trim(),
      'clinic_address': _selectedClinicLocation,
      'clinic_location': _selectedClinicLocation,
      'clinic_hospital_address': _clinicAddressController.text.trim(),
    };

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final doctorId = authProvider.user?.userId;
    final success = await dataProvider.updateDoctorProfile(updatedProfile, doctorId: doctorId);

    if (mounted) {
      setState(() {
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Profile saved successfully!' : 'Failed to save profile.'),
          backgroundColor: success ? AppTheme.primary : Colors.redAccent,
        ),
      );
      if (success) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: dataProvider.isLoading && dataProvider.doctorProfile == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Title
                    Text(
                      'My Profile',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontSize: 26,
                            color: AppTheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Keep your profile up to date — employers see this first.',
                      style: TextStyle(color: AppTheme.textMedium, fontSize: 13),
                    ),
                    const SizedBox(height: 20),

                    // Profile Details Container
                    Container(
                      decoration: AppTheme.cardDecoration(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Full name
                          const Text('Full name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textMedium)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              hintText: 'e.g. Dr. Sara',
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                            validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),

                          // Phone
                          const Text('Phone', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textMedium)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              hintText: 'e.g. 03216805213',
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                            validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),

                          // Primary specialty
                          const Text('Primary specialty', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textMedium)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            key: ValueKey(_selectedSpecialty),
                            initialValue: _selectedSpecialty,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            items: _specialties.map((s) {
                              return DropdownMenuItem(
                                value: s,
                                child: Text(s, style: const TextStyle(fontSize: 13, color: AppTheme.textDark)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedSpecialty = val;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 16),

                          // Years of experience
                          const Text('Years of experience', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textMedium)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _experienceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'e.g. 5',
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'Required';
                              if (int.tryParse(val.trim()) == null) return 'Must be a number';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // PMDC number
                          const Text('PMDC number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textMedium)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _pmdcController,
                            decoration: const InputDecoration(
                              hintText: 'e.g. PMDC-12345',
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                            validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),

                          // City
                          const Text('City', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textMedium)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _cityController,
                            decoration: const InputDecoration(
                              hintText: 'e.g. karachi',
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                            validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),

                          // Clinic/Hospital Name
                          const Text('Clinic / Hospital Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textMedium)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _clinicNameController,
                            decoration: const InputDecoration(
                              hintText: 'e.g. Imam Clinic',
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Clinic Location / Area Dropdown
                          const Text('Clinic Location / Area', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textMedium)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            key: ValueKey(_selectedClinicLocation),
                            initialValue: _selectedClinicLocation,
                            decoration: const InputDecoration(
                              hintText: 'Select clinic location',
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            items: _clinicLocations.map((loc) {
                              return DropdownMenuItem(
                                value: loc,
                                child: Text(loc, style: const TextStyle(fontSize: 13, color: AppTheme.textDark)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedClinicLocation = val;
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          // Clinic / Hospital Address
                          const Text('Clinic / Hospital Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textMedium)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _clinicAddressController,
                            decoration: const InputDecoration(
                              hintText: 'e.g. Block B, North Nazimabad, Karachi',
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Languages
                          const Text('Languages', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textMedium)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _languagesController,
                            decoration: const InputDecoration(
                              hintText: 'Urdu, English, Punjabi',
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Qualifications
                          const Text('Qualifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textMedium)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _qualificationsController,
                            decoration: const InputDecoration(
                              hintText: 'MBBS, FCPS, MRCOG...',
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Short Bio
                          const Text('Short bio', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textMedium)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _bioController,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              hintText: 'Tell employers about your background and what you\'re looking for next.',
                              contentPadding: EdgeInsets.all(12),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Availability
                          const Text('Availability', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textMedium)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            key: ValueKey(_selectedAvailability),
                            initialValue: _selectedAvailability,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            items: _availabilityOptions.map((a) {
                              return DropdownMenuItem(
                                value: a,
                                child: Text(a, style: const TextStyle(fontSize: 13, color: AppTheme.textDark)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedAvailability = val;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 16),

                          // Hourly rate (PKR)
                          const Text('Hourly rate (PKR)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textMedium)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _rateController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'e.g. 1500',
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'Required';
                              if (double.tryParse(val.trim()) == null) return 'Must be a number';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Open to remote work checkbox
                          Row(
                            children: [
                              Checkbox(
                                value: _openToRemote,
                                activeColor: AppTheme.primary,
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _openToRemote = val;
                                    });
                                  }
                                },
                              ),
                              const Text(
                                'Open to remote work',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textDark),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Save Profile Button
                          _saving
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton.icon(
                                  onPressed: _handleSave,
                                  icon: const Icon(Icons.save_outlined, size: 20),
                                  label: const Text('Save profile'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
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
  }
}
