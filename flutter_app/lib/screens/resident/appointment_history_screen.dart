import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/appointment_provider.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state.dart';
import '../../models/appointment_model.dart';
import 'appointment_detail_screen.dart';
import 'book_appointment_screen.dart';
import 'package:intl/intl.dart';

class AppointmentHistoryScreen extends StatefulWidget {
  const AppointmentHistoryScreen({super.key});

  @override
  State<AppointmentHistoryScreen> createState() => _AppointmentHistoryScreenState();
}

class _AppointmentHistoryScreenState extends State<AppointmentHistoryScreen> {
  String _filterStatus = 'All';

  @override
  void initState() {
    super.initState();
    context.read<AppointmentProvider>().fetchAppointments();
  }

  List<Appointment> _getFiltered(List<Appointment> list) {
    if (_filterStatus == 'All') return list;
    return list.where((a) => a.status == _filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('My Appointments'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2D3748),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Pending', 'Approved', 'Completed', 'Cancelled', 'Rejected']
                    .map((status) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(status),
                            selected: _filterStatus == status,
                            onSelected: (sel) => setState(() => _filterStatus = status),
                            selectedColor: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                            checkmarkColor: const Color(0xFF8B5CF6),
                            labelStyle: TextStyle(
                              color: _filterStatus == status ? const Color(0xFF8B5CF6) : Colors.grey[600],
                              fontWeight: _filterStatus == status ? FontWeight.w600 : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
          Expanded(
            child: Consumer<AppointmentProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) return const Center(child: CircularProgressIndicator());

                final filtered = _getFiltered(provider.appointments);
                if (filtered.isEmpty) {
                  return EmptyState(
                    icon: Icons.calendar_today_rounded,
                    title: _filterStatus == 'All' ? 'No appointments yet' : 'No $_filterStatus appointments',
                    subtitle: _filterStatus == 'All' ? 'Book your first appointment to get started' : 'No appointments with this status',
                    actionLabel: _filterStatus == 'All' ? 'Book Appointment' : null,
                    onAction: _filterStatus == 'All' ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookAppointmentScreen())) : null,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.fetchAppointments(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) => _buildCard(filtered[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const BookAppointmentScreen())).then((_) {
            context.read<AppointmentProvider>().fetchAppointments();
          });
        },
        backgroundColor: const Color(0xFF8B5CF6),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Book Now'),
      ),
    );
  }

  Widget _buildCard(Appointment appt) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AppointmentDetailScreen(appointment: appt))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(child: Text(appt.purpose, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF2D3748)), maxLines: 1, overflow: TextOverflow.ellipsis)),
              StatusBadge(status: appt.status),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey[400]),
              const SizedBox(width: 6),
              Text(appt.appointmentDate, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              const SizedBox(width: 16),
              Icon(Icons.access_time_rounded, size: 14, color: Colors.grey[400]),
              const SizedBox(width: 6),
              Text(appt.timeSlot, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Text(DateFormat('MMM d, y').format(appt.createdAt), style: TextStyle(fontSize: 12, color: Colors.grey[400])),
              const Spacer(),
              Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey[400]),
            ]),
          ],
        ),
      ),
    );
  }
}
