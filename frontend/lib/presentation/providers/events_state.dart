import '../../data/models/event_model.dart';

class EventsState {
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final List<EventModel> allEvents;
  final List<EventModel> upcomingEvents;
  final String selectedFilter;

  const EventsState({
    this.isLoading = true,
    this.isRefreshing = false,
    this.error,
    this.allEvents = const [],
    this.upcomingEvents = const [],
    this.selectedFilter = 'all',
  });

  EventsState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    List<EventModel>? allEvents,
    List<EventModel>? upcomingEvents,
    String? selectedFilter,
  }) {
    return EventsState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error ?? this.error,
      allEvents: allEvents ?? this.allEvents,
      upcomingEvents: upcomingEvents ?? this.upcomingEvents,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }

  List<EventModel> get displayedEvents {
    if (selectedFilter == 'upcoming') {
      return upcomingEvents;
    }
    return allEvents;
  }
}