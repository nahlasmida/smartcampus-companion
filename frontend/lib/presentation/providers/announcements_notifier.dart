import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/remote/announcements_remote_datasource.dart';
import '../../data/repositories/announcements_repository_impl.dart';
import '../../domain/repositories/announcements_repository.dart';
import 'announcements_state.dart';

final announcementsRepositoryProvider = Provider<AnnouncementsRepository>((ref) {
  return AnnouncementsRepositoryImpl(
    remoteDataSource: AnnouncementsRemoteDataSource(),
  );
});

final announcementsNotifierProvider = StateNotifierProvider<AnnouncementsNotifier, AnnouncementsState>((ref) {
  final repository = ref.watch(announcementsRepositoryProvider);
  return AnnouncementsNotifier(repository);
});

class AnnouncementsNotifier extends StateNotifier<AnnouncementsState> {
  final AnnouncementsRepository _repository;

  AnnouncementsNotifier(this._repository) : super(const AnnouncementsState()) {
    loadAnnouncements();
  }

  Future<void> loadAnnouncements() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final announcements = await _repository.getAnnouncements();
      state = state.copyWith(
        isLoading: false,
        announcements: announcements,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load announcements. Pull to refresh.',
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true, error: null);
    try {
      final announcements = await _repository.getAnnouncements();
      state = state.copyWith(
        isRefreshing: false,
        announcements: announcements,
      );
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        error: 'Failed to load announcements. Pull to refresh.',
      );
    }
  }
}