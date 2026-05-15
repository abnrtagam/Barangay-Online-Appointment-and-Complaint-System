// Shared StatusHistory model used by both Complaints and Appointments
// Extracted to avoid duplicate class definitions

class StatusHistory {
  final int id;
  final int? complaintId;
  final int? appointmentId;
  final String? oldStatus;
  final String newStatus;
  final String? notes;
  final int? changedBy;
  final DateTime changedAt;

  StatusHistory({
    required this.id,
    this.complaintId,
    this.appointmentId,
    this.oldStatus,
    required this.newStatus,
    this.notes,
    this.changedBy,
    required this.changedAt,
  });

  factory StatusHistory.fromJson(Map<String, dynamic> json) {
    return StatusHistory(
      id: json['id'],
      complaintId: json['complaint_id'],
      appointmentId: json['appointment_id'],
      oldStatus: json['old_status'],
      newStatus: json['new_status'] ?? '',
      notes: json['notes'],
      changedBy: json['changed_by'],
      changedAt: DateTime.parse(json['changed_at'] ?? DateTime.now().toString()),
    );
  }
}
