import 'package:flutter/material.dart';
import '../../models/models.dart';

class AllAppointmentsScreen extends StatelessWidget {
  final List<Appointment> appointments;
  const AllAppointmentsScreen({super.key, required this.appointments});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'All Appointments',
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: appointments.isEmpty
          ? const Center(
              child: Text(
                'no opointment yet',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontWeight: FontWeight.w500),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final app = appointments[index];
                final cleanDocName = app.doctorName.startsWith('Dr.') ? app.doctorName : 'Dr. ${app.doctorName}';
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              app.patientName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Consultation with $cleanDocName • ${app.specialty} • ${app.slotDate} • ${app.slotTime}',
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      (() {
                        final isCancelled = app.status.toLowerCase() == 'cancelled';
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isCancelled ? const Color(0xFFFCE8E6) : const Color(0xFFE6F4EA),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isCancelled ? 'Cancelled' : 'Scheduled',
                            style: TextStyle(
                              color: isCancelled ? const Color(0xFFC5221F) : const Color(0xFF137333),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      })(),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
