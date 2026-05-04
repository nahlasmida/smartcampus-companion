import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_campus_companion/core/constants/color_constants.dart';
import 'package:smart_campus_companion/core/routes/app_routes.dart';
import 'package:smart_campus_companion/presentation/providers/home_notifier.dart';
import 'package:smart_campus_companion/presentation/providers/home_state.dart';
import 'package:smart_campus_companion/presentation/widgets/offline_banner.dart';
import 'package:smart_campus_companion/data/models/models.dart';
import 'package:smart_campus_companion/presentation/screens/announcements_screen.dart';
import 'package:smart_campus_companion/presentation/screens/events_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_selectedIndex == 0) {
        ref.read(homeNotifierProvider.notifier).refresh();
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeNotifierProvider);
    final notifier = ref.read(homeNotifierProvider.notifier);

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 0) {
            notifier.refresh();
          }
        },
        children: [
          // Home Page (Dashboard)
          _buildHomePage(homeState, notifier),

          // News Page (Announcements)
          const AnnouncementsScreen(),

          // Events Page
          const EventsScreen(),

          // Settings Page
          _buildSettingsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper_outlined),
            activeIcon: Icon(Icons.newspaper),
            label: 'News',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_outlined),
            activeIcon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  // ==================== HOME PAGE ====================

  Widget _buildHomePage(HomeState homeState, HomeNotifier notifier) {
    return RefreshIndicator(
      onRefresh: notifier.refresh,
      color: AppColors.primary,
      child: CustomScrollView(
        slivers: [
          if (homeState.isOffline)
            const SliverToBoxAdapter(child: OfflineBanner()),

          SliverToBoxAdapter(
            child: _buildHeader(homeState.greeting),
          ),

          SliverToBoxAdapter(
            child: _buildScheduleSection(homeState.todaySchedule),
          ),

          SliverToBoxAdapter(
            child: _buildActionButtons(),
          ),

          SliverToBoxAdapter(
            child: _buildEventsSection(homeState.upcomingEvents),
          ),

          SliverToBoxAdapter(
            child: _buildAnnouncementsSection(homeState.recentAnnouncements),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildHeader(String? greeting) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      decoration: BoxDecoration(
        gradient: AppColors.splashGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.wb_sunny, color: Colors.white70, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '$greeting,',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Nahla',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person_outline,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.school_outlined, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text(
                  "Here's what's happening today",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSection(List<TimetableEntryModel> schedule) {
    if (schedule.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.1),
                AppColors.secondary.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(Icons.free_breakfast, size: 48, color: AppColors.primary.withOpacity(0.5)),
              const SizedBox(height: 12),
              Text(
                'No classes today',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Enjoy your day off! 📚',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Today's Schedule",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...schedule.map((class_) => _buildScheduleCard(class_)),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(TimetableEntryModel class_) {
    final color = Color(int.parse(class_.color.replaceFirst('#', '0xFF')));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 70,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withOpacity(0.2),
                  color.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  class_.startTime,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  class_.endTime,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  class_.courseName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      class_.teacher,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      class_.room,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.timetable);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.schedule, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Timetable',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'View full schedule',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.campusMap);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.map_outlined, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Campus Map',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Find your way',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsSection(List<EventModel> events) {
    if (events.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Upcoming Events',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedIndex = 2;
                    _pageController.jumpToPage(2);
                  });
                },
                child: Text(
                  'View All',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...events.take(3).map((event) => _buildEventCard(event)),
        ],
      ),
    );
  }

  Widget _buildEventCard(EventModel event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.05),
            AppColors.secondary.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getMonthAbbreviation(event.startTime.month),
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  Text(
                    event.startTime.day.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(event.startTime.hour, event.startTime.minute),
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.location_on, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.location,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsSection(List<AnnouncementModel> announcements) {
    if (announcements.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.mutedBlue,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Latest Announcements',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedIndex = 1;
                    _pageController.jumpToPage(1);
                  });
                },
                child: Text(
                  'View All',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...announcements.take(3).map((ann) => _buildAnnouncementCard(ann)),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard(AnnouncementModel announcement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: announcement.isPinned
                  ? AppColors.secondary.withOpacity(0.15)
                  : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              announcement.isPinned ? Icons.push_pin : Icons.announcement_outlined,
              color: announcement.isPinned ? AppColors.secondary : AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  announcement.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      announcement.timeAgo,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                    if (announcement.isPinned) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'PINNED',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.secondary),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
        ],
      ),
    );
  }

  String _getMonthAbbreviation(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String _formatTime(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  // ==================== SETTINGS PAGE ====================

  Widget _buildSettingsPage() {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          _buildSettingsTile(
            icon: Icons.person_outline,
            title: 'Profile',
            subtitle: 'View and edit your profile',
            onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
          _buildSettingsTile(
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            subtitle: 'Toggle dark/light theme',
            trailing: Switch(
              value: false,
              onChanged: (value) {},
              activeColor: AppColors.primary,
            ),
          ),
          _buildSettingsTile(
            icon: Icons.fingerprint,
            title: 'Biometric Login',
            subtitle: 'Use fingerprint to login',
            trailing: Switch(
              value: true,
              onChanged: (value) {},
              activeColor: AppColors.primary,
            ),
          ),
          _buildSettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Receive class reminders',
            trailing: Switch(
              value: true,
              onChanged: (value) {},
              activeColor: AppColors.primary,
            ),
          ),
          _buildSettingsTile(
            icon: Icons.map_outlined,
            title: 'Campus Map',
            subtitle: 'View interactive campus map',
            onTap: () => Navigator.pushNamed(context, AppRoutes.campusMap),
          ),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'App version 1.0.0',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'SmartCampus Companion',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2024 SmartCampus',
                children: const [
                  SizedBox(height: 8),
                  Text('Your campus companion for schedules, events, and navigation.'),
                ],
              );
            },
          ),
          const Divider(),
          _buildSettingsTile(
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            iconColor: Colors.red,
            onTap: () async {
              final confirmed = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }
}