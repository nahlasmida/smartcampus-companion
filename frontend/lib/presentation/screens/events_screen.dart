import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_campus_companion/core/constants/color_constants.dart';
import 'package:smart_campus_companion/presentation/providers/events_notifier.dart';
import 'package:smart_campus_companion/presentation/providers/events_state.dart';
import 'package:smart_campus_companion/data/models/event_model.dart';
import 'package:smart_campus_companion/presentation/screens/event_detail_screen.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(eventsNotifierProvider);
    final notifier = ref.read(eventsNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Events'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: _buildFilterChips(state, notifier),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: notifier.refresh,
        color: AppColors.primary,
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildFilterChips(EventsState state, EventsNotifier notifier) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          FilterChip(
            label: const Text('All Events'),
            selected: state.selectedFilter == 'all',
            onSelected: (_) => notifier.setFilter('all'),
            backgroundColor: Colors.white,
            selectedColor: AppColors.primary.withOpacity(0.2),
            checkmarkColor: AppColors.primary,
            labelStyle: TextStyle(
              color: state.selectedFilter == 'all' ? AppColors.primary : Colors.grey,
              fontWeight: state.selectedFilter == 'all' ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(width: 12),
          FilterChip(
            label: const Text('Upcoming'),
            selected: state.selectedFilter == 'upcoming',
            onSelected: (_) => notifier.setFilter('upcoming'),
            backgroundColor: Colors.white,
            selectedColor: AppColors.primary.withOpacity(0.2),
            checkmarkColor: AppColors.primary,
            labelStyle: TextStyle(
              color: state.selectedFilter == 'upcoming' ? AppColors.primary : Colors.grey,
              fontWeight: state.selectedFilter == 'upcoming' ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(EventsState state) {
    if (state.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading events...'),
          ],
        ),
      );
    }

    if (state.error != null && state.displayedEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(state.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(eventsNotifierProvider.notifier).loadEvents(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.displayedEvents.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No events found'),
            SizedBox(height: 8),
            Text('Check back later for upcoming events!'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.displayedEvents.length,
      itemBuilder: (context, index) {
        final event = state.displayedEvents[index];
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildEventCard(EventModel event) {
    // Format date
    final dateFormat = '${_getMonthName(event.startTime.month)} ${event.startTime.day}, ${event.startTime.year}';
    final timeFormat = '${_formatTime(event.startTime.hour, event.startTime.minute)} - ${_formatTime(event.endTime.hour, event.endTime.minute)}';

    // Get category from title
    final category = _getCategory(event.title);
    final categoryColor = _getCategoryColor(category);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailScreen(event: event),
          ),
        );
      },
      child: Container(
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
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category header with gradient
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [categoryColor, categoryColor.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getCategoryIcon(category),
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Date
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        dateFormat,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Time
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.access_time,
                          size: 16,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        timeFormat,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Location
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          event.location,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (event.description.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '📝 ',
                          style: TextStyle(fontSize: 14),
                        ),
                        Expanded(
                          child: Text(
                            event.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Organizer
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 14,
                        color: AppColors.textSecondary.withOpacity(0.7),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Organized by: ${event.organizer}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String _formatTime(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  String _getCategory(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('orientation')) return 'Orientation';
    if (lowerTitle.contains('workshop')) return 'Workshop';
    if (lowerTitle.contains('marathon')) return 'Sports';
    if (lowerTitle.contains('exam')) return 'Academic';
    if (lowerTitle.contains('career')) return 'Career';
    if (lowerTitle.contains('fair')) return 'Career';
    if (lowerTitle.contains('guest')) return 'Lecture';
    return 'Event';
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Orientation':
        return Colors.blue;
      case 'Workshop':
        return Colors.purple;
      case 'Sports':
        return Colors.green;
      case 'Academic':
        return Colors.orange;
      case 'Career':
        return Colors.teal;
      case 'Lecture':
        return Colors.indigo;
      default:
        return AppColors.primary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Orientation':
        return Icons.celebration;
      case 'Workshop':
        return Icons.computer;
      case 'Sports':
        return Icons.sports_basketball;
      case 'Academic':
        return Icons.school;
      case 'Career':
        return Icons.work;
      case 'Lecture':
        return Icons.mic;
      default:
        return Icons.event;
    }
  }
}