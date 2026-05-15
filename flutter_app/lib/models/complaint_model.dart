import 'status_history_model.dart';

// Complaint model represents a complaint filed by a resident
class Complaint {
  final int id;
  final int residentId;
  final int categoryId;
  final String subject;
  final String details;
  final String? attachmentPath;
  final String status; // 'Pending', 'Approved', 'Scheduled', 'Resolved', 'Rejected'
  final String? categoryName;
  final String? adminRemarks;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<StatusHistory>? history;

  Complaint({
    required this.id,
    required this.residentId,
    required this.categoryId,
    required this.subject,
    required this.details,
    this.attachmentPath,
    required this.status,
    this.categoryName,
    this.adminRemarks,
    required this.createdAt,
    required this.updatedAt,
    this.history,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'],
      residentId: json['resident_id'],
      categoryId: json['category_id'],
      subject: json['subject'] ?? '',
      details: json['details'] ?? '',
      attachmentPath: json['attachment_path'],
      status: json['status'] ?? 'Pending',
      categoryName: json['category_name'],
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

  // Get days since complaint was created
  int get daysAgo => DateTime.now().difference(createdAt).inDays;
}
