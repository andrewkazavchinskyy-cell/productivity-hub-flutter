import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/logger.dart';
import '../../domain/repositories/calendar_repository.dart';
import 'calendar_event.dart';
import 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  final CalendarRepository _calendarRepository;

  CalendarBloc({
    required CalendarRepository calendarRepository,
  }) : _calendarRepository = calendarRepository,
       super(CalendarInitial()) {
    
    on<LoadCalendarEvents>(_onLoadCalendarEvents);
    on<CreateEvent>(_onCreateEvent);
    on<UpdateEvent>(_onUpdateEvent);
    on<DeleteEvent>(_onDeleteEvent);
    on<SearchEvents>(_onSearchEvents);
    on<RefreshCalendar>(_onRefreshCalendar);
    on<SelectDate>(_onSelectDate);
  }

  Future<void> _onLoadCalendarEvents(
    LoadCalendarEvents event,
    Emitter<CalendarState> emit,
  ) async {
    emit(CalendarLoading());
    
    try {
      AppLogger.info('Loading calendar events from ${event.startDate} to ${event.endDate}');
      
      final result = await _calendarRepository.getEvents(
        startDate: event.startDate,
        endDate: event.endDate,
      );
      
      result.fold(
        (failure) {
          AppLogger.error('Failed to load events: ${failure.message}');
          emit(CalendarError(failure.message));
        },
        (events) {
          AppLogger.info('Successfully loaded ${events.length} events');
          emit(CalendarLoaded(
            events: events,
            selectedDate: event.startDate,
            filteredEvents: events,
          ));
        },
      );
    } catch (e) {
      AppLogger.error('Unexpected error loading events: $e');
      emit(CalendarError('Неожиданная ошибка при загрузке событий'));
    }
  }

  Future<void> _onCreateEvent(
    CreateEvent event,
    Emitter<CalendarState> emit,
  ) async {
    try {
      AppLogger.info('Creating event: ${event.event.title}');
      
      final result = await _calendarRepository.createEvent(event.event);
      
      result.fold(
        (failure) {
          AppLogger.error('Failed to create event: ${failure.message}');
          emit(CalendarError(failure.message));
        },
        (createdEvent) {
          AppLogger.info('Successfully created event: ${createdEvent.id}');
          emit(EventCreated(createdEvent));
          
          // Refresh the calendar
          add(RefreshCalendar());
        },
      );
    } catch (e) {
      AppLogger.error('Unexpected error creating event: $e');
      emit(CalendarError('Неожиданная ошибка при создании события'));
    }
  }

  Future<void> _onUpdateEvent(
    UpdateEvent event,
    Emitter<CalendarState> emit,
  ) async {
    try {
      AppLogger.info('Updating event: ${event.event.id}');
      
      final result = await _calendarRepository.updateEvent(event.event);
      
      result.fold(
        (failure) {
          AppLogger.error('Failed to update event: ${failure.message}');
          emit(CalendarError(failure.message));
        },
        (updatedEvent) {
          AppLogger.info('Successfully updated event: ${updatedEvent.id}');
          emit(EventUpdated(updatedEvent));
          
          // Refresh the calendar
          add(RefreshCalendar());
        },
      );
    } catch (e) {
      AppLogger.error('Unexpected error updating event: $e');
      emit(CalendarError('Неожиданная ошибка при обновлении события'));
    }
  }

  Future<void> _onDeleteEvent(
    DeleteEvent event,
    Emitter<CalendarState> emit,
  ) async {
    try {
      AppLogger.info('Deleting event: ${event.eventId}');
      
      final result = await _calendarRepository.deleteEvent(event.eventId);
      
      result.fold(
        (failure) {
          AppLogger.error('Failed to delete event: ${failure.message}');
          emit(CalendarError(failure.message));
        },
        (_) {
          AppLogger.info('Successfully deleted event: ${event.eventId}');
          emit(EventDeleted(event.eventId));
          
          // Refresh the calendar
          add(RefreshCalendar());
        },
      );
    } catch (e) {
      AppLogger.error('Unexpected error deleting event: $e');
      emit(CalendarError('Неожиданная ошибка при удалении события'));
    }
  }

  Future<void> _onSearchEvents(
    SearchEvents event,
    Emitter<CalendarState> emit,
  ) async {
    try {
      AppLogger.info('Searching events with query: ${event.query}');
      
      final result = await _calendarRepository.searchEvents(event.query);
      
      result.fold(
        (failure) {
          AppLogger.error('Failed to search events: ${failure.message}');
          emit(CalendarError(failure.message));
        },
        (events) {
          AppLogger.info('Found ${events.length} events matching query');
          
          final currentState = state;
          if (currentState is CalendarLoaded) {
            emit(currentState.copyWith(filteredEvents: events));
          } else {
            emit(CalendarLoaded(
              events: events,
              selectedDate: DateTime.now(),
              filteredEvents: events,
            ));
          }
        },
      );
    } catch (e) {
      AppLogger.error('Unexpected error searching events: $e');
      emit(CalendarError('Неожиданная ошибка при поиске событий'));
    }
  }

  Future<void> _onRefreshCalendar(
    RefreshCalendar event,
    Emitter<CalendarState> emit,
  ) async {
    final currentState = state;
    if (currentState is CalendarLoaded) {
      add(LoadCalendarEvents(
        startDate: currentState.selectedDate,
        endDate: currentState.selectedDate.add(const Duration(days: 30)),
      ));
    }
  }

  void _onSelectDate(
    SelectDate event,
    Emitter<CalendarState> emit,
  ) {
    final currentState = state;
    if (currentState is CalendarLoaded) {
      // Filter events for the selected date
      final dayEvents = currentState.events.where((event) {
        final eventDate = DateTime(
          event.startTime.year,
          event.startTime.month,
          event.startTime.day,
        );
        final selectedDate = DateTime(
          event.selectedDate.year,
          event.selectedDate.month,
          event.selectedDate.day,
        );
        return eventDate.isAtSameMomentAs(selectedDate);
      }).toList();

      emit(currentState.copyWith(
        selectedDate: event.selectedDate,
        filteredEvents: dayEvents,
      ));
    }
  }
}