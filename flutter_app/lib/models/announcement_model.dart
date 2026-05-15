// Announcement model represents a system announcement from the barangay
class Announcement {
  final int id;
  final String title;
  final String content;
  final String priority; // 'Normal', 'Medium', 'High'
  final int createdBy;
  final String? postedByName;
  final DateTime createdAt;
  final DateTime updatedAt;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.priority,
    required this.createdBy,
    this.postedByName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      priority: json['priority'] ?? 'Normal',
      createdBy: json['created_by'] ?? 0,
      postedByName: json['posted_by_name'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toString()),
    );
  }

  // Get days since announcement was posted
  int get daysAgo => DateTime.now().difference(createdAt).inDays;

  // Get priority color
  String get priorityColor {
    switch (priority) {
      case 'High':
        return 'FF0000';
      case 'Medium':
        return 'FFA500';
      default:
        return '008000';
    }
  }
}
