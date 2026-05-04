import 'package:dio/dio.dart';
import '../models/event_model.dart';

class EventsRemoteDataSource {
  final Dio _dio;
  static const String baseUrl = 'http://localhost:8000';

  EventsRemoteDataSource({Dio? dio}) : _dio = dio ?? Dio();

  Future<List<EventModel>> getEvents() async {
    try {
      final response = await _dio.get('$baseUrl/events/');
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
      print('❌ Failed to fetch upcoming events: $e');
      return [];
    }
  }
}