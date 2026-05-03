import '../../data/models/announcement_model.dart';
import '../../data/models/event_model.dart';
import '../../data/models/timetable_model.dart';

class HomeState {
  final bool isLoading;
  final bool isOffline;
  final String? error;
  final String? greeting;
  final List<TimetableEntryModel> todaySchedule;
  final List<EventModel> upcomingEvents;
  final List<AnnouncementModel> recentAnnouncements;

  const HomeState({
    this.isLoading = true,
    this.isOffline = false,
    this.error,
    this.greeting,
    this.todaySchedule = const [],
    this.upcomingEvents = const [],
    this.recentAnnouncements = const [],
  });

  HomeState copyWith({
    bool? isLoading,
    bool? isOffline,
    String? error,
    String? greeting,
    List<TimetableEntryModel>? todaySchedule,
    List<EventModel>? upcomingEvents,
    List<AnnouncementModel>? recentAnnouncements,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      isOffline: isOffline ?? this.isOffline,
      error: error ?? this.error,
      greeting: greeting ?? this.greeting,
      todaySchedule: todaySchedule ?? this.todaySchedule,
      upcomingEvents: upcomingEvents ?? this.upcomingEvents,
      recentAnnouncements: recentAnnouncements ?? this.recentAnnouncements,
    );
  }
}