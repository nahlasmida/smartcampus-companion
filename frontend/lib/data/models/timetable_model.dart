class TimetableEntryModel {
  final String id;
  final String courseName;
  final String teacher;
  final String day;
  final String startTime;
  final String endTime;
  final String room;
  final String color;

  TimetableEntryModel({
    required this.id,
    required this.courseName,
    required this.teacher,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.color,
  });

  factory TimetableEntryModel.fromJson(Map<String, dynamic> json) {
    return TimetableEntryModel(
      id: json['id'] ?? json['_id'] ?? '',
      courseName: json['course_name'] ?? '',
      teacher: json['teacher'] ?? '',
      day: json['day'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      room: json['room'] ?? '',
      color: json['color'] ?? '#4CAF50',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_name': courseName,
      'teacher': teacher,
      'day': day,
      'start_time': startTime,
      'end_time': endTime,
      'room': room,
      'color': color,
    };
  }

  String get timeRange => '$startTime - $endTime';
}