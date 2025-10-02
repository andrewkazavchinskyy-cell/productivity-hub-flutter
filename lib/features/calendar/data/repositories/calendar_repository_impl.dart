import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../datasources/calendar_local_data_source.dart';
import '../datasources/calendar_remote_data_source.dart';
import '../models/event_model.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  final CalendarRemoteDataSource _remoteDataSource;
  final CalendarLocalDataSource _localDataSource;

  CalendarRepositoryImpl({
    required CalendarRemoteDataSource remoteDataSource,
    required CalendarLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  @override
  Future<Either<Failure, List<Event>>> getEvents({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      AppLogger.info('Getting events from repository');
      
      // Try to get from remote first
      try {
        final remoteEvents = await _remoteDataSource.getEvents(
          startDate: startDate,
          endDate: endDate,
        );
        
        // Cache the events
        await _localDataSource.cacheEvents(remoteEvents);
        
        final events = remoteEvents.map((model) => model.toEntity()).toList();
        AppLogger.info('Successfully retrieved ${events.length} events from remote');
        return Right(events);
      } catch (e) {
        AppLogger.warning('Failed to get events from remote, trying local cache: $e');
        
        // Fallback to local cache
        final cachedEvents = await _localDataSource.getCachedEvents();
        final events = cachedEvents.map((model) => model.toEntity()).toList();
        
        if (events.isNotEmpty) {
          AppLogger.info('Retrieved ${events.length} events from cache');
          return Right(events);
        } else {
          AppLogger.error('No cached events available');
          return Left(CacheFailure('No events available offline'));
        }
      }
    } catch (e) {
      AppLogger.error('Unexpected error getting events: $e');
      return Left(ServerFailure('Failed to get events: $e'));
    }
  }

  @override
  Future<Either<Failure, Event>> createEvent(Event event) async {
    try {
      AppLogger.info('Creating event: ${event.title}');
      
      final eventModel = EventModel.fromEntity(event);
      
      try {
        // Try to create on remote
        final createdEventModel = await _remoteDataSource.createEvent(eventModel);
        
        // Cache the created event
        await _localDataSource.cacheEvent(createdEventModel);
        
        final createdEvent = createdEventModel.toEntity();
        AppLogger.info('Successfully created event: ${createdEvent.id}');
        return Right(createdEvent);
      } catch (e) {
        AppLogger.warning('Failed to create event on remote, caching locally: $e');
        
        // Cache locally for later sync
        await _localDataSource.cacheEvent(eventModel);
        
        AppLogger.info('Event cached locally for later sync');
        return Right(event);
      }
    } catch (e) {
      AppLogger.error('Unexpected error creating event: $e');
      return Left(ServerFailure('Failed to create event: $e'));
    }
  }

  @override
  Future<Either<Failure, Event>> updateEvent(Event event) async {
    try {
      AppLogger.info('Updating event: ${event.id}');
      
      final eventModel = EventModel.fromEntity(event);
      
      try {
        // Try to update on remote
        final updatedEventModel = await _remoteDataSource.updateEvent(eventModel);
        
        // Update cache
        await _localDataSource.cacheEvent(updatedEventModel);
        
        final updatedEvent = updatedEventModel.toEntity();
        AppLogger.info('Successfully updated event: ${updatedEvent.id}');
        return Right(updatedEvent);
      } catch (e) {
        AppLogger.warning('Failed to update event on remote, updating cache: $e');
        
        // Update cache locally
        await _localDataSource.cacheEvent(eventModel);
        
        AppLogger.info('Event updated in cache for later sync');
        return Right(event);
      }
    } catch (e) {
      AppLogger.error('Unexpected error updating event: $e');
      return Left(ServerFailure('Failed to update event: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEvent(String eventId) async {
    try {
      AppLogger.info('Deleting event: $eventId');
      
      try {
        // Try to delete on remote
        await _remoteDataSource.deleteEvent(eventId);
        
        // Remove from cache
        await _localDataSource.removeCachedEvent(eventId);
        
        AppLogger.info('Successfully deleted event: $eventId');
        return const Right(null);
      } catch (e) {
        AppLogger.warning('Failed to delete event on remote, removing from cache: $e');
        
        // Remove from cache locally
        await _localDataSource.removeCachedEvent(eventId);
        
        AppLogger.info('Event removed from cache for later sync');
        return const Right(null);
      }
    } catch (e) {
      AppLogger.error('Unexpected error deleting event: $e');
      return Left(ServerFailure('Failed to delete event: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Event>>> searchEvents(String query) async {
    try {
      AppLogger.info('Searching events with query: $query');
      
      try {
        // Try to search on remote
        final remoteEvents = await _remoteDataSource.searchEvents(query);
        final events = remoteEvents.map((model) => model.toEntity()).toList();
        
        AppLogger.info('Found ${events.length} events matching query');
        return Right(events);
      } catch (e) {
        AppLogger.warning('Failed to search events on remote, searching cache: $e');
        
        // Fallback to local search
        final cachedEvents = await _localDataSource.getCachedEvents();
        final filteredEvents = cachedEvents.where((event) {
          return event.title.toLowerCase().contains(query.toLowerCase()) ||
                 (event.description?.toLowerCase().contains(query.toLowerCase()) ?? false);
        }).toList();
        
        final events = filteredEvents.map((model) => model.toEntity()).toList();
        AppLogger.info('Found ${events.length} events in cache matching query');
        return Right(events);
      }
    } catch (e) {
      AppLogger.error('Unexpected error searching events: $e');
      return Left(ServerFailure('Failed to search events: $e'));
    }
  }

  @override
  Future<Either<Failure, List<DateTime>>> findFreeSlots({
    required DateTime startDate,
    required DateTime endDate,
    required Duration duration,
  }) async {
    try {
      AppLogger.info('Finding free slots from $startDate to $endDate');
      
      final freeSlots = await _remoteDataSource.findFreeSlots(
        startDate: startDate,
        endDate: endDate,
        duration: duration,
      );
      
      AppLogger.info('Found ${freeSlots.length} free slots');
      return Right(freeSlots);
    } catch (e) {
      AppLogger.error('Error finding free slots: $e');
      return Left(ServerFailure('Failed to find free slots: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> syncWithGoogle() async {
    try {
      AppLogger.info('Syncing with Google Calendar');
      
      // Clear local cache
      await _localDataSource.clearCache();
      
      // Fetch fresh data from remote
      final now = DateTime.now();
      final events = await _remoteDataSource.getEvents(
        startDate: now.subtract(const Duration(days: 30)),
        endDate: now.add(const Duration(days: 30)),
      );
      
      // Cache the fresh data
      await _localDataSource.cacheEvents(events);
      
      AppLogger.info('Successfully synced ${events.length} events with Google Calendar');
      return const Right(null);
    } catch (e) {
      AppLogger.error('Error syncing with Google Calendar: $e');
      return Left(ServerFailure('Failed to sync with Google Calendar: $e'));
    }
  }
}