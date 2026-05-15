import 'package:flutter/material.dart';
import '../models/announcement_model.dart';
import '../services/announcement_service.dart';

class AnnouncementProvider with ChangeNotifier {
  List<Announcement> _announcements = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Announcement> get announcements => _announcements;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalAnnouncements => _announcements.length;

  // Fetch all announcements
  Future<void> fetchAnnouncements() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await AnnouncementService.getAnnouncements();
      if (result['success']) {
        _announcements = result['announcements'] as List<Announcement>;
        _announcements.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else {
        _errorMessage = result['message'];
      }
    } catch (e) {
      _errorMessage = 'Error fetching announcements: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
