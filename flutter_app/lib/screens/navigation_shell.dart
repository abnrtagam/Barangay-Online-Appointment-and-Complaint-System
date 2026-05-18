import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../constants/api_constants.dart';
import 'auth/login_screen.dart';
import 'resident/dashboard_screen.dart';
import 'resident/complaint_history_screen.dart';
import 'resident/appointment_history_screen.dart';
import 'resident/announcements_screen.dart';
import 'resident/profile_screen.dart';

class NavigationShell extends StatefulWidget {
  const NavigationShell({super.key});

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  int _currentIndex = 0;
  Timer? _statusCheckTimer;
  bool _isSuspendedDialogShowing = false;

  final List<Widget> _screens = const [
    DashboardScreen(),
    ComplaintHistoryScreen(),
    AppointmentHistoryScreen(),
    AnnouncementsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _startStatusPolling();
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  void _startStatusPolling() {
    _checkStatus();
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkStatus();
    });
  }

  Future<void> _checkStatus() async {
    if (_isSuspendedDialogShowing) return;

    try {
      final response = await ApiService.get(ApiConstants.checkStatus);
      if (response['success'] == true && response['data'] != null) {
        final status = response['data']['status'];
        if (status == 'suspended') {
          _handleSuspension();
        }
      }
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('suspended') || errorStr.contains('Suspended') || errorStr.contains('403')) {
        _handleSuspension();
      }
    }
  }

  void _handleSuspension() {
    if (_isSuspendedDialogShowing) return;
    _isSuspendedDialogShowing = true;
    _statusCheckTimer?.cancel();

    int countdown = 5;
    Timer? countdownTimer;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            countdownTimer ??= Timer.periodic(const Duration(seconds: 1), (timer) {
              if (mounted) {
                setState(() {
                  countdown--;
                });
              }
              if (countdown <= 0) {
                timer.cancel();
                Navigator.pop(dialogContext);
                _logoutAndRedirect();
              }
            });

            return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                title: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
                    SizedBox(width: 8),
                    Text('Account Suspended', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Your account has been suspended by the barangay admin. '
                      'You will be logged out automatically. '
                      'Please contact Barangay Bulua office for assistance.',
                      style: TextStyle(fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: 72,
                      height: 72,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red, width: 3),
                      ),
                      child: Text(
                        '$countdown',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Logging out in $countdown seconds...',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _logoutAndRedirect() {
    if (!mounted) return;
    LoginScreen.showSuspendedSnackBar = true;
    Provider.of<AuthProvider>(context, listen: false).logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: const Border(top: BorderSide(color: AppColors.gray200, width: 1)),
          boxShadow: [
            BoxShadow(
              color: AppColors.gray950.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          backgroundColor: AppColors.white,
          surfaceTintColor: Colors.transparent,
          indicatorColor: AppColors.primary100,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          height: 70,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: AppColors.gray500),
              selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary700),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.description_outlined, color: AppColors.gray500),
              selectedIcon: Icon(Icons.description_rounded, color: AppColors.primary700),
              label: 'Complaints',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined, color: AppColors.gray500),
              selectedIcon: Icon(Icons.calendar_today_rounded, color: AppColors.primary700),
              label: 'Schedule',
            ),
            NavigationDestination(
              icon: Icon(Icons.campaign_outlined, color: AppColors.gray500),
              selectedIcon: Icon(Icons.campaign_rounded, color: AppColors.primary700),
              label: 'News',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded, color: AppColors.gray500),
              selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary700),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
