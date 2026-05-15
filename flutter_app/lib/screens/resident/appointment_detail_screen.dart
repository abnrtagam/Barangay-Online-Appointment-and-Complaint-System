import 'package:flutter/material.dart';
import '../../models/appointment_model.dart';
import '../../widgets/status_badge.dart';
import 'package:intl/intl.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final Appointment appointment;

  const AppointmentDetailScreen({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Appointment Details'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2D3748),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(appointment.purpose, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF2D3748)))),
                  StatusBadge(status: appointment.status, fontSize: 13),
                ]),
                const SizedBox(height: 8),
                Text('Appointment #${appointment.id}', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
              ]),
            ),
            const SizedBox(height: 16),

            // Schedule info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [const Icon(Icons.event_rounded, size: 18, color: Color(0xFF8B5CF6)), const SizedBox(width: 8), const Text('Schedule', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF2D3748)))]),
                const SizedBox(height: 16),
                _row(Icons.calendar_today_rounded, 'Date', appointment.appointmentDate),
                _row(Icons.access_time_rounded, 'Time Slot', appointment.timeSlot),
                _row(Icons.event_note_rounded, 'Booked On', DateFormat('MMM d, y • h:mm a').format(appointment.createdAt)),
                if (appointment.isUpcoming)
                  _row(Icons.timer_outlined, 'Days Until', '${appointment.daysUntil} day${appointment.daysUntil == 1 ? "" : "s"}'),
              ]),
            ),

            // Notes
            if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [const Icon(Icons.notes_rounded, size: 18, color: Color(0xFF8B5CF6)), const SizedBox(width: 8), const Text('Your Notes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF2D3748)))]),
                  const SizedBox(height: 12),
                  Text(appointment.notes!, style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5)),
                ]),
              ),
            ],

            // Admin remarks
            if (appointment.adminRemarks != null && appointment.adminRemarks!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [const Icon(Icons.admin_panel_settings_outlined, size: 18, color: Color(0xFF8B5CF6)), const SizedBox(width: 8), const Text('Admin Remarks', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF2D3748)))]),
                  const SizedBox(height: 12),
                  Text(appointment.adminRemarks!, style: TextStyle(fontSize: 14, color: Colors.grey[700], fontStyle: FontStyle.italic)),
                ]),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Icon(icon, size: 16, color: Colors.grey[400]),
        const SizedBox(width: 10),
        SizedBox(width: 100, child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[500]))),
        Expanded(child: Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey[700]))),
      ]),
    );
  }
}
