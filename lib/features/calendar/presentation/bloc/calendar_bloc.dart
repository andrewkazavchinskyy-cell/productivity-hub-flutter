import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/logger.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/calendar_repository.dart';
import 'calendar_event.dart';
import 'calendar_state.dart';

class CalendarBloc extends Bloc<CalendarEvent, CalendarState> {
  CalendarBloc({required CalendarRepository calendarRepository})
      : _calendarRepository = calendarRepository,
        super(CalendarInitial()) {
    on<LoadCalendarEvents>(_onLoadCalendarEvents);
    on<CreateEvent>(_onCreateEvent);
    on<UpdateEvent>(_onUpdateEvent);
    on<DeleteEvent>(_onDeleteEvent);
    on<SearchEvents>(_onSearchEvents);
    on<RefreshCalendar>(_onRefreshCalendar);
    on<SelectDate>(_onSelectDate);
  }

  final CalendarRepository _calendarRepository;
  DateTime? _lastStartDate;
  DateTime? _lastEndDate;

  Future<void> _onLoadCalendarEvents(
    LoadCalendarEvents event,
    Emitter<CalendarState> emit,
  ) async {
    emit(CalendarLoading());
    _lastStartDate = event.startDate;
    _lastEndDate = event.endDate;

    try {
      AppLogger.info('Bloc: loading events from ${event.startDate} to ${event.endDate}');

      final result = await _calendarRepository.getEvents(
        startDate: event.startDate,
        endDate: event.endDate,
      );

      result.fold(
        (failure) {
          AppLogger.error('Bloc: failed to load events: ${failure.message}');
          emit(CalendarError(failure.message));
        },
        (events) {
          final filteredEvents = _filterEventsForDate(events, event.startDate);
          emit(CalendarLoaded(
            events: events,
            selectedDate: event.startDate,
            filteredEvents: filteredEvents,
          ));
        },
      );
    } catch (error, stackTrace) {
      AppLogger.error('Bloc: unexpected error loading events: $error', error, stackTrace);
      emit(const CalendarError('Неожиданная ошибка при загрузке событий'));
    }
  }

  Future<void> _onCreateEvent(
    CreateEvent event,
    Emitter<CalendarState> emit,
  ) async {
    try {
      AppLogger.info('Bloc: creating event ${event.event.title}');

      final result = await _calendarRepository.createEvent(event.event);
      result.fold(
        (failure) {
          AppLogger.error('Bloc: failed to create event: ${failure.message}');
          emit(CalendarError(failure.message));
        },
        (_) async {
          await _reloadCalendar(emit, message: 'Событие создано');
        },
      );
    } catch (error, stackTrace) {
      AppLogger.error('Bloc: unexpected error creating event: $error', error, stackTrace);
      emit(const CalendarError('Неожиданная ошибка при создании события'));
    }
  }

  Future<void> _onUpdateEvent(
    UpdateEvent event,
    Emitter<CalendarState> emit,
  ) async {
    try {
      AppLogger.info('Bloc: updating event ${event.event.id}');

      final result = await _calendarRepository.updateEvent(event.event);
      result.fold(
        (failure) {
          AppLogger.error('Bloc: failed to update event: ${failure.message}');
          emit(CalendarError(failure.message));
        },
        (_) async {
          await _reloadCalendar(emit, message: 'Событие обновлено');
        },
      );
    } catch (error, stackTrace) {
      AppLogger.error('Bloc: unexpected error updating event: $error', error, stackTrace);
      emit(const CalendarError('Неожиданная ошибка при обновлении события'));
    }
  }

  Future<void> _onDeleteEvent(
    DeleteEvent event,
    Emitter<CalendarState> emit,
  ) async {
    try {
      AppLogger.info('Bloc: deleting event ${event.eventId}');

      final result = await _calendarRepository.deleteEvent(event.eventId);
      result.fold(
        (failure) {
          AppLogger.error('Bloc: failed to delete event: ${failure.message}');
          emit(CalendarError(failure.message));
        },
        (_) async {
          await _reloadCalendar(emit, message: 'Событие удалено');
        },
      );
    } catch (error, stackTrace) {
      AppLogger.error('Bloc: unexpected error deleting event: $error', error, stackTrace);
      emit(const CalendarError('Неожиданная ошибка при удалении события'));
    }
  }

  Future<void> _onSearchEvents(
    SearchEvents event,
    Emitter<CalendarState> emit,
  ) async {
    try {
      AppLogger.info('Bloc: searching events with query ${event.query}');
      final currentState = state;

      if (currentState is CalendarLoaded && event.query.isEmpty) {
        emit(currentState.copyWith(filteredEvents: currentState.events, clearStatusMessage: true));
        return;
      }

      final result = await _calendarRepository.searchEvents(event.query);
      result.fold(
        (failure) {
          AppLogger.error('Bloc: failed to search events: ${failure.message}');
          emit(CalendarError(failure.message));
        },
        (events) {
          if (state is CalendarLoaded) {
            final loadedState = state as CalendarLoaded;
            emit(loadedState.copyWith(
              filteredEvents: events,
              statusMessage: 'Найдено ${events.length} событий',
            ));
          } else {
            emit(CalendarLoaded(
              events: events,
              selectedDate: DateTime.now(),
              filteredEvents: events,
              statusMessage: 'Найдено ${events.length} событий',
            ));
          }
        },
      );
    } catch (error, stackTrace) {
      AppLogger.error('Bloc: unexpected error searching events: $error', error, stackTrace);
      emit(const CalendarError('Неожиданная ошибка при поиске событий'));
    }
  }

  Future<void> _onRefreshCalendar(
    RefreshCalendar event,
    Emitter<CalendarState> emit,
  ) async {
    await _reloadCalendar(emit, showLoading: true);
  }

  void _onSelectDate(
    SelectDate event,
    Emitter<CalendarState> emit,
  ) {
    final currentState = state;
    if (currentState is CalendarLoaded) {
      final dayEvents = _filterEventsForDate(currentState.events, event.selectedDate);
      emit(currentState.copyWith(
        selectedDate: event.selectedDate,
        filteredEvents: dayEvents,
        clearStatusMessage: true,
      ));
    }
  }

  Future<void> _reloadCalendar(
    Emitter<CalendarState> emit, {
    String? message,
    bool showLoading = false,
  }) async {
    if (_lastStartDate == null || _lastEndDate == null) {
      return;
    }

    final currentState = state;
    if (showLoading) {
      emit(CalendarLoading());
    }

    final result = await _calendarRepository.getEvents(
      startDate: _lastStartDate!,
      endDate: _lastEndDate!,
    );

    result.fold(
      (failure) {
        AppLogger.error('Bloc: failed to reload events: ${failure.message}');
        emit(CalendarError(failure.message));
      },
      (events) {
        final selectedDate = currentState is CalendarLoaded
            ? currentState.selectedDate
            : _lastStartDate!;
        final filteredEvents = _filterEventsForDate(events, selectedDate);
        emit(CalendarLoaded(
          events: events,
          selectedDate: selectedDate,
          filteredEvents: filteredEvents,
          statusMessage: message,
        ));
      },
    );
  }

  List<Event> _filterEventsForDate(List<Event> events, DateTime selectedDate) {
    return events.where((event) {
      final eventDate = DateTime(event.startTime.year, event.startTime.month, event.startTime.day);
      final targetDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      return eventDate == targetDate;
    }).toList();
  }
}
