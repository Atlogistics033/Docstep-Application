import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme.dart';
import '../../providers/data_provider.dart';
import '../../models/models.dart';

class CredentialsScreen extends StatefulWidget {
  const CredentialsScreen({super.key});

  @override
  State<CredentialsScreen> createState() => _CredentialsScreenState();
}

class _CredentialsScreenState extends State<CredentialsScreen> {
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCredentials();
    });
  }

  void _loadCredentials() {
    Provider.of<DataProvider>(context, listen: false).fetchDoctorCredentials();
  }

  void _showUploadDialog() {
    final titleController = TextEditingController();
    String type = 'degree';
    String? selectedFilePath;
    String? selectedFileName;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setModalState) {
            void pickFile() async {
              // Naye file_picker ke mutabiq '.platform.pickFiles' use kiya gaya hai
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
              );

              if (result != null && result.files.single.path != null) {
                setModalState(() {
                  selectedFilePath = result.files.single.path;
                  selectedFileName = result.files.single.name;
                });
              }
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text('Upload Credential Document'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Document Title',
                        hintText: 'e.g. PMDC MBBS License, FCPS Degree',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: type,
                      decoration: const InputDecoration(
                        labelText: 'Document Type',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'degree',
                          child: Text('Degree / Diploma'),
                        ),
                        DropdownMenuItem(
                          value: 'license',
                          child: Text('Medical License (PMDC)'),
                        ),
                        DropdownMenuItem(
                          value: 'other',
                          child: Text('Other Certificate'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() {
                            type = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: pickFile,
                      icon: const Icon(Icons.attach_file),
                      label: Text(selectedFileName ?? 'Attach PDF or Image'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppTheme.textMedium),
                  ),
                ),
                ElevatedButton(
                  onPressed:
                      selectedFilePath == null ||
                          titleController.text.trim().isEmpty
                      ? null
                      : () async {
                          Navigator.of(dialogContext).pop();
                          setState(() {
                            _uploading = true;
                          });

                          final dataProvider = Provider.of<DataProvider>(
                            context,
                            listen: false,
                          );
                          final success = await dataProvider.uploadCredential(
                            type,
                            titleController.text.trim(),
                            selectedFilePath!,
                          );

                          if (mounted) {
                            setState(() {
                              _uploading = false;
                            });
                            _loadCredentials();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? 'Document uploaded successfully!'
                                      : 'Failed to upload document.',
                                ),
                                backgroundColor: success
                                    ? AppTheme.primary
                                    : Colors.redAccent,
                              ),
                            );
                          }
                        },
                  child: const Text('Upload'),
                ),
              ],
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
      body: dataProvider.isLoading && dataProvider.doctorCredentials.isEmpty
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
              ),
            )
          : Column(
              children: [
                if (_uploading)
                  const LinearProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  ),

                Expanded(
                  child: dataProvider.doctorCredentials.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.workspace_premium_outlined,
                                size: 60,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No credential documents uploaded yet.',
                                style: TextStyle(color: AppTheme.textMedium),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async => _loadCredentials(),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: dataProvider.doctorCredentials.length,
                            itemBuilder: (context, index) {
                              final cred =
                                  dataProvider.doctorCredentials[index];
                              return _buildCredentialCard(context, cred);
                            },
                          ),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        onPressed: _showUploadDialog,
        icon: const Icon(Icons.upload_file, color: Colors.white),
        label: const Text(
          'Upload Document',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildCredentialCard(BuildContext context, Credential cred) {
    final isVerified = cred.verified == 1;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          isVerified ? Icons.verified : Icons.hourglass_top,
          color: isVerified ? Colors.green : Colors.orange,
          size: 28,
        ),
        title: Text(
          cred.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Type: ${cred.credType.toUpperCase()}\nStatus: ${isVerified ? 'Verified' : 'Pending Verification'}',
          style: const TextStyle(fontSize: 12),
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Delete Document'),
                content: const Text(
                  'Are you sure you want to delete this document?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              if (!context.mounted) return;
              final success = await Provider.of<DataProvider>(
                context,
                listen: false,
              ).deleteCredential(cred.id);
              if (context.mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Document deleted.'),
                    backgroundColor: Colors.teal,
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }
}
