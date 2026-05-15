import 'package:flutter/material.dart';
import '../../models/complaint_model.dart';
import '../../widgets/status_badge.dart';
import '../../constants/app_colors.dart';
import 'package:intl/intl.dart';

class ComplaintDetailScreen extends StatelessWidget {
  final Complaint complaint;

  const ComplaintDetailScreen({super.key, required this.complaint});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Complaint Details'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2D3748),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(complaint.subject, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF2D3748)))),
                      StatusBadge(status: complaint.status, fontSize: 13),
                    ],
                  ),
                  if (complaint.categoryName != null) ...[
                    const SizedBox(height: 4),
                    Text(complaint.categoryName!, style: TextStyle(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w500)),
                  ],
                  const SizedBox(height: 12),
                  Text('Complaint #${complaint.id}', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Details
            _section('Details', Icons.article_outlined, child: Text(complaint.details, style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.6))),
            const SizedBox(height: 16),

            // Info
            _section('Information', Icons.info_outline_rounded, child: Column(children: [
              _infoRow('Date Filed', DateFormat('MMM d, y • h:mm a').format(complaint.createdAt)),
              _infoRow('Last Updated', DateFormat('MMM d, y • h:mm a').format(complaint.updatedAt)),
              _infoRow('Days Since Filed', '${complaint.daysAgo} day${complaint.daysAgo == 1 ? "" : "s"}'),
            ])),

            // Admin remarks
            if (complaint.adminRemarks != null && complaint.adminRemarks!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _section('Admin Remarks', Icons.comment_outlined, child: Text(complaint.adminRemarks!, style: TextStyle(fontSize: 14, color: Colors.grey[700], fontStyle: FontStyle.italic))),
            ],

            const SizedBox(height: 16),
            // Timeline
            _section('Status History', Icons.history_rounded, child: _buildTimeline(complaint.history ?? [])),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(List<dynamic> history) {
    if (history.isEmpty) {
      return const Text('No history available', style: TextStyle(fontSize: 13, color: AppColors.gray400));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        final isLast = index == history.length - 1;
        
        return IntrinsicHeight(
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: index == 0 ? AppColors.primary600 : AppColors.gray300,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [BoxShadow(color: AppColors.primary600.withValues(alpha: 0.3), blurRadius: 4)],
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(width: 2, color: AppColors.gray200),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.newStatus.toUpperCase(),
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _getStatusColor(item.newStatus)),
                          ),
                          Text(
                            DateFormat('MMM d, y • h:mm a').format(item.changedAt),
                            style: TextStyle(fontSize: 10, color: AppColors.gray400),
                          ),
                        ],
                      ),
                      if (item.notes != null && item.notes!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.notes!,
                          style: TextStyle(fontSize: 13, color: AppColors.gray600, height: 1.4),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return AppColors.warning;
      case 'approved': return AppColors.success;
      case 'scheduled': return AppColors.accentTeal;
      case 'resolved': return AppColors.success;
      case 'rejected': return AppColors.danger;
      default: return AppColors.gray500;
    }
  }

  Widget _section(String title, IconData icon, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, size: 18, color: const Color(0xFF3B82F6)), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF2D3748)))]),
        const SizedBox(height: 12),
        child,
      ]),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        SizedBox(width: 130, child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w500))),
        Expanded(child: Text(value, style: TextStyle(fontSize: 13, color: Colors.grey[700], fontWeight: FontWeight.w500))),
      ]),
    );
  }
}
