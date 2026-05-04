import 'package:dio/dio.dart';
import '../models/announcement_model.dart';

class AnnouncementsRemoteDataSource {
final Dio _dio;
static const String baseUrl = 'http://localhost:8000';

AnnouncementsRemoteDataSource({Dio? dio}) : _dio = dio ?? Dio();

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
}