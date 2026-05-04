import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/remote/events_remote_datasource.dart';
import '../../data/repositories/events_repository_impl.dart';
import '../../domain/repositories/events_repository.dart';
import 'events_state.dart';

final eventsRepositoryProvider = Provider<EventsRepository>((ref) {
  return EventsRepositoryImpl(
    remoteDataSource: EventsRemoteDataSource(),
  );
});

final eventsNotifierProvider = StateNotifierProvider<EventsNotifier, EventsState>((ref) {
  final repository = ref.watch(eventsRepositoryProvider);
  return EventsNotifier(repository);
});

class EventsNotifier extends StateNotifier<EventsState> {
  final EventsRepository _repository;

  EventsNotifier(this._repository) : super(const EventsState()) {
    loadEvents();
  }

  Future<void> loadEvents() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final [allEvents, upcomingEvents] = await Future.wait([
        _repository.getEvents(),
        _repository.getUpcomingEvents(),
      ]);

      state = state.copyWith(
        isLoading: false,
        allEvents: allEvents,
        upcomingEvents: upcomingEvents,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load events. Pull to refresh.',
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true, error: null);
    try {
      final [allEvents, upcomingEvents] = await Future.wait([
        _repository.getEvents(),
        _repository.getUpcomingEvents(),
      ]);

      state = state.copyWith(
        isRefreshing: false,
        allEvents: allEvents,
        upcomingEvents: upcomingEvents,
      );
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        error: 'Failed to load events. Pull to refresh.',
      );
    }
  }

  void setFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }
}