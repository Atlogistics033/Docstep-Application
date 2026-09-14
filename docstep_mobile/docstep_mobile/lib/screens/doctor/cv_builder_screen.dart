import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/data_provider.dart';
import '../../providers/auth_provider.dart';

class CvBuilderScreen extends StatefulWidget {
  const CvBuilderScreen({super.key});

  @override
  State<CvBuilderScreen> createState() => _CvBuilderScreenState();
}

class _CvBuilderScreenState extends State<CvBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _summaryController = TextEditingController();
  final _skillsController = TextEditingController();
  final _experienceController = TextEditingController();
  final _educationController = TextEditingController();
  final _certsController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final doctorId = authProvider.user?.userId;
      await Provider.of<DataProvider>(context, listen: false)
          .fetchDoctorDashboard(doctorId: doctorId);
      if (mounted) {
        setState(_loadCvData);
      }
    });
  }

  void _loadCvData() {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    if (dataProvider.doctorProfile != null) {
      final p = dataProvider.doctorProfile!;
      _summaryController.text = p['cv_summary'] ?? p['cvSummary'] ?? '';
      _skillsController.text = p['cv_skills'] ?? p['cvSkills'] ?? '';
      _experienceController.text =
          p['cv_experience'] ?? p['cvExperience'] ?? '';
      _educationController.text = p['cv_education'] ?? p['cvEducation'] ?? '';
      _certsController.text =
          p['cv_certifications'] ?? p['cvCertifications'] ?? '';
    }
  }

  @override
  void dispose() {
    _summaryController.dispose();
    _skillsController.dispose();
    _experienceController.dispose();
    _educationController.dispose();
    _certsController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    setState(() {
      _saving = true;
    });

    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final doctorId = authProvider.user?.userId;
    final success = await dataProvider.saveCv({
      'cv_summary': _summaryController.text.trim(),
      'cv_skills': _skillsController.text.trim(),
      'cv_experience': _experienceController.text.trim(),
      'cv_education': _educationController.text.trim(),
      'cv_certifications': _certsController.text.trim(),
    }, doctorId: doctorId);

    if (mounted) {
      setState(() {
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'CV saved successfully!' : 'Failed to save CV.'),
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
                      'Build Your Professional Resume',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This information will be displayed to medical employers when you apply for jobs.',
                      style: TextStyle(color: AppTheme.textMedium),
                    ),
                    const SizedBox(height: 20),
                    
                    TextFormField(
                      controller: _summaryController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Professional Summary',
                        hintText: 'Describe your medical background and career goals...',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _skillsController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Clinical & Technical Skills',
                        hintText: 'e.g. Telemedicine, Antenatal care, Ultrasound, Pediatrics, CBT...',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _experienceController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Work Experience',
                        hintText: 'Job Title — Hospital Name (Start Year - End Year)\ne.g. Senior Registrar — JPMC (2018-2021)',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _educationController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Education',
                        hintText: 'Degree — Institution Name (Year)\ne.g. MBBS — Dow Medical College (2015)',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _certsController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Certifications',
                        hintText: 'e.g. BLS Certified, CBT Therapist, Telemedicine Practitioner...',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _saving
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _handleSave,
                            child: const Text('Save Resume'),
                          ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }
}
