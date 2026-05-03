import 'package:dio/dio.dart';
import '../models/announcement_model.dart';
import '../models/event_model.dart';
import '../models/timetable_model.dart';

class HomeRemoteDataSource {
  final Dio _dio;
  static const String baseUrl = 'http://localhost:8000';

  HomeRemoteDataSource({Dio? dio}) : _dio = dio ?? Dio();

  Future<List<AnnouncementModel>> getAnnouncements() async {
    try {
      final response = await _dio.get('$baseUrl/announcements/');
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((json) => AnnouncementModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('❌ Failed to fetch announcements: $e');
      return [];
    }
  }

  Future<List<EventModel>> getUpcomingEvents() async {
    try {
      final response = await _dio.get('$baseUrl/events/upcoming');
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((json) => EventModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('❌ Failed to fetch events: $e');
      return [];
    }
  }

  Future<List<TimetableEntryModel>> getTodayTimetable() async {
    try {
      final now = DateTime.now();
      final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      final today = days[now.weekday - 1];

      final response = await _dio.get('$baseUrl/timetable/day/$today');
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((json) => TimetableEntryModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('❌ Failed to fetch timetable: $e');
      return [];
    }
  }
}