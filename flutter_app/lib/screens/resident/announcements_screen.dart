import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/announcement_provider.dart';
import '../../widgets/empty_state.dart';
import '../../models/announcement_model.dart';
import 'package:intl/intl.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AnnouncementProvider>().fetchAnnouncements();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Announcements'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2D3748),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<AnnouncementProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.announcements.isEmpty) {
            return const EmptyState(
              icon: Icons.campaign_outlined,
              title: 'No Announcements',
              message: 'There are no announcements from the barangay yet. Check back later.',
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchAnnouncements(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.announcements.length,
              itemBuilder: (context, index) {
                return _buildCard(provider.announcements[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(Announcement announcement) {
    Color priorityColor;
    IconData priorityIcon;
    switch (announcement.priority) {
      case 'High':
        priorityColor = const Color(0xFFEF4444);
        priorityIcon = Icons.priority_high_rounded;
        break;
      case 'Medium':
        priorityColor = const Color(0xFFF59E0B);
        priorityIcon = Icons.info_outline_rounded;
        break;
      default:
        priorityColor = const Color(0xFF10B981);
        priorityIcon = Icons.campaign_outlined;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: priorityColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: const Border(),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: priorityColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(priorityIcon, color: priorityColor, size: 20),
        ),
        title: Text(
          announcement.title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF2D3748)),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(announcement.priority, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: priorityColor)),
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('MMM d, y').format(announcement.createdAt),
                style: TextStyle(fontSize: 11, color: Colors.grey[400]),
              ),
            ],
          ),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              announcement.content,
              style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.6),
            ),
          ),
          if (announcement.postedByName != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person_outline_rounded, size: 14, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text('Posted by ${announcement.postedByName}', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
