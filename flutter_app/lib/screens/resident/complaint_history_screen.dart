import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/complaint_provider.dart';
import '../../constants/app_colors.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/shimmer_loading.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ComplaintProvider>().fetchComplaints();
    });
  }

  List<dynamic> _getFilteredComplaints(List<dynamic> complaints) {
    if (_filterStatus == 'All') return complaints;
    return complaints.where((c) => c.status == _filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const Text('MY COMPLAINTS'),
      ),
      body: Column(
        children: [
          // Professional filter chips
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Pending', 'Approved', 'Scheduled', 'Resolved', 'Rejected']
                    .map((status) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(status.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            selected: _filterStatus == status,
                            onSelected: (selected) {
                              setState(() => _filterStatus = status);
                            },
                            backgroundColor: AppColors.gray50,
                            selectedColor: AppColors.primary100,
                            checkmarkColor: AppColors.primary700,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
          
          Expanded(
            child: Consumer<ComplaintProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.complaints.isEmpty) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: 5,
                    itemBuilder: (context, index) => const ShimmerCard(),
                  );
                }

                final complaints = _getFilteredComplaints(provider.complaints);

                if (complaints.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_late_outlined, size: 64, color: AppColors.gray300),
                        const SizedBox(height: 16),
                        Text('No complaints found', style: TextStyle(color: AppColors.gray500, fontSize: 16)),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.fetchComplaints(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: complaints.length,
                    itemBuilder: (context, index) {
                      final complaint = complaints[index];
                      return _buildComplaintCard(context, complaint);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SubmitComplaintScreen())),
        label: const Text('FILE COMPLAINT', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1)),
        icon: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildComplaintCard(BuildContext context, dynamic complaint) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ComplaintDetailScreen(complaint: complaint))),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatusBadge(status: complaint.status),
                  Text(
                    DateFormat('MMM dd, yyyy').format(complaint.createdAt),
                    style: const TextStyle(color: AppColors.gray500, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                complaint.subject,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary900),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                complaint.details,
                style: const TextStyle(color: AppColors.gray600, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.category_outlined, size: 14, color: AppColors.gray500),
                  const SizedBox(width: 4),
                  Text(
                    complaint.categoryName ?? 'General',
                    style: const TextStyle(color: AppColors.gray500, fontSize: 12),
                  ),
                  const Spacer(),
                  const Text(
                    'View Details',
                    style: TextStyle(color: AppColors.primary600, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.primary600),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
