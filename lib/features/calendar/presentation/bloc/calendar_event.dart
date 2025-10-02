import 'package:equatable/equatable.dart';

import '../../domain/entities/event.dart';

abstract class CalendarEvent extends Equatable {
  const CalendarEvent();

  @override
  List<Object?> get props => [];
}

class LoadCalendarEvents extends CalendarEvent {
  final DateTime startDate;
  final DateTime endDate;

  const LoadCalendarEvents({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

class CreateEvent extends CalendarEvent {
  final Event event;

  const CreateEvent(this.event);

  @override
  List<Object?> get props => [event];
}

class UpdateEvent extends CalendarEvent {
  final Event event;

  const UpdateEvent(this.event);

  @override
  List<Object?> get props => [event];
}

class DeleteEvent extends CalendarEvent {
  final String eventId;

  const DeleteEvent(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

class SearchEvents extends CalendarEvent {
  final String query;

  const SearchEvents(this.query);

  @override
  List<Object?> get props => [query];
}

class RefreshCalendar extends CalendarEvent {}

class SelectDate extends CalendarEvent {
  final DateTime selectedDate;

  const SelectDate(this.selectedDate);

  @override
  List<Object?> get props => [selectedDate];
}