import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/event.dart';
import '../repositories/calendar_repository.dart';

class UpdateCalendarEvent {
  const UpdateCalendarEvent(this.repository);

  final CalendarRepository repository;

  Future<Either<Failure, Event>> call(Event event) {
    return repository.updateEvent(event);
  }
}
