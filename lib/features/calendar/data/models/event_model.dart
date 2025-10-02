import 'package:json_annotation/json_annotation.dart';

part 'event_model.g.dart';

@JsonSerializable()
class EventModel {
  final String id;
  final String title;
  final String? description;
  @JsonKey(name: 'start_time')
  final DateTime startTime;
  @JsonKey(name: 'end_time')
  final DateTime endTime;
  final String? location;
  @JsonKey(name: 'is_all_day')
  final bool isAllDay;
  final List<String> attendees;
  final String? recurrence;
  @JsonKey(name: 'reminder_minutes')
  final int reminderMinutes;
  @JsonKey(name: 'calendar_id')
  final String? calendarId;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const EventModel({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    this.location,
    this.isAllDay = false,
    this.attendees = const [],
    this.recurrence,
    this.reminderMinutes = 15,
    this.calendarId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) =>
      _$EventModelFromJson(json);

  Map<String, dynamic> toJson() => _$EventModelToJson(this);

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
}