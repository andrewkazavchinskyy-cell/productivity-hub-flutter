import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/calendar_repository.dart';

class FindFreeSlots {
  const FindFreeSlots(this.repository);

  final CalendarRepository repository;

  Future<Either<Failure, List<DateTime>>> call({
    required DateTime startDate,
    required DateTime endDate,
    required Duration duration,
  }) {
    return repository.findFreeSlots(
      startDate: startDate,
      endDate: endDate,
      duration: duration,
    );
  }
}
