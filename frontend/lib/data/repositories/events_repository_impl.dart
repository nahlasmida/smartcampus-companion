import '../../domain/repositories/events_repository.dart';
import '../remote/events_remote_datasource.dart';
import '../models/event_model.dart';

class EventsRepositoryImpl implements EventsRepository {
  final EventsRemoteDataSource _remoteDataSource;

  EventsRepositoryImpl({required EventsRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<EventModel>> getEvents() async {
    return await _remoteDataSource.getEvents();
  }

  @override
  Future<List<EventModel>> getUpcomingEvents() async {
    return await _remoteDataSource.getUpcomingEvents();
  }
}