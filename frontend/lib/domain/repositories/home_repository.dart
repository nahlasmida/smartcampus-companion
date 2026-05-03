import '../../data/models/announcement_model.dart';
import '../../data/models/announcement_model.dart';
import '../../data/models/event_model.dart';
import '../../data/models/timetable_model.dart';
abstract class HomeRepository {
  Future<List<AnnouncementModel>> getAnnouncements();
  Future<List<EventModel>> getUpcomingEvents();
  Future<List<TimetableEntryModel>> getTodayTimetable();
}