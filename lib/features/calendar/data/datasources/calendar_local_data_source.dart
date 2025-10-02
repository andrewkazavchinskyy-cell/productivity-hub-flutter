import 'package:hive/hive.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../models/event_model.dart';

abstract class CalendarLocalDataSource {
  Future<List<EventModel>> getCachedEvents();

  Future<void> cacheEvents(List<EventModel> events);

  Future<void> cacheEvent(EventModel event);

  Future<void> removeCachedEvent(String eventId);

  Future<void> clearCache();
}

class CalendarLocalDataSourceImpl implements CalendarLocalDataSource {
  static const String _eventsBoxName = 'calendar_events';
  static const String _eventsKey = 'events';

  late Box<Map> _box;

  Future<void> _initBox() async {
    if (!Hive.isBoxOpen(_eventsBoxName)) {
      _box = await Hive.openBox<Map>(_eventsBoxName);
    } else {
      _box = Hive.box<Map>(_eventsBoxName);
    }
  }

  @override
  Future<List<EventModel>> getCachedEvents() async {
    try {
      await _initBox();

      final cachedData = _box.get(_eventsKey);
      if (cachedData != null) {
        final List<dynamic> eventsJson = cachedData['events'] ?? [];
        final events = eventsJson
            .map((json) => EventModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();

        AppLogger.info('Retrieved ${events.length} cached events');
        return events;
      }

      AppLogger.info('No cached events found');
      return [];
    } catch (e) {
      AppLogger.error('Error retrieving cached events: $e');
      throw CacheFailure('Failed to retrieve cached events: $e');
    }
  }

  @override
  Future<void> cacheEvents(List<EventModel> events) async {
    try {
      await _initBox();

      final eventsJson = events.map((event) => event.toJson()).toList();
      await _box.put(_eventsKey, {
        'events': eventsJson,
        'cached_at': DateTime.now().toIso8601String(),
      });

      AppLogger.info('Cached ${events.length} events');
    } catch (e) {
      AppLogger.error('Error caching events: $e');
      throw CacheFailure('Failed to cache events: $e');
    }
  }

  @override
  Future<void> cacheEvent(EventModel event) async {
    try {
      await _initBox();

      final cachedEvents = await getCachedEvents();
      final existingIndex = cachedEvents.indexWhere((e) => e.id == event.id);

      if (existingIndex != -1) {
        cachedEvents[existingIndex] = event;
      } else {
        cachedEvents.add(event);
      }

      await cacheEvents(cachedEvents);
      AppLogger.info('Cached event: ${event.id}');
    } catch (e) {
      AppLogger.error('Error caching event: $e');
      throw CacheFailure('Failed to cache event: $e');
    }
  }

  @override
  Future<void> removeCachedEvent(String eventId) async {
    try {
      await _initBox();

      final cachedEvents = await getCachedEvents();
      cachedEvents.removeWhere((event) => event.id == eventId);

      await cacheEvents(cachedEvents);
      AppLogger.info('Removed cached event: $eventId');
    } catch (e) {
      AppLogger.error('Error removing cached event: $e');
      throw CacheFailure('Failed to remove cached event: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _initBox();
      await _box.clear();
      AppLogger.info('Cleared calendar cache');
    } catch (e) {
      AppLogger.error('Error clearing cache: $e');
      throw CacheFailure('Failed to clear cache: $e');
    }
  }
}
