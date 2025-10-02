import '../../domain/entities/event.dart';

class EventModel {
  const EventModel({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.description,
    this.location,
    this.isAllDay = false,
    this.attendees = const [],
    this.recurrence,
    this.reminderMinutes = 15,
    this.calendarId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final String? location;
  final bool isAllDay;
  final List<String> attendees;
  final String? recurrence;
  final int reminderMinutes;
  final String? calendarId;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final start = json['start_time'] ?? json['start'] ?? {};
    final end = json['end_time'] ?? json['end'] ?? {};

    DateTime parseDateTime(dynamic value) {
      if (value is String) {
        return DateTime.parse(value).toLocal();
      }
      if (value is Map<String, dynamic>) {
        final dateTime = value['dateTime'] ?? value['date'];
        if (dateTime is String) {
          return DateTime.parse(dateTime).toLocal();
        }
      }
      throw ArgumentError('Invalid date value: $value');
    }

    return EventModel(
      id: json['id']?.toString() ?? '',
      title: json['summary']?.toString() ?? json['title']?.toString() ?? 'Событие',
      description: json['description'] as String?,
      startTime: parseDateTime(start),
      endTime: parseDateTime(end),
      location: json['location'] as String?,
      isAllDay: json['is_all_day'] as bool? ?? false,
      attendees: (json['attendees'] as List<dynamic>? ?? [])
          .map((item) => item is Map<String, dynamic> ? item['email']?.toString() ?? '' : item.toString())
          .where((email) => email.isNotEmpty)
          .toList(),
      recurrence: (json['recurrence'] as List<dynamic>?)?.cast<String>().join('; '),
      reminderMinutes: json['reminder_minutes'] as int? ?? 15,
      calendarId: json['calendar_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toLocal()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String).toLocal()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'location': location,
      'is_all_day': isAllDay,
      'attendees': attendees,
      'recurrence': recurrence,
      'reminder_minutes': reminderMinutes,
      'calendar_id': calendarId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory EventModel.fromEntity(Event event) {
    return EventModel(
      id: event.id,
      title: event.title,
      description: event.description,
      startTime: event.startTime,
      endTime: event.endTime,
      location: event.location,
      isAllDay: event.isAllDay,
      attendees: event.attendees,
      recurrence: event.recurrence,
      reminderMinutes: event.reminderMinutes,
      calendarId: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Event toEntity() {
    return Event(
      id: id,
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      location: location,
      isAllDay: isAllDay,
      attendees: attendees,
      recurrence: recurrence,
      reminderMinutes: reminderMinutes,
    );
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    bool? isAllDay,
    List<String>? attendees,
    String? recurrence,
    int? reminderMinutes,
    String? calendarId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      isAllDay: isAllDay ?? this.isAllDay,
      attendees: attendees ?? this.attendees,
      recurrence: recurrence ?? this.recurrence,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      calendarId: calendarId ?? this.calendarId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
