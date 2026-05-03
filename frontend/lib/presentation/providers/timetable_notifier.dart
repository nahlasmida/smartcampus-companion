import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:html' as html; // FOR WEB
import '../../data/models/timetable_model.dart';
import 'timetable_state.dart';

final timetableNotifierProvider = StateNotifierProvider<TimetableNotifier, TimetableState>((ref) {
  return TimetableNotifier();
});

class TimetableNotifier extends StateNotifier<TimetableState> {
  final Dio _dio = Dio();
  static const String baseUrl = 'http://localhost:8000';

  TimetableNotifier() : super(const TimetableState()) {
    loadAllTimetable();
  }

  Future<void> loadAllTimetable() async {
    print('📡 Loading timetable...');
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.get('$baseUrl/timetable/');
      print('✅ Response: ${response.statusCode}');

      if (response.statusCode == 200 && response.data is List) {
        final allEntries = (response.data as List)
            .map((json) => TimetableEntryModel.fromJson(json))
            .toList();

        print('📊 Found ${allEntries.length} entries');

        final today = _getCurrentDay();
        final filteredEntries = allEntries.where((e) => e.day == today).toList();
        filteredEntries.sort((a, b) => a.startTime.compareTo(b.startTime));

        state = state.copyWith(
          isLoading: false,
          allEntries: allEntries,
          filteredEntries: filteredEntries,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to load timetable',
        );
      }
    } catch (e) {
      print('❌ Error: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Network error: ${e.toString()}',
      );
    }
  }

  Future<void> loadTimetableByDay(String day) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final filtered = state.allEntries.where((e) => e.day == day).toList();
      filtered.sort((a, b) => a.startTime.compareTo(b.startTime));

      state = state.copyWith(
        isLoading: false,
        filteredEntries: filtered,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load timetable for $day',
      );
    }
  }

  Future<bool> exportPDF() async {
    try {
      final response = await _dio.get(
        '$baseUrl/timetable/export/pdf',
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200) {
        final bytes = response.data as List<int>;

        // Check if running on web
        if (isWebPlatform()) {
          // Web: Use html anchor to download
          final blob = html.Blob([bytes], 'application/pdf');
          final url = html.Url.createObjectUrlFromBlob(blob);
          html.AnchorElement(href: url)
            ..setAttribute('download', 'timetable_${DateTime.now().millisecondsSinceEpoch}.pdf')
            ..click();
          html.Url.revokeObjectUrl(url);
          print('✅ PDF downloaded on web');
          return true;
        } else {
          // Mobile/Desktop: Save to file system
          final directory = await getDownloadsDirectory();
          if (directory != null) {
            final filePath = '${directory.path}/timetable_${DateTime.now().millisecondsSinceEpoch}.pdf';
            final file = File(filePath);
            await file.writeAsBytes(bytes);
            print('✅ PDF saved to: $filePath');
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      print('❌ Export error: $e');
      return false;
    }
  }

  bool isWebPlatform() {
    // Safe check for web platform
    try {
      // ignore: undefined_prefixed_name
      return identical(0, 0.0) ? false : true; // Simple web detection
    } catch (e) {
      return false;
    }
  }

  Future<void> refresh() async {
    await loadAllTimetable();
  }

  String _getCurrentDay() {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[DateTime.now().weekday - 1];
  }
}