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
  const CalendarLoaded({
    required this.events,
    required this.selectedDate,
    this.filteredEvents = const [],
    this.statusMessage,
  });

  final List<Event> events;
  final DateTime selectedDate;
  final List<Event> filteredEvents;
  final String? statusMessage;

  CalendarLoaded copyWith({
    List<Event>? events,
    DateTime? selectedDate,
    List<Event>? filteredEvents,
    String? statusMessage,
    bool clearStatusMessage = false,
  }) {
    return CalendarLoaded(
      events: events ?? this.events,
      selectedDate: selectedDate ?? this.selectedDate,
      filteredEvents: filteredEvents ?? this.filteredEvents,
      statusMessage: clearStatusMessage
          ? null
          : statusMessage ?? this.statusMessage,
    );
  }

  @override
  List<Object?> get props => [events, selectedDate, filteredEvents, statusMessage];
}

class CalendarError extends CalendarState {
  const CalendarError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
