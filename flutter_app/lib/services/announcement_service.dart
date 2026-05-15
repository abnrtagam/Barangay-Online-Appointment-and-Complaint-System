import 'api_service.dart';
import '../constants/api_constants.dart';
import '../models/announcement_model.dart';

class AnnouncementService {
  // Get all announcements
  static Future<Map<String, dynamic>> getAnnouncements() async {
    try {
      final response = await ApiService.get(ApiConstants.announcements);
      if (response['success']) {
        final data = response['data'];
        List<Announcement> announcements = [];

        if (data is List) {
          announcements = data.map((a) => Announcement.fromJson(a)).toList();
        } else if (data is Map && data['announcements'] != null) {
          announcements = (data['announcements'] as List)
              .map((a) => Announcement.fromJson(a))
              .toList();
        }

        return {'success': true, 'announcements': announcements};
      } else {
        return {'success': false, 'message': response['message'] ?? 'Failed to fetch announcements'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
