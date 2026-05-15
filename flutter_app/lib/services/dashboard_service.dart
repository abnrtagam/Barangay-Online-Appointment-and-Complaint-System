import 'api_service.dart';
import '../constants/api_constants.dart';

class DashboardService {
  // Get dashboard statistics for the logged-in resident
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await ApiService.get(ApiConstants.dashboardStats);
      if (response['success']) {
        return {
          'success': true,
          'stats': response['data'],
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to fetch dashboard stats',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
