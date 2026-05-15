import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/complaint_provider.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state.dart';
import '../../models/complaint_model.dart';
import 'complaint_detail_screen.dart';
import 'submit_complaint_screen.dart';
import 'package:intl/intl.dart';

class ComplaintHistoryScreen extends StatefulWidget {
  const ComplaintHistoryScreen({super.key});

  @override
  State<ComplaintHistoryScreen> createState() => _ComplaintHistoryScreenState();
}

class _ComplaintHistoryScreenState extends State<ComplaintHistoryScreen> {
  String _filterStatus = 'All';

  @override
  void initState() {
    super.initState();
    context.read<ComplaintProvider>().fetchComplaints();
  }

  List<Complaint> _getFilteredComplaints(List<Complaint> complaints) {
    if (_filterStatus == 'All') return complaints;
    return complaints.where((c) => c.status == _filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('My Complaints'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2D3748),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Pending', 'Approved', 'Scheduled', 'Resolved', 'Rejected']
                    .map((status) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(status),
                            selected: _filterStatus == status,
                            onSelected: (selected) {
                              setState(() => _filterStatus = status);
                            },
                            selectedColor: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                            checkmarkColor: const Color(0xFF3B82F6),
                            labelStyle: TextStyle(
                              color: _filterStatus == status
                                  ? const Color(0xFF3B82F6)
                                  : Colors.grey[600],
                              fontWeight: _filterStatus == status
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),

          // Complaint list
          Expanded(
            child: Consumer<ComplaintProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filtered = _getFilteredComplaints(provider.complaints);

                if (filtered.isEmpty) {
                  return EmptyState(
                    icon: Icons.description_outlined,
                    title: _filterStatus == 'All'
                        ? 'No complaints yet'
                        : 'No $_filterStatus complaints',
                    subtitle: _filterStatus == 'All'
                        ? 'Submit your first complaint to get started'
                        : 'You don\'t have any complaints with this status',
                    actionLabel: _filterStatus == 'All' ? 'Submit Complaint' : null,
                    onAction: _filterStatus == 'All'
                        ? () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SubmitComplaintScreen(),
                              ),
                            )
                        : null,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.fetchComplaints(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return _buildComplaintCard(filtered[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SubmitComplaintScreen()),
          ).then((_) {
            // Refresh after returning from submit screen
            context.read<ComplaintProvider>().fetchComplaints();
          });
        },
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Complaint'),
      ),
    );
  }

  Widget _buildComplaintCard(Complaint complaint) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ComplaintDetailScreen(complaint: complaint),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    complaint.subject,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                StatusBadge(status: complaint.status),
              ],
            ),
            const SizedBox(height: 8),
            if (complaint.categoryName != null)
              Row(
                children: [
                  Icon(Icons.category_outlined, size: 14, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(
                    complaint.categoryName!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            const SizedBox(height: 4),
            Text(
              complaint.details,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time_rounded, size: 14, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM d, y').format(complaint.createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
                const Spacer(),
                Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey[400]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
