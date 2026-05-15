import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 12,
  });

  Color _getBackgroundColor() {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.warningBg;
      case 'approved':
      case 'scheduled':
        return AppColors.infoBg;
      case 'resolved':
      case 'completed':
        return AppColors.successBg;
      case 'rejected':
      case 'cancelled':
      case 'suspended':
        return AppColors.dangerBg;
      default:
        return AppColors.gray150;
    }
  }

  Color _getTextColor() {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.warningText;
      case 'approved':
      case 'scheduled':
        return AppColors.infoText;
      case 'resolved':
      case 'completed':
        return AppColors.successText;
      case 'rejected':
      case 'cancelled':
      case 'suspended':
        return AppColors.dangerText;
      default:
        return AppColors.gray600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: _getTextColor().withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: _getTextColor(),
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          fontFamily: 'Plus Jakarta Sans',
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
