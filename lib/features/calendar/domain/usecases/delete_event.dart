import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/calendar_repository.dart';

class DeleteCalendarEvent {
  const DeleteCalendarEvent(this.repository);

  final CalendarRepository repository;

  Future<Either<Failure, void>> call(String eventId) {
    return repository.deleteEvent(eventId);
  }
}
