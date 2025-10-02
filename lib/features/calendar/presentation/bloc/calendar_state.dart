import 'package:equatable/equatable.dart';

import '../../domain/entities/event.dart';

abstract class CalendarState extends Equatable {
  const CalendarState();

  @override
  List<Object?> get props => [];
}

class CalendarInitial extends CalendarState {}

class CalendarLoading extends CalendarState {}

class CalendarLoaded extends CalendarState {
  final List<Event> events;
  final DateTime selectedDate;
  final List<Event> filteredEvents;

  const CalendarLoaded({
    required this.events,
    required this.selectedDate,
    this.filteredEvents = const [],
  });

  CalendarLoaded copyWith({
    List<Event>? events,
    DateTime? selectedDate,
    List<Event>? filteredEvents,
  }) {
    return CalendarLoaded(
      events: events ?? this.events,
      selectedDate: selectedDate ?? this.selectedDate,
      filteredEvents: filteredEvents ?? this.filteredEvents,
    );
  }

  @override
  List<Object?> get props => [events, selectedDate, filteredEvents];
}

class CalendarError extends CalendarState {
  final String message;

  const CalendarError(this.message);

  @override
  List<Object?> get props => [message];
}

class EventCreated extends CalendarState {
  final Event event;

  const EventCreated(this.event);

  @override
  List<Object?> get props => [event];
}

class EventUpdated extends CalendarState {
  final Event event;

  const EventUpdated(this.event);

  @override
  List<Object?> get props => [event];
}

class EventDeleted extends CalendarState {
  final String eventId;

  const EventDeleted(this.eventId);

  @override
  List<Object?> get props => [eventId];
}