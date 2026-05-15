import 'package:flutter/material.dart';

/// A colored badge that displays the status of a complaint or appointment.
/// Automatically picks colors based on the status text.
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
        return const Color(0xFFFFF3CD);
      case 'approved':
        return const Color(0xFFD1E7DD);
      case 'resolved':
      case 'completed':
        return const Color(0xFFCFE2FF);
      case 'rejected':
        return const Color(0xFFF8D7DA);
      case 'suspended':
        return const Color(0xFFF8D7DA);
      case 'scheduled':
        return const Color(0xFFE2E3F1);
      case 'cancelled':
        return const Color(0xFFE2E3E5);
      default:
        return const Color(0xFFE2E3E5);
    }
  }

  Color _getTextColor() {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFF856404);
      case 'approved':
        return const Color(0xFF0F5132);
      case 'resolved':
      case 'completed':
        return const Color(0xFF084298);
      case 'rejected':
        return const Color(0xFF842029);
      case 'suspended':
        return const Color(0xFF842029);
      case 'scheduled':
        return const Color(0xFF41469B);
      case 'cancelled':
        return const Color(0xFF41464B);
      default:
        return const Color(0xFF41464B);
    }
  }

  IconData _getIcon() {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_empty_rounded;
      case 'approved':
        return Icons.check_circle_outline_rounded;
      case 'resolved':
      case 'completed':
        return Icons.task_alt_rounded;
      case 'rejected':
        return Icons.cancel_outlined;
      case 'suspended':
        return Icons.block_rounded;
      case 'scheduled':
        return Icons.event_rounded;
      case 'cancelled':
        return Icons.remove_circle_outline_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getIcon(), size: fontSize + 2, color: _getTextColor()),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: _getTextColor(),
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
