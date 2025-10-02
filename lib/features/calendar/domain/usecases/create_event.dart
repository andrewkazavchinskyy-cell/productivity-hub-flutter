import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/event.dart';
import '../repositories/calendar_repository.dart';

class CreateCalendarEvent {
  const CreateCalendarEvent(this.repository);

  final CalendarRepository repository;

  Future<Either<Failure, Event>> call(Event event) {
    return repository.createEvent(event);
  }
}
