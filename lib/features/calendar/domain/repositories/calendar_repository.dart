import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/event.dart';

abstract class CalendarRepository {
  Future<Either<Failure, List<Event>>> getEvents({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<Either<Failure, Event>> createEvent(Event event);

  Future<Either<Failure, Event>> updateEvent(Event event);

  Future<Either<Failure, void>> deleteEvent(String eventId);

  Future<Either<Failure, List<Event>>> searchEvents(String query);

  Future<Either<Failure, List<DateTime>>> findFreeSlots({
    required DateTime startDate,
    required DateTime endDate,
    required Duration duration,
  });

  Future<Either<Failure, void>> syncWithGoogle();
}
