import 'status_history_model.dart';

// Appointment model represents a booked appointment
class Appointment {
  final int id;
  final int residentId;
  final String appointmentDate;
  final String timeSlot;
  final String purpose;
  final String? notes;
  final String status; // 'Pending', 'Approved', 'Completed', 'Cancelled', 'Rejected'
  final String? adminRemarks;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<StatusHistory>? history;

  Appointment({
    required this.id,
    required this.residentId,
    required this.appointmentDate,
    required this.timeSlot,
    required this.purpose,
    this.notes,
    required this.status,
    this.adminRemarks,
    required this.createdAt,
    required this.updatedAt,
    this.history,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      residentId: json['resident_id'],
      appointmentDate: json['appointment_date'] ?? '',
      timeSlot: json['time_slot'] ?? '',
      purpose: json['purpose'] ?? '',
      notes: json['notes'],
      status: json['status'] ?? 'Pending',
      adminRemarks: json['admin_remarks'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toString()),
      history: json['history'] != null
          ? (json['history'] as List)
              .map((h) => StatusHistory.fromJson(h))
              .toList()
          : null,
    );
  }

  // Check if appointment is in the future
  bool get isUpcoming {
    return DateTime.parse(appointmentDate).isAfter(DateTime.now());
  }

  // Get days until appointment
  int get daysUntil {
    return DateTime.parse(appointmentDate).difference(DateTime.now()).inDays;
  }
}
