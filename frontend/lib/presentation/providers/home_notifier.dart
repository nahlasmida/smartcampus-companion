import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/remote/home_remote_datasource.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/repositories/home_repository.dart';
import '../../data/models/announcement_model.dart';
import '../../data/models/event_model.dart';
import '../../data/models/timetable_model.dart';
import 'home_state.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepositoryImpl(
    remoteDataSource: HomeRemoteDataSource(),
  );
});

final homeNotifierProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return HomeNotifier(repository);
});

class HomeNotifier extends StateNotifier<HomeState> {
  final HomeRepository _repository;

  HomeNotifier(this._repository) : super(const HomeState()) {
    _getGreeting();
    loadHomeData();
  }

  void _getGreeting() {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }
    state = state.copyWith(greeting: greeting);
  }

  Future<void> loadHomeData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final results = await Future.wait([
        _repository.getTodayTimetable(),
        _repository.getUpcomingEvents(),
        _repository.getAnnouncements(),
      ]);

      // ✅ FIX: Cast each result to the correct type
      final todaySchedule = results[0] as List<TimetableEntryModel>;
      final upcomingEvents = results[1] as List<EventModel>;
      final recentAnnouncements = results[2] as List<AnnouncementModel>;

      state = state.copyWith(
        isLoading: false,
        todaySchedule: todaySchedule.take(3).toList(),
        upcomingEvents: upcomingEvents.take(3).toList(),
        recentAnnouncements: recentAnnouncements.take(3).toList(),
      );
    } catch (e) {
      print('❌ Error loading home data: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load data. Pull to refresh.',
      );
    }
  }

  Future<void> refresh() async {
    await loadHomeData();
  }

  void setOfflineMode(bool isOffline) {
    state = state.copyWith(isOffline: isOffline);
  }
}