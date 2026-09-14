import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../models/models.dart';

// Note: Agar 'AppTheme' ka code mein koi use nahi hai, to theme.dart ka import ab remove kar diya gaya hai.

class JobsManagerScreen extends StatefulWidget {
  const JobsManagerScreen({super.key});

  @override
  State<JobsManagerScreen> createState() => _JobsManagerScreenState();
}

class _JobsManagerScreenState extends State<JobsManagerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadJobs();
    });
  }

  void _loadJobs() {
    Provider.of<DataProvider>(context, listen: false).fetchEmployerDashboard();
  }

  void _showJobFormSheet({Job? job}) {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final profile = dataProvider.employerDashboard?['profile'];
    final employerPhone =
        profile?['phone'] ??
        profile?['phoneNumber'] ??
        profile?['contact_phone'] ??
        profile?['contactPhone'] ??
        '';
    final titleController = TextEditingController(text: job?.title ?? '');
    final phoneController = TextEditingController(text: employerPhone.toString());
    final cityController = TextEditingController(text: job?.city ?? '');
    final salaryController = TextEditingController(text: job?.salaryRange ?? '');
    final descController = TextEditingController(text: job?.description ?? '');
    final reqController = TextEditingController(text: job?.requirements ?? '');
    
    String specialty = job?.specialty ?? 'General Practice';
    String jobType = job?.jobType ?? 'Part-time';
    String mode = job?.mode ?? 'Remote';
    String status = job?.status ?? 'open';

    final List<String> specialties = [
      'General Practice', 'Gynecology', 'Pediatrics', 'Psychiatry', 
      'Dermatology', 'Internal Medicine', 'Cardiology', 'Other'
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFFFFFF), // White
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20, right: 20, top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Text(
                          job == null ? 'Post a Job' : 'Edit Job Details', 
                          style: const TextStyle(
                            color: Color(0xFF1E3A8A), // Navy
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, color: Color(0xFF1E3A8A)), // Navy
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const Divider(color: Color(0xFFE0E7FF)), // Lavender
                    const SizedBox(height: 12),
                    
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Job Title', 
                        labelStyle: TextStyle(color: Color(0xFF1E3A8A)), // Navy
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF14B8A6))), // Soft Teal
                        hintText: 'e.g. Gynecology Teleconsultant',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Employer Phone',
                        labelStyle: TextStyle(color: Color(0xFF1E3A8A)),
                        prefixIcon: Icon(Icons.phone_outlined),
                        helperText: 'Fetched from the logged-in employer profile',
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: specialty,
                            decoration: const InputDecoration(
                              labelText: 'Specialty',
                              labelStyle: TextStyle(color: Color(0xFF1E3A8A)), // Navy
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF14B8A6))), // Soft Teal
                            ),
                            items: specialties.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 12, color: Color(0xFF1E3A8A))))).toList(),
                            onChanged: (val) {
                              if (val != null) setModalState(() => specialty = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: mode,
                            decoration: const InputDecoration(
                              labelText: 'Work Mode',
                              labelStyle: TextStyle(color: Color(0xFF1E3A8A)), // Navy
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF14B8A6))), // Soft Teal
                            ),
                            items: const [
                              DropdownMenuItem(value: 'Remote', child: Text('Remote', style: TextStyle(color: Color(0xFF1E3A8A)))),
                              DropdownMenuItem(value: 'Hybrid', child: Text('Hybrid', style: TextStyle(color: Color(0xFF1E3A8A)))),
                              DropdownMenuItem(value: 'Onsite', child: Text('Onsite', style: TextStyle(color: Color(0xFF1E3A8A)))),
                            ],
                            onChanged: (val) {
                              if (val != null) setModalState(() => mode = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: jobType,
                            decoration: const InputDecoration(
                              labelText: 'Job Type',
                              labelStyle: TextStyle(color: Color(0xFF1E3A8A)), // Navy
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF14B8A6))), // Soft Teal
                            ),
                            items: const [
                              DropdownMenuItem(value: 'Full-time', child: Text('Full-time', style: TextStyle(color: Color(0xFF1E3A8A)))),
                              DropdownMenuItem(value: 'Part-time', child: Text('Part-time', style: TextStyle(color: Color(0xFF1E3A8A)))),
                              DropdownMenuItem(value: 'Contract', child: Text('Contract', style: TextStyle(color: Color(0xFF1E3A8A)))),
                              DropdownMenuItem(value: 'Internship', child: Text('Internship', style: TextStyle(color: Color(0xFF1E3A8A)))),
                            ],
                            onChanged: (val) {
                              if (val != null) setModalState(() => jobType = val);
                            },
                          ),
                        ),
                        if (job != null) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: status,
                              decoration: const InputDecoration(
                                labelText: 'Status',
                                labelStyle: TextStyle(color: Color(0xFF1E3A8A)), // Navy
                                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF14B8A6))), // Soft Teal
                              ),
                              items: const [
                                DropdownMenuItem(value: 'open', child: Text('Open', style: TextStyle(color: Color(0xFF1E3A8A)))),
                                DropdownMenuItem(value: 'closed', child: Text('Closed', style: TextStyle(color: Color(0xFF1E3A8A)))),
                              ],
                              onChanged: (val) {
                                if (val != null) setModalState(() => status = val);
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: cityController,
                            decoration: const InputDecoration(
                              labelText: 'City of Posting', 
                              labelStyle: TextStyle(color: Color(0xFF1E3A8A)), // Navy
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF14B8A6))), // Soft Teal
                              hintText: 'e.g. Karachi',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: salaryController,
                            decoration: const InputDecoration(
                              labelText: 'Salary Range', 
                              labelStyle: TextStyle(color: Color(0xFF1E3A8A)), // Navy
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF14B8A6))), // Soft Teal
                              hintText: 'e.g. 80k-120k / mo',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    TextField(
                      controller: descController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Job Description', 
                        labelStyle: TextStyle(color: Color(0xFF1E3A8A)), // Navy
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF14B8A6))), // Soft Teal
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    TextField(
                      controller: reqController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Candidate Requirements', 
                        labelStyle: TextStyle(color: Color(0xFF1E3A8A)), // Navy
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF14B8A6))), // Soft Teal
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF14B8A6), // Soft Teal
                        foregroundColor: const Color(0xFFFFFFFF), // White
                        disabledBackgroundColor: const Color(0xFFE0E7FF), // Lavender (for disabled state)
                      ),
                      onPressed: titleController.text.trim().isEmpty || descController.text.trim().isEmpty
                          ? null
                          : () async {
                              Navigator.of(context).pop();
                              
                              final body = {
                                'title': titleController.text.trim(),
                                'employer_phone': phoneController.text.trim(),
                                'employerPhone': phoneController.text.trim(),
                                'specialty': specialty,
                                'job_type': jobType,
                                'mode': mode,
                                'city': cityController.text.trim().isNotEmpty ? cityController.text.trim() : 'Anywhere',
                                'salary_range': salaryController.text.trim().isNotEmpty ? salaryController.text.trim() : 'Negotiable',
                                'description': descController.text.trim(),
                                'requirements': reqController.text.trim(),
                                if (job != null) 'status': status,
                              };
                              
                              if (job == null) {
                                await dataProvider.postJob(body);
                              } else {
                                await dataProvider.editJob(job.id, body);
                              }
                              
                              _loadJobs();
                            },
                      child: Text(job == null ? 'Post Opening' : 'Save Changes'),
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
      backgroundColor: const Color(0xFFE0E7FF).withValues(alpha: 0.4), // Light Lavender Tint Screen Background
      body: dataProvider.isLoading && dataProvider.employerJobs.isEmpty
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF14B8A6)))) // Soft Teal Loader
          : dataProvider.employerJobs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.work_outline, size: 60, color: Color(0xFF1E3A8A)), // Navy Empty Icon
                      const SizedBox(height: 16),
                      const Text(
                        'You have not posted any jobs yet.', 
                        style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.w500), // Navy
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: const Color(0xFF14B8A6), // Soft Teal Refresh Loader
                  onRefresh: () async => _loadJobs(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: dataProvider.employerJobs.length,
                    itemBuilder: (context, index) {
                      final job = dataProvider.employerJobs[index];
                      return Card(
                        color: const Color(0xFFFFFFFF), // White
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(
                            job.title, 
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)), // Navy
                          ),
                          subtitle: Text(
                            'Type: ${job.jobType} | Mode: ${job.mode}\nStatus: ${job.status.toUpperCase()}',
                            style: const TextStyle(color: Color(0xFF1E3A8A)), // Navy text details
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: Color(0xFF14B8A6)), // Soft Teal Edit Button
                                onPressed: () => _showJobFormSheet(job: job),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Color(0xFF1E3A8A)), // Navy Delete Button
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: const Color(0xFFFFFFFF), // White
                                      title: const Text('Delete Job', style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold)),
                                      content: const Text('Are you sure you want to delete this job posting?', style: TextStyle(color: Color(0xFF1E3A8A))),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false), 
                                          child: const Text('No', style: TextStyle(color: Color(0xFF14B8A6))), // Soft Teal Action
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(true), 
                                          child: const Text('Delete', style: TextStyle(color: Color(0xFF1E3A8A))), // Navy Action
                                        ),
                                      ],
                                    ),
                                  );
                                  
                                  if (confirm == true) {
                                    await dataProvider.deleteJob(job.id);
                                    _loadJobs();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF14B8A6), // Soft Teal
        onPressed: () => _showJobFormSheet(),
        icon: const Icon(Icons.add, color: Color(0xFFFFFFFF)), // White
        label: const Text('Post a Job', style: TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.bold)), // White
      ),
    );
  }
}
