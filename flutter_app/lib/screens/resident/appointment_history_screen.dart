import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/appointment_provider.dart';
import '../../constants/app_colors.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/shimmer_loading.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentProvider>().fetchAppointments();
    });
  }

  List<dynamic> _getFilteredAppointments(List<dynamic> appointments) {
    if (_filterStatus == 'All') return appointments;
    return appointments.where((a) => a.status == _filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const Text('MY APPOINTMENTS'),
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Pending', 'Approved', 'Completed', 'Cancelled', 'Rejected']
                    .map((status) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(status.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            selected: _filterStatus == status,
                            onSelected: (selected) {
                              setState(() => _filterStatus = status);
                            },
                            backgroundColor: AppColors.gray50,
                            selectedColor: AppColors.primary100,
                            checkmarkColor: AppColors.primary700,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
          
          Expanded(
            child: Consumer<AppointmentProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.appointments.isEmpty) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: 5,
                    itemBuilder: (context, index) => const ShimmerCard(),
                  );
                }

                final appointments = _getFilteredAppointments(provider.appointments);

                if (appointments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 64, color: AppColors.gray300),
                        const SizedBox(height: 16),
                        Text('No appointments found', style: TextStyle(color: AppColors.gray500, fontSize: 16)),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.fetchAppointments(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      final appointment = appointments[index];
                      return _buildAppointmentCard(context, appointment);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BookAppointmentScreen())),
        label: const Text('BOOK APPOINTMENT', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1)),
        icon: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildAppointmentCard(BuildContext context, dynamic appointment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AppointmentDetailScreen(appointment: appointment))),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatusBadge(status: appointment.status),
                  Text(
                    DateFormat('MMM dd, yyyy').format(appointment.appointmentDate),
                    style: const TextStyle(color: AppColors.primary700, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                appointment.purpose,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary900),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 14, color: AppColors.gray500),
                  const SizedBox(width: 4),
                  Text(
                    appointment.timeSlot,
                    style: const TextStyle(color: AppColors.gray600, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'View Details',
                    style: TextStyle(color: AppColors.primary600, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.primary600),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
