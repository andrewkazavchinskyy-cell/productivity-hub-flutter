import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';

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
  final Dio _dio;

  CalendarRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<EventModel>> getEvents({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      AppLogger.info('Fetching events from Google Calendar API');
      
      final response = await _dio.get(
        '/calendar/v3/calendars/primary/events',
        queryParameters: {
          'timeMin': startDate.toIso8601String(),
          'timeMax': endDate.toIso8601String(),
          'singleEvents': true,
          'orderBy': 'startTime',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> items = response.data['items'] ?? [];
        final events = items
            .map((json) => EventModel.fromJson(json))
            .toList();
        
        AppLogger.info('Successfully fetched ${events.length} events');
        return events;
      } else {
        throw ServerFailure('Failed to fetch events: ${response.statusCode}');
      }
    } on DioException catch (e) {
      AppLogger.error('Dio error fetching events: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw AuthenticationFailure('Unauthorized access to Google Calendar');
      } else if (e.response?.statusCode == 403) {
        throw AuthenticationFailure('Access forbidden to Google Calendar');
      } else {
        throw ServerFailure('Network error: ${e.message}');
      }
    } catch (e) {
      AppLogger.error('Unexpected error fetching events: $e');
      throw ServerFailure('Unexpected error: $e');
    }
  }

  @override
  Future<EventModel> createEvent(EventModel event) async {
    try {
      AppLogger.info('Creating event: ${event.title}');
      
      final response = await _dio.post(
        '/calendar/v3/calendars/primary/events',
        data: event.toJson(),
      );

      if (response.statusCode == 200) {
        final createdEvent = EventModel.fromJson(response.data);
        AppLogger.info('Successfully created event: ${createdEvent.id}');
        return createdEvent;
      } else {
        throw ServerFailure('Failed to create event: ${response.statusCode}');
      }
    } on DioException catch (e) {
      AppLogger.error('Dio error creating event: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw AuthenticationFailure('Unauthorized access to Google Calendar');
      } else {
        throw ServerFailure('Network error: ${e.message}');
      }
    } catch (e) {
      AppLogger.error('Unexpected error creating event: $e');
      throw ServerFailure('Unexpected error: $e');
    }
  }

  @override
  Future<EventModel> updateEvent(EventModel event) async {
    try {
      AppLogger.info('Updating event: ${event.id}');
      
      final response = await _dio.put(
        '/calendar/v3/calendars/primary/events/${event.id}',
        data: event.toJson(),
      );

      if (response.statusCode == 200) {
        final updatedEvent = EventModel.fromJson(response.data);
        AppLogger.info('Successfully updated event: ${updatedEvent.id}');
        return updatedEvent;
      } else {
        throw ServerFailure('Failed to update event: ${response.statusCode}');
      }
    } on DioException catch (e) {
      AppLogger.error('Dio error updating event: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw AuthenticationFailure('Unauthorized access to Google Calendar');
      } else {
        throw ServerFailure('Network error: ${e.message}');
      }
    } catch (e) {
      AppLogger.error('Unexpected error updating event: $e');
      throw ServerFailure('Unexpected error: $e');
    }
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    try {
      AppLogger.info('Deleting event: $eventId');
      
      final response = await _dio.delete(
        '/calendar/v3/calendars/primary/events/$eventId',
      );

      if (response.statusCode == 204) {
        AppLogger.info('Successfully deleted event: $eventId');
      } else {
        throw ServerFailure('Failed to delete event: ${response.statusCode}');
      }
    } on DioException catch (e) {
      AppLogger.error('Dio error deleting event: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw AuthenticationFailure('Unauthorized access to Google Calendar');
      } else {
        throw ServerFailure('Network error: ${e.message}');
      }
    } catch (e) {
      AppLogger.error('Unexpected error deleting event: $e');
      throw ServerFailure('Unexpected error: $e');
    }
  }

  @override
  Future<List<EventModel>> searchEvents(String query) async {
    try {
      AppLogger.info('Searching events with query: $query');
      
      final response = await _dio.get(
        '/calendar/v3/calendars/primary/events',
        queryParameters: {
          'q': query,
          'singleEvents': true,
          'orderBy': 'startTime',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> items = response.data['items'] ?? [];
        final events = items
            .map((json) => EventModel.fromJson(json))
            .toList();
        
        AppLogger.info('Found ${events.length} events matching query');
        return events;
      } else {
        throw ServerFailure('Failed to search events: ${response.statusCode}');
      }
    } on DioException catch (e) {
      AppLogger.error('Dio error searching events: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw AuthenticationFailure('Unauthorized access to Google Calendar');
      } else {
        throw ServerFailure('Network error: ${e.message}');
      }
    } catch (e) {
      AppLogger.error('Unexpected error searching events: $e');
      throw ServerFailure('Unexpected error: $e');
    }
  }

  @override
  Future<List<DateTime>> findFreeSlots({
    required DateTime startDate,
    required DateTime endDate,
    required Duration duration,
  }) async {
    try {
      AppLogger.info('Finding free slots from $startDate to $endDate');
      
      // Get busy times from Google Calendar
      final response = await _dio.post(
        '/calendar/v3/freeBusy',
        data: {
          'timeMin': startDate.toIso8601String(),
          'timeMax': endDate.toIso8601String(),
          'items': [
            {'id': 'primary'}
          ],
        },
      );

      if (response.statusCode == 200) {
        final busyTimes = response.data['calendars']['primary']['busy'] ?? [];
        final freeSlots = _calculateFreeSlots(
          startDate: startDate,
          endDate: endDate,
          busyTimes: busyTimes,
          duration: duration,
        );
        
        AppLogger.info('Found ${freeSlots.length} free slots');
        return freeSlots;
      } else {
        throw ServerFailure('Failed to find free slots: ${response.statusCode}');
      }
    } on DioException catch (e) {
      AppLogger.error('Dio error finding free slots: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw AuthenticationFailure('Unauthorized access to Google Calendar');
      } else {
        throw ServerFailure('Network error: ${e.message}');
      }
    } catch (e) {
      AppLogger.error('Unexpected error finding free slots: $e');
      throw ServerFailure('Unexpected error: $e');
    }
  }

  List<DateTime> _calculateFreeSlots({
    required DateTime startDate,
    required DateTime endDate,
    required List<dynamic> busyTimes,
    required Duration duration,
  }) {
    final freeSlots = <DateTime>[];
    final busyPeriods = busyTimes.map((busy) => {
      'start': DateTime.parse(busy['start']),
      'end': DateTime.parse(busy['end']),
    }).toList();

    // Sort busy periods by start time
    busyPeriods.sort((a, b) => a['start'].compareTo(b['start']));

    DateTime currentTime = startDate;
    
    for (final busyPeriod in busyPeriods) {
      final busyStart = busyPeriod['start'] as DateTime;
      final busyEnd = busyPeriod['end'] as DateTime;
      
      // Check if there's a free slot before this busy period
      if (currentTime.add(duration).isBefore(busyStart)) {
        freeSlots.add(currentTime);
      }
      
      // Move current time to after this busy period
      currentTime = busyEnd.isAfter(currentTime) ? busyEnd : currentTime;
    }
    
    // Check if there's a free slot at the end
    if (currentTime.add(duration).isBefore(endDate)) {
      freeSlots.add(currentTime);
    }
    
    return freeSlots;
  }
}