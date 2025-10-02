import 'dart:async';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../models/event_model.dart';

abstract class CalendarRemoteDataSource {
  Future<List<EventModel>> getEvents({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<EventModel> createEvent(EventModel event);

  Future<EventModel> updateEvent(EventModel event);

  Future<void> deleteEvent(String eventId);

  Future<List<EventModel>> searchEvents(String query);

  Future<List<DateTime>> findFreeSlots({
    required DateTime startDate,
    required DateTime endDate,
    required Duration duration,
  });
}

class CalendarRemoteDataSourceImpl implements CalendarRemoteDataSource {
  CalendarRemoteDataSourceImpl({List<EventModel>? seedEvents})
      : _events = List<EventModel>.from(seedEvents ?? _generateInitialEvents());

  final List<EventModel> _events;

  static List<EventModel> _generateInitialEvents() {
    final now = DateTime.now();
    return [
      EventModel(
        id: 'event-1',
        title: 'Утренний брифинг',
        description: 'Ежедневная синхронизация с командой',
        startTime: DateTime(now.year, now.month, now.day, 9, 0),
        endTime: DateTime(now.year, now.month, now.day, 9, 30),
        createdAt: now,
        updatedAt: now,
      ),
      EventModel(
        id: 'event-2',
        title: 'Работа над проектом',
        description: 'Фокусное время на ключевые задачи',
        startTime: DateTime(now.year, now.month, now.day, 11, 0),
        endTime: DateTime(now.year, now.month, now.day, 13, 0),
        location: 'Офис',
        createdAt: now,
        updatedAt: now,
      ),
      EventModel(
        id: 'event-3',
        title: 'Встреча с клиентом',
        description: 'Обсуждение требований',
        startTime: DateTime(now.year, now.month, now.day + 1, 15, 0),
        endTime: DateTime(now.year, now.month, now.day + 1, 16, 0),
        location: 'Zoom',
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  Future<T> _simulateNetworkCall<T>(FutureOr<T> Function() action) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return action();
  }

  @override
  Future<List<EventModel>> getEvents({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _simulateNetworkCall(() {
      AppLogger.info('Remote: fetching events from $startDate to $endDate');
      return _events
          .where((event) =>
              !event.endTime.isBefore(startDate) &&
              !event.startTime.isAfter(endDate))
          .toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
    });
  }

  @override
  Future<EventModel> createEvent(EventModel event) {
    return _simulateNetworkCall(() {
      AppLogger.info('Remote: creating event ${event.title}');
      final generatedId = event.id.isEmpty
          ? 'event-${DateTime.now().microsecondsSinceEpoch}'
          : event.id;
      final newEvent = event.copyWith(
        id: generatedId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _events.add(newEvent);
      return newEvent;
    });
  }

  @override
  Future<EventModel> updateEvent(EventModel event) {
    return _simulateNetworkCall(() {
      AppLogger.info('Remote: updating event ${event.id}');
      final index = _events.indexWhere((item) => item.id == event.id);
      if (index == -1) {
        throw ServerFailure('Event not found');
      }
      final updatedEvent = event.copyWith(updatedAt: DateTime.now());
      _events[index] = updatedEvent;
      return updatedEvent;
    });
  }

  @override
  Future<void> deleteEvent(String eventId) {
    return _simulateNetworkCall(() {
      AppLogger.info('Remote: deleting event $eventId');
      _events.removeWhere((event) => event.id == eventId);
    });
  }

  @override
  Future<List<EventModel>> searchEvents(String query) {
    return _simulateNetworkCall(() {
      final lowerQuery = query.toLowerCase();
      AppLogger.info('Remote: searching events for "$lowerQuery"');
      return _events
          .where((event) =>
              event.title.toLowerCase().contains(lowerQuery) ||
              (event.description?.toLowerCase().contains(lowerQuery) ?? false))
          .toList();
    });
  }

  @override
  Future<List<DateTime>> findFreeSlots({
    required DateTime startDate,
    required DateTime endDate,
    required Duration duration,
  }) {
    return _simulateNetworkCall(() {
      AppLogger.info('Remote: finding free slots between $startDate and $endDate');
      final busyPeriods = _events
          .where((event) =>
              !event.endTime.isBefore(startDate) &&
              !event.startTime.isAfter(endDate))
          .map((event) => _BusyPeriod(event.startTime, event.endTime))
          .toList();

      busyPeriods.sort((a, b) => a.start.compareTo(b.start));

      final freeSlots = <DateTime>[];
      var currentTime = startDate;

      for (final busy in busyPeriods) {
        if (currentTime.add(duration).isBefore(busy.start)) {
          freeSlots.add(currentTime);
        }
        if (busy.end.isAfter(currentTime)) {
          currentTime = busy.end;
        }
      }

      if (currentTime.add(duration).isBefore(endDate)) {
        freeSlots.add(currentTime);
      }

      return freeSlots;
    });
  }
}

class _BusyPeriod {
  _BusyPeriod(this.start, this.end);

  final DateTime start;
  final DateTime end;
}
