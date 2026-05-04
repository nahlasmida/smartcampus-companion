import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_campus_companion/core/constants/color_constants.dart';
import 'package:smart_campus_companion/presentation/providers/announcements_notifier.dart';
import 'package:smart_campus_companion/presentation/providers/announcements_state.dart';
import 'package:smart_campus_companion/data/models/announcement_model.dart';

class AnnouncementsScreen extends ConsumerStatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  ConsumerState<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends ConsumerState<AnnouncementsScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(announcementsNotifierProvider);
    final notifier = ref.read(announcementsNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Announcements'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: notifier.refresh,
        color: AppColors.primary,
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(AnnouncementsState state) {
    if (state.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading announcements...'),
          ],
        ),
      );
    }

    if (state.error != null && state.announcements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(state.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(announcementsNotifierProvider.notifier).loadAnnouncements(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.announcements.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.announcement_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No announcements yet'),
            SizedBox(height: 8),
            Text('Check back later!'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.announcements.length,
      itemBuilder: (context, index) {
        final announcement = state.announcements[index];
        return _buildAnnouncementCard(announcement, isPinned: announcement.isPinned && index < 3);
      },
    );
  }

  Widget _buildAnnouncementCard(AnnouncementModel announcement, {bool isPinned = false}) {
    // Get category from content or title
    String category = _getCategory(announcement.title);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: isPinned
            ? Border.all(color: AppColors.secondary, width: 1.5)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with category and pinned badge
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getCategoryIcon(category),
                        size: 14,
                        color: _getCategoryColor(category),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        category,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: _getCategoryColor(category),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (isPinned)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.push_pin, size: 12, color: AppColors.secondary),
                        const SizedBox(width: 4),
                        Text(
                          'PINNED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              announcement.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Content (preview)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              announcement.content.length > 120
                  ? '${announcement.content.substring(0, 120)}...'
                  : announcement.content,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Footer with time ago
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  announcement.timeAgo,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    announcement.author,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCategory(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('library') || lowerTitle.contains('exam')) return 'Academic';
    if (lowerTitle.contains('course') || lowerTitle.contains('registration')) return 'Registration';
    if (lowerTitle.contains('wifi') || lowerTitle.contains('maintenance')) return 'IT';
    if (lowerTitle.contains('hackathon') || lowerTitle.contains('event')) return 'Events';
    if (lowerTitle.contains('welcome')) return 'Welcome';
    return 'General';
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Academic':
        return Colors.blue;
      case 'Registration':
        return Colors.green;
      case 'IT':
        return Colors.orange;
      case 'Events':
        return Colors.purple;
      case 'Welcome':
        return AppColors.primary;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Academic':
        return Icons.school;
      case 'Registration':
        return Icons.edit_calendar;
      case 'IT':
        return Icons.wifi;
      case 'Events':
        return Icons.event;
      case 'Welcome':
        return Icons.waving_hand;
      default:
        return Icons.announcement;
    }
  }
}