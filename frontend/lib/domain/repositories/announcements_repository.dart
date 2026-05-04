import '../../data/models/announcement_model.dart';

abstract class AnnouncementsRepository {
  Future<List<AnnouncementModel>> getAnnouncements();
}