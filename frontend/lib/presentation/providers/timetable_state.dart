import '../../data/models/timetable_model.dart';

class TimetableState {
  final bool isLoading;
  final String? error;
  final List<TimetableEntryModel> allEntries;
  final List<TimetableEntryModel> filteredEntries;

  const TimetableState({
    this.isLoading = true,
    this.error,
    this.allEntries = const [],
    this.filteredEntries = const [],
  });

  TimetableState copyWith({
    bool? isLoading,
    String? error,
    List<TimetableEntryModel>? allEntries,
    List<TimetableEntryModel>? filteredEntries,
  }) {
    return TimetableState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      allEntries: allEntries ?? this.allEntries,
      filteredEntries: filteredEntries ?? this.filteredEntries,
    );
  }
}