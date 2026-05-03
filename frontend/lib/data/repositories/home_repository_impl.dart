import '../../domain/repositories/home_repository.dart';
import '../remote/home_remote_datasource.dart';
import '../models/announcement_model.dart';
import 'package:dio/dio.dart';
import '../models/announcement_model.dart';
import '../models/event_model.dart';
import '../models/timetable_model.dart';
class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource _remoteDataSource;

  HomeRepositoryImpl({required HomeRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<AnnouncementModel>> getAnnouncements() async {
    return await _remoteDataSource.getAnnouncements();
  }

  @override
  Future<List<EventModel>> getUpcomingEvents() async {
    return await _remoteDataSource.getUpcomingEvents();
  }

  @override
  Future<List<TimetableEntryModel>> getTodayTimetable() async {
    return await _remoteDataSource.getTodayTimetable();
  }
}