import '../../domain/repositories/announcements_repository.dart';
import '../remote/announcements_remote_datasource.dart';
import '../models/announcement_model.dart';

class AnnouncementsRepositoryImpl implements AnnouncementsRepository {
  final AnnouncementsRemoteDataSource _remoteDataSource;

  AnnouncementsRepositoryImpl({required AnnouncementsRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<AnnouncementModel>> getAnnouncements() async {
    return await _remoteDataSource.getAnnouncements();
  }
}