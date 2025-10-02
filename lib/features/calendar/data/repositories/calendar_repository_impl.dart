import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../datasources/calendar_local_data_source.dart';
import '../datasources/calendar_remote_data_source.dart';
import '../models/event_model.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  CalendarRepositoryImpl({
    required CalendarRemoteDataSource remoteDataSource,
    required CalendarLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final CalendarRemoteDataSource _remoteDataSource;
  final CalendarLocalDataSource _localDataSource;

  Failure _mapError(Object error) {
    if (error is Failure) {
      return error;
    }
    return ServerFailure(error.toString(), cause: error);
  }

  @override
  Future<Either<Failure, List<Event>>> getEvents({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      AppLogger.info('Repository: requesting events');

      try {
        final remoteEvents = await _remoteDataSource.getEvents(
          startDate: startDate,
          endDate: endDate,
        );

        await _localDataSource.cacheEvents(remoteEvents);

        final events = remoteEvents.map((model) => model.toEntity()).toList();
        AppLogger.info('Repository: loaded ${events.length} events from remote');
        return Right(events);
      } catch (error) {
        AppLogger.warning('Repository: remote failed, loading from cache: $error');

        final cachedEvents = await _localDataSource.getCachedEvents();
        if (cachedEvents.isEmpty) {
          return Left(CacheFailure('Нет доступных событий в офлайне', cause: error));
        }

        final events = cachedEvents.map((model) => model.toEntity()).toList();
        AppLogger.info('Repository: loaded ${events.length} events from cache');
        return Right(events);
      }
    } catch (error) {
      final failure = _mapError(error);
      AppLogger.error('Repository: unexpected error getting events', error);
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, Event>> createEvent(Event event) async {
    try {
      AppLogger.info('Repository: creating event ${event.title}');
      final eventModel = EventModel.fromEntity(event);

      try {
        final createdEventModel = await _remoteDataSource.createEvent(eventModel);
        await _localDataSource.cacheEvent(createdEventModel);
        return Right(createdEventModel.toEntity());
      } catch (error) {
        AppLogger.warning('Repository: remote create failed, caching locally: $error');
        await _localDataSource.cacheEvent(eventModel);
        return Right(event);
      }
    } catch (error) {
      final failure = _mapError(error);
      AppLogger.error('Repository: error creating event', error);
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, Event>> updateEvent(Event event) async {
    try {
      AppLogger.info('Repository: updating event ${event.id}');
      final eventModel = EventModel.fromEntity(event);

      try {
        final updatedEventModel = await _remoteDataSource.updateEvent(eventModel);
        await _localDataSource.cacheEvent(updatedEventModel);
        return Right(updatedEventModel.toEntity());
      } catch (error) {
        AppLogger.warning('Repository: remote update failed, caching locally: $error');
        await _localDataSource.cacheEvent(eventModel);
        return Right(event);
      }
    } catch (error) {
      final failure = _mapError(error);
      AppLogger.error('Repository: error updating event', error);
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, void>> deleteEvent(String eventId) async {
    try {
      AppLogger.info('Repository: deleting event $eventId');

      try {
        await _remoteDataSource.deleteEvent(eventId);
        await _localDataSource.removeCachedEvent(eventId);
        return const Right(null);
      } catch (error) {
        AppLogger.warning('Repository: remote delete failed, removing from cache: $error');
        await _localDataSource.removeCachedEvent(eventId);
        return const Right(null);
      }
    } catch (error) {
      final failure = _mapError(error);
      AppLogger.error('Repository: error deleting event', error);
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, List<Event>>> searchEvents(String query) async {
    try {
      AppLogger.info('Repository: searching events by "$query"');

      try {
        final remoteEvents = await _remoteDataSource.searchEvents(query);
        return Right(remoteEvents.map((model) => model.toEntity()).toList());
      } catch (error) {
        AppLogger.warning('Repository: remote search failed, searching cache: $error');
        final cachedEvents = await _localDataSource.getCachedEvents();
        final filteredEvents = cachedEvents.where((event) {
          final lowerQuery = query.toLowerCase();
          return event.title.toLowerCase().contains(lowerQuery) ||
              (event.description?.toLowerCase().contains(lowerQuery) ?? false);
        }).toList();
        return Right(filteredEvents.map((model) => model.toEntity()).toList());
      }
    } catch (error) {
      final failure = _mapError(error);
      AppLogger.error('Repository: error searching events', error);
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, List<DateTime>>> findFreeSlots({
    required DateTime startDate,
    required DateTime endDate,
    required Duration duration,
  }) async {
    try {
      final freeSlots = await _remoteDataSource.findFreeSlots(
        startDate: startDate,
        endDate: endDate,
        duration: duration,
      );
      return Right(freeSlots);
    } catch (error) {
      final failure = _mapError(error);
      AppLogger.error('Repository: error finding free slots', error);
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, void>> syncWithGoogle() async {
    try {
      AppLogger.info('Repository: syncing with remote');
      await _localDataSource.clearCache();
      final now = DateTime.now();
      final events = await _remoteDataSource.getEvents(
        startDate: now.subtract(const Duration(days: 30)),
        endDate: now.add(const Duration(days: 30)),
      );
      await _localDataSource.cacheEvents(events);
      return const Right(null);
    } catch (error) {
      final failure = _mapError(error);
      AppLogger.error('Repository: error syncing with remote', error);
      return Left(failure);
    }
  }
}
