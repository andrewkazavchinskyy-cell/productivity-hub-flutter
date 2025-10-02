import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/event.dart';
import '../repositories/calendar_repository.dart';

class GetEvents {
  const GetEvents(this.repository);

  final CalendarRepository repository;

  Future<Either<Failure, List<Event>>> call({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return repository.getEvents(startDate: startDate, endDate: endDate);
  }
}
