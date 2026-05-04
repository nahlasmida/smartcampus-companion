import '../../data/models/announcement_model.dart';

class AnnouncementsState {
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final List<AnnouncementModel> announcements;

  const AnnouncementsState({
    this.isLoading = true,
    this.isRefreshing = false,
    this.error,
    this.announcements = const [],
  });

  AnnouncementsState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    List<AnnouncementModel>? announcements,
  }) {
    return AnnouncementsState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error ?? this.error,
      announcements: announcements ?? this.announcements,
    );
  }

  List<AnnouncementModel> get pinnedAnnouncements {
    return announcements.where((a) => a.isPinned).toList();
  }

  List<AnnouncementModel> get regularAnnouncements {
    return announcements.where((a) => !a.isPinned).toList();
  }
}